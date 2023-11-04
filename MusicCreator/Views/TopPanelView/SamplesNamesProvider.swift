//
//  SamplesNamesProvider.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 04.11.2023.
//

import UIKit

class SamplesNamesProvider: NSObject {
    private weak var selectDelegate: ItemSelector?
    private let samples: [String]

    init<Delegate: ItemSelector> (samples: [String], selectDelegate: Delegate) {
        self.selectDelegate = selectDelegate
        self.samples = samples
    }

    func getSamplesCount() -> Int {
        return samples.count
    }
}

extension SamplesNamesProvider: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return samples.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SampleCell")
        else { return UITableViewCell() }

        var content = cell.defaultContentConfiguration()
        content.text = samples[indexPath.row]
        content.textProperties.alignment = .center
        content.textProperties.font = .systemFont(ofSize: FontSize.standart.rawValue)
        cell.contentConfiguration = content
        cell.backgroundColor = .clear
        let gradientView = GradientView()
        gradientView.setColors(colors: [UIColor.customLightGreen, UIColor.foregroundPrimary, UIColor.foregroundPrimary, UIColor.customLightGreen])
        cell.selectedBackgroundView = gradientView
        return cell
    }
}

extension SamplesNamesProvider: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectDelegate?.select(index: indexPath.row)
    }
}
