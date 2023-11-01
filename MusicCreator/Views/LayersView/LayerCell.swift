//
//  LayerCell.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 31.10.2023.
//

import UIKit

class LayerCell: UITableViewCell {
    private let nameLabel = UILabel()

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
        buttonsStack.addArrangedSubview(playButton)

        var setEnableButtonConfig = UIButton.Configuration.plain()
        setEnableButtonConfig.image = UIImage(systemName: "speaker.fill")
        setEnableButtonConfig.baseForegroundColor = .customGray
        setEnableButtonConfig.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        let setEnableButton = UIButton(configuration: setEnableButtonConfig)
        buttonsStack.addArrangedSubview(setEnableButton)

        var removeButtonConfig = UIButton.Configuration.filled()
        removeButtonConfig.image = UIImage(systemName: "xmark",
                                           withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
        removeButtonConfig.cornerStyle = .medium
        removeButtonConfig.baseForegroundColor = .customGray
        removeButtonConfig.baseBackgroundColor = .customLightGray
        let removeButton = UIButton(configuration: removeButtonConfig)
        buttonsStack.addArrangedSubview(removeButton)

        mainStack.addArrangedSubview(buttonsStack)
        contentView.addSubview(mainStack)

        let constraint = mainStack.leadingAnchor.constraint(equalTo: leadingAnchor)
        constraint.priority = UILayoutPriority(999)

        NSLayoutConstraint.activate([
            playButton.widthAnchor.constraint(equalTo: playButton.heightAnchor),
            setEnableButton.widthAnchor.constraint(equalTo: setEnableButton.heightAnchor),
            removeButton.widthAnchor.constraint(equalTo: removeButton.heightAnchor),

            constraint,
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func setName(name: String) {
        nameLabel.text = name
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
