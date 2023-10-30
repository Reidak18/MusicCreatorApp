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

        let upperStackView = UIStackView()
        upperStackView.axis = .horizontal
        upperStackView.alignment = .center
        upperStackView.distribution = .equalSpacing
        upperStackView.isLayoutMarginsRelativeArrangement = true
        upperStackView.layoutMargins = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        upperStackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        let guitarButton = InstrumentButton()
        guitarButton.setImage(named: "Guitar",
                              insets: UIEdgeInsets(top: 20, left: 23, bottom: 0, right: 23))
        guitarButton.setTitle(title: "гитара")
        let drumsButton = InstrumentButton()
        drumsButton.setImage(named: "Drums",
                             insets: UIEdgeInsets(top: 23, left: 18, bottom: 23, right: 18))
        drumsButton.setTitle(title: "ударные")
        let windButton = InstrumentButton()
        windButton.setImage(named: "Wind",
                            insets: UIEdgeInsets(top: 26, left: 10, bottom: 24, right: 14))
        windButton.setTitle(title: "духовые")

        upperStackView.addArrangedSubview(guitarButton)
        upperStackView.addArrangedSubview(drumsButton)
        upperStackView.addArrangedSubview(windButton)
        stackView.addArrangedSubview(upperStackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
        ])
    }
}

