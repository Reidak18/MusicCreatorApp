//
//  MicroRecording.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 03.11.2023.
//

import AVFoundation
import UIKit

enum RecordMicroError: Error {
    case alreadyStarted(String)
    case errorInProgress(String)
    case fileNotCreated(String)
}

enum RequestMicroPermissionResult {
    case notRequested
    case allow
    case deny
}

protocol MicrophoneRecordingProtocol {
    func hasPermission() -> Bool
    func requestPermission()
    func startRecording(errorHandler: @escaping(_ error: RecordMicroError) -> ())
    func isRecording() -> Bool
    func finishRecording() -> AudioSample?
}

class MicrophoneRecording: NSObject, MicrophoneRecordingProtocol {
    private let recordingSession = AVAudioSession.sharedInstance()
    private var recorder: AVAudioRecorder? = nil
    private var recordIndex: Int = 0
    private var currentName: String { return "microphoneRecord_\(recordIndex).m4a" }
    private var errorHandler: ((_ error: RecordMicroError) -> ())?
    private let settings: Dictionary<String, Int> = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

    func hasPermission() -> Bool {
        return recordingSession.recordPermission == .granted
    }

    func requestPermission() {
        switch recordingSession.recordPermission {
        case .undetermined:
            recordingSession.requestRecordPermission({ _ in })
        case .granted:
            return
        case .denied:
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString)
            else { return }
            UIApplication.shared.open(settingsUrl)
        @unknown default:
            break
        }
    }

    func startRecording(errorHandler: @escaping(_ error: RecordMicroError) -> ()) {
        switchCategory(category: .playAndRecord)
        self.errorHandler = errorHandler

        guard recorder == nil
        else {
            errorHandler(.alreadyStarted("Call finish recording before"))
            return
        }

        let audioURL = createRecordUrl()

        do {
            let unwRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            unwRecorder.delegate = self
            unwRecorder.record()

            recorder = unwRecorder
        } catch (let error) {
            errorHandler(.errorInProgress(error.localizedDescription))
            return
        }
    }

    func isRecording() -> Bool {
        return recorder != nil
    }

    func finishRecording() -> AudioSample? {
        guard let url = recorder?.url
        else { return nil }

        clear()
        switchCategory(category: .playback)

        return AudioSample(name: currentName, audioUrl: url, isMicrophone: true, volume: 1)
    }

    private func switchCategory(category: AVAudioSession.Category) {
        do {
            try recordingSession.setActive(false)
            try recordingSession.setCategory(category, mode: .default)
            try recordingSession.setActive(true)
        } catch(let error) {
            print(error)
        }
    }

    private func clear() {
        recorder?.stop()
        recorder = nil
    }

    private func createRecordUrl() -> URL {
        recordIndex += 1
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent(currentName)
    }
}

extension MicrophoneRecording: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            errorHandler?(.errorInProgress(error.localizedDescription))
        }
    }
}
