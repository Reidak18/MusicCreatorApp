//
//  SamplePicker.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 31.10.2023.
//

import UIKit

protocol ItemSelector: AnyObject {
    func select(index: Int)
}

class VerticalSegmentedControl: UITableView {
    weak var selectDelegate: ItemSelector?
    private var samples: [String] = []

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)

        setupView()
    }

    private func setupView() {
        register(UITableViewCell.self, forCellReuseIdentifier: "SampleCell")
        dataSource = self
        delegate = self
        isScrollEnabled = false
        separatorStyle = .none
        rowHeight = UIHeight.segmentRow.rawValue
        backgroundColor = .clear
    }

    func setSamples(samples: [String], width: CGFloat) {
        self.samples = samples
        let height = CGFloat(CGFloat(samples.count) * UIHeight.segmentRow.rawValue) + UIHeight.segmentRow.rawValue / 2
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }

    func resetSelection() {
        for cell in visibleCells {
            cell.setSelected(false, animated: true)
        }

        reloadData()
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

extension VerticalSegmentedControl: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectDelegate?.select(index: indexPath.row)
    }
}

