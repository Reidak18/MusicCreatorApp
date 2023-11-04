//
//  MainView.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 02.11.2023.
//

import UIKit

class MainView: UIView {
    var playStopper: PlayStopper? {
        didSet {
            paramsView.playStopper = playStopper
        }
    }
    var mixTrackPlayer: MixTrackPlayer? {
        didSet {
            bottomPanelView.mixTrackPlayer = mixTrackPlayer
        }
    }
    public var switchViewDelegate: MiddleViewsSwitcher? {
        didSet {
            bottomPanelView.switchViewDelegate = switchViewDelegate
        }
    }
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
    public var addMicrophoneRecordSubscriber: AddMicrophoneRecordListener? {
        didSet {
            bottomPanelView.addMicrophoneRecordSubscriber = addMicrophoneRecordSubscriber
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

    private func setupView() {
        stackView.axis = .vertical
        stackView.backgroundColor = .backgroundPrimary
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        addSubview(topPanelView)

        backgroundView.setColors(colors: [UIColor.clear, UIColor.customPurpleColor])
        backgroundView.addArrangedSubview(paramsView)
        layersView.isHidden = true
        backgroundView.addArrangedSubview(layersView)
        stackView.addArrangedSubview(backgroundView)
        stackView.addArrangedSubview(bottomPanelView)
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            topPanelView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            topPanelView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Padding.standart.rawValue),
            topPanelView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Padding.standart.rawValue),

            backgroundView.heightAnchor.constraint(equalTo: backgroundView.widthAnchor, multiplier: 1.35),
            stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Padding.standart.rawValue),
            stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Padding.standart.rawValue),
        ])
    }

    func setSamples(samplesNames: Dictionary<MusicInstrument, [String]>) {
        topPanelView.setSamples(samplesNames: samplesNames)
    }

    func setWaveform(url: URL?) {
        self.bottomPanelView.setWaveform(url: url)
    }

    func setWaveformProgress(progress: Float) {
        DispatchQueue.main.async {
            self.bottomPanelView.setWaveformProgress(progress: progress)
        }
    }

    func setLayersProvider<T1: SessionProtocol, T2: SampleActionDelegate>(session: T1, delegate: T2) {
        let provider = LayersProvider(session: session, sampleActionDelegate: delegate)
        layersView.setProvider(provider)
    }

    func switchView(viewType: CurrentViewType) {
        layersView.isHidden = viewType != .layers
        paramsView.isHidden = viewType != .params
        bottomPanelView.switchView(viewType: viewType)
    }

    func setSlidersParams(volume: Float, frequency: Float) {
        paramsView.setSlidersParams(volume: volume, frequency: frequency)
    }

    func disableAll(exceptTag: Int) {
        for subview in getAllSubviews(types: [UIControl.self, UITableViewCell.self]) {
            if subview.tag != exceptTag {
                if let control = subview as? UIControl {
                    control.isEnabled = false
                } else if let cell = subview as? UITableViewCell {
                    cell.isUserInteractionEnabled = false
                }
            }
        }
    }

    // все кнопки всегда доступны, так что можно просто включить все
    func enableAll() {
        for subview in getAllSubviews(types: [UIControl.self, UITableViewCell.self]) {
            if let control = subview as? UIControl {
                control.isEnabled = true
            } else if let cell = subview as? UITableViewCell {
                cell.isUserInteractionEnabled = true
            }
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
