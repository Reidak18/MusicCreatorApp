//
//  AudioMixer.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 03.11.2023.
//

import AVFoundation
import UIKit

class AudioMixer {
    private let sampleRate = 44100
    private let channelsCount = 2
    private let bufferSize: UInt32 = 8192

    private var audioEngine: AVAudioEngine = AVAudioEngine()
    private var audioMixer: AVAudioMixerNode = AVAudioMixerNode()

    private let audioUrl: URL
    private let audioUrlMeta: URL
    private let recordSettings: Dictionary<String, Any>

    init() {
        let filename = "\(StringConstants.audioMixRecordingName.rawValue)\(StringConstants.createdFilesExtension.rawValue)"
        audioUrl = FileManager.default.getDocumentsPath(filename: filename)
        if FileManager.default.fileExists(atPath: audioUrl.path) {
            try! FileManager.default.removeItem(at: audioUrl)
        }
        let filenameWithMeta = "\(StringConstants.audioMixRecordingNameChangedMeta.rawValue)\(StringConstants.createdFilesExtension.rawValue)"
        audioUrlMeta = FileManager.default.getDocumentsPath(filename: filenameWithMeta)
        if FileManager.default.fileExists(atPath: audioUrlMeta.path) {
            try! FileManager.default.removeItem(at: audioUrlMeta)
        }

        recordSettings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: channelsCount,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
    }

    func playMixedAudio(samples: [AudioSample]) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let engine = self?.audioEngine,
                  let mixer = self?.audioMixer
            else { return }
            engine.attach(mixer)
            engine.connect(mixer, to: engine.outputNode, format: nil)
            do {
                try engine.start()
            } catch(let error) {
                print(error)
                return
            }

            for sample in samples {
                // создаем плеер и подключаем к остальным
                let audioPlayer = AVAudioPlayerNode()
                engine.attach(audioPlayer)
                engine.connect(audioPlayer, to: mixer, format: nil)

                // получаем аудиофайл
                guard let file = try? AVAudioFile(forReading: sample.audioUrl)
                else {
                    print("Can't create audio file from \(sample.audioUrl.absoluteString)")
                    return
                }

                // планируем время начала проигрывания
                let startTime = AVAudioFramePosition(0)
                audioPlayer.volume = sample.volume
                audioPlayer.scheduleFile(file,
                                         at: AVAudioTime(sampleTime: startTime,
                                                         atRate: file.processingFormat.sampleRate),
                                         completionHandler: {
                    if !sample.isMicrophone {
                        self?.scheduleNext(startTime: startTime,
                                           delay: 1 / Double(sample.frequency),
                                           audioFile: file,
                                           audioPlayer: audioPlayer) }
                })
                audioPlayer.play()
            }
        }
    }

    func finishPlayingMixedAudio() {
        audioEngine.stop()
    }

    func recordMuxedAudio(samples: [AudioSample]) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.playMixedAudio(samples: samples)

            guard let url = self?.audioUrl,
                  let settings = self?.recordSettings,
                  let bufferSize = self?.bufferSize
            else { return }

            var audioFile: AVAudioFile
            do {
                audioFile = try AVAudioFile(forWriting: url,
                                            settings: settings,
                                            commonFormat: .pcmFormatFloat32,
                                            interleaved: false)
            }
            catch {
                print ("Failed to open audio file for writing: \(error.localizedDescription)")
                return
            }

            self?.audioMixer.installTap(onBus: 0, bufferSize: bufferSize, format: nil, block: { pcmBuffer, when in
                do {
                    try audioFile.write(from: pcmBuffer)
                }
                catch {
                    print("Failed to write Audio File: \(error.localizedDescription)")
                }
            })
        }
    }

    func finishRecordingMixedAudio() -> URL {
        audioEngine.stop()
        audioMixer.removeTap(onBus: 0)

        setMeta(filePath: audioUrl, exportPath: audioUrlMeta, artistName: "ARTIST", coverImageName: "Wind")

        return audioUrlMeta
    }

    private func setMeta(filePath: URL, exportPath: URL, artistName: String, coverImageName: String) {
        let asset = AVAsset(url: filePath)

        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            print("Failed to create AVAssetExportSession with \(filePath)")
            return
        }

        let artistMetadata = AVMutableMetadataItem()
        artistMetadata.key = AVMetadataKey.commonKeyArtist as NSString
        artistMetadata.keySpace = .common
        artistMetadata.value = artistName as NSString

        let artworkMetadata = AVMutableMetadataItem()
        artworkMetadata.key = AVMetadataKey.commonKeyArtwork as NSString
        artworkMetadata.keySpace = .common

        if let image = UIImage(named: coverImageName),
           let imageData = image.pngData() {
            artworkMetadata.value = imageData as NSData
        } else {
            print("Can't load image named \(coverImageName)")
        }

        exporter.outputURL = exportPath
        exporter.outputFileType = .m4a
        exporter.metadata = [artistMetadata, artworkMetadata]

        exporter.exportAsynchronously {
            switch exporter.status {
            case .completed:
                print("File saved successfully")
            case .failed:
                print("Error when saving file: \(exporter.error ?? NSError())")
            case .cancelled:
                print("Saving cancelled")
            default:
                break
            }
        }
    }

    // считаем время следующего запуска
    private func scheduleNext(startTime: AVAudioFramePosition,
                              delay: TimeInterval,
                              audioFile: AVAudioFile,
                              audioPlayer: AVAudioPlayerNode) {
        let sampleRate = audioFile.processingFormat.sampleRate
        // время прошлого запуска + длина трека + задержка (переводим секунды в кадры)
        let nextTime = startTime + audioFile.length + Int64(delay * sampleRate)
        // планируем следующий запуск
        audioPlayer.scheduleFile(audioFile,
                                 at: AVAudioTime(sampleTime: nextTime,
                                                 atRate: sampleRate),
                                 completionHandler: { [weak self] in self?.scheduleNext(startTime: nextTime,
                                                                                        delay: delay,
                                                                                        audioFile: audioFile,
                                                                                        audioPlayer: audioPlayer) })
    }
}
