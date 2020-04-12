//
//  OverlayViewController.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 2017/2/26.
//  Copyright © 2017 kingxt. All rights reserved.
//

import UIKit
import pop

let SwipeMinimumVelocity: CGFloat = 600.0
let SwipeDistanceThreshold: CGFloat = 200.0

open class OverlayViewController: UIViewController {

    public weak var overlayWindow: OverlayControllerWindow?
    weak var panToDismissView: UIView?

    private var dismissBeginPosition = CGPoint.zero
    private var dismissTranslationInitFrame = CGRect.zero

    public private(set) var panToDismissGestureRecognizer: UIPanGestureRecognizer?
    public var willDissmiss: (() -> Void)?

    open var backViewMaxAlpha: CGFloat = 1 {
        didSet {
            backView.alpha = backViewMaxAlpha
        }
    }

    open func dismiss() {
        willDissmiss?()
        overlayWindow?.dismiss()
    }

    open func show() {
        let window = OverlayControllerWindow(contentController: self)
        overlayWindow = window
        window.show()
    }

    open func enablePanToDismiss(target: UIView, animationTargetView: UIView) {
        if let panGestureRecognizer = self.panToDismissGestureRecognizer {
            panGestureRecognizer.view?.removeGestureRecognizer(panGestureRecognizer)
        }

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panToDismissGestureRecognized))
        target.addGestureRecognizer(panGestureRecognizer)
        panToDismissView = animationTargetView
        self.panToDismissGestureRecognizer = panGestureRecognizer
    }

    open func canPanToDismiss() -> Bool {
        return true
    }

    @objc open func panToDismissGestureRecognized(gestureRecognizer: UIPanGestureRecognizer) {
        let gesPoint: CGPoint = gestureRecognizer.location(in: view)
        if !canPanToDismiss() {
            return
        }
        guard let panToDismissView = self.panToDismissView else {
            return
        }
        switch gestureRecognizer.state {
        case .began:
            dismissBeginPosition = gesPoint
            dismissTranslationInitFrame = panToDismissView.frame
            dismissTransitionWillBegin()
        case .changed:
            let yDistance = gesPoint.y - dismissBeginPosition.y
            let xDistance = gesPoint.x - dismissBeginPosition.x
            let dismissProgress = self.dismissProgress(forSwipeDistance: yDistance)
            updateDismissTransition(withProgress: dismissProgress, animated: false)
            updateDismissTransitionMovement(yDistance: yDistance, xDistance: xDistance, animated: false)
        case .ended:
            var swipeVelocity: CGFloat = gestureRecognizer.velocity(in: view).y
            if abs(swipeVelocity) < SwipeMinimumVelocity {
                swipeVelocity = (swipeVelocity < 0.0 ? -1.0 : 1.0) * SwipeMinimumVelocity
            }
            let transitionOut: ((_: CGFloat) -> Bool) = { [weak self] (_ swipeVelocity: CGFloat) -> Bool in
                if let strongSelf = self {
                    strongSelf.beginTransitionOut(withVelocity: swipeVelocity)
                    return true
                }
                return false
            }
            let distance = gesPoint.y - dismissBeginPosition.y
            if abs(distance) < SwipeDistanceThreshold {
                updateDismissTransition(withProgress: 0, animated: true)
                updateDismissTransitionMovement(animated: true, completion: {
                    self.dismissTransitionDidCancel()
                })
            } else {
                _ = transitionOut(swipeVelocity)
            }
            dismissBeginPosition = CGPoint.zero
            dismissTranslationInitFrame = CGRect.zero
        case .cancelled:
            updateDismissTransition(withProgress: 0, animated: true)
            updateDismissTransitionMovement(animated: true, completion: {
                self.dismissTransitionDidCancel()
            })
            dismissBeginPosition = CGPoint.zero
            dismissTranslationInitFrame = CGRect.zero
        default:
            break
        }
    }

    open func beginTransitionOut(withVelocity _: CGFloat) {
        guard let panToDismissView = self.panToDismissView else {
            dismissTransitionDidFinish()
            return dismiss()
        }
        // slide down to dismiss
        self.panToDismissView?.isUserInteractionEnabled = false
        let frame = panToDismissView.frame
        let finalRect = CGRect(x: frame.origin.x, y: view.frame.size.height + frame.size.height, width: frame.size.width, height: frame.size.height)
        UIView.animate(withDuration: 0.25, animations: {
            self.panToDismissView?.frame = finalRect
            self.backView.alpha = 0
        }) { _ in
            self.dismissTransitionDidFinish()
            self.dismiss()
        }
    }

    open func dismiss(animationView: UIView, displayFrame: CGRect, animationContainerEdge: UIEdgeInsets = UIEdgeInsets.zero,
                      toFrame: CGRect, fromContentMode: UIView.ContentMode, toContentMode: UIView.ContentMode, cornerRadius: CGFloat = 0) {
        guard let panToDismissView = self.panToDismissView else {
            dismissTransitionDidFinish()
            return dismiss()
        }

        if fromContentMode == toContentMode {
            let animationContainerView = UIView(frame: view.bounds.inset(by: animationContainerEdge))
            animationContainerView.layer.masksToBounds = true
            view.addSubview(animationContainerView)
            let newFrame = panToDismissView.convert(panToDismissView.frame, to: animationContainerView)
            animationContainerView.addSubview(panToDismissView)
            panToDismissView.frame = newFrame
            let toFrame = view.convert(toFrame, to: animationContainerView)

            let frameAnimation = POPBasicAnimation(propertyNamed: kPOPViewFrame)
            frameAnimation?.autoreverses = false
            frameAnimation?.removedOnCompletion = true
            frameAnimation?.duration = 0.2
            frameAnimation?.fromValue = NSValue(cgRect: panToDismissView.frame)
            frameAnimation?.toValue = NSValue(cgRect: toFrame)
            frameAnimation?.completionBlock = { _, _ in
                self.dismissTransitionDidFinish()
                DispatchQueue.main.async {
                    self.dismiss()
                }
            }
            panToDismissView.pop_add(frameAnimation, forKey: "animationOut")
        } else {
            let animationContainerView = UIView(frame: view.bounds.inset(by: animationContainerEdge))
            animationContainerView.layer.masksToBounds = true
            view.addSubview(animationContainerView)
            let toFrame = view.convert(toFrame, to: animationContainerView)

            let a = panToDismissView.convert(animationView.frame, to: animationContainerView)
            let b = displayFrame.applying(panToDismissView.transform)
            let final = CGRect(x: a.origin.x + b.origin.x, y: a.origin.y + b.origin.y, width: b.size.width, height: b.size.height)

            let translationView: AspectModeScaleImageView = AspectModeScaleImageView(frame: final)
            if animationView is UIImageView {
                translationView.image = (animationView as! UIImageView).image
            } else {
                translationView.image = UIImage(view: animationView).crop(rect: displayFrame)
            }
            translationView.layer.cornerRadius = cornerRadius
            translationView.layer.masksToBounds = true

            panToDismissView.alpha = 0
            translationView.contentMode = fromContentMode
            animationContainerView.addSubview(translationView)
            let mode: AspectModeScaleImageView.ScaleAspect = toContentMode == .scaleAspectFill ? .fill : .fit
            translationView.animate(mode, frame: toFrame, duration: 0.4, delay: 0, completion: { _ in
                self.dismissTransitionDidFinish()
                DispatchQueue.main.async {
                    self.dismiss()
                }
            })
        }

        let animationBackground = POPBasicAnimation(propertyNamed: kPOPViewBackgroundColor)
        animationBackground?.autoreverses = false
        animationBackground?.duration = 0.2
        animationBackground?.removedOnCompletion = true
        animationBackground?.fromValue = UIColor.black
        animationBackground?.toValue = UIColor.clear
        self.backView.pop_add(animationBackground, forKey: "animationBackground")
    }

    private func updateDismissTransitionMovement(yDistance: CGFloat = 0, xDistance: CGFloat = 0, animated: Bool = false, completion: (() -> Void)? = nil) {
        guard let panToDismissView = self.panToDismissView else {
            return
        }
        let targetPosition = CGPoint(x: dismissTranslationInitFrame.midX + min(150, xDistance / 3), y: dismissTranslationInitFrame.midY + yDistance)
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                panToDismissView.center = targetPosition
            }, completion: { _ in
                completion?()
            })
        } else {
            panToDismissView.center = targetPosition
            completion?()
        }
    }

    open func updateDismissTransition(withProgress progress: CGFloat, animated: Bool) {
        let alpha: CGFloat = max(backViewMaxAlpha - max(0.0, min(1, progress)), backViewMaxAlpha / 2)
        if animated {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.backView.alpha = alpha
            })
        } else {
            backView.alpha = alpha
        }
        let scale = max(0.5, 1 - progress / 5)
        if progress == 0 {
            panToDismissView?.transform = CGAffineTransform.identity
        } else {
            panToDismissView?.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }

    open func dismissTransitionWillBegin() {
    }

    open func dismissTransitionDidCancel() {
    }

    open func dismissTransitionDidFinish() {
    }

    private func dismissProgress(forSwipeDistance distance: CGFloat) -> CGFloat {
        return max(0.0, min(1.0, abs(distance / 150.0)))
    }

    public private(set) lazy var backView: UIView = {
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: 1280, height: 1280))
        backView.center = self.view.center
        backView.alpha = self.backViewMaxAlpha
        backView.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleBottomMargin]
        backView.backgroundColor = UIColor.black
        self.view.addSubview(backView)
        self.view.sendSubviewToBack(backView)
        return backView
    }()
}

public extension OverlayViewController {
    public  func enableTapToDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapToDismiss))
        backView.addGestureRecognizer(tap)
    }
    
    @objc private func tapToDismiss() {
        dismiss()
    }
}
