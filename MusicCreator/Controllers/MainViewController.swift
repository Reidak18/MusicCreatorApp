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

    private var uiBlocker: UIBlocker

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        database = SamplesDatabase()
        audioPlayer = AudioPlayer()
        session = WorkSession()
        audioMixer = AudioMixer()
        uiBlocker = UIBlocker(parentView: mainView)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        session.subscribeForUpdates(self)
        audioPlayer.subscribeForUpdates(session)
    }

    override func loadView() {
        mainView.setSamples(samplesNames: database.getSamples())
        mainView.setPlayStopper(stopper: audioPlayer)

        audioPlayer.audioProgressSubscriber = self
        audioPlayer.audioChangeSampleSubscriber = self
        mainView.setLayersProvider(session: session, delegate: self)
        mainView.selectSampleDelegate = self
        mainView.slidersChangesListener = self
        mainView.switchViewDelegate = self
        mainView.addMicrophoneRecordSubscriber = self
        mainView.mixTrackPlayer = self
        view = mainView
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
        guard let sample = database.getSample(instrument: instrument, index: index)
        else { return }

        mainView.setSlidersParams(volume: sample.volume, frequency: sample.frequency)
        session.updateSample(sample: sample)
        audioPlayer.play(sample: sample)
    }
}

extension MainViewController: MiddleViewsSwitcher {
    func switchButtonClicked(to viewType: CurrentViewType) {
        var volume = FloatConstants.defaultVolume.rawValue
        var frequency = FloatConstants.defaultFrequency.rawValue
        if let id = audioPlayer.getPlayingClipId(),
           let sample = session.getSample(id: id) {
            volume = sample.volume
            frequency = sample.frequency
        }
        mainView.setSlidersParams(volume: volume, frequency: frequency)
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

        sample.setVolume(volume)
        session.updateSample(sample: sample)
    }

    func frequencyValueUpdated(frequency: Float) {
        audioPlayer.setFrequency(frequency)
        guard let id = audioPlayer.getPlayingClipId(),
              var sample = session.getSample(id: id)
        else { return }

        sample.setFrequency(frequency)
        session.updateSample(sample: sample)
    }
}

extension MainViewController: SampleActionDelegate {
    func setIsPlaying(id: String, isPlaying: Bool) {
        guard let sample = session.getSample(id: id)
        else { return }

        if isPlaying {
            audioPlayer.play(sample: sample)
        } else {
            audioPlayer.stop()
        }
    }

    func setIsMute(id: String, isMute: Bool) {
        guard var sample = session.getSample(id: id)
        else { return }

        sample.setMute(isMute)
        session.updateSample(sample: sample)
    }

    func removeSample(id: String) {
        session.removeSample(id: id)
    }

    func selectSample(id: String) {
        mainView.switchView(viewType: .params)
        guard let sample = session.getSample(id: id)
        else { return }

        mainView.setSlidersParams(volume: sample.volume, frequency: sample.frequency)
        audioPlayer.play(sample: sample)
    }
}

extension MainViewController: AddMicrophoneRecordListener {
    func startRecording() {
        audioPlayer.stop()
        if let alert = uiBlocker.blockUI(exceptTag: IntConstants.microButtonTag.rawValue) {
            present(alert, animated: true)
        }

    }

    func recordAdded(sample: AudioSample) {
        session.updateSample(sample: sample)
        uiBlocker.releaseUI()
    }

    func errorHappend(error: RecordMicroError) {
        uiBlocker.releaseUI()
    }
}

extension MainViewController: MixTrackPlayer {
    func mixAndPlay() {
        audioPlayer.stop()
        if let alert = uiBlocker.blockUI(exceptTag: IntConstants.playMixButtonTag.rawValue) {
            present(alert, animated: true)
        }
        audioMixer.play(samples: session.getSamples().filter({ !$0.isMute }))
    }

    func stopPlay() {
        audioMixer.stopPlay()
        uiBlocker.releaseUI()
    }

    func mixAndRecord() {
        audioPlayer.stop()
        if let alert = uiBlocker.blockUI(exceptTag: IntConstants.recordButtonTag.rawValue) {
            present(alert, animated: true)
        }
        let filename = "\(StringConstants.audioMixRecordingName.rawValue)\(StringConstants.createdFilesExtension.rawValue)"
        audioMixer.playAndRecord(samples: session.getSamples().filter({ !$0.isMute }),
                                 filename: filename)
    }

    func stopRecord() {
        audioMixer.stopRecord()
        uiBlocker.releaseUI()
        let filename = "\(StringConstants.audioMixRecordingName.rawValue)\(StringConstants.createdFilesExtension.rawValue)"
        shareAudio(filename: filename)
    }
}

extension MainViewController: SessionUpdateListener {
    func update(samples: [AudioSample]) {
        if let id = audioPlayer.getPlayingClipId(),
           session.getSample(id: id) == nil {
            audioPlayer.stop()
        }
    }
}
