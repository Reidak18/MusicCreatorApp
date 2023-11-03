//
//  ParamsView.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 30.10.2023.
//

import UIKit

protocol SlidersChangesListener {
    func volumeValueUpdated(volume: Float)
    func frequencyValueUpdated(frequency: Float)
}

class ParamsView: UIView {
    public var slidersChangesListener: SlidersChangesListener?
    private let volumeSlider = ThumbTextSlider()
    private let frequencySlider = ThumbTextSlider()

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
        volumeSlider.value = 0.5
        volumeSlider.addTarget(self, action: #selector(volumeValueChanged), for: .valueChanged)
        addSubview(volumeSlider)
        frequencySlider.setThumbLabel(label: "скорость")
        frequencySlider.setBackgroundImage(named: "HorizontalSliderBackground")
        frequencySlider.translatesAutoresizingMaskIntoConstraints = false
        frequencySlider.minimumValue = 0.2
        frequencySlider.maximumValue = 10
        frequencySlider.value = 2
        frequencySlider.addTarget(self, action: #selector(frequencyValueChanged), for: .valueChanged)
        addSubview(frequencySlider)
    }

    private func setConstraints() {
        let volumeSliderThumbHeight = volumeSlider.frame.width
        let frequencySliderThumbHeight = frequencySlider.frame.height
        NSLayoutConstraint.activate([
            volumeSlider.widthAnchor.constraint(equalTo: heightAnchor, constant: -volumeSliderThumbHeight / 2),
            volumeSlider.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -volumeSliderThumbHeight / 2 + 5),
            volumeSlider.centerXAnchor.constraint(equalTo: leadingAnchor, constant: volumeSliderThumbHeight - 5),

            frequencySlider.widthAnchor.constraint(equalTo: widthAnchor, constant: -frequencySliderThumbHeight / 2),
            frequencySlider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: frequencySliderThumbHeight + 5),
            frequencySlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: frequencySliderThumbHeight / 2)
        ])
    }

    func setSlidersParams(volume: Float, frequency: Float) {
        volumeSlider.value = volume
        volumeValueChanged()
        frequencySlider.value = frequency
        frequencyValueChanged()
    }

    @objc private func volumeValueChanged() {
        slidersChangesListener?.volumeValueUpdated(volume: volumeSlider.value)
    }

    @objc private func frequencyValueChanged() {
        slidersChangesListener?.frequencyValueUpdated(frequency: frequencySlider.value)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
