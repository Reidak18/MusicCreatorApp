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
    private var audioMixer: AudioMixerProtocol

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        database = SamplesDatabase()
        audioPlayer = AudioPlayer()
        session = WorkSession(player: audioPlayer)
        audioMixer = AudioMixer()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func loadView() {
        mainView.setSamples(samplesNames: database.getSamples())

        audioPlayer.audioProgressSubscriber = self
        audioPlayer.audioChangeSampleSubscriber = self
        mainView.setCurrentSession(session: session)
        mainView.selectSampleDelegate = self
        mainView.slidersChangesListener = self
        mainView.switchViewDelegate = self
        mainView.sampleSelectListener = self
        mainView.addMicrophoneRecordSubscriber = self
        mainView.mixTrackPlayer = self
        mainView.playStopper = self
        view = mainView
    }

    private func blockUI(exceptTag: Int) {
        if UserDefaults.standard.bool(forKey: StringConstants.showDisableAlert.rawValue) == true {
            self.mainView.disableAll(exceptTag: exceptTag)
        } else {
            let alert = UIAlertController(title: "Отключение UI",
                                          message: "UI будет отключен на время работы функции. Вы можете вернуться в режим редактирования повторным нажатием на кнопку",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: { _ in
                self.mainView.disableAll(exceptTag: IntConstants.microButtonTag.rawValue)
                UserDefaults.standard.set(true, forKey: StringConstants.showDisableAlert.rawValue)
            }))
            present(alert, animated: true)
        }
    }

    private func shareAudio(filename: String) {
        let fileUrl = FileManager.default.getDocumentsPath(filename: filename)

        let activityVC = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view

        self.present(activityVC, animated: true, completion: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainViewController: SampleTrackSelector {
    func selectSampleFromLibrary(instrument: MusicInstrument, index: Int) {
        guard var sample = database.getSample(instrument: instrument, index: index)
        else { return }

        mainView.setSlidersParams(volume: sample.volume, frequency: sample.frequency)
        sample.setIsPlaying(true)
        session.updateSample(sample: sample)
        audioPlayer.play(sample: sample)
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
        audioPlayer.setVolume(volume)
        guard let id = audioPlayer.getPlayingClipId(),
              var sample = session.getSample(id: id)
        else { return }

        sample.setVolume(volume: volume)
        session.updateSample(sample: sample)
    }

    func frequencyValueUpdated(frequency: Float) {
        audioPlayer.setFrequency(frequency)
        guard let id = audioPlayer.getPlayingClipId(),
              var sample = session.getSample(id: id)
        else { return }

        sample.setFrequency(frequency: frequency)
        session.updateSample(sample: sample)
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
    }
}

extension MainViewController: AddMicrophoneRecordListener {
    func startRecording() {
        audioPlayer.stop()
        blockUI(exceptTag: IntConstants.microButtonTag.rawValue)
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
        audioPlayer.stop()
        blockUI(exceptTag: IntConstants.playMixButtonTag.rawValue)
        audioMixer.play(samples: session.getSamples().filter({ !$0.isMute }))
    }

    func stopPlay() {
        audioMixer.stopPlay()
        mainView.enableAll()
    }

    func mixAndRecord() {
        audioPlayer.stop()
        blockUI(exceptTag: IntConstants.recordButtonTag.rawValue)
        let filename = "\(StringConstants.audioMixRecordingName.rawValue)\(StringConstants.createdFilesExtension.rawValue)"
        audioMixer.playAndRecord(samples: session.getSamples().filter({ !$0.isMute }),
                                 filename: filename)
    }

    func stopRecord() {
        audioMixer.stopRecord()
        mainView.enableAll()
        let filename = "\(StringConstants.audioMixRecordingName.rawValue)\(StringConstants.createdFilesExtension.rawValue)"
        shareAudio(filename: filename)
    }
}

extension MainViewController: PlayStopper {
    func stop() {
        audioPlayer.stop()
    }
}
