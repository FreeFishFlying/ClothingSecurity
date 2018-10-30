//
//  CaptionInputView.swift
//  Components-Swift
//
//  Created by kingxt on 6/9/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa
import Core

class CaptionInputView: UIView {

    fileprivate lazy var containerView: UIView = UIView()

    public var confirmInputCallback: ((_ text: String) -> Void)?

    public var text: String {
        set {
            growingTextView.text = newValue
        }
        get {
            return growingTextView.text
        }
    }

    fileprivate lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    fileprivate lazy var entryImageView: UIImageView = {
        let imageView = UIImageView()
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 16, height: 16), false, 0.0)
        var context: CGContext? = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColorRGBA(0xFFFFFF, 0.1).cgColor)
        var path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 16, height: 16), cornerRadius: 16)
        path.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        UIGraphicsEndImageContext()
        imageView.image = image
        return imageView
    }()

    fileprivate lazy var growingTextView: GrowingTextView = {
        let textView = GrowingTextView()
        textView.getInputTextView().keyboardAppearance = .dark
        textView.getInputTextView().textColor = .white
        textView.maxNumberOfLines = 3
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.returnKeyType = UIReturnKeyType.done
        textView.heightValues.take(during: self.reactive.lifetime).observeValues { [weak self] textView, height in
            if let strongSelf = self {
                strongSelf.growingTextView(textView: textView, changeHeight: height)
            }
        }
        textView.shouldChangeTextInRange = { [weak self] (_: NSRange, replacementText: String) -> Bool in
            if replacementText == "\n" {
                self?.growingTextView.resignFirstResponder()
                return false
            }
            return true
        }
        textView.textValues.take(during: self.reactive.lifetime).observeValues { [weak self] textView, text in
            if let strongSelf = self {
                strongSelf.growingTextView(textView: textView, changeText: text)
            }
        }
        textView.statusValues.take(during: self.reactive.lifetime).observeValues({ [weak self] _, begin in
            if !begin {
                if let strongSelf = self {
                    strongSelf.confirmInputCallback?(strongSelf.growingTextView.text)
                }
            }
        })
        return textView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initalizeSubviews()
        addNotification()
    }

    private func initalizeSubviews() {
        addSubview(backgroundImageView)
        addSubview(containerView)
        containerView.addSubview(entryImageView)
        containerView.addSubview(growingTextView)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(6)
            make.right.equalTo(-6)
        }
        growingTextView.snp.makeConstraints { make in
            make.top.equalTo(7)
            make.bottom.equalTo(-7)
            make.left.equalTo(containerView).offset(5)
            make.right.equalTo(containerView).offset(-5)
        }
        entryImageView.snp.makeConstraints { make in
            make.left.equalTo(growingTextView).offset(-3)
            make.right.equalTo(growingTextView).offset(3)
            make.top.equalTo(growingTextView)
            make.bottom.equalTo(growingTextView)
        }
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @discardableResult
    public override func resignFirstResponder() -> Bool {
        return growingTextView.resignFirstResponder()
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return growingTextView.becomeFirstResponder()
    }

    override var isFirstResponder: Bool {
        return growingTextView.isFirstResponder
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: keyboard notification
extension CaptionInputView {

    func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(note: Notification) {
        if growingTextView.isFirstResponder {
            if let keyboardBounds = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                let superview = superview,
                let userInfo = note.userInfo {
                let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.2
                let convertRect = superview.convert(keyboardBounds, from: nil)
                let keyboardHeight = superview.frame.size.height - convertRect.origin.y

                let options = UIView.AnimationOptions(rawValue: UInt((userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
                UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                    self.pin.bottom(keyboardHeight)
                }, completion: { _ in

                })
            }
        }
    }

    @objc private func keyboardWillHide(note: Notification) {
        if growingTextView.isFirstResponder {
            if let userInfo = note.userInfo {
                let options = UIView.AnimationOptions(rawValue: UInt((userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
                let duration = note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.2
                var safeBottomAreaHeight: CGFloat = 0
                if #available(iOS 11.0, *) {
                    safeBottomAreaHeight = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
                }
                UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                    self.pin.bottom(46 + safeBottomAreaHeight)
                }, completion: nil)
            }
        }
    }
}

// MARK: growing text view siganl
extension CaptionInputView {

    fileprivate func growingTextView(textView _: GrowingTextView, changeHeight height: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.pin.bottom(self.superview!.frame.height - self.frame.maxY).height(height + 25)
        }
    }

    fileprivate func growingTextView(textView _: GrowingTextView, changeText text: String?) {
        if text == "\n" {
            growingTextView.resignFirstResponder()
        }
    }
}
