//
//  LayersView.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 31.10.2023.
//

import UIKit

struct Sample {
    let name: String
}

class LayersView: UITableView {
    let samples: [Sample] = [Sample(name: "Гитара"), Sample(name: "Ударные"), Sample(name: "Духовые")]

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)

        setupView()
    }

    private func setupView() {
        backgroundColor = .clear
        transform = CGAffineTransformMakeScale(1, -1)
        register(LayerCell.self, forCellReuseIdentifier: "LayerCell")
        alwaysBounceVertical = false
        isScrollEnabled = false
        dataSource = self
        delegate = self
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension LayersView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        samples.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LayerCell", for: indexPath) as? LayerCell
        else { return LayerCell() }

        cell.setName(name: samples[indexPath.row].name)
        return cell
    }
}

extension LayersView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50 + 10
    }
}
