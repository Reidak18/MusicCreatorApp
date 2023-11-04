//
//  Constants+Extensions.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 30.10.2023.
//

import UIKit

enum StringConstants: String {
    case MicroRecordingName = "microphoneRecord_"
    case AudioMixRecordingName = "share"
    case CreatedFilesExtension = ".m4a"
    case ShowDisableAlert = "ShowDisableAlert"
}

enum IntConstants: Int {
    case MicroButtonTag = 1000
    case PlayMixButtonTag = 1001
    case RecordButtonTag = 1002
}

enum FloatConstants: Float {
    case minimumVolume = 0
    case maximumVolume = 1
    case defaultVolume = 0.5
    case minimumFrequency = 0.2
    case maximumFrequency = 10
    case defaultFrequency = 2
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
