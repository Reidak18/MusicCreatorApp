//
//  ParamsView.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 30.10.2023.
//

import UIKit

class ParamsView: UIView {
    private let volumeSlider = ThumbTextSlider()
    private let speedSlider = ThumbTextSlider()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setConstraints()
    }

    private func setupView() {
        volumeSlider.setThumbLabel(label: "громкость")
        volumeSlider.transform = CGAffineTransformMakeRotation(-CGFloat.pi / 2)
        volumeSlider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(volumeSlider)
        speedSlider.setThumbLabel(label: "скорость")
        speedSlider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(speedSlider)
    }

    private func setConstraints() {
        let volumeSliderThumbHeight = (volumeSlider.getThumbHeight() ?? 15) + 5
        let speedSliderThumbHeight = (speedSlider.getThumbHeight() ?? 15) + 5
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 1.35),
            volumeSlider.widthAnchor.constraint(equalTo: heightAnchor, constant: -volumeSliderThumbHeight),
            volumeSlider.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -volumeSliderThumbHeight / 2),
            volumeSlider.centerXAnchor.constraint(equalTo: leadingAnchor, constant: volumeSliderThumbHeight / 2),
            speedSlider.widthAnchor.constraint(equalTo: widthAnchor, constant: -speedSliderThumbHeight),
            speedSlider.bottomAnchor.constraint(equalTo: bottomAnchor),
            speedSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: speedSliderThumbHeight),
        ])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
