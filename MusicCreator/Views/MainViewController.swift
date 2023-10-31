//
//  ViewController.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 30.10.2023.
//

import UIKit

class MainViewController: UIViewController {
    override func loadView() {
        super.loadView()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.backgroundColor = .backgroundPrimary
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        let topPanelView = TopPanelView()
        view.addSubview(topPanelView)

        let paramsView = ParamsView()
//        paramsView.setSamplesNames(samples: [Sample(name: "Гитара"), Sample(name: "Ударные"), Sample(name: "Духовые")])
        let backgroundView = GradientView()
        backgroundView.setColors(colors: [UIColor.clear, UIColor.customPurpleColor])
        backgroundView.addArrangedSubview(paramsView)
        stackView.addArrangedSubview(backgroundView)

        let bottomPanelView = BottomPanelView()
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

