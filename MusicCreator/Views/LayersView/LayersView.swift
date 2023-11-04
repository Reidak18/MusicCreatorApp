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
    weak var sampleActionDelegate: SampleActionDelegate?
    private weak var session: SessionProtocol?

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)

        setupView()
    }

    private func setupView() {
        backgroundColor = .clear
        transform = CGAffineTransformMakeScale(1, -1)
        register(LayerCell.self, forCellReuseIdentifier: "LayerCell")
        alwaysBounceVertical = false
        dataSource = self
        delegate = self
        separatorStyle = .none
        translatesAutoresizingMaskIntoConstraints = false
    }

    func setCurrentSession(session: some SessionProtocol) {
        session.subscribeForUpdates(self)
        self.session = session
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension LayersView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let samples = session?.getSamples()
        else { return 0 }

        return samples.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LayerCell", for: indexPath) as? LayerCell,
              let sample = session?.getSamples().reversed()[indexPath.row]
        else { return LayerCell() }

        cell.setLayerSample(sample: sample)
        cell.listener = self
        return cell
    }
}

extension LayersView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIHeight.segmentRow.rawValue
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? LayerCell,
              cell.isSelectable(),
              let cellId = cell.getId()
        else { return }

        sampleActionDelegate?.selectSample(id: cellId)
    }
}

extension LayersView: LayerCellListener {
    func setIsPlaying(id: String, isPlaying: Bool) {
        sampleActionDelegate?.setIsPlaying(id: id, isPlaying: isPlaying)
    }

    func setIsMute(id: String, isMute: Bool) {
        sampleActionDelegate?.setIsMute(id: id, isMute: isMute)
        reloadData()
    }

    func removeLayer(id: String) {
        sampleActionDelegate?.removeSample(id: id)
        reloadData()
    }
}

extension LayersView: SessionUpdateListener {
    func update(samples: [AudioSample]) {
        reloadData()
    }
}
