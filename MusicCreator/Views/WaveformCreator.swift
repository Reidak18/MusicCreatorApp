//
//  WaveformCreator.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 01.11.2023.
//

import UIKit
import AVFoundation

class WaveformCreator {
    var audioPlayer: AVAudioPlayer?

    private func loadAudio(fileName: String, fileType: String = ".mp3") -> AVAudioPlayer? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: fileType)
        else {
            print("File not found")
            return nil
        }
        let player: AVAudioPlayer
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
        } catch(let error) {
            print("Can't create AVAudioPlayer: \(error)")
            return nil
        }

        return player
    }

    func drawWaveform() {
//        let pencil = UIBezierPath(rect: view.bounds)
//        let firstPoint = CGPoint(x: 6, y: view.bounds.midY)
//        let jump: CGFloat = (view.bounds.width - (firstPoint.x * 2)) / 200
        let layer = CAShapeLayer()
        var traitLength: CGFloat!
//        var start: CGPoint = firstPoint

        guard let player = loadAudio(fileName: "Taxi", fileType: ".mp3")
        else { return }
        audioPlayer = player

        player.isMeteringEnabled = true
        player.play()
        var audioTime = Float(player.duration)
        var powers = [CGFloat]()
        let step = 0.02
        timer = Timer.scheduledTimer(withTimeInterval: step, repeats: true, block: { _ in
            powers.append(self.averagePowerFromAllChannels(player: player))
            audioTime -= Float(step)
            if audioTime <= 0 {
                self.timer?.invalidate()
                self.timer = nil

                guard let maxPower = powers.max(),
                      let minPower = powers.min()
                else { return }

                powers = powers.map({ ($0 - minPower) / (maxPower - minPower) })
                print(powers)
            }
        })
    }

    var timer: Timer? = nil

    // средняя мощность в дБ от -160 до 0
    private func averagePowerFromAllChannels(player: AVAudioPlayer) -> CGFloat {
        var power: CGFloat = 0.0
        player.updateMeters()
        for i in 0..<player.numberOfChannels {
            power = power + CGFloat(player.averagePower(forChannel: i))
        }
        return power / CGFloat(player.numberOfChannels)
    }
}
