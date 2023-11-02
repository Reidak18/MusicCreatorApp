//
//  TopPanelView.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 30.10.2023.
//

import UIKit

class TopPanelView: UIStackView {
    public var selectDelegate: SampleTrackSelector? {
        didSet {
            guitarButton.selectDelegate = selectDelegate
            drumsButton.selectDelegate = selectDelegate
            windButton.selectDelegate = selectDelegate
        }
    }

    private let guitarButton = InstrumentButtonView()
    private let drumsButton = InstrumentButtonView()
    private let windButton = InstrumentButtonView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    private func setupView() {
        axis = .horizontal
        alignment = .top
        distribution = .equalSpacing
        isLayoutMarginsRelativeArrangement = true
        translatesAutoresizingMaskIntoConstraints = false

        guitarButton.setInstrument(.guitar)
        guitarButton.setImage(named: "Guitar",
                              insets: UIEdgeInsets(top: 20, left: 23, bottom: 0, right: 23))
        guitarButton.setTitle(title: "гитара")
        drumsButton.setInstrument(.drums)
        drumsButton.setImage(named: "Drums",
                             insets: UIEdgeInsets(top: 23, left: 18, bottom: 23, right: 18))
        drumsButton.setTitle(title: "ударные")
        windButton.setInstrument(.wind)
        windButton.setImage(named: "Wind",
                            insets: UIEdgeInsets(top: 26, left: 10, bottom: 24, right: 14))
        windButton.setTitle(title: "духовые")

        addArrangedSubview(guitarButton)
        addArrangedSubview(drumsButton)
        addArrangedSubview(windButton)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}
