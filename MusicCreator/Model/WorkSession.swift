//
//  WorkSession.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 02.11.2023.
//

import Foundation

protocol SessionUpdateListener: AnyObject {
    func update(samples: [AudioSample])
}

protocol SessionProtocol: AnyObject {
    func updateSample(sample: AudioSample)
    func removeSample(id: String)
    func getSample(id: String) -> AudioSample?
    func getSamples() -> [AudioSample]
    func subscribeForUpdates<Listener>(_ listener: Listener) where Listener: SessionUpdateListener
}

class WorkSession: SessionProtocol {
    private var listeners: [SessionUpdateListener] = []
    private var samples: [AudioSample] = []
    private var player: AudioPlayerProtocol

    init(player: AudioPlayerProtocol) {
        self.player = player
        self.player.audioStopSubscriber = self
    }

    func updateSample(sample: AudioSample) {
        if let index = samples.firstIndex(where: { $0.id == sample.id }) {
            samples[index] = sample
        }
        else {
            samples.append(sample)
        }
        notifyListeners()
    }

    func removeSample(id: String) {
        guard let index = samples.firstIndex(where: { $0.id == id })
        else { return }
        
        samples.remove(at: index)
        notifyListeners()
    }

    func getSample(id: String) -> AudioSample? {
        guard let index = samples.firstIndex(where: { $0.id == id })
        else { return nil }

        return samples[index]
    }

    func getSamples() -> [AudioSample] {
        return samples
    }

    func subscribeForUpdates<Listener>(_ listener: Listener) where Listener: SessionUpdateListener {
        listeners.append(listener)
    }

    private func notifyListeners() {
        for listener in listeners {
            listener.update(samples: samples)
        }
    }
}

extension WorkSession: AudioStopListener {
    func stopPlaying(id: String) {
        guard let index = samples.firstIndex(where: { $0.id == id })
        else { return }

        samples[index].setIsPlaying(false)
        updateSample(sample: samples[index])
    }
}
