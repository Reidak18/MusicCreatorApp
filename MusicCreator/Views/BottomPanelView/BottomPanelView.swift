//
//  BottomPanelView.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 31.10.2023.
//

import UIKit

class BottomPanelView: UIStackView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    private func setupView() {
        axis = .vertical
        spacing = 10

        let waveformImage = UIImageView(image: UIImage(named: "HorizontalSliderBackground"))
        addArrangedSubview(waveformImage)

        let buttonsStackView = UIStackView()
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 104
        addArrangedSubview(buttonsStackView)

        var stylesButtonConfig = UIButton.Configuration.filled()
        stylesButtonConfig.baseBackgroundColor = .foregroundPrimary
        stylesButtonConfig.title = "Слои"
        stylesButtonConfig.baseForegroundColor = .labelPrimary
        stylesButtonConfig.image = UIImage(systemName: "chevron.up")
        stylesButtonConfig.imagePadding = 16
        stylesButtonConfig.imagePlacement = .trailing
        stylesButtonConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
        stylesButtonConfig.cornerStyle = .medium

        let stylesButton = UIButton(configuration: stylesButtonConfig)
        stylesButton.widthAnchor.constraint(equalTo: stylesButton.heightAnchor,
                                            multiplier: 2).isActive = true
        buttonsStackView.addArrangedSubview(stylesButton)
        buttonsStackView.addArrangedSubview(BottomControlButtonsView())
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}
