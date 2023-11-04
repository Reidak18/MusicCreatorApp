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
    func playAndRecord(samples: [AudioSample], filename: String)
    func stopRecord()
}

class AudioMixer: AudioMixerProtocol {
    private let recordingSession = AVAudioSession.sharedInstance()
    private var audioEngine: AVAudioEngine = AVAudioEngine()
    private var audioMixer: AVAudioMixerNode = AVAudioMixerNode()

    private let recordSettings: Dictionary<String, Any>

    init() {
        recordSettings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
    }

    func play(samples: [AudioSample]) {
        DispatchQueue.global(qos: .background).async {
            try! AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            try! AVAudioSession.sharedInstance().setActive(true)

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

    func stopPlay() {
        audioEngine.stop()
    }

    func playAndRecord(samples: [AudioSample], filename: String) {
        play(samples: samples)

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = documentsDirectory.appendingPathComponent(filename)

        var audioFile: AVAudioFile
        do {
            audioFile = try AVAudioFile(forWriting: audioURL, settings: recordSettings, commonFormat: .pcmFormatFloat32, interleaved: false)
        }
        catch {
            print ("Failed to open audio file for writing: \(error.localizedDescription)")
            return
        }

        self.audioMixer.installTap(onBus: 0, bufferSize: 8192, format: nil, block: { pcmBuffer, when in
            do {
                try audioFile.write(from: pcmBuffer)
            }
            catch {
                print("Failed to write Audio File: \(error.localizedDescription)")
            }
        })
    }

    func stopRecord() {
        stopPlay()
        self.audioMixer.removeTap(onBus: 0)
        switchCategory(category: .playback)
    }

    private func switchCategory(category: AVAudioSession.Category) {
        do {
            try recordingSession.setActive(false)
            try recordingSession.setCategory(category)
            try recordingSession.setActive(true)
        } catch(let error) {
            print(error)
        }
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
