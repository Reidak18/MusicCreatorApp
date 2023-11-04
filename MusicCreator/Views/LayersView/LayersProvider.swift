//
//  LayersProvider.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 05.11.2023.
//

import UIKit

class LayersProvider: NSObject {
    var reloadData: (() -> Void)?
    private weak var session: SessionProtocol?
    private weak var sampleActionDelegate: SampleActionDelegate?

    init(session: SessionProtocol, sampleActionDelegate: SampleActionDelegate) {
        self.session = session
        self.sampleActionDelegate = sampleActionDelegate
        super.init()
        session.subscribeForUpdates(self)
    }
}

extension LayersProvider: UITableViewDataSource {
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

extension LayersProvider: UITableViewDelegate {
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

extension LayersProvider: LayerCellListener {
    func setIsPlaying(id: String, isPlaying: Bool) {
        sampleActionDelegate?.setIsPlaying(id: id, isPlaying: isPlaying)
    }

    func setIsMute(id: String, isMute: Bool) {
        sampleActionDelegate?.setIsMute(id: id, isMute: isMute)
    }

    func removeLayer(id: String) {
        sampleActionDelegate?.removeSample(id: id)
    }
}

extension LayersProvider: SessionUpdateListener {
    func update(samples: [AudioSample]) {
        reloadData?()
    }
}