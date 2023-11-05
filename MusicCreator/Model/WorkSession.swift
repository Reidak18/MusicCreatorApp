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

protocol SessionProtocol: AnyObject, AudioPlayerStateListener {
    func updateSample(sample: AudioSample)
    func removeSample(id: String)
    func getSample(id: String) -> AudioSample?
    func getSamples() -> [AudioSample]
    func subscribeForUpdates<Listener: SessionUpdateListener>(_ listener: Listener)
}

class WorkSession: SessionProtocol {
    private var listeners: [SessionUpdateListener] = []
    private var samples: [AudioSample] = []

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

    func subscribeForUpdates<Listener: SessionUpdateListener>(_ listener: Listener) {
        listeners.append(listener)
    }

    private func notifyListeners() {
        for listener in listeners {
            listener.update(samples: samples)
        }
    }

    func onStateChanged(oldId: String?, newSample: AudioSample?) {
        if let id = oldId,
           let index = samples.firstIndex(where: { $0.id == id }) {
            samples[index].setIsPlaying(false)
        }

        if let id = newSample?.id,
           let index = samples.firstIndex(where: { $0.id == id }) {
            samples[index].setIsPlaying(true)
        }

        notifyListeners()
    }
}
