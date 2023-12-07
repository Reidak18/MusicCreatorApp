//
//  BottomControlButtonsView.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 31.10.2023.
//

import UIKit

protocol RecordingStatusSubscriber: AnyObject {
    func started(_ type: RecordingType)
    func finished(_ type: RecordingType, url: URL?)
    func error(_ type: RecordingType, error: RecordMicroError)
}

class BottomControlButtonsView: UIStackView {
    private weak var sampleProvider: SessionSamplesProvider?
    private weak var recordingSubscriber: RecordingStatusSubscriber?
    private let audioRecorder: AudioRecorderProtocol = AudioRecorder()

    private var microButton = UIButton()
    private var playButton = UIButton()
    private var recordButton = UIButton()

    private var isPlaying = false
    private var isRecording = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    private func setupView() {
        axis = .horizontal
        spacing = Spacing.small.rawValue

        microButton = UIButton(configuration: createConfiguration("mic.fill",
                                                                  scale: .large))
        microButton.widthAnchor.constraint(equalTo: microButton.heightAnchor).isActive = true
        microButton.tag = IntConstants.microButtonTag.rawValue
        microButton.addTarget(self, action: #selector(startMicroRecord), for: .touchUpInside)
        addArrangedSubview(microButton)
        recordButton = UIButton(configuration: createConfiguration("circle.fill",
                                                                   scale: .medium))
        recordButton.widthAnchor.constraint(equalTo: recordButton.heightAnchor).isActive = true
        recordButton.tag = IntConstants.recordButtonTag.rawValue
        recordButton.addTarget(self, action: #selector(startMixRecord), for: .touchUpInside)
        addArrangedSubview(recordButton)
        playButton = UIButton(configuration: createConfiguration("play.fill",
                                                                 scale: .large))
        playButton.widthAnchor.constraint(equalTo: playButton.heightAnchor).isActive = true
        playButton.tag = IntConstants.playMixButtonTag.rawValue
        playButton.addTarget(self, action: #selector(playMixedTrack), for: .touchUpInside)
        addArrangedSubview(playButton)
    }

    func setVisualListener<Listener: AudioVisualizer>(listener: Listener) {
        audioRecorder.setVisualListener(listener: listener)
    }

    func setProviderAndSubscriber<Provider: SessionSamplesProvider,
                                  Subscriber: RecordingStatusSubscriber>(provider: Provider,
                                                                         subscriber: Subscriber) {
        sampleProvider = provider
        recordingSubscriber = subscriber
    }

    private func createConfiguration(_ imageSystemName: String,
                                     scale: UIImage.SymbolScale) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .foregroundPrimary
        config.baseForegroundColor = .labelPrimary
        config.image = UIImage(systemName: imageSystemName)
        config.imagePlacement = .all
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: scale)
        config.cornerStyle = .medium

        return config
    }

    @objc private func startMicroRecord() {
        guard audioRecorder.hasMicrophonePermission()
        else {
            audioRecorder.requestMicrophonePermission()
            return
        }

        if audioRecorder.isRecording(.microphoneRecording){
            changeMicroRecordStatus(isRecording: false)
            guard let url = audioRecorder.finishMicrophoneRecording()
            else {
                recordingSubscriber?.error(.microphoneRecording, error: .fileNotCreated("Can't read file path"))
                return
            }

            recordingSubscriber?.finished(.microphoneRecording, url: url)
        } else {
            recordingSubscriber?.started(.microphoneRecording)
            changeMicroRecordStatus(isRecording: true)
            audioRecorder.startMicrophoneRecording { [weak self] error in
                DispatchQueue.main.async {
                    self?.changeMicroRecordStatus(isRecording: false)
                }
                self?.recordingSubscriber?.error(.microphoneRecording, error: error)
            }
        }
    }

    @objc private func playMixedTrack() {
        if isPlaying {
            audioRecorder.finishPlayingMixedAudio()
            recordingSubscriber?.finished(.mixAudioPlaying, url: nil)
        } else {
            guard let samples = sampleProvider?.getSamples().filter({ !$0.isMute })
            else { return }
            audioRecorder.startPlayingMixedAudio(samples: samples)
            recordingSubscriber?.started(.mixAudioPlaying)
        }
        isPlaying.toggle()
        changePlayingStatus(isPlaying: isPlaying)
    }

    @objc private func startMixRecord() {
        if isRecording {
            let fileUrl = audioRecorder.finishRecordingMixedAudio()
            recordingSubscriber?.finished(.mixAudioRecording, url: fileUrl)
        } else {
            guard let samples = sampleProvider?.getSamples().filter({ !$0.isMute })
            else { return }
            audioRecorder.startRecordingMuxedAudio(samples: samples)
            recordingSubscriber?.started(.mixAudioRecording)
        }
        isRecording.toggle()
        changeMixRecordingStatus(isRecording: isRecording)
    }

    private func changePlayingStatus(isPlaying: Bool) {
        var config = playButton.configuration ?? UIButton.Configuration.filled()
        config.image = UIImage(systemName: isPlaying ? "stop.fill" : "play.fill")
        playButton.configuration = config
    }

    private func changeMicroRecordStatus(isRecording: Bool) {
        var config = microButton.configuration ?? UIButton.Configuration.filled()
        config.baseForegroundColor = isRecording ? .red : .labelPrimary
        microButton.configuration = config
    }

    private func changeMixRecordingStatus(isRecording: Bool) {
        var config = recordButton.configuration ?? UIButton.Configuration.filled()
        config.baseForegroundColor = isRecording ? .red : .labelPrimary
        recordButton.configuration = config
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}
