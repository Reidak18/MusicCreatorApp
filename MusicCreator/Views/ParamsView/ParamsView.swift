//
//  ParamsView.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 30.10.2023.
//

import UIKit

protocol SlidersChangesListener {
    func volumeValueUpdated(volume: Float)
    func speedValueUpdated(speed: Float)
}

class ParamsView: UIView {
    public var slidersChangesListener: SlidersChangesListener?
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
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
        volumeSlider.value = 1
        volumeSlider.addTarget(self, action: #selector(volumeValueChanged), for: .valueChanged)
        addSubview(volumeSlider)
        speedSlider.setThumbLabel(label: "скорость")
        speedSlider.setBackgroundImage(named: "HorizontalSliderBackground")
        speedSlider.translatesAutoresizingMaskIntoConstraints = false
        speedSlider.minimumValue = 0.5
        speedSlider.maximumValue = 2
        speedSlider.value = 1
        speedSlider.addTarget(self, action: #selector(speedValueChanged), for: .valueChanged)
        addSubview(speedSlider)
    }

    private func setConstraints() {
        let volumeSliderThumbHeight = volumeSlider.frame.width
        let speedSliderThumbHeight = speedSlider.frame.height
        NSLayoutConstraint.activate([
            volumeSlider.widthAnchor.constraint(equalTo: heightAnchor, constant: -volumeSliderThumbHeight / 2),
            volumeSlider.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -volumeSliderThumbHeight / 2 + 5),
            volumeSlider.centerXAnchor.constraint(equalTo: leadingAnchor, constant: volumeSliderThumbHeight - 5),

            speedSlider.widthAnchor.constraint(equalTo: widthAnchor, constant: -speedSliderThumbHeight / 2),
            speedSlider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: speedSliderThumbHeight + 5),
            speedSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: speedSliderThumbHeight / 2)
        ])
    }

    @objc private func volumeValueChanged() {
        slidersChangesListener?.volumeValueUpdated(volume: volumeSlider.value)
    }

    @objc private func speedValueChanged() {
        slidersChangesListener?.speedValueUpdated(speed: speedSlider.value)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
