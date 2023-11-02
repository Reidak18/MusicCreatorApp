//
//  LayerCell.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 31.10.2023.
//

import UIKit

protocol LayerCellListener {
    func playLayer(id: String)
    func muteLayer(id: String)
    func removeLayer(id: String)
}

class LayerCell: UITableViewCell {
    public var listener: LayerCellListener?

    private var id = ""
    private let nameLabel = UILabel()
    private var setMuteButton = UIButton()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none
        transform = CGAffineTransformMakeScale(1, -1)

        let mainStack = UIStackView()
        mainStack.axis = .horizontal
        mainStack.backgroundColor = .foregroundPrimary
        mainStack.layer.cornerRadius = 4
        mainStack.isLayoutMarginsRelativeArrangement = true
        mainStack.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        let buttonsStack = UIStackView()
        buttonsStack.axis = .horizontal
        buttonsStack.alignment = .fill
        buttonsStack.distribution = .fillEqually

        nameLabel.font = .systemFont(ofSize: 12)
        mainStack.addArrangedSubview(nameLabel)

        var playButtonConfig = UIButton.Configuration.plain()
        playButtonConfig.image = UIImage(systemName: "play.fill")
        playButtonConfig.baseForegroundColor = .customGray
        playButtonConfig.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        let playButton = UIButton(configuration: playButtonConfig)
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

    func setLayerParams(id: String, name: String, isMute: Bool) {
        self.id = id
        nameLabel.text = name

        var config = setMuteButton.configuration ?? UIButton.Configuration.filled()
        config.image = isMute ? UIImage(systemName: "speaker.slash.fill") : UIImage(systemName: "speaker.fill")
        setMuteButton.configuration = config
    }

    @objc private func play() {
        listener?.playLayer(id: id)
    }

    @objc private func mute() {
        listener?.muteLayer(id: id)
    }

    @objc private func remove() {
        listener?.removeLayer(id: id)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
