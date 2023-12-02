//
//  VisualView.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 02.12.2023.
//

import Foundation
import UIKit

class VisualView: UIView {
    var curTime = 0
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    private func setupView() {
        backgroundColor = .black
        translatesAutoresizingMaskIntoConstraints = false

        label.tintColor = .white
        label.font = .systemFont(ofSize: FontSize.timer.rawValue)
        label.textAlignment = .center
        label.text = "0:00"
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        _ = Timer.scheduledTimer(timeInterval: 1,
                                         target: self,
                                         selector: #selector(updateTimer),
                                         userInfo: nil, repeats: true)
    }

    @objc func updateTimer() {
        curTime += 1
        let minutes = curTime / 60
        let seconds = curTime % 60
        var str = "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
        label.text = str
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
