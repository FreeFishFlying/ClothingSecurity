//
//  KeyboardFollowingView.swift
//  Components
//
//  Created by kingxt on 7/23/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import UIKit

open class KeyboardFollowingView: UIView {

    public var offset: CGFloat = 0
    public private(set) var keyboardVisibleHeight: CGFloat = 0

    public override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardFollowingView.keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardFollowingView.keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Notification

    @objc open func keyboardWillShowNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let frame = frameValue.cgRectValue
                keyboardVisibleHeight = frame.size.height
            }

            updateConstant()
            switch (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber, userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber) {
            case let (.some(duration), .some(curve)):

                let options = UIView.AnimationOptions(rawValue: curve.uintValue)

                UIView.animate(
                    withDuration: TimeInterval(duration.doubleValue),
                    delay: 0,
                    options: options,
                    animations: {
                        self.superview?.layoutIfNeeded()
                        return
                    }, completion: { _ in
                })
            default:

                break
            }
        }
    }

    @objc open func keyboardWillHideNotification(_ notification: NSNotification) {
        keyboardVisibleHeight = 0
        updateConstant()

        if let userInfo = notification.userInfo {

            switch (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber, userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber) {
            case let (.some(duration), .some(curve)):

                let options = UIView.AnimationOptions(rawValue: curve.uintValue)

                UIView.animate(
                    withDuration: TimeInterval(duration.doubleValue),
                    delay: 0,
                    options: options,
                    animations: {
                        self.superview?.layoutIfNeeded()
                        return
                    }, completion: { _ in
                })
            default:
                break
            }
        }
    }

    open func updateConstant() {
        if self.superview != nil {
            if keyboardVisibleHeight <= 0 {
                snp.updateConstraints { make in
                    if #available(iOS 11.0, *) {
                        make.bottom.equalTo(-keyboardVisibleHeight - offset - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0))
                    } else {
                        make.bottom.equalTo(-keyboardVisibleHeight - offset)
                    }
                }
            } else {
                snp.updateConstraints { make in
                    make.bottom.equalTo(-keyboardVisibleHeight - offset)
                }
            }
        }
    }
}
