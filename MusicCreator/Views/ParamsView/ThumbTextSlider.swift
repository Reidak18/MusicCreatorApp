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
        newBounds.size.height = UIHeight.sliderThumb.rawValue
        return newBounds
    }

    func setBackgroundImage(named: String) {
        guard let trackImage = UIImage(named: named)
        else { return }
        setMinimumTrackImage(trackImage, for:.normal)
        setMaximumTrackImage(trackImage, for:.normal)
    }

    func setThumbLabel(label: String) {
        setThumbImage(createThumbImage(label: label), for: .normal)
    }

    private func createThumbImage(label: String) -> UIImage {
        let thumbView = UIView(frame: CGRect(x: 0,
                                             y: UIHeight.sliderThumb.rawValue,
                                             width: 72,
                                             height: UIHeight.sliderThumb.rawValue))
        thumbView.layer.cornerRadius = CornerRadius.standart.rawValue
        thumbView.backgroundColor = .sliderThumbColor

        let thumbTextLabel: UILabel = UILabel()
        thumbTextLabel.textAlignment = .center
        thumbTextLabel.textColor = .labelPrimary
        thumbTextLabel.text = label
        thumbTextLabel.textColor = .labelPrimary
        thumbTextLabel.font = .systemFont(ofSize: FontSize.standart.rawValue)
        thumbView.addSubview(thumbTextLabel)
        thumbTextLabel.frame = thumbView.bounds

        return thumbView.asImage()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

