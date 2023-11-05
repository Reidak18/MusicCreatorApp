//
//  File.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 05.11.2023.
//

import UIKit

class UIBlocker {
    private let parentView: UIView

    init(parentView: UIView) {
        self.parentView = parentView
    }

    func blockUI(exceptTag: Int) -> UIAlertController? {
        if UserDefaults.standard.bool(forKey: StringConstants.showDisableAlert.rawValue) == true {
            disableAll(exceptTag: exceptTag)
        } else {
            let alert = UIAlertController(title: "Отключение UI",
                                          message: "UI будет отключен на время работы функции. Вы можете вернуться в режим редактирования повторным нажатием на кнопку",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: { [weak self] _ in
                self?.disableAll(exceptTag: IntConstants.microButtonTag.rawValue)
                UserDefaults.standard.set(true, forKey: StringConstants.showDisableAlert.rawValue)
            }))
            return alert
        }

        return nil
    }

    func releaseUI(exceptTags: Set<Int>) {
        for subview in UIView.getAllSubviews(from: parentView, types: [UIControl.self, UITableViewCell.self]) {
            if !exceptTags.contains(subview.tag) {
                if let control = subview as? UIControl {
                    control.isEnabled = true
                } else if let cell = subview as? UITableViewCell {
                    cell.isUserInteractionEnabled = true
                }
            }
        }
    }

    private func disableAll(exceptTag: Int) {
        for subview in UIView.getAllSubviews(from: parentView, types: [UIControl.self, UITableViewCell.self]) {
            if subview.tag != exceptTag {
                if let control = subview as? UIControl {
                    control.isEnabled = false
                } else if let cell = subview as? UITableViewCell {
                    cell.isUserInteractionEnabled = false
                }
            }
        }
    }
}
