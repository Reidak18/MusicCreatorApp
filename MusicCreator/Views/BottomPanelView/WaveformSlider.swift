//
//  WaveformSlider.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 01.11.2023.
//

import UIKit

class WaveformSlider: UISlider {
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setConstraints()
    }

    private func setupView() {
        setThumbImage(UIImage(), for: .normal)
        isUserInteractionEnabled = false
        minimumValue = 0
        maximumValue = 1
    }

    private func setConstraints() {
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    func setParams(background: UIImage) {
        setMinimumTrackImage(background.withTintColor(.customLightGreen), for: .normal)
        setMaximumTrackImage(background.withTintColor(.white), for: .normal)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
