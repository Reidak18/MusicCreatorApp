//
//  TopPanelView.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 30.10.2023.
//

import UIKit

class TopPanelView: UIStackView {
    private var databaseFactory: SamplesDatabaseFactoryProtocol = SamplesDatabaseFactory()
    private lazy var database: SamplesDatabaseProtocol = databaseFactory.getDatabase()

    private let guitarButton: InstrumentButtonView = {
        let button = InstrumentButtonView()
        button.setInstrument(.guitar)
        button.setImage(named: "Guitar",
                        insets: UIEdgeInsets(top: 20, left: 23, bottom: 0, right: 23))
        button.setTitle(title: "гитара")
        return button
    }()
    private let drumsButton: InstrumentButtonView = {
        let button = InstrumentButtonView()
        button.setInstrument(.drums)
        button.setImage(named: "Drums",
                        insets: UIEdgeInsets(top: 23, left: 18, bottom: 23, right: 18))
        button.setTitle(title: "ударные")
        return button
    }()
    private let windButton: InstrumentButtonView = {
        let button = InstrumentButtonView()
        button.setInstrument(.wind)
        button.setImage(named: "Wind",
                        insets: UIEdgeInsets(top: 26, left: 10, bottom: 24, right: 14))
        button.setTitle(title: "духовые")
        return button
    }()

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

        addArrangedSubview(guitarButton)
        addArrangedSubview(drumsButton)
        addArrangedSubview(windButton)

        loadSamplesFromDatabase(samplesNames: database.getSamples())
    }

    private func loadSamplesFromDatabase(samplesNames: Dictionary<MusicInstrument, [String]>) {
        for instrument in samplesNames.keys {
            switch instrument {
            case .guitar:
                guitarButton.setDatabase(database: database)
                guitarButton.loadSamplesNames(instrument: instrument)
            case .drums:
                drumsButton.setDatabase(database: database)
                drumsButton.loadSamplesNames(instrument: instrument)
            case .wind:
                windButton.setDatabase(database: database)
                windButton.loadSamplesNames(instrument: instrument)
            }
        }
    }

    func setDatabaseSelector<T: AddSampleListener>(selector: T) {
        guitarButton.selectDelegate = selector
        drumsButton.selectDelegate = selector
        windButton.selectDelegate = selector
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}
