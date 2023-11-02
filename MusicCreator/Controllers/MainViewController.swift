//
//  ViewController.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 30.10.2023.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController {
    private let audioPlayer = AudioPlayer()

    override func loadView() {
        let mainView = MainView()
        view = mainView
    }

//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        let clip = try! AVAudioFile(forReading: Bundle.main.url(forResource: "DrumsFutureLoop", withExtension: "wav")!)
//        audioPlayer.play(clip: clip)
//    }
}
