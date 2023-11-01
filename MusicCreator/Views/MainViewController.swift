//
//  ViewController.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 30.10.2023.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController {
    let paramsView = ParamsView()
    let layersView = LayersView()
    let bottomPanelView = BottomPanelView()

    override func loadView() {
        super.loadView()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.backgroundColor = .backgroundPrimary
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        let topPanelView = TopPanelView()
        view.addSubview(topPanelView)

        let backgroundView = GradientView()
        backgroundView.setColors(colors: [UIColor.clear, UIColor.customPurpleColor])
        backgroundView.addArrangedSubview(paramsView)
        layersView.setSamplesNames(samples: [Sample(name: "Гитара"), Sample(name: "Ударные"), Sample(name: "Духовые")])
        layersView.isHidden = true
        backgroundView.addArrangedSubview(layersView)
        stackView.addArrangedSubview(backgroundView)

        bottomPanelView.delegate = self
        stackView.addArrangedSubview(bottomPanelView)

        NSLayoutConstraint.activate([
            topPanelView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topPanelView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            topPanelView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),

            backgroundView.heightAnchor.constraint(equalTo: backgroundView.widthAnchor, multiplier: 1.35),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
        ])
    }

    var player: AVAudioPlayer?
    lazy var displayLink: CADisplayLink = CADisplayLink(target: self, selector: #selector(updatePlaybackStatus))

    @objc func updatePlaybackStatus() {
        guard let player = player
        else { return }
        let playbackProgress = Float(player.currentTime / player.duration)
        DispatchQueue.main.async {
            self.bottomPanelView.setWaveformProgress(progress: playbackProgress)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let path = Bundle.main.path(forResource: "Taxi", ofType: ".mp3")!
        let url = URL(fileURLWithPath: path)
        let audioFile: AVAudioFile
        do {
            audioFile = try AVAudioFile(forReading: url)
        } catch(let error) {
            print(error)
            return
        }

        let waveformCreator = WaveformCreator()
        waveformCreator.averagePowers(audioFile: audioFile, numberOfFrames: 75, completionHandler: { result in
            switch result {
            case .success(let resultArray):
                guard let maxPower = resultArray.max(),
                      let minPower = resultArray.min()
                else { return }

                let diff = maxPower - minPower
                var normalized: [Float]
                if diff != 0 {
                    normalized = resultArray.map({ ($0 - minPower) / diff })
                } else {
                    normalized = resultArray
                }
                DispatchQueue.main.async {
                    let img = waveformCreator.drawWaveform(frame: CGRect(x: 0, y: 0, width: 363, height: 56),
                                                           traitsLengths: normalized)
                    self.bottomPanelView.setWaveformParams(background: img)
                }

                self.player = try! AVAudioPlayer(contentsOf: url)
                self.player?.play()
                self.displayLink.add(to: .main, forMode: .common)
            case .failure(let error):
                print(error)
            }

        })
    }
}

extension MainViewController: StylesWindowOpener {
    func openStylesWindow(viewType: CurrentViewType) {
        layersView.isHidden = viewType != .layers
        paramsView.isHidden = viewType != .params
    }
}
