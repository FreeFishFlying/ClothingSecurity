//
//  FloatingViewController.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 2017/3/1.
//  Copyright © 2017 kingxt. All rights reserved.
//

import UIKit

private let FloatingViewMargin: CGFloat = 10
private let FloatingAngleEpsilon: CGFloat = 30.0
private let SlipSize: CGFloat = 40.0

open class FloatingViewController: OverlayViewController, UIGestureRecognizerDelegate {

    public static var defaultCorner: FloatingViewController.Corner = .topRight

    public enum Corner: Int {
        case none
        case topLeft
        case topRight
        case bottomRight
        case bottomLeft
    }

    public var minimalPipSize: CGSize = CGSize(width: 200, height: 200)
    public var corner: Corner = Corner.none
    public var contentView: UIView = UIView(frame: UIScreen.main.bounds)
    public var closing: Bool = false
    public var translation: Bool = false
    public var isEnableHidden = true

    private(set) var keyboardHeight: CGFloat = 0
    private(set) var hidden: Bool = false
    private(set) var maxSize: CGSize = CGSize.zero
    private var highVelocityOnGestureStart: Bool = false

    private var arrowOnRightSide: Bool = false {
        didSet {
            var arrowX: CGFloat = 0
            if self.arrowOnRightSide {
                self.arrowView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                arrowX = floor((SlipSize - self.arrowView.frame.size.width) / 2.0)
            } else {
                self.arrowView.transform = CGAffineTransform.identity
                arrowX = self.contentView.frame.size.width - SlipSize + floor((SlipSize - self.arrowView.frame.size.width) / 2.0)
            }
            self.arrowView.frame = CGRect(x: arrowX, y: floor((self.contentView.frame.size.height - self.arrowView.frame.size.height) / 2.0), width: self.arrowView.frame.size.width, height: self.arrowView.frame.size.height)
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        view.addSubview(contentView)
        contentView.addGestureRecognizer(panGestureRecognizer)
        contentView.addGestureRecognizer(pinchGestureRecognizer)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        let duration: TimeInterval = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let curve: UInt = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let screenKeyboardFrame: CGRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let keyboardFrame: CGRect = view.convert(screenKeyboardFrame, from: nil)
        var keyboardHeight: CGFloat = (keyboardFrame.size.height <= CGFloat.ulpOfOne || keyboardFrame.size.width <= CGFloat.ulpOfOne) ? 0.0 : (view.frame.size.height - keyboardFrame.origin.y)
        keyboardHeight = max(keyboardHeight, 0.0)
        if keyboardFrame.origin.y + keyboardFrame.size.height < view.frame.size.height - CGFloat.ulpOfOne {
            keyboardHeight = 0.0
        }
        self.keyboardHeight = keyboardHeight
        UIView.animate(withDuration: duration, delay: 0.0, options: [UIView.AnimationOptions(rawValue: curve)], animations: { () -> Void in
            self.layoutView(at: self.corner, hidden: self.hidden)
        }, completion: { _ in })
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let minSide: CGFloat = min(view.frame.size.width, view.frame.size.height)
        let maxSide: CGFloat = max(view.frame.size.width, view.frame.size.height)
        maxSize = CGSize(width: minSide - FloatingViewMargin * 2, height: floor(maxSide / 1.6667))
    }

    public func enableGesture() {
        panGestureRecognizer.isEnabled = true
        pinchGestureRecognizer.isEnabled = true
    }

    public func disableGesture() {
        panGestureRecognizer.isEnabled = false
        pinchGestureRecognizer.isEnabled = false
    }

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan))
        panGestureRecognizer.delegate = self
        return panGestureRecognizer
    }()

    private lazy var pinchGestureRecognizer: UIPinchGestureRecognizer = {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinch))
        pinchGestureRecognizer.delegate = self
        return pinchGestureRecognizer
    }()

    public func brintToFront() {
        if hidden {
            animateView(with: .allowUserInteraction, block: { () -> Void in
                self.layoutView(at: self.corner, hidden: false)
            }, completion: nil)
            setBlurred(false, animated: true)
        }
    }

    private func setPanning(_ panning: Bool) {
        arrowView.setAngled(panning, animated: true)
    }

    private lazy var arrowView: FloatingPullArrowView = {
        let arrowView = FloatingPullArrowView(frame: CGRect(x: 0, y: 0, width: 8, height: 38))
        arrowView.alpha = 0.0
        return arrowView
    }()

    private lazy var overlayBlurView: UIVisualEffectView = {
        let overlayBlurView = UIVisualEffectView(effect: nil)
        overlayBlurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayBlurView.frame = self.contentView.bounds
        overlayBlurView.isHidden = true
        self.contentView.addSubview(overlayBlurView)
        overlayBlurView.contentView.addSubview(self.arrowView)
        return overlayBlurView
    }()

    public func animateView(with options: UIView.AnimationOptions?, block: @escaping () -> Void, completion: ((_: Bool) -> Void)?) {
        if nil != options {
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.4, initialSpringVelocity: 0.1, options: [.curveLinear, options!], animations: block, completion: completion)
        } else {
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.4, initialSpringVelocity: 0.1, options: .curveLinear, animations: block, completion: completion)
        }
    }

    private func setBlurred(_ blurred: Bool, animated: Bool) {
        if (blurred && overlayBlurView.effect != nil) || (!blurred && overlayBlurView.effect == nil) {
            return
        }
        let effect: UIVisualEffect? = blurred ? UIBlurEffect(style: .light) : nil
        if animated {
            if blurred {
                overlayBlurView.isHidden = false
            }
            UIView.animate(withDuration: 0.35, animations: { () -> Void in
                self.overlayBlurView.effect = effect
                self.arrowView.alpha = blurred ? 1.0 : 0.0
            }, completion: { (_ finished: Bool) -> Void in
                if finished && !blurred {
                    self.overlayBlurView.isHidden = true
                }
            })
        } else {
            overlayBlurView.effect = effect
            overlayBlurView.isHidden = !blurred
            arrowView.alpha = blurred ? 1.0 : 0.0
        }
    }

    open override func dismiss() {
        closing = true
        super.dismiss()
    }

    open override func show() {
        let window = FloatingWindow(contentController: self)
        overlayWindow = window
        window.show()
    }

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !closing && !translation {
            layoutView(at: corner, hidden: hidden)
        }
    }

    private func layoutView(at corner: Corner, hidden: Bool) {
        self.corner = corner
        self.hidden = hidden
        contentView.frame = rectForView(at: corner, size: contentView.frame.size, hidden: hidden)
        FloatingViewController.defaultCorner = corner
        UIView.performWithoutAnimation({ () -> Void in
            self.arrowOnRightSide = (self.contentView.center.x > (self.view.frame.size.width / 2.0))
        })
    }

    open func rectForView(at corner: Corner, size: CGSize, hidden: Bool) -> CGRect {
        let statusBarSize: CGSize = UIApplication.shared.statusBarFrame.size
        var statusBarHeight: CGFloat = min(statusBarSize.width, statusBarSize.height)
        statusBarHeight = max(20, statusBarHeight)
        let isLandscape: Bool = UIApplication.shared.statusBarOrientation.isLandscape
        let topBarHeight: CGFloat = isLandscape ? 32 : 44
        let topMargin: CGFloat = FloatingViewMargin + topBarHeight + statusBarHeight
        let bottomMargin: CGFloat = FloatingViewMargin + 44.0 + keyboardHeight
        let hiddenWidth: CGFloat = size.width - SlipSize
        let bottomY: CGFloat = view.frame.size.height - bottomMargin - size.height
        let topY: CGFloat = min(bottomY, topMargin)
        switch corner {
        case .topLeft:
            var rect = CGRect(x: FloatingViewMargin, y: topY, width: size.width, height: size.height)
            if hidden {
                rect.origin.x -= hiddenWidth
            }
            return rect
        case .bottomRight:
            var rect = CGRect(x: view.frame.size.width - FloatingViewMargin - size.width, y: bottomY, width: size.width, height: size.height)
            if hidden {
                rect.origin.x += hiddenWidth
            }
            return rect
        case .bottomLeft:
            var rect = CGRect(x: FloatingViewMargin, y: bottomY, width: size.width, height: size.height)
            if hidden {
                rect.origin.x -= hiddenWidth
            }
            return rect
        default:
            var rect = CGRect(x: view.frame.size.width - FloatingViewMargin - size.width, y: topY, width: size.width, height: size.height)
            if hidden {
                rect.origin.x += hiddenWidth
            }
            return rect
        }
    }

    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation: CGPoint = gestureRecognizer.translation(in: view)
        let velocity: CGPoint = gestureRecognizer.velocity(in: view)
        switch gestureRecognizer.state {
        case .began:
            setPanning(true)
            let velocityVal: CGFloat = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
            highVelocityOnGestureStart = (velocityVal > 500)
        case .changed:
            if highVelocityOnGestureStart {
                highVelocityOnGestureStart = false
                return
            }
            contentView.center = CGPoint(x: contentView.center.x + translation.x, y: contentView.center.y + translation.y)
            arrowOnRightSide = (contentView.center.x > (view.frame.size.width / 2.0))
            var shouldHide: Bool? = false
            _ = self.targetCorner(forLocation: contentView.center, hide: &shouldHide)
            setBlurred(shouldHide!, animated: true)
            hidden = shouldHide!
            gestureRecognizer.setTranslation(CGPoint.zero, in: view)
        case .ended, .cancelled:
            var shouldHide: Bool? = false
            let velocityVal: CGFloat = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
            var targetCorner: Corner = corner
            if velocityVal > 500 {
                targetCorner = self.targetCorner(forVelocity: velocity, hide: &shouldHide)
            } else {
                targetCorner = self.targetCorner(forLocation: contentView.center, hide: &shouldHide)
            }
            animateView(with: .allowUserInteraction, block: { () -> Void in
                self.layoutView(at: targetCorner, hidden: shouldHide!)
            }, completion: nil)
            setPanning(false)
            setBlurred(shouldHide!, animated: true)
            hidden = shouldHide!
        default:
            break
        }
    }

    @objc private func handlePinch(_ gestureRecognizer: UIPinchGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let zoom: CGFloat = gestureRecognizer.scale
            let size: CGSize = contentView.frame.size
            let ratio: CGFloat = size.width / size.height
            var newWidth: CGFloat = floor(size.width * zoom)
            if newWidth >= maxSize.width {
                newWidth = maxSize.width
            } else if newWidth <= minimalPipSize.width {
                newWidth = minimalPipSize.width
            }

            var newHeight: CGFloat = newWidth / ratio
            if newHeight >= maxSize.height {
                newHeight = maxSize.height
                newWidth = newHeight * ratio
            }
            let newSize = CGSize(width: newWidth, height: newHeight)
            let center: CGPoint = contentView.center
            contentView.frame = CGRect(x: center.x - newSize.width / 2.0, y: center.y - newSize.height / 2.0, width: newSize.width, height: newSize.height)
            gestureRecognizer.scale = 1
        }
    }

    private func targetCorner(forVelocity velocity: CGPoint, hide: inout Bool?) -> Corner {
        let x: CGFloat = velocity.x
        let y: CGFloat = velocity.y
        var angle: CGFloat = atan2(y, x) * 180.0 / .pi * -1
        if angle < 0 {
            angle += 360.0
        }
        var corner: Corner = self.corner
        var shouldHide: Bool = hidden
        switch self.corner {
        case .topLeft:
            if (angle > 0 && angle < 90 - FloatingAngleEpsilon) || angle > 360 - FloatingAngleEpsilon {
                if !shouldHide {
                    corner = .topRight
                } else {
                    shouldHide = false
                }
            } else if angle > 180 + FloatingAngleEpsilon && angle < 270 + FloatingAngleEpsilon {
                corner = .bottomLeft
                shouldHide = false
            } else if angle > 270 + FloatingAngleEpsilon && angle < 360 - FloatingAngleEpsilon {
                if !shouldHide {
                    corner = .bottomRight
                } else {
                    shouldHide = false
                }
            } else if !shouldHide {
                shouldHide = true
            }

        case .topRight:
            if angle > 90 + FloatingAngleEpsilon && angle < 180 + FloatingAngleEpsilon {
                if !shouldHide {
                    corner = .topLeft
                } else {
                    shouldHide = false
                }
            } else if angle > 270 - FloatingAngleEpsilon && angle < 360 - FloatingAngleEpsilon {
                corner = .bottomRight
                shouldHide = false
            } else if angle > 180 + FloatingAngleEpsilon && angle < 270 - FloatingAngleEpsilon {
                if !shouldHide {
                    corner = .bottomLeft
                } else {
                    shouldHide = false
                }
            } else if !shouldHide {
                shouldHide = true
            }

        case .bottomLeft:
            if angle > 90 - FloatingAngleEpsilon && angle < 180 - FloatingAngleEpsilon {
                corner = .topLeft
                shouldHide = false
            } else if angle < FloatingAngleEpsilon || angle > 270 + FloatingAngleEpsilon {
                if !shouldHide {
                    corner = .bottomRight
                } else {
                    shouldHide = false
                }
            } else if angle > FloatingAngleEpsilon && angle < 90 - FloatingAngleEpsilon {
                if !shouldHide {
                    corner = .topRight
                } else {
                    shouldHide = false
                }
            } else if !shouldHide {
                shouldHide = true
            }

        case .bottomRight:
            if angle > FloatingAngleEpsilon && angle < 90 + FloatingAngleEpsilon {
                corner = .topRight
                shouldHide = false
            } else if angle > 180 - FloatingAngleEpsilon && angle < 270 - FloatingAngleEpsilon {
                if !shouldHide {
                    corner = .bottomLeft
                } else {
                    shouldHide = false
                }
            } else if angle > 90 + FloatingAngleEpsilon && angle < 180 - FloatingAngleEpsilon {
                if !shouldHide {
                    corner = .topLeft
                } else {
                    shouldHide = false
                }
            } else if !shouldHide {
                shouldHide = true
            }

        default:
            break
        }
        if isEnableHidden {
            if hide != nil {
                hide = shouldHide
            }
        }
        return corner
    }

    private func targetCorner(forLocation location: CGPoint, hide: inout Bool?) -> Corner {
        var right: Bool = false
        var bottom: Bool = false
        if location.x > view.frame.size.width / 2.0 {
            right = true
        }
        if location.y > (view.frame.size.height - keyboardHeight) / 2.0 {
            bottom = true
        }
        if isEnableHidden {
            if hide != nil && (location.x < FloatingViewMargin || location.x > view.frame.size.width - FloatingViewMargin) {
                hide = true
            }
        }
        if !right && !bottom {
            return .topLeft
        } else if right && !bottom {
            return .topRight
        } else if !right && bottom {
            return .bottomLeft
        } else {
            return .bottomRight
        }
    }
}
