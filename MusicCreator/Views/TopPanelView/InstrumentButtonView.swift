//
//  InstrumentButton.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 30.10.2023.
//

import Foundation
import UIKit

protocol AddSampleListener: AnyObject {
    func addSampleFromLibrary(sample: AudioSample)
}

class InstrumentButtonView: UIStackView {
    weak var selectDelegate: AddSampleListener?
    weak var database: SamplesDatabaseProtocol?
    
    private var associatedInstrument: MusicInstrument?
    private let imageButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "Ellipse")?.withTintColor(.foregroundPrimary), for: .normal)
        button.tintColor = .foregroundPrimary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let nameLabel = UILabel()
    private let segmentControl = VerticalSegmentedControl()

    private var isOpened = false
    private let animDuration = 0.25

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
        spacing = Spacing.standart.rawValue
        translatesAutoresizingMaskIntoConstraints = false

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (playDefaultSample))
        imageButton.addGestureRecognizer(tapGesture)
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(openInstrumentsList))
        imageButton.addGestureRecognizer(longGesture)

        addArrangedSubview(imageButton)
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            imageButton.heightAnchor.constraint(equalToConstant: UIHeight.topButton.rawValue),
            imageButton.widthAnchor.constraint(equalTo: imageButton.heightAnchor)
        ])
    }

    func setDatabase(database: SamplesDatabaseProtocol) {
        self.database = database
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
        nameLabel.font = .systemFont(ofSize: FontSize.title.rawValue)
        addArrangedSubview(nameLabel)
    }

    func loadSamplesNames(instrument: MusicInstrument) {
        guard let samplesNames = database?.getSamples()[instrument, default: []]
        else { return }
        let provider = SamplesNamesProvider(samples: samplesNames, selectDelegate: self)
        segmentControl.setProvider(provider: provider)
    }

    @objc private func playDefaultSample() {
        if isOpened {
            closeSampleList()
            return
        }

        preopenSampleList()

        guard let instrument = associatedInstrument,
              let sample = database?.getSample(instrument: instrument, index: 0)
        else { return }
        selectDelegate?.addSampleFromLibrary(sample: sample)
    }

    @objc private func openInstrumentsList() {
        if !isOpened {
            openSampleList()
        }
    }

    private func preopenSampleList() {
        layer.cornerRadius = bounds.width / 2
        backgroundColor = .customLightGreen
        let buttonImage = UIImage(named: "Ellipse")
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
        UIView.animate(withDuration: animDuration) { [weak self] in
            self?.frame = newFrame
            self?.layoutIfNeeded()
        } completion: { [weak self] _ in
            self?.nameLabel.removeConstraint(heightConstraint)
            UIView.animate(withDuration: self?.animDuration ?? 0) {
                self?.frame = oldFrame
                self?.layoutIfNeeded()
            } completion: { [weak self] _ in
                self?.backgroundColor = .clear
                self?.imageButton.setBackgroundImage(buttonImage?.withTintColor(.foregroundPrimary), for: .normal)
                self?.nameLabel.textColor = .foregroundPrimary
            }
        }
    }

    private func openSampleList() {
        isOpened = true
        layer.cornerRadius = bounds.width / 2
        nameLabel.isHidden = true
        backgroundColor = .customLightGreen
        imageButton.setBackgroundImage(UIImage(named: "Ellipse")?.withTintColor(.customLightGreen), for: .normal)
        segmentControl.setWidth(width: bounds.width)
        addArrangedSubview(segmentControl)
        layoutIfNeeded()

        let newFrame = CGRect(x: frame.minX,
                              y: frame.minY,
                              width: frame.width,
                              height: frame.height + segmentControl.frame.height)
        UIView.animate(withDuration: 1) { [weak self] in
            self?.frame = newFrame
            self?.layoutIfNeeded()
        }
    }

    private func closeSampleList() {
        isOpened = false
        UIView.animate(withDuration: 1) { [weak self] in
            self?.segmentControl.isHidden = true
            self?.segmentControl.resetSelection()
        } completion: { [weak self] value in
            self?.segmentControl.isHidden = false
            self?.segmentControl.removeFromSuperview()

            self?.backgroundColor = .clear
            self?.imageButton.setBackgroundImage(UIImage(named: "Ellipse")?.withTintColor(.foregroundPrimary), for: .normal)
            self?.nameLabel.isHidden = false
        }
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension InstrumentButtonView: ItemSelector {
    func select(index: Int) {
        closeSampleList()

        guard let instrument = associatedInstrument,
              let sample = database?.getSample(instrument: instrument, index: index)
        else { return }

        selectDelegate?.addSampleFromLibrary(sample: sample)
    }
}
