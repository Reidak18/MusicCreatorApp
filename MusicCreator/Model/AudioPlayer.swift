//
//  AudioPlayer.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 02.11.2023.
//

import AVFoundation

protocol AudioProgressListener: AnyObject {
    func updateProgress(progress: Float)
}

protocol AudioPlayerStateListener: AnyObject {
    func onStateChanged(oldId: String?, newSample: AudioSample?)
}

protocol AudioPlayerSubscribeAdder: AnyObject {
    func subscribeForUpdates<Listener: AudioPlayerStateListener>(_ listener: Listener)
    func subscribeForProgressUpdates<Listener: AudioProgressListener>(_ listener: Listener)
}

protocol PlayStopper: AudioPlayerSubscribeAdder {
    func stop()
}

protocol AudioPlayerProtocol: PlayStopper {
    func play(sample: AudioSample)
    func setVolume(_ volume: Float)
    func setFrequency(_ frequency: Float)
    func getPlayingClipId() -> String?
}

class AudioPlayer: NSObject, AudioPlayerProtocol, PlayStopper {
    private var progressListeners: [AudioProgressListener] = []
    private var stateListeners: [AudioPlayerStateListener] = []
    private var frequency: Float = FloatConstants.defaultFrequency.rawValue
    private var playerInstance: AVAudioPlayer?
    private var playingId: String?
    private var isOnePlay = false

    var displayLink: CADisplayLink?

    func play(sample: AudioSample) {
        stop()

        guard let player = try? AVAudioPlayer(contentsOf: sample.audioUrl)
        else {
            print("Can't create AVAudioPlayer with clip \(sample.audioUrl)")
            return
        }

        player.delegate = self
        player.numberOfLoops = 0
        player.play()
        player.volume = sample.volume
        frequency = sample.frequency
        isOnePlay = sample.isMicrophone
        playerInstance = player

        startDisplayLink()

        notifyListeners(oldId: playingId, newSample: sample)
        playingId = sample.id
    }

    func stop() {
        guard let id = playingId
        else { return }
        playerInstance?.stop()
        playerInstance = nil
        stopDisplayLink()
        notifyListeners(progress: 0)
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        notifyListeners(oldId: id, newSample: nil)
        playingId = nil
    }

    func setVolume(_ volume: Float) {
        if let player = playerInstance {
            player.volume = volume
        }
    }

    func setFrequency(_ frequency: Float) {
        if playingId != nil {
            self.frequency = frequency
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            playAgain()
        }
    }

    func getPlayingClipId() -> String? {
        return playingId
    }

    func subscribeForUpdates<Listener: AudioPlayerStateListener>(_ listener: Listener) {
        stateListeners.append(listener)
    }

    func subscribeForProgressUpdates<Listener: AudioProgressListener>(_ listener: Listener) {
        progressListeners.append(listener)
    }

    @objc private func updateAudioProgress() {
        guard let player = playerInstance
        else { return }

        let progress = Float(player.currentTime / player.duration)
        notifyListeners(progress: progress)
    }

    private func startDisplayLink() {
        if displayLink != nil {
            stopDisplayLink()
        }
        displayLink = CADisplayLink(target: self, selector: #selector(updateAudioProgress))
        displayLink?.add(to: .main, forMode: .common)
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    private func notifyListeners(oldId: String?, newSample: AudioSample?) {
        for listener in stateListeners {
            listener.onStateChanged(oldId: oldId, newSample: newSample)
        }
    }

    private func notifyListeners(progress: Float) {
        for listener in progressListeners {
            listener.updateProgress(progress: progress)
        }
    }
} 

// все семплы зациклены; после завершения запускается заново через установленный таймаут
// в UI добавил кнопку для выключения проигрывания текущего, так как всегда выключать через слои неудобно
extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if isOnePlay {
            stop()
        } else {
            self.perform(#selector(playAgain), with: nil, afterDelay: 1 / Double(frequency))
        }
    }

    @objc func playAgain() {
        playerInstance?.play()
    }
}
