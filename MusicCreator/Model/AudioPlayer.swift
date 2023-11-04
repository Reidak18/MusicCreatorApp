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

protocol AudioChangeSampleListener: AnyObject {
    func sampleChanged(newSample: AudioSample?)
}

protocol AudioStopListener: AnyObject {
    func stopPlaying(id: String)
}

protocol AudioPlayerProtocol {
    func play(sample: AudioSample)
    func stop()
    func setVolume(_ volume: Float)
    func setFrequency(_ frequency: Float)
    func getPlayingClipId() -> String?
    var audioProgressSubscriber: AudioProgressListener? { get set }
    var audioChangeSampleSubscriber: AudioChangeSampleListener? { get set }
    var audioStopSubscriber: AudioStopListener? { get set }
}

class AudioPlayer: NSObject, AudioPlayerProtocol {
    weak var audioProgressSubscriber: AudioProgressListener?
    weak var audioChangeSampleSubscriber: AudioChangeSampleListener?
    weak var audioStopSubscriber: AudioStopListener?
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

        playingId = sample.id
        player.delegate = self
        player.numberOfLoops = 0
        player.play()
        player.volume = sample.volume
        frequency = sample.frequency
        isOnePlay = sample.isMicrophone
        playerInstance = player

        startDisplayLink()

        audioChangeSampleSubscriber?.sampleChanged(newSample: sample)
    }

    func stop() {
        guard let id = playingId
        else { return }
        playerInstance?.stop()
        playerInstance = nil
        stopDisplayLink()
        audioProgressSubscriber?.updateProgress(progress: 0)
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        audioChangeSampleSubscriber?.sampleChanged(newSample: nil)
        audioStopSubscriber?.stopPlaying(id: id)
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

    @objc private func updateAudioProgress() {
        guard let player = playerInstance
        else { return }

        let progress = Float(player.currentTime / player.duration)
        audioProgressSubscriber?.updateProgress(progress: progress)
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
