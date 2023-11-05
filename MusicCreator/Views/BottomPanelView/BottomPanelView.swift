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

protocol MiddleViewsSwitcher: AnyObject {
    func switchButtonClicked(to viewType: CurrentViewType)
}

class BottomPanelView: UIStackView {
    weak var mixTrackPlayer: MixTrackPlayer? {
        didSet {
            bottomControlButtons.mixTrackPlayer = mixTrackPlayer
        }
    }
    weak var addMicrophoneRecordSubscriber: AddMicrophoneRecordListener? {
        didSet {
            bottomControlButtons.addMicrophoneRecordSubscriber = addMicrophoneRecordSubscriber
        }
    }
    weak var switchViewDelegate: MiddleViewsSwitcher?
    private var currentViewType: CurrentViewType = .params
    private let waveformSlider = WaveformSlider()
    private let bottomControlButtons = BottomControlButtonsView()

    private let stylesButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .foregroundPrimary
        config.baseForegroundColor = .labelPrimary
        config.title = "Слои"
        config.image = UIImage(systemName: "chevron.up")
        config.imagePadding = Padding.standart.rawValue
        config.imagePlacement = .trailing
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
        config.cornerStyle = .medium
        config.titleTextAttributesTransformer =
           UIConfigurationTextAttributesTransformer { incoming in
             var outgoing = incoming
             outgoing.font = UIFont.systemFont(ofSize: FontSize.title.rawValue)
             return outgoing
         }

        let button = UIButton(configuration: config)
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
        spacing = Spacing.standart.rawValue

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

    func setSubscribeAdder<Adder: AudioPlayerSubscribeAdder>(adder: Adder) {
        waveformSlider.setSubscribeAdder(adder: adder)
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
