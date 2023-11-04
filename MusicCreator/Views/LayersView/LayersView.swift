//
//  LayersView.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 31.10.2023.
//

import UIKit

protocol SampleActionDelegate: AnyObject {
    func setIsPlaying(id: String, isPlaying: Bool)
    func setIsMute(id: String, isMute: Bool)
    func removeSample(id: String)
    func selectSample(id: String)
}

class LayersView: UITableView {
    private var layersProvider: LayersProvider?

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)

        setupView()
    }

    private func setupView() {
        backgroundColor = .clear
        transform = CGAffineTransformMakeScale(1, -1)
        register(LayerCell.self, forCellReuseIdentifier: "LayerCell")
        alwaysBounceVertical = false
        separatorStyle = .none
        translatesAutoresizingMaskIntoConstraints = false
    }

    func setProvider(_ provider: LayersProvider) {
        dataSource = provider
        delegate = provider
        provider.reloadData = reloadData
        layersProvider = provider
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
