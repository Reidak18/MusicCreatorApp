//
//  LayerCell.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 31.10.2023.
//

import UIKit

protocol LayerCellListener {
    func playLayer(id: String, play: Bool)
    func muteLayer(id: String)
    func removeLayer(id: String)
}

class LayerCell: UITableViewCell {
    public var listener: LayerCellListener?

    private let nameLabel = UILabel()
    private let mainStack = UIStackView()
    private var playButton = UIButton()
    private var setMuteButton = UIButton()

    private var sample: AudioSample?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none
        transform = CGAffineTransformMakeScale(1, -1)

        mainStack.axis = .horizontal
        mainStack.backgroundColor = .foregroundPrimary
        mainStack.layer.cornerRadius = CornerRadius.standart.rawValue
        mainStack.isLayoutMarginsRelativeArrangement = true
        mainStack.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        let buttonsStack = UIStackView()
        buttonsStack.axis = .horizontal
        buttonsStack.alignment = .fill
        buttonsStack.distribution = .fillEqually

        nameLabel.font = .systemFont(ofSize: FontSize.standart.rawValue)
        mainStack.addArrangedSubview(nameLabel)

        var playButtonConfig = UIButton.Configuration.plain()
        playButtonConfig.image = UIImage(systemName: "play.fill")
        playButtonConfig.baseForegroundColor = .customGray
        playButtonConfig.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        playButton = UIButton(configuration: playButtonConfig)
        playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
        buttonsStack.addArrangedSubview(playButton)

        var setMuteButtonConfig = UIButton.Configuration.plain()
        setMuteButtonConfig.image = UIImage(systemName: "speaker.fill")
        setMuteButtonConfig.baseForegroundColor = .customGray
        setMuteButtonConfig.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        setMuteButton = UIButton(configuration: setMuteButtonConfig)
        setMuteButton.addTarget(self, action: #selector(mute), for: .touchUpInside)
        buttonsStack.addArrangedSubview(setMuteButton)

        var removeButtonConfig = UIButton.Configuration.filled()
        removeButtonConfig.image = UIImage(systemName: "xmark",
                                           withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
        removeButtonConfig.cornerStyle = .medium
        removeButtonConfig.baseForegroundColor = .customGray
        removeButtonConfig.baseBackgroundColor = .customLightGray
        let removeButton = UIButton(configuration: removeButtonConfig)
        removeButton.addTarget(self, action: #selector(remove), for: .touchUpInside)
        buttonsStack.addArrangedSubview(removeButton)

        mainStack.addArrangedSubview(buttonsStack)
        contentView.addSubview(mainStack)

        let constraint = mainStack.leadingAnchor.constraint(equalTo: leadingAnchor)
        constraint.priority = UILayoutPriority(999)

        NSLayoutConstraint.activate([
            playButton.widthAnchor.constraint(equalTo: playButton.heightAnchor),
            setMuteButton.widthAnchor.constraint(equalTo: setMuteButton.heightAnchor),
            removeButton.widthAnchor.constraint(equalTo: removeButton.heightAnchor),

            constraint,
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func setLayerSample(sample: AudioSample) {
        self.sample = sample
        updateView()
    }

    func getId() -> String? {
        return sample?.id
    }

    func isSelectable() -> Bool {
        guard let isMicrophone = sample?.isMicrophone
        else { return false }

        return !isMicrophone
    }

    private func updateView() {
        guard let unwSample = sample
        else { return }

        nameLabel.text = unwSample.name

        var muteConfig = setMuteButton.configuration ?? UIButton.Configuration.filled()
        muteConfig.image = unwSample.isMute ? UIImage(systemName: "speaker.slash.fill") : UIImage(systemName: "speaker.fill")
        setMuteButton.configuration = muteConfig

        var playConfig = playButton.configuration ?? UIButton.Configuration.plain()
        if unwSample.isPlaying {
            playConfig.image = UIImage(systemName: "pause.fill")
            mainStack.backgroundColor = .customLightGreen
        } else {
            playConfig.image = UIImage(systemName: "play.fill")
            mainStack.backgroundColor = .foregroundPrimary
        }
        playButton.configuration = playConfig
    }

    @objc private func play() {
        guard let unwSample = sample
        else { return }

        listener?.playLayer(id: unwSample.id, play: !unwSample.isPlaying)
    }

    @objc private func mute() {
        guard let id = sample?.id
        else { return }

        listener?.muteLayer(id: id)
    }

    @objc private func remove() {
        guard var unwSample = sample
        else { return }

        unwSample.setIsPlaying(false)
        sample = unwSample

        listener?.removeLayer(id: unwSample.id)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
