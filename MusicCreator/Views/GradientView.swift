//
//  GradientView.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 31.10.2023.
//

import UIKit

class GradientView: UIStackView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        if let gradientLayer = layer as? CAGradientLayer {
            let transparentGradientColor = UIColor.gradientColor.withAlphaComponent(0).cgColor
            gradientLayer.colors = [transparentGradientColor, UIColor.gradientColor.cgColor]
        }
    }

    override open class var layerClass: AnyClass {
       return CAGradientLayer.classForCoder()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}
