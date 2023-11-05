//
//  WorkSession.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 02.11.2023.
//

import Foundation

protocol SessionUpdateListener: AnyObject {
    func update(id: String, updatedSample: AudioSample?)
}

protocol SessionSamplesProvider: AnyObject {
    func getSamples() -> [AudioSample]
    func subscribeForUpdates<Listener: SessionUpdateListener>(_ listener: Listener)
}

protocol SessionProtocol: SessionSamplesProvider, AudioPlayerStateListener {
    func updateSample(sample: AudioSample)
    func removeSample(id: String)
    func getSample(id: String) -> AudioSample?
}

class WorkSession: SessionProtocol {
    private var listeners: [SessionUpdateListener] = []
    private var samples: [AudioSample] = []

    func updateSample(sample: AudioSample) {
        if let index = samples.firstIndex(where: { $0.id == sample.id }) {
            if samples[index] != sample {
                samples[index] = sample
                notifyListeners(id: sample.id, updatedSample: sample)
            }
        }
        else {
            samples.append(sample)
            notifyListeners(id: sample.id, updatedSample: sample)
        }
    }

    func removeSample(id: String) {
        guard let index = samples.firstIndex(where: { $0.id == id })
        else { return }
        
        samples.remove(at: index)
        notifyListeners(id: id, updatedSample: nil)
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

    private func notifyListeners(id: String, updatedSample: AudioSample?) {
        for listener in listeners {
            listener.update(id: id, updatedSample: updatedSample)
        }
    }
}

// AudioPlayerStateListener
extension WorkSession {
    func onStateChanged(oldId: String?, newSample: AudioSample?) {
        if let id = oldId,
           let index = samples.firstIndex(where: { $0.id == id }),
           samples[index].isPlaying {
            samples[index].setIsPlaying(false)
            notifyListeners(id: id, updatedSample: samples[index])
        }

        if let id = newSample?.id,
           let index = samples.firstIndex(where: { $0.id == id }),
           !samples[index].isPlaying {
            samples[index].setIsPlaying(true)
            notifyListeners(id: id, updatedSample: samples[index])
        }
    }
}
