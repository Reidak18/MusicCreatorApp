//
//  ThumbTextSlider.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 30.10.2023.
//

import UIKit

class ThumbTextSlider: UISlider {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = super.trackRect(forBounds: bounds)
        newBounds.size.height = 15
        return newBounds
    }

    func setBackgroundImage(named: String) {
        guard let trackImage = UIImage(named: named)
        else { return }
        self.setMinimumTrackImage(trackImage, for:.normal)
        self.setMaximumTrackImage(trackImage, for:.normal)
    }

    func setThumbLabel(label: String) {
        setThumbImage(createThumbImage(label: label), for: .normal)
    }

    private func createThumbImage(label: String) -> UIImage {
        let thumbView = UIView(frame: CGRect(x: 0, y: 15, width: 72, height: 15))
        thumbView.layer.cornerRadius = 4
        thumbView.backgroundColor = .sliderThumbColor

        let thumbTextLabel: UILabel = UILabel()
        thumbTextLabel.textAlignment = .center
        thumbTextLabel.textColor = .labelPrimary
        thumbTextLabel.text = label
        thumbTextLabel.textColor = .labelPrimary
        thumbTextLabel.font = .systemFont(ofSize: 11)
        thumbView.addSubview(thumbTextLabel)
        thumbTextLabel.frame = thumbView.bounds

        return thumbView.asImage()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

