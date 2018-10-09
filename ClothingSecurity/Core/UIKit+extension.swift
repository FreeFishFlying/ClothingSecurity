//
//  UIKit+extension.swift
//  blackboard
//
//  Created by kingxt on 2017/10/19.
//  Copyright © 2017年 xkb. All rights reserved.
//

import Foundation
//import HUD
import ReactiveSwift
import Result
import SnapKit
import UIKit

private var AssociatedUIViewTapHandle: Void?
private var AssociatedDisposableHandle: Void?

extension UIViewController {
    private class InternalTapGestureRecognizer: UITapGestureRecognizer {}

    public var safeAreaTopLayoutGuide: SnapKit.ConstraintItem {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.snp.top
        } else {
            return topLayoutGuide.snp.bottom
        }
    }

    @objc public var autoHideKeyboard: Bool {
        get {
            return (objc_getAssociatedObject(self, &AssociatedUIViewTapHandle) as? NSNumber)?.boolValue ?? false
        }
        set {
            if autoHideKeyboard == newValue {
                return
            }
            objc_setAssociatedObject(self, &AssociatedUIViewTapHandle, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if newValue {
                let tap = InternalTapGestureRecognizer(target: self, action: #selector(hideKeyboard))
                view.addGestureRecognizer(tap)
            } else {
                view.gestureRecognizers?.forEach({ item in
                    if item is InternalTapGestureRecognizer {
                        view.removeGestureRecognizer(item)
                    }
                })
            }
        }
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}

private var defaultBeyondLimitCallback: () -> Void = { () in
//    HUD.tip(text: "超过最大输入长度")
}

extension Range where Bound == String.Index {
    var nsRange: NSRange {
        return NSRange(location: lowerBound.encodedOffset,
                       length: upperBound.encodedOffset -
                           lowerBound.encodedOffset)
    }
}

extension String {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }

    func transformToPinYin() -> String {

        let mutableString = NSMutableString(string: self)
        // 把汉字转为拼音
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        // 去掉拼音的音标
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)

        let string = String(mutableString)
        // 去掉空格
        return string.replacingOccurrences(of: " ", with: "")
    }
}

extension UIButton {

    @objc func set(image anImage: UIImage?, title: String,
                   titlePosition: UIView.ContentMode, additionalSpacing: CGFloat, state: UIControl.State) {
        imageView?.contentMode = .center
        setImage(anImage, for: state)

        positionLabelRespectToImage(title: title, position: titlePosition, spacing: additionalSpacing)

        titleLabel?.contentMode = .center
        setTitle(title, for: state)
    }

    private func positionLabelRespectToImage(title: String, position: UIView.ContentMode,
                                             spacing: CGFloat) {
        let imageSize = imageRect(forContentRect: frame)
        let titleFont = titleLabel?.font!
        let titleSize = title.size(withAttributes: [NSAttributedString.Key.font: titleFont!])

        var titleInsets: UIEdgeInsets
        var imageInsets: UIEdgeInsets

        switch position {
        case .top:
            titleInsets = UIEdgeInsets(top: -(imageSize.height + titleSize.height + spacing),
                                       left: -(imageSize.width), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
        case .bottom:
            titleInsets = UIEdgeInsets(top: (imageSize.height + titleSize.height + spacing),
                                       left: -(imageSize.width), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
        case .left:
            titleInsets = UIEdgeInsets(top: 0, left: -(imageSize.width * 2), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0,
                                       right: -(titleSize.width * 2 + spacing))
        case .right:
            titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -spacing)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        default:
            titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }

        titleEdgeInsets = titleInsets
        imageEdgeInsets = imageInsets
    }
}
