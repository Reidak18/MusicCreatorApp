import AVFoundation
import Accelerate

final class AudioContext {
    // добавить fail замыкание
    func averagePowers(audioFileURL: URL,
                       forChannel channelNumber: Int,
                       completionHandler: @escaping(_ success: [Float]) -> ()) {
        let audioFile = try! AVAudioFile(forReading: audioFileURL)
        let audioFilePFormat = audioFile.processingFormat
        let audioFileLength = audioFile.length

        let numberOfFrames = 300
        let frameSizeToRead = Int(audioFileLength) / numberOfFrames

        //Create a pcm buffer the size of a frame
        guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFilePFormat,
                                                 frameCapacity: AVAudioFrameCount(frameSizeToRead))
        else { return }

        DispatchQueue.global(qos: .background).async {
            var returnArray : [Float] = [Float]()

            for i in 0..<numberOfFrames {
                audioFile.framePosition = AVAudioFramePosition(i * frameSizeToRead)

                do {
                    try audioFile.read(into: audioBuffer, frameCount: AVAudioFrameCount(frameSizeToRead))
                } catch(let error) {
                    print(error)
                    return
                }

                // тут надо смотреть все каналы!
                //Get the data from the chosen channel
                let channelData = audioBuffer.floatChannelData![channelNumber]

                let arr = Array(UnsafeBufferPointer(start: channelData, count: frameSizeToRead))
                let meanValue = arr.reduce(0, {$0 + abs($1)}) / Float(arr.count)
                let dbPower: Float = meanValue > 0.000_000_01 ? 20 * log10(meanValue) : -160.0

                returnArray.append(dbPower)
            }

            completionHandler(returnArray)
        }
    }
}
