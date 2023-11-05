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

    private var uiBlocker: UIBlockerProtocol

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        database = SamplesDatabase()
        audioPlayer = AudioPlayer()
        session = WorkSession()
        uiBlocker = UIBlocker(parentView: mainView)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        session.subscribeForUpdates(self)
        audioPlayer.subscribeForUpdates(session)
    }

    override func loadView() {
        mainView.setSamples(samplesNames: database.getSamples())
        mainView.setPlayStopper(stopper: audioPlayer)
        mainView.setRecordProviderAndSubscriber(provider: session,
                                                subscriber: self)

        mainView.setLayersProvider(session: session, delegate: self)
        mainView.selectSampleDelegate = self
        mainView.slidersChangesListener = self
        mainView.switchViewDelegate = self
        view = mainView
    }

    private func shareAudio(fileUrl: URL) {
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
    func selectSample(id: String) {
        mainView.switchView(viewType: .params)
        guard let sample = session.getSample(id: id)
        else { return }

        mainView.setSlidersParams(volume: sample.volume, frequency: sample.frequency)
        audioPlayer.play(sample: sample)
    }
}

extension MainViewController: RecordingStatusSubscriber {
    func started(_ type: RecordingType) {
        audioPlayer.stop()
        var exceptTag: IntConstants
        switch type {
        case .microphoneRecording:
            exceptTag = .microButtonTag
        case .mixAudioPlaying:
            exceptTag = .playMixButtonTag
        case .mixAudioRecording:
            exceptTag = .recordButtonTag
        }
        if let alert = uiBlocker.blockUI(exceptTag: exceptTag.rawValue) {
            present(alert, animated: true)
        }
    }

    func finished(_ type: RecordingType, url: URL?) {
        uiBlocker.releaseUI(exceptTags: Set([IntConstants.stopButtonTag.rawValue]))

        guard let fileUrl = url
        else { return }

        switch(type) {
        case .microphoneRecording:
            let sample = AudioSample(name: fileUrl.lastPathComponent,
                                     audioUrl: fileUrl,
                                     isMicrophone: true,
                                     volume: FloatConstants.maximumVolume.rawValue)
            session.updateSample(sample: sample)
        case .mixAudioRecording:
            shareAudio(fileUrl: fileUrl)
        default:
            break
        }
    }

    func error(_ type: RecordingType, error: RecordMicroError) {
        uiBlocker.releaseUI(exceptTags: Set([IntConstants.stopButtonTag.rawValue]))
    }
}

extension MainViewController: SessionUpdateListener {
    func update(id: String, updatedSample: AudioSample?) {
        guard let sample = updatedSample
        else {
            // семпл был удален
            if id == audioPlayer.getPlayingClipId() {
                audioPlayer.stop()
                mainView.setSlidersParams(volume: FloatConstants.defaultVolume.rawValue,
                                          frequency: FloatConstants.defaultFrequency.rawValue)
            }
            return
        }

        if sample.id == audioPlayer.getPlayingClipId() {
            if !sample.isPlaying {
                audioPlayer.stop()
            }
        }
        else {
            if sample.isPlaying {
                audioPlayer.play(sample: sample)
            }
        }

        mainView.setSlidersParams(volume: sample.volume,
                                  frequency: sample.frequency)
    }
}
