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
    func removeSample(id: String)
    func getSample(id: String) -> AudioSample?
    func getSamples() -> [AudioSample]
    func playSample(id: String, play: Bool)
    func stop()
    var updateListener: SessionUpdateListener? { get set }
}

class WorkSession: Session {
    var updateListener: SessionUpdateListener?
    private var samples: [AudioSample] = []
    private let player: AudioPlayer

    init(player: AudioPlayer) {
        self.player = player
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
        player.updateSample(sample: sample)
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
        guard let playingId = player.getPlayingClipId(),
              let index = samples.firstIndex(where: { $0.id == playingId })
        else { return }

        samples[index].setIsPlaying(false)
        updateSample(sample: samples[index])
        player.stop()
    }

    private func startPlay(id: String) {
        guard let index = samples.firstIndex(where: { $0.id == id })
        else { return }

        // уже проигрывается этот семпл - ничего не делать
        if id == player.getPlayingClipId() {
            return
        } else {
            // если что-то другое проигрывается - выключаем
            if let plaingId = player.getPlayingClipId(),
               let playingIndex = samples.firstIndex(where: { $0.id == plaingId }) {
                samples[playingIndex].setIsPlaying(false)
                updateSample(sample: samples[playingIndex])
                player.stop()
            }

            // включаем семпл
            samples[index].setIsPlaying(true)
            updateSample(sample: samples[index])
            player.play(sample: samples[index])
        }

        updateListener?.update(samples: getSamples())
    }

    private func stopPlay(id: String) {
        // ничего не проигрывается - ничего не делать
        guard let index = samples.firstIndex(where: { $0.id == id }),
              let playingId = player.getPlayingClipId()
        else { return }

        // если проигрывается другое - ничего не делать
        if id != playingId {
            return
        } else {
            // выключаем семпл
            guard let playingIndex = samples.firstIndex(where: { $0.id == playingId })
            else { return }
            samples[playingIndex].setIsPlaying(false)
            updateSample(sample: samples[playingIndex])
            player.stop()
        }

        updateListener?.update(samples: getSamples())
    }
}
