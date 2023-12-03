//
//  WaveformSlider.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 01.11.2023.
//

import UIKit

class WaveformSlider: UISlider {
    private let numberOfFrames = 75
    private var waveformCreator: WaveformCreatorProtocol = WaveformCreator()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setConstraints()
    }

    func setSubscribeAdder<Adder: AudioPlayerSubscribeAdder>(adder: Adder) {
        adder.subscribeForUpdates(self)
        adder.subscribeForProgressUpdates(self)
    }

    private func setupView() {
        setThumbImage(UIImage(), for: .normal)
        isUserInteractionEnabled = false
        minimumValue = 0
        maximumValue = 1
    }

    private func setConstraints() {
        heightAnchor.constraint(equalToConstant: UIHeight.waveform.rawValue).isActive = true
    }

    private func setWaveform(url: URL?) {
        guard let url = url
        else {
            DispatchQueue.main.async { [weak self] in
                self?.setMinimumTrackImage(nil, for: .normal)
                self?.setMaximumTrackImage(nil, for: .normal)
            }
            return
        }
        waveformCreator.drawWaveform(fileUrl: url,
                                     numberOfFrames: numberOfFrames,
                                     frame: frame) { result in
            switch(result) {
            case .failure(let error):
                print(error)
            case .success(let resultImage):
                DispatchQueue.main.async { [weak self] in
                    self?.setMinimumTrackImage(resultImage.withTintColor(.customLightGreen), for: .normal)
                    self?.setMaximumTrackImage(resultImage.withTintColor(.white), for: .normal)
                }
            }
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension WaveformSlider: AudioPlayerStateListener {
    func onStateChanged(oldId: String?, newSample: AudioSample?) {
        setWaveform(url: newSample?.audioUrl)
    }
}

extension WaveformSlider: AudioProgressListener {
    func updateProgress(progress: Float) {
        value = progress
    }
}
