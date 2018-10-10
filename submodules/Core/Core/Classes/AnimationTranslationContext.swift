//
//  AnimationTranslationContext.swift
//  Components-Swift
//
//  Created by kingxt on 5/22/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import Result
import pop

public class AnimationTranslationContext {

    public enum State: Int {
        case willTranslationIn
        case didTranslationIn
        case willTranslationOut
        case didTranslationOut
    }

    public init() {
    }

    public var fromView: UIView?
    public var dismissTargetRect: ((_ position: Int?) -> (CGRect, UIView.ContentMode?))?

    public var dismissalView: UIView?

    public var cornerRadius: CGFloat = 0

    fileprivate let (stateOutput, stateInput) = Signal<State, NoError>.pipe()

    public func translationIn(on contextView: UIView, toView: UIImageView, delayHideTime: TimeInterval = 0) -> Bool {
        guard let animationView = fromView else {
            return false
        }
        let fromRect = animationView.convert(animationView.frame, to: contextView)
        if animationView is UIImageView {
            let beginImageView = fromView as! UIImageView
            if (beginImageView.contentMode == .scaleAspectFit || beginImageView.contentMode == .scaleAspectFill) &&
                (toView.contentMode == .scaleAspectFit || toView.contentMode == .scaleAspectFill) {

                let translationView: AspectModeScaleImageView = AspectModeScaleImageView(frame: fromRect)
                translationView.image = beginImageView.image
                translationView.layer.cornerRadius = cornerRadius
                translationView.layer.masksToBounds = true
                contextView.addSubview(translationView)

                let toFrame = toView.frame
                let mode: AspectModeScaleImageView.ScaleAspect = toView.contentMode == .scaleAspectFill ? .fill : .fit
                translationView.animate(mode, frame: toFrame, duration: 0.25, delay: 0, completion: { _ in
                    self.stateInput.send(value: .didTranslationIn)
                    if delayHideTime > 0 {
                        delay(delayHideTime, closure: {
                            translationView.removeFromSuperview()
                        })
                    } else {
                        translationView.removeFromSuperview()
                    }
                })
                return true
            }
        }

        return translationIn(on: contextView, toRect: toView.frame, contentMode: toView.contentMode, delayHideTime: delayHideTime)
    }

    public func stateChangeSignal() -> SignalProducer<State, NoError> {
        return SignalProducer<State, NoError>.init(stateOutput)
    }

    @discardableResult public func translationIn(on contextView: UIView, toRect: CGRect, contentMode: UIView.ContentMode? = nil, delayHideTime: TimeInterval = 0) -> Bool {
        if let fromView = fromView {
            var toRect = toRect
            if contentMode != nil {
                let size = ImageUtils.scaleToSize(size: fromView.frame.size, maxSize: toRect.size)
                toRect = toRect.fit(size: size, mode: contentMode!)
            }
            stateInput.send(value: .willTranslationIn)

            let fromRect = fromView.frame
            let animationView = fromView

            contextView.addSubview(animationView)
            let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
            animation?.springSpeed = 12
            animation?.springBounciness = 1
            animation?.fromValue = NSValue(cgRect: fromRect)
            animation?.toValue = NSValue(cgRect: toRect)
            animation?.completionBlock = { (_: POPAnimation?, _: Bool) -> Void in
                self.stateInput.send(value: .didTranslationIn)
                if delayHideTime > 0 {
                    delay(delayHideTime, closure: {
                        animationView.removeFromSuperview()
                    })
                } else {
                    animationView.removeFromSuperview()
                }
            }
            animationView.pop_add(animation, forKey: "frameAnimation")
            return true
        }
        stateInput.send(value: .willTranslationIn)
        stateInput.send(value: .didTranslationIn)
        return false
    }

    @discardableResult public func translationOut(on contextView: UIView, delayHideTime: TimeInterval = 0, position: Int? = nil) -> Bool {
        if let dismissalView = dismissalView {
            if let result = dismissTargetRect?(position) {
                stateInput.send(value: .willTranslationOut)
                var toFrame = result.0
                if result.1 != nil {
                    toFrame = toFrame.fit(size: dismissalView.frame.size, mode: result.1!)
                }
                let fromRect = dismissalView.frame

                let animationView = dismissalView.superview == nil ? dismissalView : dismissalView.snapshotView(afterScreenUpdates: false) ?? dismissalView
                animationView.frame = fromRect

                contextView.addSubview(animationView)
                let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
                animation?.springSpeed = 12
                animation?.springBounciness = 1
                animation?.fromValue = NSValue(cgRect: fromRect)
                animation?.toValue = NSValue(cgRect: toFrame)
                animation?.completionBlock = { (_: POPAnimation?, _: Bool) -> Void in
                    self.stateInput.send(value: .didTranslationOut)
                    if delayHideTime > 0 {
                        delay(delayHideTime, closure: {
                            animationView.removeFromSuperview()
                        })
                    } else {
                        animationView.removeFromSuperview()
                    }
                }
                animationView.pop_add(animation, forKey: "frameAnimation")
                return true
            }
        }
        stateInput.send(value: .willTranslationOut)
        stateInput.send(value: .didTranslationOut)
        return false
    }
}
