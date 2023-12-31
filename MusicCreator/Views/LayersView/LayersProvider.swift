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
    private weak var viewSwitcher: MiddleViewsSwitcher?

    init<Provider: SessionProtocol, Delegate: MiddleViewsSwitcher> (session: Provider, viewSwitcher: Delegate) {
        self.session = session
        self.viewSwitcher = viewSwitcher
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
              let cellId = cell.getId(),
              var sample = session?.getSample(id: cellId)
        else { return }

        sample.setIsPlaying(true)
        session?.updateSample(sample: sample)
        viewSwitcher?.switchButtonClicked(to: .params)
    }
}

extension LayersProvider: LayerCellListener {
    func setIsPlaying(id: String, isPlaying: Bool) {
        guard var sample = session?.getSample(id: id)
        else { return }

        sample.setIsPlaying(isPlaying)
        session?.updateSample(sample: sample)
    }

    func setIsMute(id: String, isMute: Bool) {
        guard var sample = session?.getSample(id: id)
        else { return }

        sample.setMute(isMute)
        session?.updateSample(sample: sample)
    }

    func removeLayer(id: String) {
        session?.removeSample(id: id)
    }
}

extension LayersProvider: SessionUpdateListener {
    func update(id: String, updatedSample: AudioSample?) {
        reloadData?()
    }
}
