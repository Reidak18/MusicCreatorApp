//
//  AudioRecorder.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 05.11.2023.
//

import AVFoundation

enum RecordingType {
    case microphoneRecording
    case mixAudioPlaying
    case mixAudioRecording
}

protocol AudioRecorderProtocol {
    func hasMicrophonePermission() -> Bool
    func requestMicrophonePermission()
    func isRecording(_ type: RecordingType) -> Bool
    func startMicrophoneRecording(errorHandler: @escaping(_ error: RecordMicroError) -> ())
    func finishMicrophoneRecording() -> URL?
    func startPlayingMixedAudio(samples: [AudioSample])
    func finishPlayingMixedAudio()
    func startRecordingMuxedAudio(samples: [AudioSample])
    func finishRecordingMixedAudio() -> URL
    var players: Dictionary<String, AVAudioPlayerNode> { get }
}

class AudioRecorder: AudioRecorderProtocol {
    private let microRecording = MicrophoneRecording()
    private let audioMixer = AudioMixer()
    private var isWorking = Dictionary<RecordingType, Bool>()

    var playersIsPlaying: Dictionary<String, AVAudioPlayerNode> {
        get {
            return audioMixer.players
        }
    }

    var players: Dictionary<String, AVAudioPlayerNode> {
        get {
            return audioMixer.players
        }
    }

    func hasMicrophonePermission() -> Bool {
        return microRecording.hasPermission()
    }

    func requestMicrophonePermission() {
        microRecording.requestPermission()
    }

    func startMicrophoneRecording(errorHandler: @escaping (RecordMicroError) -> ()) {
        isWorking[.microphoneRecording] = true
        switchCategory(category: .playAndRecord)
        microRecording.startRecording(errorHandler: { [weak self] error in
            self?.isWorking[.microphoneRecording] = false
            errorHandler(error)
        })
    }

    func isRecording(_ type: RecordingType) -> Bool {
        return isWorking[type, default: false]
    }

    func finishMicrophoneRecording() -> URL? {
        let url = microRecording.finishRecording()
        switchCategory(category: .playback)
        isWorking[.microphoneRecording] = false
        return url
    }

    func startPlayingMixedAudio(samples: [AudioSample]) {
        isWorking[.mixAudioPlaying] = true
        audioMixer.playMixedAudio(samples: samples)
    }

    func finishPlayingMixedAudio() {
        isWorking[.mixAudioPlaying] = false
        audioMixer.finishPlayingMixedAudio()
    }

    func startRecordingMuxedAudio(samples: [AudioSample]) {
        isWorking[.mixAudioRecording] = true
        switchCategory(category: .playAndRecord)
        audioMixer.recordMuxedAudio(samples: samples)
    }

    func finishRecordingMixedAudio() -> URL {
        let url = audioMixer.finishRecordingMixedAudio()
        switchCategory(category: .playback)
        isWorking[.mixAudioRecording] = false
        return url
    }

    private func switchCategory(category: AVAudioSession.Category) {
        do {
            let options: AVAudioSession.CategoryOptions = category == .playAndRecord ? [.defaultToSpeaker] : []
            try AVAudioSession.sharedInstance().setCategory(category, options: options)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch(let error) {
            print(error)
        }
    }
}
