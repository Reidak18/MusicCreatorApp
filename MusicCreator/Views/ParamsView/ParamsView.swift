//
//  ParamsView.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 30.10.2023.
//

import UIKit

protocol SlidersChangesListener: AnyObject {
    func volumeValueUpdated(volume: Float)
    func frequencyValueUpdated(frequency: Float)
}

class ParamsView: UIView {
    weak var slidersChangesListener: SlidersChangesListener?

    private let volumeSlider: ThumbTextSlider = {
        let slider = ThumbTextSlider()
        slider.setThumbLabel(label: "громкость")
        slider.setBackgroundImage(named: "VerticalSliderBackground")
        slider.transform = CGAffineTransformMakeRotation(-CGFloat.pi / 2)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = FloatConstants.minimumVolume.rawValue
        slider.maximumValue = FloatConstants.maximumVolume.rawValue
        slider.value = FloatConstants.defaultVolume.rawValue
        return slider
    }()
    private let frequencySlider: ThumbTextSlider = {
        let slider = ThumbTextSlider()
        slider.setThumbLabel(label: "скорость")
        slider.setBackgroundImage(named: "HorizontalSliderBackground")
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = FloatConstants.minimumFrequency.rawValue
        slider.maximumValue = FloatConstants.maximumFrequency.rawValue
        slider.value = FloatConstants.defaultFrequency.rawValue
        slider.isContinuous = false
        return slider
    }()
    private let stopButton = StopButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setConstraints()
    }

    private func setupView() {
        volumeSlider.addTarget(self, action: #selector(volumeValueChanged), for: .valueChanged)
        addSubview(volumeSlider)
        frequencySlider.addTarget(self, action: #selector(frequencyValueChanged), for: .valueChanged)
        addSubview(frequencySlider)
        addSubview(stopButton)
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
            frequencySlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: frequencySliderThumbHeight / 2),

            stopButton.topAnchor.constraint(equalTo: topAnchor),
            stopButton.rightAnchor.constraint(equalTo: rightAnchor),
            stopButton.heightAnchor.constraint(equalTo: stopButton.widthAnchor)
        ])
    }

    func setSlidersParams(volume: Float, frequency: Float) {
        volumeSlider.value = volume
        frequencySlider.value = frequency
    }

    func setPlayStopper<Stopper: PlayStopper>(stopper: Stopper) {
        stopButton.setPlayStopper(stopper: stopper)
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
