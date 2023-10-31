//
//  GradientView.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 31.10.2023.
//

import UIKit

class GradientView: UIStackView {
    func setColors(colors: [UIColor]) {
        if let gradientLayer = layer as? CAGradientLayer {
            gradientLayer.colors = colors.map({ $0.cgColor })
        }
    }

    override open class var layerClass: AnyClass {
       return CAGradientLayer.classForCoder()
    }
}
