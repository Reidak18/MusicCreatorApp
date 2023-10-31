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
        volumeSlider.setBackgroundImage(named: "VerticalSliderBackground")
        volumeSlider.transform = CGAffineTransformMakeRotation(-CGFloat.pi / 2)
        volumeSlider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(volumeSlider)
        speedSlider.setThumbLabel(label: "скорость")
        speedSlider.setBackgroundImage(named: "HorizontalSliderBackground")
        speedSlider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(speedSlider)
    }

    private func setConstraints() {
        let volumeSliderThumbHeight = volumeSlider.frame.width
        let speedSliderThumbHeight = speedSlider.frame.height
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 1.35),
            volumeSlider.widthAnchor.constraint(equalTo: heightAnchor, constant: -volumeSliderThumbHeight / 2),
            volumeSlider.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -volumeSliderThumbHeight / 2 + 5),
            volumeSlider.centerXAnchor.constraint(equalTo: leadingAnchor, constant: volumeSliderThumbHeight - 5),

            speedSlider.widthAnchor.constraint(equalTo: widthAnchor, constant: -speedSliderThumbHeight / 2),
            speedSlider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: speedSliderThumbHeight + 5),
            speedSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: speedSliderThumbHeight / 2)
        ])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
