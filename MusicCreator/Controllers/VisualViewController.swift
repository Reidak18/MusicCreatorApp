//
//  VisualViewController.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 02.12.2023.
//

import UIKit
import AVFAudio

class VisualViewController: UIViewController {
    var samples: [AudioSample] = []
    var powersDict: Dictionary<String, ([Float], Double)> = [:]
    var figures: Dictionary<String, UIView> = [:]
    var audioRecorder: AudioRecorderProtocol?
    private let visualView = VisualView()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.tintColor = .red
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(named: "backButton"), for: .normal)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)

        backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor).isActive = true

        view.addSubview(visualView)
        NSLayoutConstraint.activate([
            visualView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            visualView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            visualView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            visualView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        createSampleFigures()
    }

    @objc func back() {
        navigationController?.popViewController(animated: true)
    }

    private func createSampleFigures() {
        for sample in samples {
            guard let audioFile = try? AVAudioFile(forReading: sample.audioUrl)
            else { return }

            WaveformCreator.getPowers(audioFile: audioFile,
                                      numberOfFrames: 50) { result in
                switch(result) {
                case .failure(let error):
                    print(error)
                    return
                case .success(let powers):
                    self.powersDict[sample.id] = (powers, Double(audioFile.length))
                    let image = UIImage(named: sample.imageName) ?? UIImage(named: "Microphone")
                    let imageView = UIImageView(image: image)
                    let size = CGFloat.random(in: 50...200)
                    imageView.frame = CGRect(x: CGFloat.random(in: 0...self.view.frame.width - 200),
                                             y: CGFloat.random(in: 0...self.view.frame.height - 200),
                                             width: size,
                                             height: size)
                    self.view.addSubview(imageView)
                    self.figures[sample.id] = imageView

                    _ = Timer.scheduledTimer(timeInterval: 0.2,
                                                     target: self,
                                                     selector: #selector(self.updateAnimation),
                                                     userInfo: nil, repeats: true)
                }
            }
        }
    }

    @objc private func updateAnimation() {
        guard let recorder = audioRecorder
        else { return }

        for key in powersDict.keys {
            guard let player = recorder.players[key],
                  let powers = powersDict[key],
                  let figure = figures[key]
            else { return }

            var curTime = player.currentTime

            let timeout = 1 / Double(samples.first(where: { $0.id == key })!.frequency)
            while curTime - powers.1 - timeout > 0 {
                curTime = curTime - powers.1 - timeout
            }
            let animVal = powers.0[Int(curTime / powers.1 * Double(powers.0.count))]
            figure.transform = CGAffineTransform(scaleX: CGFloat(animVal), y: CGFloat(animVal))
        }
    }
}
