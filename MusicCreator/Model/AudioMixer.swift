//
//  AudioMixer.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 03.11.2023.
//

import AVFoundation

protocol AudioMixerProtocol {
    func play(samples: [AudioSample])
    func stopPlay()
    func playAndRecord(samples: [AudioSample])
    func stopRecord()
}

class AudioMixer: AudioMixerProtocol {
    private var audioEngine: AVAudioEngine = AVAudioEngine()
    private var mixer: AVAudioMixerNode = AVAudioMixerNode()

    func play(samples: [AudioSample]) {
        DispatchQueue.global(qos: .background).async {
            self.audioEngine.attach(self.mixer)
            self.audioEngine.connect(self.mixer, to: self.audioEngine.outputNode, format: nil)
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
                self.audioEngine.connect(audioPlayer, to: self.mixer, format: nil)

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

    func stopPlay() {
        audioEngine.stop()
    }

    func playAndRecord(samples: [AudioSample]) {
        
    }

    func stopRecord() {
        
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
