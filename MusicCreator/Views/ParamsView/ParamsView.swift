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

protocol PlayStopper: AnyObject {
    func stop()
}

class ParamsView: UIView {
    weak var slidersChangesListener: SlidersChangesListener?
    weak var playStopper: PlayStopper?
    private let volumeSlider = ThumbTextSlider()
    private let frequencySlider = ThumbTextSlider()
    private var stopButton = UIButton()

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
        volumeSlider.minimumValue = FloatConstants.minimumVolume.rawValue
        volumeSlider.maximumValue = FloatConstants.maximumVolume.rawValue
        volumeSlider.value = FloatConstants.defaultVolume.rawValue
        volumeSlider.addTarget(self, action: #selector(volumeValueChanged), for: .valueChanged)
        addSubview(volumeSlider)
        frequencySlider.setThumbLabel(label: "скорость")
        frequencySlider.setBackgroundImage(named: "HorizontalSliderBackground")
        frequencySlider.translatesAutoresizingMaskIntoConstraints = false
        frequencySlider.minimumValue = FloatConstants.minimumFrequency.rawValue
        frequencySlider.maximumValue = FloatConstants.maximumFrequency.rawValue
        frequencySlider.value = FloatConstants.defaultFrequency.rawValue
        frequencySlider.isContinuous = false
        frequencySlider.addTarget(self, action: #selector(frequencyValueChanged), for: .valueChanged)
        addSubview(frequencySlider)

        // кнопка для остановки проигрывания текущего семпла
        var stopButtonConfiguration = UIButton.Configuration.filled()
        stopButtonConfiguration.image = UIImage(systemName: "stop.fill")
        stopButtonConfiguration.baseBackgroundColor = .foregroundPrimary
        stopButtonConfiguration.baseForegroundColor = .labelPrimary
        stopButtonConfiguration.imagePlacement = .all
        stopButtonConfiguration.cornerStyle = .medium
        stopButton = UIButton(configuration: stopButtonConfiguration)
        stopButton.addTarget(self, action: #selector(stopPlaying), for: .touchUpInside)
//        stopButton.isEnabled = false
        stopButton.translatesAutoresizingMaskIntoConstraints = false
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
            stopButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            stopButton.heightAnchor.constraint(equalTo: stopButton.widthAnchor)
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

    @objc private func stopPlaying() {
        playStopper?.stop()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
