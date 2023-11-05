//
//  StopButton.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 05.11.2023.
//

import UIKit

// кнопка для остановки проигрывания текущего семпла
class StopButton: UIButton {
    weak var playStopper: PlayStopper?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    private func setupView() {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "stop.fill")
        config.baseBackgroundColor = .foregroundPrimary
        config.baseForegroundColor = .labelPrimary
        config.imagePlacement = .all
        config.cornerStyle = .medium
        configuration = config
        translatesAutoresizingMaskIntoConstraints = false
        isEnabled = false
        addTarget(self, action: #selector(stopPlaying), for: .touchUpInside)
    }

    func setPlayStopper<Stopper: PlayStopper>(stopper: Stopper) {
        stopper.subscribeForUpdates(self)
        playStopper = stopper
    }

    @objc private func stopPlaying() {
        playStopper?.stop()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension StopButton: AudioPlayerStateListener {
    func onStateChanged(oldId: String?, newSample: AudioSample?) {
        isEnabled = newSample != nil
    }
}
