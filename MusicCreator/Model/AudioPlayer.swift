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

protocol AudioPlayer {
    func play(sample: AudioSample, loop: Bool)
    func stop()
    var volume: Float { get set }
    var speed: Float { get set }
    func getPlayingClipId() -> String?
    func updateSample(sample: AudioSample)
    var audioProgressSubscriber: AudioProgressListener? { get set }
}

class SimpleAudioPlayer: AudioPlayer {
    var audioProgressSubscriber: AudioProgressListener?
    private var playerInstance: AVAudioPlayer?
    var volume: Float {
        didSet {
            if let player = playerInstance {
                player.volume = volume
            }
        }
    }
    var speed: Float {
        didSet {
            if let player = playerInstance {
                player.rate = speed
            }
        }
    }
    private var playingId: String?

    lazy var displayLink: CADisplayLink = CADisplayLink(target: self, selector: #selector(updateAudioProgress))

    init(defaultVolume: Float = 1, defaultSpeed: Float = 1) {
        volume = defaultVolume
        speed = defaultSpeed
    }

    func play(sample: AudioSample, loop: Bool) {
        guard let player = try? AVAudioPlayer(contentsOf: sample.audioUrl)
        else {
            print("Can't create AVAudioPlayer with clip \(sample.audioUrl)")
            return
        }

        playingId = sample.id

        player.enableRate = true
        player.numberOfLoops = loop ? -1 : 0
        player.play()
        player.volume = sample.isMute ? 0 : sample.volume
        player.rate = sample.speed
        playerInstance = player
        displayLink.add(to: .main, forMode: .common)
    }

    func stop() {
        playingId = nil
        playerInstance?.stop()
        playerInstance = nil
        displayLink.remove(from: .main, forMode: .common)
        audioProgressSubscriber?.updateProgress(progress: 0)
    }

    func getPlayingClipId() -> String? {
        return playingId
    }

    func updateSample(sample: AudioSample) {
        guard playingId == sample.id
        else { return }

        volume = sample.isMute ? 0 : sample.volume
        speed = sample.speed
    }

    @objc private func updateAudioProgress() {
        guard let player = playerInstance
        else { return }

        let progress = Float(player.currentTime / player.duration)
        audioProgressSubscriber?.updateProgress(progress: progress)

        if !player.isPlaying {
            stop()
        }
    }
}
