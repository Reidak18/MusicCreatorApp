//
//  InstrumentButton.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 30.10.2023.
//

import Foundation
import UIKit

protocol SampleTrackSelector {
    func selectSampleFromLibrary(instrument: MusicInstrument, index: Int)
}

class InstrumentButtonView: UIStackView {
    public var selectDelegate: SampleTrackSelector?

    private var samplesNames: [String] = []
    private var associatedInstrument: MusicInstrument?
    private let imageButton = UIButton()
    private let nameLabel = UILabel()
    private let segmentControl = VerticalSegmentedControl()
    private var isOpened = false

    private let buttonImage = UIImage(named: "Ellipse")

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

        imageButton.setBackgroundImage(buttonImage?.withTintColor(.foregroundPrimary), for: .normal)

        imageButton.tintColor = .foregroundPrimary
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (playDefaultSample))
        imageButton.addGestureRecognizer(tapGesture)
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(openInstrumentsList))
        imageButton.addGestureRecognizer(longGesture)
        imageButton.translatesAutoresizingMaskIntoConstraints = false
        addArrangedSubview(imageButton)
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            imageButton.heightAnchor.constraint(equalToConstant: 80),
            imageButton.widthAnchor.constraint(equalTo: imageButton.heightAnchor)
        ])
    }

    func setInstrument(_ instrument: MusicInstrument) {
        associatedInstrument = instrument
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

    func setSamples(samplesNames: [String]) {
        self.samplesNames = samplesNames
    }

    @objc private func playDefaultSample() {
        if isOpened {
            closeSampleList()
            return
        }

        preopenSampleList()

        guard let instrument = associatedInstrument
        else { return }
        selectDelegate?.selectSampleFromLibrary(instrument: instrument, index: 0)
    }

    @objc private func openInstrumentsList() {
        if !isOpened {
            openSampleList()
        }
    }

    private func preopenSampleList() {
        layer.cornerRadius = bounds.width / 2
        backgroundColor = .customLightGreen
        imageButton.setBackgroundImage(buttonImage?.withTintColor(.customLightGreen), for: .normal)

        let labelHeight = nameLabel.frame.height
        let heightConstraint = nameLabel.heightAnchor.constraint(equalToConstant: labelHeight * 2)
        nameLabel.textColor = .clear
        heightConstraint.isActive = true

        let oldFrame = frame
        let newFrame = CGRect(x: frame.minX,
                              y: frame.minY,
                              width: frame.width,
                              height: frame.height + labelHeight)
        UIView.animate(withDuration: 0.25) {
            self.frame = newFrame
            self.layoutIfNeeded()
        } completion: { _ in
            self.nameLabel.removeConstraint(heightConstraint)
            UIView.animate(withDuration: 0.25) {
                self.frame = oldFrame
                self.layoutIfNeeded()
            } completion: { _ in
                self.backgroundColor = .clear
                self.imageButton.setBackgroundImage(self.buttonImage?.withTintColor(.foregroundPrimary), for: .normal)
                self.nameLabel.textColor = .foregroundPrimary
            }
        }
    }

    private func openSampleList() {
        isOpened = true
        layer.cornerRadius = bounds.width / 2
        nameLabel.isHidden = true
        backgroundColor = .customLightGreen
        imageButton.setBackgroundImage(buttonImage?.withTintColor(.customLightGreen), for: .normal)
        segmentControl.setSamples(samples: samplesNames, width: self.bounds.width)
        segmentControl.selectDelegate = self
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
    }

    private func closeSampleList() {
        isOpened = false
        UIView.animate(withDuration: 1) {
            self.segmentControl.isHidden = true
            self.segmentControl.resetSelection()
        } completion: { value in
            self.segmentControl.isHidden = false
            self.segmentControl.removeFromSuperview()

            self.backgroundColor = .clear
            self.imageButton.setBackgroundImage(self.buttonImage?.withTintColor(.foregroundPrimary), for: .normal)
            self.nameLabel.isHidden = false
        }
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension InstrumentButtonView: ItemSelector {
    func select(index: Int) {
        closeSampleList()

        guard let instrument = associatedInstrument
        else { return }

        selectDelegate?.selectSampleFromLibrary(instrument: instrument, index: index)
    }
}
