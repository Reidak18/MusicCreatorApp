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

    func setSamples(samples: [String],
                    width: CGFloat,
                    selectDelegate: ItemSelector?) {
        let samplesNamesProvider = SamplesNamesProvider(samples: samples, selectDelegate: selectDelegate)
        dataSource = samplesNamesProvider
        delegate = samplesNamesProvider
        self.samplesNamesProvider = samplesNamesProvider

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

