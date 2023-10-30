//
//  Constants+Extensions.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 30.10.2023.
//

import UIKit

extension UIColor {
    static var backgroundPrimary: UIColor { UIColor(named: "backgroundPrimary") ?? UIColor() }
    static var foregroundPrimary: UIColor { UIColor(named: "foregroundPrimary") ?? UIColor() }
    static var labelPrimary: UIColor { UIColor(named: "labelPrimary") ?? UIColor() }
    static var sliderThumbColor: UIColor { UIColor(named: "sliderThumbColor") ?? UIColor() }
    static var gradientColor: UIColor { UIColor(named: "gradientColor") ?? UIColor() }
}

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
