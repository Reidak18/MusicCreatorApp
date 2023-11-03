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

protocol SessionProtocol {
    func updateSample(sample: AudioSample)
    func removeSample(id: String)
    func getSample(id: String) -> AudioSample?
    func getSamples() -> [AudioSample]
    func playSample(id: String, play: Bool)
    func stop()
    var updateListener: SessionUpdateListener? { get set }
}

class WorkSession: SessionProtocol {
    var updateListener: SessionUpdateListener?
    private var samples: [AudioSample] = []
    private var player: AudioPlayerProtocol

    init(player: AudioPlayerProtocol) {
        self.player = player
        self.player.audioStopSubscriber = self
    }

    func updateSample(sample: AudioSample) {
        defer {
            updateListener?.update(samples: getSamples())
        }

        guard let index = samples.firstIndex(where: { $0.id == sample.id })
        else {
            samples.append(sample)
            return
        }
        samples[index] = sample
    }

    func removeSample(id: String) {
        guard let index = samples.firstIndex(where: { $0.id == id })
        else { return }

        if player.getPlayingClipId() == id {
            player.stop()
        }
        samples.remove(at: index)
        updateListener?.update(samples: getSamples())
    }

    func getSample(id: String) -> AudioSample? {
        guard let index = samples.firstIndex(where: { $0.id == id })
        else { return nil }

        return samples[index]
    }

    func getSamples() -> [AudioSample] {
        return samples
    }

    func playSample(id: String, play: Bool) {
        // если нужно включить
        if play {
            startPlay(id: id)
        } else { // если надо выключить
            stopPlay(id: id)
        }
    }

    func stop() {
        player.stop()
    }

    private func startPlay(id: String) {
        guard let index = samples.firstIndex(where: { $0.id == id })
        else { return }

        // уже проигрывается этот семпл - ничего не делать
        if id == player.getPlayingClipId() {
            return
        } else {
            // включаем семпл
            samples[index].setIsPlaying(true)
            updateSample(sample: samples[index])
            player.play(sample: samples[index])
        }

        updateListener?.update(samples: getSamples())
    }

    private func stopPlay(id: String) {
        // ничего не проигрывается - ничего не делать
        guard let playingId = player.getPlayingClipId()
        else { return }

        // если проигрывается другое - ничего не делать
        if id != playingId {
            return
        } else {
            // выключаем семпл
            player.stop()
        }

        updateListener?.update(samples: getSamples())
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
