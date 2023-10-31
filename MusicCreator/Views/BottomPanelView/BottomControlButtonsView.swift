//
//  BottomControlButtonsView.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 31.10.2023.
//

import UIKit

class BottomControlButtonsView: UIStackView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    private func setupView() {
        axis = .horizontal
        spacing = 5

        let microButton = UIButton(configuration: createConfiguration("mic.fill",
                                                                      scale: .large))
        microButton.widthAnchor.constraint(equalTo: microButton.heightAnchor).isActive = true
        addArrangedSubview(microButton)
        let recordButton = UIButton(configuration: createConfiguration("circle.fill",
                                                                       scale: .medium))
        recordButton.widthAnchor.constraint(equalTo: recordButton.heightAnchor).isActive = true

        addArrangedSubview(recordButton)
        let playButton = UIButton(configuration: createConfiguration("play.fill",
                                                                     scale: .large))
        playButton.widthAnchor.constraint(equalTo: playButton.heightAnchor).isActive = true

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

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}
