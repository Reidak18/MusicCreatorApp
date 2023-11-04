//
//  Constants+Extensions.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 30.10.2023.
//

import UIKit

enum StringConstants: String {
    case microRecordingName = "microphoneRecord_"
    case audioMixRecordingName = "share"
    case createdFilesExtension = ".m4a"
    case showDisableAlert = "ShowDisableAlert"
}

enum IntConstants: Int {
    case microButtonTag = 1000
    case playMixButtonTag = 1001
    case recordButtonTag = 1002
}

enum FloatConstants: Float {
    case minimumVolume = 0
    case maximumVolume = 1
    case defaultVolume = 0.5
    case minimumFrequency = 0.2
    case maximumFrequency = 10
    case defaultFrequency = 2
}

enum Padding: CGFloat {
    case standart = 15
}

enum UIHeight: CGFloat {
    case topButton = 80
    case segmentRow = 60
    case sliderThumb = 15
    case waveform = 50
}

enum CornerRadius: CGFloat {
    case standart = 4
}

enum FontSize: CGFloat {
    case standart = 12
    case title = 16
}

enum Spacing: CGFloat {
    case small = 5
    case standart = 10
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
