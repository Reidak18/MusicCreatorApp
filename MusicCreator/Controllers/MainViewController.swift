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
    private var currentSettings: CurrentSampleSettings
    private var audioMixer: AudioMixer

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        database = SamplesDatabase()
        audioPlayer = AudioPlayer()
        session = WorkSession(player: audioPlayer)
        currentSettings = CurrentSampleSettings()
        audioMixer = AudioMixer()
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
        mainView.mixTrackPlayer = self
        view = mainView
    }

    private func saveSample() {
        if let id = currentSettings.id,
           var sample = session.getSample(id: id) {
            sample.setVolume(volume: currentSettings.volume)
            sample.setFrequency(frequency: currentSettings.frequency)
            session.updateSample(sample: sample)
            currentSettings.id = nil
        }
    }

    private func blockUI(exceptTag: Int) {
        if UserDefaults.standard.bool(forKey: StringConstants.ShowDisableAlert.rawValue) == true {
            self.mainView.disableAll(exceptTag: exceptTag)
        } else {
            let alert = UIAlertController(title: "Отключение UI",
                                          message: "UI будет отключен на время работы функции. Вы можете вернуться в режим редактирования повторным нажатием на кнопку",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: { _ in
                self.mainView.disableAll(exceptTag: IntConstants.MicroButtonTag.rawValue)
                UserDefaults.standard.set(true, forKey: StringConstants.ShowDisableAlert.rawValue)
            }))
            present(alert, animated: true)
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

        currentSettings = CurrentSampleSettings(sample: sample)

        session.updateSample(sample: sample)
        session.playSample(id: sample.id, play: true)
    }
}

extension MainViewController: MiddleViewsSwitcher {
    func switchButtonClicked(to viewType: CurrentViewType) {
        if viewType == .layers {
            saveSample()
        }
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
        currentSettings.volume = volume
        audioPlayer.volume = volume
    }

    func frequencyValueUpdated(frequency: Float) {
        currentSettings.frequency = frequency
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
        currentSettings = CurrentSampleSettings(sample: sample)
    }
}

extension MainViewController: AddMicrophoneRecordListener {
    func startRecording() {
        saveSample()
        audioPlayer.stop()
        blockUI(exceptTag: IntConstants.MicroButtonTag.rawValue)
    }

    func recordAdded(sample: AudioSample) {
        session.updateSample(sample: sample)
        mainView.enableAll()
    }

    func errorHappend(error: RecordMicroError) {
        mainView.enableAll()
    }
}

extension MainViewController: MixTrackPlayer {
    func mixAndPlay() {
        saveSample()
        audioPlayer.stop()
        blockUI(exceptTag: IntConstants.PlayMixButtonTag.rawValue)
        audioMixer.play(samples: session.getSamples().filter({ !$0.isMute }))
    }

    func stopPlay() {
        audioMixer.stopPlay()
        mainView.enableAll()
    }

    func mixAndRecord() {

    }

    func stopRecord() {
        
    }
}
