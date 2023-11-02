//
//  AudioPlayer.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 01.11.2023.
//

import UIKit
import AVFoundation

enum WaveformCreatorError: Error {
    case createPCMBufferError(String)
    case readAudioFileError(String)
    case getAudioChannelDataError(String)
}

class WaveformCreator {
    func averagePowers(audioFile: AVAudioFile,
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

        DispatchQueue.global(qos: .background).async {
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

                var channelIndex = 0
                var dbPower: Float = 0
                while let channelData = audioBuffer.floatChannelData?[channelIndex] {
                    let arr = Array(UnsafeBufferPointer(start: channelData, count: frameSizeToRead))
                    let meanValue = arr.reduce(0, {$0 + abs($1)}) / Float(arr.count)
                    dbPower += meanValue > 0.000_000_01 ? 20 * log10(meanValue) : -160.0
                    channelIndex += 1
                }

                if channelIndex == 0 {
                    let error = WaveformCreatorError.getAudioChannelDataError("Can't get audio channel data")
                    completionHandler(.failure(error))
                    return
                }

                returnArray.append(dbPower / Float(channelIndex))
            }

            completionHandler(.success(returnArray))
        }
    }

    func drawWaveform(frame: CGRect, traitsLengths: [Float]) -> UIImage {
        let pencil = UIBezierPath()
        let wfLayer = CAShapeLayer()
        let view = UIView(frame: frame)
        var start = CGPoint(x: 6, y: view.bounds.midY)
        let step = (view.bounds.width - start.x * 2) / CGFloat(traitsLengths.count)

        for trait in traitsLengths {
            var length = CGFloat(trait) * view.frame.height / 4
            length = max(2, length)

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
}
