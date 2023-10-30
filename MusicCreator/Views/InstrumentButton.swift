//
//  InstrumentButton.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 30.10.2023.
//

import Foundation
import UIKit

class InstrumentButton: UIStackView {
    private let imageButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setConstraints()
    }

    private func setupView() {
        axis = .vertical
        backgroundColor = .clear
        alignment = .center
        distribution = .equalSpacing
        spacing = 8
        translatesAutoresizingMaskIntoConstraints = false

        imageButton.setBackgroundImage(UIImage(systemName: "circle.fill"), for: .normal)

        imageButton.tintColor = .foregroundPrimary
        imageButton.translatesAutoresizingMaskIntoConstraints = false
        addArrangedSubview(imageButton)
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            imageButton.heightAnchor.constraint(equalToConstant: 80),
            imageButton.widthAnchor.constraint(equalTo: imageButton.heightAnchor)
        ])
    }

    func setImage(named: String, insets: UIEdgeInsets) {
        imageButton.setImage(UIImage(named: named), for: .normal)
        imageButton.imageEdgeInsets = insets
    }

    func setTitle(title: String) {
        let nameLabel = UILabel()
        nameLabel.text = title
        nameLabel.textColor = .foregroundPrimary
        nameLabel.textAlignment = .center
        addArrangedSubview(nameLabel)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}
