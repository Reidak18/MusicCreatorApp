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

    func playMixedAudio(samples: [AudioSample]) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.audioEngine.attach(self.audioMixer)
            self.audioEngine.connect(self.audioMixer, to: self.audioEngine.outputNode, format: nil)
            do {
                try self.audioEngine.start()
            } catch(let error) {
                print(error)
                return
            }

            for sample in samples {
                // создаем плеер и подключаем к остальным
                let audioPlayer = AVAudioPlayerNode()
                self.audioEngine.attach(audioPlayer)
                self.audioEngine.connect(audioPlayer, to: self.audioMixer, format: nil)

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
        }
    }

    func finishPlayingMixedAudio() {
        audioEngine.stop()
    }

    func recordMuxedAudio(samples: [AudioSample]) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.playMixedAudio(samples: samples)

            var audioFile: AVAudioFile
            do {
                audioFile = try AVAudioFile(forWriting: self.audioUrl,
                                            settings: self.recordSettings,
                                            commonFormat: .pcmFormatFloat32,
                                            interleaved: false)
            }
            catch {
                print ("Failed to open audio file for writing: \(error.localizedDescription)")
                return
            }

            self.audioMixer.installTap(onBus: 0, bufferSize: self.bufferSize, format: nil, block: { pcmBuffer, when in
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
        return audioUrl
    }

    private func createRecordUrl(filename: String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent(filename)
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
