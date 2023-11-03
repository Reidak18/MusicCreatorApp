//
//  Constants+Extensions.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 30.10.2023.
//

import UIKit

enum StringConstants: String {
    case ShowDisableAlert = "ShowDisableAlert"
}

enum IntConstants: Int {
    case MicroButtonTag = 1000
}

extension UIColor {
    static var backgroundPrimary: UIColor { UIColor(named: "backgroundPrimary") ?? UIColor() }
    static var foregroundPrimary: UIColor { UIColor(named: "foregroundPrimary") ?? UIColor() }
    static var labelPrimary: UIColor { UIColor(named: "labelPrimary") ?? UIColor() }
    static var sliderThumbColor: UIColor { UIColor(named: "sliderThumbColor") ?? UIColor() }
    static var customPurpleColor: UIColor { UIColor(named: "customPurpleColor") ?? UIColor() }
    static var customGray: UIColor { UIColor(named: "customGray") ?? UIColor() }
    static var customLightGray: UIColor { UIColor(named: "customLightGray") ?? UIColor() }
    static var customLightGreen: UIColor { UIColor(named: "customLightGreen") ?? UIColor() }
}
