//
//  MainView.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 02.11.2023.
//

import UIKit

class MainView: UIView {
    public var selectSampleDelegate: SampleTrackSelector? {
        didSet {
            topPanelView.selectDelegate = selectSampleDelegate
        }
    }
    public var slidersChangesListener: SlidersChangesListener? {
        didSet {
            paramsView.slidersChangesListener = slidersChangesListener
        }
    }

    private let stackView = UIStackView()

    private let topPanelView = TopPanelView()

    private let backgroundView = GradientView()
    private let paramsView = ParamsView()
    private let layersView = LayersView()

    private let bottomPanelView = BottomPanelView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setConstraints()
    }

    func setupView() {
        stackView.axis = .vertical
        stackView.backgroundColor = .backgroundPrimary
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        addSubview(topPanelView)

        backgroundView.setColors(colors: [UIColor.clear, UIColor.customPurpleColor])
        backgroundView.addArrangedSubview(paramsView)
        layersView.setSamplesNames(samples: [Sample(name: "Гитара"), Sample(name: "Ударные"), Sample(name: "Духовые")])
        layersView.isHidden = true
        backgroundView.addArrangedSubview(layersView)
        stackView.addArrangedSubview(backgroundView)

        bottomPanelView.switchViewDelegate = self
        stackView.addArrangedSubview(bottomPanelView)
    }

    func setConstraints() {
        NSLayoutConstraint.activate([
            topPanelView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            topPanelView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            topPanelView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15),

            backgroundView.heightAnchor.constraint(equalTo: backgroundView.widthAnchor, multiplier: 1.35),
            stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15),
            stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
        ])
    }

    func getWaveformFrame() -> CGRect {
        return bottomPanelView.getWaveformFrame()
    }

    func setWaveformParams(background: UIImage) {
        DispatchQueue.main.async {
            self.bottomPanelView.setWaveformParams(background: background)
        }
    }

    func setWaveformProgress(progress: Float) {
        DispatchQueue.main.async {
            self.bottomPanelView.setWaveformProgress(progress: progress)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension MainView: StylesWindowOpener {
    func openStylesWindow(viewType: CurrentViewType) {
        layersView.isHidden = viewType != .layers
        paramsView.isHidden = viewType != .params
    }
}
