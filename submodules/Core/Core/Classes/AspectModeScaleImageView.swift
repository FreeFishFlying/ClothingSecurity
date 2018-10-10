//
//  AspectModeScaleUIImageView.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 2017/4/15.
//  Copyright © 2017年 kingxt. All rights reserved.
//

import Foundation
import UIKit

open class AspectModeScaleImageView: UIView {

    public enum ScaleAspect {
        case fit
        case fill
    }

    @IBInspectable open var image: UIImage? {
        didSet {
            transitionImage.image = image
        }
    }

    internal var transitionImage: UIImageView
    fileprivate var newTransitionImageFrame: CGRect?
    fileprivate var newSelfFrame: CGRect?

    public required init?(coder aDecoder: NSCoder) {

        transitionImage = UIImageView()
        transitionImage.contentMode = .center

        super.init(coder: aDecoder)

        addSubview(transitionImage)
        transitionImage.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        transitionImage.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        clipsToBounds = true
    }

    public override init(frame: CGRect) {

        transitionImage = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        transitionImage.contentMode = .scaleAspectFit

        super.init(frame: frame)

        addSubview(transitionImage)
        clipsToBounds = true
    }

    open func animate(_ scaleAspect: ScaleAspect, frame: CGRect? = nil, duration: Double, delay: Double? = nil, completion: ((Bool) -> Void)? = nil) {
        var newFrame = self.frame
        if frame != nil {
            newFrame = frame!
        }
        initialeState(scaleAspect, newFrame: newFrame)

        var delayAnimation = 0.0
        if delay != nil {
            delayAnimation = delay!
        }
        UIView.animate(withDuration: duration, delay: delayAnimation, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [.allowAnimatedContent, .beginFromCurrentState], animations: {
            self.transitionState(scaleAspect)
        }) { finished in
            self.endState(scaleAspect)
            completion?(finished)
        }
    }

    open func initialeState(_ newScaleAspect: ScaleAspect, newFrame: CGRect) {
        if transitionImage.image == nil {
            return
        }

        if newScaleAspect == ScaleAspect.fill && contentMode == .scaleAspectFill ||
            newScaleAspect == ScaleAspect.fit && contentMode == .scaleAspectFit {
            print("UIImageViewModeScaleAspect - Warning : You are trying to animate your image to \(contentMode) but it's already set.")
        }

        let ratio = transitionImage.image!.size.width / transitionImage.image!.size.height

        if newScaleAspect == ScaleAspect.fill {
            newTransitionImageFrame = initialeTransitionImageFrame(newScaleAspect, ratio: ratio, newFrame: newFrame)
        } else {
            transitionImage.frame = initialeTransitionImageFrame(newScaleAspect, ratio: ratio, newFrame: frame)
            transitionImage.contentMode = UIView.ContentMode.scaleAspectFit
            newTransitionImageFrame = CGRect(x: 0, y: 0, width: newFrame.size.width, height: newFrame.size.height)
        }
        newSelfFrame = newFrame
    }

    /**
     If you want to animate yourself the image, you need to call this function inside the animation block

     - Parameters:
     - scaleAspect: Content mode that you want to change.

     - Returns: New frame for the image
     */
    open func transitionState(_: ScaleAspect) {
        if let newTransitionImageFrame = self.newTransitionImageFrame {
            transitionImage.frame = newTransitionImageFrame
        }
        if let newSelfFrame = self.newSelfFrame {
            super.frame = newSelfFrame
        }
    }

    /**
     If you want to animate yourself the image, you need to call this function in the completion block of the animation.

     - Parameters:
     - scaleAspect: Content mode that you want to change.

     - Returns: New frame for the image
     */
    open func endState(_ scaleAspect: ScaleAspect) {
        if scaleAspect == ScaleAspect.fill {
            transitionImage.contentMode = .scaleAspectFill
            transitionImage.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        }
    }

    open override var frame: CGRect {
        didSet {
            transitionImage.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        }
    }

    open override var contentMode: UIView.ContentMode {
        get {
            return transitionImage.contentMode
        }
        set(newContentMode) {
            transitionImage.contentMode = newContentMode
        }
    }

    fileprivate static func contentMode(_ scaleAspect: ScaleAspect) -> UIView.ContentMode {
        switch scaleAspect {
        case .fit:
            return UIView.ContentMode.scaleAspectFit
        case .fill:
            return UIView.ContentMode.scaleAspectFill
        }
    }

    fileprivate func initialeTransitionImageFrame(_ scaleAspect: ScaleAspect, ratio: CGFloat, newFrame: CGRect) -> CGRect {

        var selectFrameFormula = false

        let ratioSelf = newFrame.size.width / newFrame.size.height

        if ratio > ratioSelf {
            selectFrameFormula = true
        }

        if scaleAspect == ScaleAspect.fill {

            if selectFrameFormula {
                return CGRect(x: -(newFrame.size.height * ratio - newFrame.size.width) / 2.0, y: 0, width: newFrame.size.height * ratio, height: newFrame.size.height)
            } else {
                return CGRect(x: 0, y: -(newFrame.size.width / ratio - newFrame.size.height) / 2.0, width: newFrame.size.width, height: newFrame.size.width / ratio)
            }

        } else {

            if selectFrameFormula {
                return CGRect(x: -(frame.size.height * ratio - frame.size.width) / 2.0, y: 0, width: frame.size.height * ratio, height: frame.size.height)
            } else {
                return CGRect(x: 0, y: -(frame.size.width / ratio - frame.size.height) / 2.0, width: frame.size.width, height: frame.size.width / ratio)
            }
        }
    }
}
