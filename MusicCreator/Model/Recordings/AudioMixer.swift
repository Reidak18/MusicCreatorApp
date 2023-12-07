//
//  AudioMixer.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 03.11.2023.
//

import AVFoundation

class AudioMixer {
    private let sampleRate = 44100
    private let channelsCount = 2
    private let bufferSize: UInt32 = 8192

    private var audioEngine: AVAudioEngine = AVAudioEngine()
    private var audioMixer: AVAudioMixerNode = AVAudioMixerNode()

    private let audioUrl: URL
    private let recordSettings: Dictionary<String, Any>

    init() {
        let filename = "\(StringConstants.audioMixRecordingName.rawValue)\(StringConstants.createdFilesExtension.rawValue)"
        audioUrl = FileManager.default.getDocumentsPath(filename: filename)

        recordSettings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: channelsCount,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
    }

    func playMixedAudio(samples: [AudioSample], update: (([Float]) -> Void)?) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self
            else { return }

            audioEngine.attach(audioMixer)
            audioEngine.connect(audioMixer, to: audioEngine.outputNode, format: nil)
            do {
                try audioEngine.start()
            } catch(let error) {
                print(error)
                return
            }

            for sample in samples {
                // создаем плеер и подключаем к остальным
                let audioPlayer = AVAudioPlayerNode()
                audioEngine.attach(audioPlayer)
                audioEngine.connect(audioPlayer, to: audioMixer, format: nil)

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
                        self.scheduleNext(startTime: startTime,
                                     delay: 1 / Double(sample.frequency),
                                     audioFile: file,
                                     audioPlayer: audioPlayer) }
                })
                audioPlayer.play()
            }

            if update != nil {
                audioMixer.installTap(onBus: 0, bufferSize: bufferSize, format: nil, block: { pcmBuffer, when in
                    self.visualizationTap(pcmBuffer: pcmBuffer, update: update)
                })
            }
        }
    }

    func finishPlayingMixedAudio(stop: (() -> Void)?) {
        audioEngine.stop()
        audioMixer.removeTap(onBus: 0)
        stop?()
    }

    func recordMuxedAudio(samples: [AudioSample], update: (([Float]) -> Void)?) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self
            else { return }

            playMixedAudio(samples: samples, update: nil)

            var audioFile: AVAudioFile
            do {
                audioFile = try AVAudioFile(forWriting: audioUrl,
                                            settings: recordSettings,
                                            commonFormat: .pcmFormatFloat32,
                                            interleaved: false)
            }
            catch {
                print ("Failed to open audio file for writing: \(error.localizedDescription)")
                return
            }

            audioMixer.installTap(onBus: 0, bufferSize: bufferSize, format: nil, block: { pcmBuffer, when in
                self.visualizationTap(pcmBuffer: pcmBuffer, update: update)
                self.saveTap(pcmBuffer: pcmBuffer, audioFile: audioFile)
            })
        }
    }

    func finishRecordingMixedAudio(stop: (() -> Void)?) -> URL {
        audioEngine.stop()
        audioMixer.removeTap(onBus: 0)
        stop?()
        return audioUrl
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

    private func visualizationTap(pcmBuffer: AVAudioPCMBuffer, update: (([Float]) -> Void)?) {
        if let channelData = pcmBuffer.floatChannelData?[Int(0)] {
            let arr = Array(UnsafeBufferPointer(start: channelData, count: Int(self.bufferSize)))
            let framesCount = 75
            let frameSize = Int(self.bufferSize) / framesCount
            var result = [Float]()
            for i in 0..<framesCount {
                var meanValue: Float = 0
                for j in 0..<frameSize {
                    meanValue += abs(arr[i * frameSize + j])
                }
                result.append(meanValue)
            }
            update?(result.normalized())
        }
    }

    private func saveTap(pcmBuffer: AVAudioPCMBuffer, audioFile: AVAudioFile) {
        do {
            try audioFile.write(from: pcmBuffer)
        }
        catch {
            print("Failed to write Audio File: \(error.localizedDescription)")
        }
    }
}
