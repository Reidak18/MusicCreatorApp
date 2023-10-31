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
        stackView.addArrangedSubview(topPanelView)
        let paramsView = ParamsView()
        stackView.addArrangedSubview(paramsView)
        let bottomPanelView = BottomPanelView()
        stackView.addArrangedSubview(bottomPanelView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
        ])
    }
}

