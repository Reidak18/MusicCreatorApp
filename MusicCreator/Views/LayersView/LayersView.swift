//
//  LayersView.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 31.10.2023.
//

import UIKit

protocol SampleSelectListener: AnyObject {
    func sampleSelected(id: String?)
}

class LayersView: UITableView {
    weak var sampleSelectListener: SampleSelectListener?
//    private var samples: [AudioSample] = []
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

//    func setSamplesNames(samples: [AudioSample]) {
//        self.samples = samples
//    }

    func setCurrentSession(session: some SessionProtocol) {
        var session = session
        session.updateListener = self
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
              cell.isSelectable()
        else { return }

        sampleSelectListener?.sampleSelected(id: cell.getId())
    }
}

extension LayersView: LayerCellListener {
    func playLayer(id: String, play: Bool) {
        session?.playSample(id: id, play: play)
    }

    func muteLayer(id: String) {
        guard var sample = session?.getSample(id: id)
        else { return }

        sample.setMute(isMute: !sample.isMute)
        session?.updateSample(sample: sample)
        reloadData()
    }

    func removeLayer(id: String) {
        session?.removeSample(id: id)
        reloadData()
    }
}

extension LayersView: SessionUpdateListener {
    func update(samples: [AudioSample]) {
        reloadData()
    }
}
