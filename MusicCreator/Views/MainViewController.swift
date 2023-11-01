//
//  ViewController.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 30.10.2023.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController {
    let paramsView = ParamsView()
    let layersView = LayersView()
    let bottomPanelView = BottomPanelView()

    override func loadView() {
        super.loadView()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.backgroundColor = .backgroundPrimary
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        let topPanelView = TopPanelView()
        view.addSubview(topPanelView)

        let backgroundView = GradientView()
        backgroundView.setColors(colors: [UIColor.clear, UIColor.customPurpleColor])
        backgroundView.addArrangedSubview(paramsView)
        layersView.setSamplesNames(samples: [Sample(name: "Гитара"), Sample(name: "Ударные"), Sample(name: "Духовые")])
        layersView.isHidden = true
        backgroundView.addArrangedSubview(layersView)
        stackView.addArrangedSubview(backgroundView)

        bottomPanelView.delegate = self
        stackView.addArrangedSubview(bottomPanelView)

        NSLayoutConstraint.activate([
            topPanelView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topPanelView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            topPanelView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),

            backgroundView.heightAnchor.constraint(equalTo: backgroundView.widthAnchor, multiplier: 1.35),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
        ])
    }
}

extension MainViewController: StylesWindowOpener {
    func openStylesWindow(viewType: CurrentViewType) {
        layersView.isHidden = viewType != .layers
        paramsView.isHidden = viewType != .params
    }
}
