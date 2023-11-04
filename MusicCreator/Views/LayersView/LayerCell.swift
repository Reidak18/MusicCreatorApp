//
//  LayerCell.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 31.10.2023.
//

import UIKit

protocol LayerCellListener: AnyObject {
    func setIsPlaying(id: String, isPlaying: Bool)
    func setIsMute(id: String, isMute: Bool)
    func removeLayer(id: String)
}

class LayerCell: UITableViewCell {
    weak var listener: LayerCellListener?
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: FontSize.standart.rawValue)
        return label
    }()
    
    private let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.backgroundColor = .foregroundPrimary
        stack.layer.cornerRadius = CornerRadius.standart.rawValue
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var playButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "play.fill")
        config.baseForegroundColor = .customGray
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        let button = UIButton(configuration: config)
        return button
    }()
    
    private var setMuteButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "speaker.fill")
        config.baseForegroundColor = .customGray
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        let button = UIButton(configuration: config)
        return button
    }()
    
    private var removeButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "xmark",
                               withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
        config.cornerStyle = .medium
        config.baseForegroundColor = .customGray
        config.baseBackgroundColor = .customLightGray
        let button = UIButton(configuration: config)
        return button
    }()
    
    private var sample: AudioSample?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        transform = CGAffineTransformMakeScale(1, -1)
        
        let buttonsStack = UIStackView()
        buttonsStack.axis = .horizontal
        buttonsStack.alignment = .fill
        buttonsStack.distribution = .fillEqually
        
        mainStack.addArrangedSubview(nameLabel)
        
        playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
        buttonsStack.addArrangedSubview(playButton)
        
        setMuteButton.addTarget(self, action: #selector(mute), for: .touchUpInside)
        buttonsStack.addArrangedSubview(setMuteButton)
        
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
        
        listener?.setIsPlaying(id: unwSample.id, isPlaying: !unwSample.isPlaying)
    }
    
    @objc private func mute() {
        guard let unwSample = sample
        else { return }
        
        listener?.setIsMute(id: unwSample.id, isMute: !unwSample.isMute)
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
