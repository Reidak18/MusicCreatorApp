//
//  AudioSampleEditor.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 03.11.2023.
//

import Foundation

class AudioSampleEditor {
    private var current: AudioSample?

    func setAudioSample(_ sample: AudioSample?) {
        current = sample
    }

    func setIsPlaying(isPlaying: Bool) {
        current?.setIsPlaying(isPlaying)
    }
    
    func setVolume(volume: Float) {
        current?.setVolume(volume: volume)
    }

    func setFrequency(frequency: Float) {
        current?.setFrequency(frequency: frequency)
    }

    func getAudioSample() -> AudioSample? {
        return current
    }
}
