//
//  Extensions.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 31.10.2023.
//

import UIKit

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

extension UIView {
    func getAllSubviews<T: UIView>(from parentView: UIView) -> [T] {
        return parentView.subviews.flatMap { subView -> [T] in
            var result = getAllSubviews(from: subView) as [T]
            if let view = subView as? T { result.append(view) }
            return result
        }
    }

    func getAllControls() -> [UIControl] {
        return self.subviews.flatMap { subView -> [UIControl] in
            var result = getAllSubviews(from: subView) as [UIControl]
            if let control = subView as? UIControl {
                result.append(control)
                return result
            }
            return result
        }
    }
}
