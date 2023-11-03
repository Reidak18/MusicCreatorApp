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

    private var database: SamplesDatabaseProtocol
    private var audioPlayer: AudioPlayerProtocol
    private var session: SessionProtocol
    private var sampleEditor: AudioSampleEditor

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        database = SamplesDatabase()
        audioPlayer = AudioPlayer()
        session = WorkSession(player: audioPlayer)
        sampleEditor = AudioSampleEditor()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func loadView() {
        audioPlayer.audioProgressSubscriber = self
        audioPlayer.audioChangeSampleSubscriber = self
        mainView.setCurrentSession(session: session)
        mainView.selectSampleDelegate = self
        mainView.slidersChangesListener = self
        mainView.switchViewDelegate = self
        mainView.sampleSelectListener = self
        mainView.addMicrophoneRecordSubscriber = self
        view = mainView
    }

    private func saveSample() {
        if let oldSample = sampleEditor.getAudioSample() {
            session.updateSample(sample: oldSample)
            sampleEditor.setAudioSample(nil)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainViewController: SampleTrackSelector {
    func selectSampleFromLibrary(instrument: MusicInstrument, index: Int) {
        saveSample()

        guard var sample = database.getSample(instrument: instrument, index: index)
        else { return }

        sample.setVolume(volume: audioPlayer.volume)
        sample.setFrequency(frequency: audioPlayer.frequency)
        sample.setIsPlaying(true)
        sampleEditor.setAudioSample(sample)

        session.updateSample(sample: sample)
        session.playSample(id: sample.id, play: true)
    }
}

extension MainViewController: MiddleViewsSwitcher {
    func switchButtonClicked(to viewType: CurrentViewType) {
        mainView.switchView(viewType: viewType)
    }
}

extension MainViewController: AudioProgressListener {
    func updateProgress(progress: Float) {
        mainView.setWaveformProgress(progress: progress)
    }
}

extension MainViewController: AudioChangeSampleListener {
    func sampleChanged(newSample: AudioSample?) {
        mainView.setWaveform(url: newSample?.audioUrl)
    }
}

extension MainViewController: SlidersChangesListener {
    func volumeValueUpdated(volume: Float) {
        sampleEditor.setVolume(volume: volume)
        audioPlayer.volume = volume
    }

    func frequencyValueUpdated(frequency: Float) {
        sampleEditor.setFrequency(frequency: frequency)
        audioPlayer.frequency = frequency
    }
}

extension MainViewController: SampleSelectListener {
    func sampleSelected(id: String?) {
        mainView.switchView(viewType: .params)
        guard let id = id,
              let sample = session.getSample(id: id)
        else { return }

        mainView.setSlidersParams(volume: sample.volume, frequency: sample.frequency)
        session.playSample(id: id, play: true)
        sampleEditor.setAudioSample(sample)
    }
}

extension MainViewController: AddMicrophoneRecordListener {
    func startRecording() {
        saveSample()
        audioPlayer.stop()

        if UserDefaults.standard.bool(forKey: StringConstants.ShowDisableAlert.rawValue) == true {
            self.mainView.disableAll(exceptTag: IntConstants.MicroButtonTag.rawValue)
        } else {
            let alert = UIAlertController(title: "Отключение UI",
                                          message: "UI будет отключен на время записи с микрофона",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: { _ in
                self.mainView.disableAll(exceptTag: IntConstants.MicroButtonTag.rawValue)
                UserDefaults.standard.set(true, forKey: StringConstants.ShowDisableAlert.rawValue)
            }))
            present(alert, animated: true)
        }
    }

    func recordAdded(sample: AudioSample) {
        session.updateSample(sample: sample)
        mainView.enableAll()
    }

    func errorHappend(error: RecordMicroError) {
        mainView.enableAll()
    }
}
