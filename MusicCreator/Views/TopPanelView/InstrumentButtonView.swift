//
//  InstrumentButton.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 30.10.2023.
//

import Foundation
import UIKit

class InstrumentButtonView: UIStackView {
    // ToDo: сделать ленивыми?
    private let imageButton = UIButton()
    private let nameLabel = UILabel()
    private let segmentControl = VerticalSegmentedControl()
    private var isOpened = false

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
        imageButton.addTarget(self, action: #selector(openSampleList), for: .touchUpInside)
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
        nameLabel.text = title
        nameLabel.textColor = .foregroundPrimary
        nameLabel.textAlignment = .center
        addArrangedSubview(nameLabel)
    }

    @objc private func openSampleList() {
        isOpened.toggle()
        if isOpened {
            layer.cornerRadius = bounds.width / 2
            nameLabel.isHidden = true
            backgroundColor = .customLightGreen
            imageButton.tintColor = .clear
            segmentControl.setSamples(samples: ["cемпл 1", "cемпл 2", "cемпл 3"], width: self.bounds.width)
            addArrangedSubview(self.segmentControl)
            layoutIfNeeded()
            
            let newFrame = CGRect(x: frame.minX,
                                  y: frame.minY,
                                  width: frame.width,
                                  height: frame.height + segmentControl.frame.height)
            UIView.animate(withDuration: 1) {
                self.frame = newFrame
                self.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 1) {
                self.segmentControl.isHidden = true
                self.segmentControl.resetSelection()
            } completion: { value in
                self.segmentControl.isHidden = false
                self.segmentControl.removeFromSuperview()

                self.backgroundColor = .clear
                self.imageButton.tintColor = .foregroundPrimary
                self.nameLabel.isHidden = false
            }
        }
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}
