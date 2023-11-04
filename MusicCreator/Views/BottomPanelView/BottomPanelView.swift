//
//  BottomPanelView.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 31.10.2023.
//

import UIKit

enum CurrentViewType {
    case params
    case layers
}

protocol MiddleViewsSwitcher {
    func switchButtonClicked(to viewType: CurrentViewType)
}

class BottomPanelView: UIStackView {
    var mixTrackPlayer: MixTrackPlayer? {
        didSet {
            bottomControlButtons.mixTrackPlayer = mixTrackPlayer
        }
    }
    var addMicrophoneRecordSubscriber: AddMicrophoneRecordListener? {
        didSet {
            bottomControlButtons.addMicrophoneRecordSubscriber = addMicrophoneRecordSubscriber
        }
    }
    var switchViewDelegate: MiddleViewsSwitcher?
    private var currentViewType: CurrentViewType = .params
    private let waveformSlider = WaveformSlider()
    private let bottomControlButtons = BottomControlButtonsView()

    private let stylesButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .foregroundPrimary
        config.baseForegroundColor = .labelPrimary
        config.title = "Слои"
        config.image = UIImage(systemName: "chevron.up")
        config.imagePadding = 16
        config.imagePlacement = .trailing
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
        config.cornerStyle = .medium
        config.titleTextAttributesTransformer =
           UIConfigurationTextAttributesTransformer { incoming in
             var outgoing = incoming
             outgoing.font = UIFont.systemFont(ofSize: 16)
             return outgoing
         }

        let button = UIButton(configuration: config)
        button.titleLabel!.font = .systemFont(ofSize: 6)
        button.widthAnchor.constraint(equalTo: button.heightAnchor,
                                      multiplier: 2).isActive = true

        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    private func setupView() {
        axis = .vertical
        spacing = 10

        addArrangedSubview(waveformSlider)

        let buttonsStackView = UIStackView()
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 104
        addArrangedSubview(buttonsStackView)

        stylesButton.addTarget(self, action: #selector(onStylesButtonClick), for: .touchUpInside)
        buttonsStackView.addArrangedSubview(stylesButton)
        buttonsStackView.addArrangedSubview(bottomControlButtons)
    }

    @objc private func onStylesButtonClick() {
        switch currentViewType {
        case .layers:
            switchViewDelegate?.switchButtonClicked(to: .params)
        case .params:
            switchViewDelegate?.switchButtonClicked(to: .layers)
        }
    }

    func setWaveform(url: URL?) {
        waveformSlider.setWaveform(url: url)
    }

    func setWaveformProgress(progress: Float) {
        waveformSlider.value = progress
    }

    func switchView(viewType: CurrentViewType) {
        var config = stylesButton.configuration ?? UIButton.Configuration.filled()
        currentViewType = viewType
        switch currentViewType {
        case .params:
            config.baseBackgroundColor = .foregroundPrimary
            config.image = UIImage(systemName: "chevron.up")
        case .layers:
            config.baseBackgroundColor = .customLightGreen
            config.image = UIImage(systemName: "chevron.down")
        }
        stylesButton.configuration = config
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}
