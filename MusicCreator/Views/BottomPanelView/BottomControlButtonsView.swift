//
//  BottomControlButtonsView.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 31.10.2023.
//

import UIKit

protocol AddMicrophoneRecordListener: AnyObject {
    func startRecording()
    func recordAdded(sample: AudioSample)
    func errorHappend(error: RecordMicroError)
}

protocol MixTrackPlayer: AnyObject {
    func mixAndPlay()
    func stopPlay()
    func mixAndRecord()
    func stopRecord()
}

class BottomControlButtonsView: UIStackView {
    weak var mixTrackPlayer: MixTrackPlayer?
    weak var addMicrophoneRecordSubscriber: AddMicrophoneRecordListener?
    private let microphoneRecording: MicrophoneRecordingProtocol = MicrophoneRecording()

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
            changeMicroRecordStatus(isRecording: false)
            guard let sample = microphoneRecording.finishRecording()
            else {
                addMicrophoneRecordSubscriber?.errorHappend(error: .fileNotCreated("Can't read file path"))
                return
            }

            addMicrophoneRecordSubscriber?.recordAdded(sample: sample)
        } else {
            addMicrophoneRecordSubscriber?.startRecording()
            changeMicroRecordStatus(isRecording: true)
            microphoneRecording.startRecording { error in
                DispatchQueue.main.async {
                    self.changeMicroRecordStatus(isRecording: false)
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

    @objc private func startMixRecord() {
        if isRecording {
            mixTrackPlayer?.stopRecord()
        } else {
            mixTrackPlayer?.mixAndRecord()
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
