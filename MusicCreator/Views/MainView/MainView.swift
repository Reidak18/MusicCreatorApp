//
//  MainView.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 02.11.2023.
//

import UIKit

class MainView: UIView {
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

    func setPlayStopper<Stopper: PlayStopper>(stopper: Stopper) {
        paramsView.setPlayStopper(stopper: stopper)
        bottomPanelView.setAudioPlayerSubscribeAdder(adder: stopper)
    }

    func setSlidersChangesListener<T: SlidersChangesListener>(listener: T) {
        paramsView.slidersChangesListener = listener
    }

    func setSwitchViewDelegate<T: MiddleViewsSwitcher>(switcher: T) {
        bottomPanelView.switchViewDelegate = switcher
    }

    func setRecordProviderAndSubscriber<Provider: SessionSamplesProvider,
                                        Subscriber: RecordingStatusSubscriber>(provider: Provider,
                                                                               subscriber: Subscriber) {
        bottomPanelView.setRecordProviderAndSubscriber(provider: provider,
                                                       subscriber: subscriber)
    }

    func setLayersProvider<T1: SessionProtocol, T2: SampleActionDelegate>(session: T1, delegate: T2) {
        let provider = LayersProvider(session: session, sampleActionDelegate: delegate)
        layersView.setProvider(provider)
    }

    func setDatabaseSelector<T: AddSampleListener>(selector: T) {
        topPanelView.setDatabaseSelector(selector: selector)
    }

    func switchView(viewType: CurrentViewType) {
        layersView.isHidden = viewType != .layers
        paramsView.isHidden = viewType != .params
        bottomPanelView.switchView(viewType: viewType)
    }

    func setSlidersParams(volume: Float, frequency: Float) {
        paramsView.setSlidersParams(volume: volume, frequency: frequency)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
