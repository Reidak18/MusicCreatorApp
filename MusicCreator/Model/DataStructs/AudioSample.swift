//
//  AudioSample.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 02.11.2023.
//

import AVFAudio

struct AudioSample {
    let id: String = UUID().uuidString
    let name: String
    let audioUrl: URL

    var volume: Float
    var frequency: Float
    var isMute: Bool

    init(name: String, audioUrl: URL, volume: Float = 1, frequency: Float = 1, isMute: Bool = false) {
        self.name = name
        self.audioUrl = audioUrl
        self.volume = volume
        self.frequency = frequency
        self.isMute = isMute
    }

    mutating func setVolume(volume: Float) {
        self.volume = volume
    }

    mutating func setFrequency(frequency: Float) {
        self.frequency = frequency
    }

    mutating func setMute(isMute: Bool) {
        self.isMute = isMute
    }
}
