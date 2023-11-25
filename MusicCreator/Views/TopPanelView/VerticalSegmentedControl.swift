//
//  SamplePicker.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 31.10.2023.
//

import UIKit

class VerticalSegmentedControl: UITableView {
    private var samplesNamesProvider: SamplesNamesProvider?

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)

        setupView()
    }

    private func setupView() {
        register(UITableViewCell.self, forCellReuseIdentifier: "SampleCell")
        isScrollEnabled = false
        separatorStyle = .none
        rowHeight = UIHeight.segmentRow.rawValue
        backgroundColor = .clear
    }

    func setProvider(provider: SamplesNamesProvider) {
        dataSource = provider
        delegate = provider
        self.samplesNamesProvider = provider

        let height = CGFloat(CGFloat(provider.getSamplesCount()) * UIHeight.segmentRow.rawValue) + UIHeight.segmentRow.rawValue / 2
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    func setWidth(width: CGFloat) {
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }

    func resetSelection() {
        for cell in visibleCells {
            cell.setSelected(false, animated: true)
        }

        reloadData()
    }

    func setTableIsHidden(isHidden: Bool) {
        dataSource = isHidden ? nil : samplesNamesProvider
        reloadData()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

