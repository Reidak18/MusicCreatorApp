//
//  AudioPlayer.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 02.11.2023.
//

import AVFoundation

protocol AudioProgressSubscriber {
    func updateProgress(progress: Float)
}

protocol AudioPlayer {
    func play(clipUrl: URL)
    func stop()
    func setVolume(volume: Float)
    func setSpeed(speed: Float)
    var audioProgressSubscriber: AudioProgressSubscriber? { get set }
}

class SimpleAudioPlayer: AudioPlayer {
    var audioProgressSubscriber: AudioProgressSubscriber?
    private var playerInstance: AVAudioPlayer?
    private var volume: Float
    private var speed: Float

    lazy var displayLink: CADisplayLink = CADisplayLink(target: self, selector: #selector(updateAudioProgress))

    init(defaultVolume: Float = 1, defaultSpeed: Float = 1) {
        volume = defaultVolume
        speed = defaultSpeed
    }

    func play(clipUrl: URL) {
        guard let player = try? AVAudioPlayer(contentsOf: clipUrl)
        else {
            print("Can't create AVAudioPlayer with clip \(clipUrl)")
            return
        }

        playerInstance = player
        player.enableRate = true
        player.numberOfLoops = -1
        player.play()
        player.volume = volume
        player.rate = speed
        displayLink.add(to: .main, forMode: .common)
    }

    func stop() {
        playerInstance?.stop()
        playerInstance = nil
        displayLink.invalidate()
    }

    func setVolume(volume: Float) {
        self.volume = min(max(0, volume), 1.0)
        if let player = playerInstance {
            player.volume = volume
        }
    }

    func setSpeed(speed: Float) {
        self.speed = min(max(0.5, volume), 2.0)
        if let player = playerInstance {
            player.rate = speed
        }
    }

    @objc private func updateAudioProgress() {
        guard let player = playerInstance
        else { return }

        audioProgressSubscriber?.updateProgress(progress: Float(player.currentTime / player.duration))
    }
}
