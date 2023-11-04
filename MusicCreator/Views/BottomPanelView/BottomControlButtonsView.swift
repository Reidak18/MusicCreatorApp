//
//  BottomControlButtonsView.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 31.10.2023.
//

import UIKit

protocol AddMicrophoneRecordListener {
    func startRecording()
    func recordAdded(sample: AudioSample)
    func errorHappend(error: RecordMicroError)
}

protocol MixTrackPlayer {
    func mixAndPlay()
    func stopPlay()
    func mixAndRecord()
    func stopRecord()
}

class BottomControlButtonsView: UIStackView {
    var mixTrackPlayer: MixTrackPlayer?
    var addMicrophoneRecordSubscriber: AddMicrophoneRecordListener?
    private let microphoneRecording: MicrophoneRecordingProtocol = MicrophoneRecording()

    private var microButton = UIButton()
    private var playButton = UIButton()

    private var isPlaying = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    private func setupView() {
        axis = .horizontal
        spacing = 5

        microButton = UIButton(configuration: createConfiguration("mic.fill",
                                                                  scale: .large))
        microButton.widthAnchor.constraint(equalTo: microButton.heightAnchor).isActive = true
        microButton.tag = IntConstants.MicroButtonTag.rawValue
        microButton.addTarget(self, action: #selector(startMicroRecord), for: .touchUpInside)
        addArrangedSubview(microButton)
        let recordButton = UIButton(configuration: createConfiguration("circle.fill",
                                                                       scale: .medium))
        recordButton.widthAnchor.constraint(equalTo: recordButton.heightAnchor).isActive = true

        addArrangedSubview(recordButton)
        playButton = UIButton(configuration: createConfiguration("play.fill",
                                                                     scale: .large))
        playButton.widthAnchor.constraint(equalTo: playButton.heightAnchor).isActive = true
        playButton.tag = IntConstants.PlayMixButtonTag.rawValue
        playButton.addTarget(self, action: #selector(playMixedTrack), for: .touchUpInside)
        addArrangedSubview(playButton)
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
        guard microphoneRecording.hasPermission()
        else {
            microphoneRecording.requestPermission()
            return
        }

        if microphoneRecording.isRecording() {
            changeRecordStatus(isRecording: false)
            guard let sample = microphoneRecording.finishRecording()
            else {
                addMicrophoneRecordSubscriber?.errorHappend(error: .fileNotCreated("Can't read file path"))
                return
            }

            addMicrophoneRecordSubscriber?.recordAdded(sample: sample)
        } else {
            addMicrophoneRecordSubscriber?.startRecording()
            changeRecordStatus(isRecording: true)
            microphoneRecording.startRecording { error in
                DispatchQueue.main.async {
                    self.changeRecordStatus(isRecording: false)
                }
                self.addMicrophoneRecordSubscriber?.errorHappend(error: error)
            }
        }
    }

    @objc private func playMixedTrack() {
        if isPlaying {
            mixTrackPlayer?.stopPlay()
        } else {
            mixTrackPlayer?.mixAndPlay()
        }
        isPlaying.toggle()
        changePlayingStatus(isPlaying: isPlaying)
    }

    private func changePlayingStatus(isPlaying: Bool) {
        var config = playButton.configuration ?? UIButton.Configuration.filled()
        config.image = UIImage(systemName: isPlaying ? "stop.fill" : "play.fill")
        playButton.configuration = config
    }

    private func changeRecordStatus(isRecording: Bool) {
        var config = microButton.configuration ?? UIButton.Configuration.filled()
        config.baseForegroundColor = isRecording ? .red : .labelPrimary
        microButton.configuration = config
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}
