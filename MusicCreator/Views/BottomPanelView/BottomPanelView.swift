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

protocol StylesWindowOpener {
    func openStylesWindow(viewType: CurrentViewType)
}

class BottomPanelView: UIStackView {
    public var switchViewDelegate: StylesWindowOpener?
    private var currentViewType: CurrentViewType = .params
    private let waveformSlider = WaveformSlider()

    private let stylesButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .foregroundPrimary
        config.title = "Слои"
        config.baseForegroundColor = .labelPrimary
        config.image = UIImage(systemName: "chevron.up")
        config.imagePadding = 16
        config.imagePlacement = .trailing
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
        config.cornerStyle = .medium

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
        spacing = 10

        addArrangedSubview(waveformSlider)

        let buttonsStackView = UIStackView()
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 104
        addArrangedSubview(buttonsStackView)

        stylesButton.addTarget(self, action: #selector(onStylesButtonClick), for: .touchUpInside)
        buttonsStackView.addArrangedSubview(stylesButton)
        buttonsStackView.addArrangedSubview(BottomControlButtonsView())
    }

    @objc private func onStylesButtonClick() {
        var config = stylesButton.configuration ?? UIButton.Configuration.filled()
        switch currentViewType {
        case .layers:
            currentViewType = .params
            config.baseBackgroundColor = .foregroundPrimary
            config.image = UIImage(systemName: "chevron.up")
        case .params:
            currentViewType = .layers
            config.baseBackgroundColor = .customLightGreen
            config.image = UIImage(systemName: "chevron.down")
        }
        stylesButton.configuration = config
        switchViewDelegate?.openStylesWindow(viewType: currentViewType)
    }

    func setWaveform(url: URL) {
        waveformSlider.setWaveform(url: url)
    }

    func setWaveformProgress(progress: Float) {
        waveformSlider.value = progress
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}
