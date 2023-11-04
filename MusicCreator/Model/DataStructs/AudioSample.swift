//
//  AudioSample.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 02.11.2023.
//

import AVFAudio

struct AudioSample {
    let id: String
    let name: String
    let audioUrl: URL
    let isMicrophone: Bool

    private(set) var volume: Float
    private(set) var frequency: Float
    private(set) var isMute: Bool
    private(set) var isPlaying: Bool

    init(name: String,
         audioUrl: URL,
         isMicrophone: Bool = false,
         volume: Float = FloatConstants.defaultVolume.rawValue,
         frequency: Float = FloatConstants.defaultFrequency.rawValue,
         isMute: Bool = false,
         isPlaying: Bool = false) {
        self.id = UUID().uuidString
        self.name = name
        self.audioUrl = audioUrl
        self.isMicrophone = isMicrophone
        self.volume = isMicrophone ? FloatConstants.maximumVolume.rawValue : volume
        self.frequency = frequency
        self.isMute = isMute
        self.isPlaying = isPlaying
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

    mutating func setIsPlaying(_ isPlaying: Bool) {
        self.isPlaying = isPlaying
    }
}
