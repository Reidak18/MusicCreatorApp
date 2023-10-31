//
//  SamplePicker.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 31.10.2023.
//

import UIKit

class VerticalSegmentedControl: UITableView {
    private var samples: [String] = []

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)

        setupView()
    }

    private func setupView() {
        register(UITableViewCell.self, forCellReuseIdentifier: "SampleCell")
        dataSource = self
        isScrollEnabled = false
        separatorStyle = .none
        rowHeight = 60
        backgroundColor = .clear
    }

    func setSamples(samples: [String], width: CGFloat) {
        self.samples = samples
        heightAnchor.constraint(equalToConstant: CGFloat(samples.count * 60) + 30).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension VerticalSegmentedControl: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return samples.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SampleCell")
        else { return UITableViewCell() }

        var content = cell.defaultContentConfiguration()
        content.text = samples[indexPath.row]
        content.textProperties.font = .systemFont(ofSize: 12)
        cell.contentConfiguration = content
        cell.backgroundColor = .clear
        let gradientView = GradientView()
        gradientView.setColors(colors: [UIColor.customLightGreen, UIColor.foregroundPrimary, UIColor.foregroundPrimary, UIColor.customLightGreen])
        cell.selectedBackgroundView = gradientView
        return cell
    }
}

