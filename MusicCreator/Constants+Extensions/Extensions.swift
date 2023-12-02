//
//  Extensions.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 31.10.2023.
//

import UIKit
import AVFAudio

struct Weak<T> {
    private weak var _value: AnyObject?
    var value: T? {
        get {
            return _value as? T
        }
        set {
            _value = newValue as? AnyObject
        }
    }

    init(_ _value: AnyObject? = nil) {
        self._value = _value
    }
}

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

extension UIView {
    class func getAllSubviews<T: UIView>(from parentView: UIView) -> [T] {
        return parentView.subviews.flatMap { subView -> [T] in
            var result = getAllSubviews(from: subView) as [T]
            if let view = subView as? T { result.append(view) }
            return result
        }
    }

    class func getAllSubviews(from parentView: UIView, types: [UIView.Type]) -> [UIView] {
        return parentView.subviews.flatMap { subView -> [UIView] in
            var result = getAllSubviews(from: subView) as [UIView]
            for type in types {
                if subView.classForCoder == type {
                    result.append(subView)
                    return result
                }
            }
            return result
        }
    }
}

extension FileManager {
    func getDocumentsPath(filename: String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent(filename)
    }
}

extension AVAudioPlayerNode {
    var currentTime: TimeInterval {
        get {
            if let nodeTime: AVAudioTime = self.lastRenderTime,
               let playerTime: AVAudioTime = self.playerTime(forNodeTime: nodeTime) {
                return Double(playerTime.sampleTime)
            }
            return 0
        }
    }
}
