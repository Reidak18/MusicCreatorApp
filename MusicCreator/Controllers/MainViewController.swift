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

    private var database: SamplesDatabase
    private var audioPlayer: AudioPlayer
    private var waveformCreator: WaveformCreator
    private var session: Session

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        database = SoundsDatabase()
        audioPlayer = SimpleAudioPlayer()
        waveformCreator = CustomWaveformCreator()
        session = WorkSession(player: audioPlayer)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func loadView() {
        audioPlayer.audioProgressSubscriber = self
        mainView.setCurrentSession(session: session)
        mainView.selectSampleDelegate = self
        mainView.slidersChangesListener = self
        view = mainView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainViewController: SampleTrackSelector {
    func selectSample(instrument: MusicInstrument, index: Int) {
        guard var sample = database.getSample(instrument: instrument, index: index)
        else { return }

        waveformCreator.drawWaveform(fileUrl: sample.audioUrl,
                                     numberOfFrames: 75,
                                     frame: mainView.getWaveformFrame()) { result in
            switch(result) {
            case .failure(let error):
                print(error)
            case .success(let resultImage):
                self.mainView.setWaveformParams(background: resultImage)
            }
        }

        sample.setVolume(volume: audioPlayer.volume)
        sample.setFrequency(frequency: audioPlayer.frequency)
        session.addSample(sample: sample)
        audioPlayer.play(sample: sample)
    }
}

extension MainViewController: AudioProgressListener {
    func updateProgress(progress: Float) {
        mainView.setWaveformProgress(progress: progress)
    }
}

extension MainViewController: SlidersChangesListener {
    func volumeValueUpdated(volume: Float) {
        audioPlayer.volume = volume
    }

    func frequencyValueUpdated(frequency: Float) {
        audioPlayer.frequency = frequency
    }
}
