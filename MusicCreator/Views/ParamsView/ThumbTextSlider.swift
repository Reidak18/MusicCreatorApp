//
//  ThumbTextSlider.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 30.10.2023.
//

import UIKit

class ThumbTextSlider: UISlider {
    func setThumbLabel(label: String) {
        setThumbImage(createThumbImage(label: label), for: .normal)
    }

    func getThumbHeight() -> CGFloat? {
        return currentThumbImage?.size.height
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
}

