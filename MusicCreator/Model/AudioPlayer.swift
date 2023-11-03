//
//  AudioPlayer.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 02.11.2023.
//

import AVFoundation

protocol AudioProgressListener {
    func updateProgress(progress: Float)
}

protocol AudioChangeSampleListener {
    func sampleChanged(newSample: AudioSample?)
}

protocol AudioPlayer {
    func play(sample: AudioSample)
    func stop()
    var volume: Float { get set }
    var frequency: Float { get set }
    func getPlayingClipId() -> String?
    func updateSample(sample: AudioSample)
    var audioProgressSubscriber: AudioProgressListener? { get set }
    var audioChangeSampleSubscriber: AudioChangeSampleListener? { get set }
}

class SimpleAudioPlayer: NSObject, AudioPlayer {
    var audioProgressSubscriber: AudioProgressListener?
    var audioChangeSampleSubscriber: AudioChangeSampleListener?
    private var playerInstance: AVAudioPlayer?
    var volume: Float {
        didSet {
            if let player = playerInstance {
                player.volume = volume
            }
        }
    }
    // 0.25...4
    var frequency: Float
    private var playingId: String?

    var displayLink: CADisplayLink?

    init(defaultVolume: Float = 1, defaultFrequency: Float = 1) {
        volume = defaultVolume
        frequency = defaultFrequency
    }

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
        playerInstance = player

        startDisplayLink()

        audioChangeSampleSubscriber?.sampleChanged(newSample: sample)
    }

    func stop() {
        playingId = nil
        playerInstance?.stop()
        playerInstance = nil
        stopDisplayLink()
        audioProgressSubscriber?.updateProgress(progress: 0)
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        audioChangeSampleSubscriber?.sampleChanged(newSample: nil)
    }

    func getPlayingClipId() -> String? {
        return playingId
    }

    func updateSample(sample: AudioSample) {
        guard playingId == sample.id
        else { return }

        volume = sample.volume
        frequency = sample.frequency
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

extension SimpleAudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.perform(#selector(playAgain), with: nil, afterDelay: 1 / Double(frequency))
    }

    @objc func playAgain() {
        playerInstance?.play()
    }
}
