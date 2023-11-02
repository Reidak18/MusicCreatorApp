//
//  AudioPlayer.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 02.11.2023.
//

import AVFoundation

class AudioPlayer {
    private var playerInstance: AVAudioPlayer?
    private var volume: Float
    private var speed: Float

    init(defaultVolume: Float = 1, defaultSpeed: Float = 1) {
        volume = defaultVolume
        speed = defaultSpeed
    }

    func play(clip: AVAudioFile, loop: Bool = true) {
        guard let player = try? AVAudioPlayer(contentsOf: clip.url)
        else {
            print("Can't create AVAudioPlayer with clip \(clip.url)")
            return
        }

        playerInstance = player
        player.enableRate = true
        player.numberOfLoops = loop ? -1 : 1
        player.play()
        player.volume = volume
        player.rate = speed
    }

    func stop() {
        playerInstance?.stop()
        playerInstance = nil
    }

    func setVolume(volume: Float) {
        self.volume = min(max(0, volume), 1.0)
    }

    func setSpeed(speed: Float) {
        self.speed = min(max(0.5, volume), 2.0)
    }
}
