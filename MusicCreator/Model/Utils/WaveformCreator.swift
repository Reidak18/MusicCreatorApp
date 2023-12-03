//
//  AudioPlayer.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 01.11.2023.
//

import UIKit
import AVFoundation

enum WaveformCreatorError: Error {
    case loadAudioFromUrlError(String)
    case createPCMBufferError(String)
    case readAudioFileError(String)
    case getAudioChannelDataError(String)
}

protocol WaveformCreatorProtocol {
    func drawWaveform(fileUrl: URL,
                      numberOfFrames: Int,
                      frame: CGRect,
                      completionHandler: @escaping(_ result: Result<UIImage, WaveformCreatorError>) -> ())
}

class WaveformCreator: WaveformCreatorProtocol {
    private let minTraitLength: CGFloat = 2
    private let startDrawPos: CGFloat = 6

    func drawWaveform(fileUrl: URL,
                      numberOfFrames: Int,
                      frame: CGRect,
                      completionHandler: @escaping(_ result: Result<UIImage, WaveformCreatorError>) -> ()) {
        guard let audioFile = try? AVAudioFile(forReading: fileUrl)
        else {
            completionHandler(.failure(.loadAudioFromUrlError("Can't read audio file from \(fileUrl)")))
            return
        }

        calculateAveragePowers(audioFile: audioFile,
                               numberOfFrames: numberOfFrames) { result in
            switch(result) {
            case .failure(let error):
                completionHandler(.failure(error))
            case .success(let powers):
                DispatchQueue.main.async { [weak self] in
                    guard let self
                    else { return }
                    
                    let normalized = self.normalizePowers(powers)
                    completionHandler(.success(self.createWaveformFromPovers(powers: normalized, frame: frame)))
                }
            }
        }
    }

    private func createWaveformFromPovers(powers: [Float], frame: CGRect) -> UIImage {
        let pencil = UIBezierPath()
        let wfLayer = CAShapeLayer()
        let view = UIView(frame: frame)
        var start = CGPoint(x: startDrawPos, y: view.bounds.midY)
        let step = (view.bounds.width - start.x * 2) / CGFloat(powers.count)

        for trait in powers {
            var length = CGFloat(trait) * view.frame.height / 4
            length = max(minTraitLength, length)

            pencil.move(to: start)
            pencil.addLine(to: CGPoint(x: start.x, y: start.y + length))
            pencil.addLine(to: CGPoint(x: start.x, y: start.y - length))
            start = CGPoint(x: start.x + step, y: start.y)
        }

        wfLayer.path = pencil.cgPath
        wfLayer.strokeColor = UIColor.white.cgColor
        wfLayer.fillColor = UIColor.black.cgColor
        wfLayer.lineWidth = step / 2
        wfLayer.contentsCenter = view.frame
        view.layer.addSublayer(wfLayer)
        view.setNeedsDisplay()

        return view.asImage()
    }

    private func calculateAveragePowers(audioFile: AVAudioFile,
                                        numberOfFrames: Int,
                                        completionHandler: @escaping(_ result: Result<[Float], WaveformCreatorError>) -> ()) {
        let audioFilePFormat = audioFile.processingFormat
        let audioFileLength = audioFile.length

        let frameSizeToRead = Int(audioFileLength) / numberOfFrames

        guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFilePFormat,
                                                 frameCapacity: AVAudioFrameCount(frameSizeToRead))
        else {
            let error = WaveformCreatorError.createPCMBufferError("Can't create AVAudioPCMBuffer")
            completionHandler(.failure(error))
            return
        }

        DispatchQueue.global(qos: .utility).async {
            var returnArray = [Float]()

            for i in 0..<numberOfFrames {
                audioFile.framePosition = AVAudioFramePosition(i * frameSizeToRead)

                do {
                    try audioFile.read(into: audioBuffer, frameCount: AVAudioFrameCount(frameSizeToRead))
                } catch(let catchedError) {
                    let error = WaveformCreatorError.readAudioFileError(catchedError.localizedDescription)
                    completionHandler(.failure(error))
                    return
                }

                let channelsCount = audioFile.processingFormat.channelCount

                if channelsCount == 0 {
                    let error = WaveformCreatorError.getAudioChannelDataError("Can't get audio channel data")
                    completionHandler(.failure(error))
                    return
                }

                var dbPower: Float = 0
                for channelIndex in 0..<channelsCount {
                    guard let channelData = audioBuffer.floatChannelData?[Int(channelIndex)]
                    else { continue }
                    let arr = Array(UnsafeBufferPointer(start: channelData, count: frameSizeToRead))
                    let meanValue = arr.reduce(0, {$0 + abs($1)}) / Float(arr.count)
                    dbPower += meanValue > 0.000_000_01 ? 20 * log10(meanValue) : -160.0
                }

                returnArray.append(dbPower / Float(channelsCount))
            }

            completionHandler(.success(returnArray))
        }
    }

    private func normalizePowers(_ powers: [Float]) -> [Float] {
        guard let maxPower = powers.max(),
              let minPower = powers.min()
        else { return powers }

        let diff = maxPower - minPower
        var normalized: [Float]
        if diff != 0 {
            normalized = powers.map({ ($0 - minPower) / diff })
        } else {
            normalized = powers
        }

        return normalized
    }
}
