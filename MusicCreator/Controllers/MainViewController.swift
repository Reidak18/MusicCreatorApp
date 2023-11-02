//
//  ViewController.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 30.10.2023.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController {
    private let mainView = MainView()
    private let database: SamplesDatabase = SoundsDatabase()
    private var audioPlayer: AudioPlayer = SimpleAudioPlayer()
    private let waveformCreator: WaveformCreator = CustomWaveformCreator()

    override func loadView() {
        audioPlayer.audioProgressSubscriber = self
        mainView.selectSampleDelegate = self
        mainView.slidersChangesListener = self
        view = mainView
    }
}

extension MainViewController: SampleTrackSelector {
    func selectSample(instrument: MusicInstrument, index: Int) {
        guard let sampleUrl = database.getSample(instrument: instrument, index: index)
        else { return }

        waveformCreator.drawWaveform(fileUrl: sampleUrl,
                                     numberOfFrames: 75,
                                     frame: mainView.getWaveformFrame()) { result in
            switch(result) {
            case .failure(let error):
                print(error)
            case .success(let resultImage):
                self.mainView.setWaveformParams(background: resultImage)
            }
        }
        audioPlayer.play(clipUrl: sampleUrl)
    }
}

extension MainViewController: AudioProgressSubscriber {
    func updateProgress(progress: Float) {
        mainView.setWaveformProgress(progress: progress)
    }
}

extension MainViewController: SlidersChangesListener {
    func volumeValueUpdated(volume: Float) {
        audioPlayer.setVolume(volume: volume)
    }

    func speedValueUpdated(speed: Float) {
        audioPlayer.setSpeed(speed: speed)
    }
}
