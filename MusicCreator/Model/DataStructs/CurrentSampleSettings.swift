//
//  AudioSampleEditor.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 03.11.2023.
//

import Foundation

struct CurrentSampleSettings {
    var id: String? = nil
    var volume: Float = FloatConstants.defaultVolume.rawValue
    var frequency: Float = FloatConstants.defaultFrequency.rawValue

    init(sample: AudioSample) {
        id = sample.id
        volume = sample.volume
        frequency = sample.frequency
    }

    init(id: String? = nil,
         volume: Float = FloatConstants.defaultVolume.rawValue,
         frequency: Float = FloatConstants.defaultFrequency.rawValue) {
        self.id = id
        self.volume = volume
        self.frequency = frequency
    }
}
