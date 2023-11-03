//
//  AudioSampleEditor.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 03.11.2023.
//

import Foundation

struct CurrentSampleSettings {
    var id: String? = nil
    var volume: Float = 0.5
    var frequency: Float = 2

    init(sample: AudioSample) {
        id = sample.id
        volume = sample.volume
        frequency = sample.frequency
    }

    init(id: String? = nil, volume: Float = 0.5, frequency: Float = 2) {
        self.id = id
        self.volume = volume
        self.frequency = frequency
    }
}
