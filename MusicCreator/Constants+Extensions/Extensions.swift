//
//  Extensions.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 31.10.2023.
//

import UIKit

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

extension Array<Float> {
    func normalized() -> Self {
        guard let maximum = self.max(),
              let minimum = self.min()
        else { return self }

        let difference = maximum - minimum

        var normalized: [Float]
        if difference != 0 {
            normalized = self.map({ ($0 - minimum) / difference })
        } else {
            normalized = self
        }

        return normalized
    }
}
