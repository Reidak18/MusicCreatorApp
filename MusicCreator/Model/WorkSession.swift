//
//  WorkSession.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 02.11.2023.
//

import Foundation

protocol SessionUpdateListener {
    func update(samples: [AudioSample])
}

protocol Session {
    func updateSample(sample: AudioSample)
    func addSample(sample: AudioSample)
    func removeSample(id: String)
    func getSample(id: String) -> AudioSample?
    func getSamples() -> [AudioSample]
    func playSample(id: String)
    var updateListener: SessionUpdateListener? { get set }
}

class WorkSession: Session {
    var updateListener: SessionUpdateListener?
    private var samples: Dictionary<String, AudioSample> = [:]
    private let player: AudioPlayer

    init(player: AudioPlayer) {
        self.player = player
    }

    func updateSample(sample: AudioSample) {
        samples[sample.id] = sample
        player.updateSample(sample: sample)
        updateListener?.update(samples: getSamples())
    }

    func addSample(sample: AudioSample) {
        samples[sample.id] = sample
        updateListener?.update(samples: getSamples())
    }

    func removeSample(id: String) {
        if player.getPlayingClipId() == id {
            player.stop()
        }
        samples[id] = nil
        updateListener?.update(samples: getSamples())
    }

    func getSample(id: String) -> AudioSample? {
        return samples[id]
    }

    func getSamples() -> [AudioSample] {
        return Array(samples.values)
    }

    func playSample(id: String) {
        guard let sample = samples[id]
        else { return }
        
        player.play(sample: sample, loop: false)
    }
}
