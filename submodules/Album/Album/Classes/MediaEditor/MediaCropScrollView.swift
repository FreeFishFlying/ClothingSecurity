//
//  MediaCropScrollView.swift
//  Components-Swift
//
//  Created by kingxt on 5/18/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import UIKit
import pop
import Core
import ObjcExceptionBridging

struct MediaCropRectangle {
    var tl: CGPoint
    var tr: CGPoint
    var bl: CGPoint
    var br: CGPoint
}

func rubberBandDistance(offset: CGFloat, dimension: CGFloat) -> CGFloat {
    let constant: CGFloat = 0.55
    let result: CGFloat = (constant * abs(offset) * dimension) / (dimension + constant * abs(offset))
    return (offset < 0.0) ? -result : result
}

class MediaCropScrollView: UIView {

    public var shouldBeginChanging: (() -> Bool)?
    public var didBeginChanging: (() -> Void)?
    public var didEndChanging: (() -> Void)?
    public var maximumZoomScale: CGFloat = 10.0
    public var minimumZoomScale: CGFloat = 1.0

    fileprivate var rotationStartScale: CGFloat = 0
    fileprivate var touchCenter = CGPoint.zero
    fileprivate var pinchCenter = CGPoint.zero
    fileprivate var pinchStartScale: CGFloat = 0
    fileprivate var mirrored: Bool = false

    fileprivate var beganInteraction: Bool = false
    public fileprivate(set) var isTracking: Bool = false
    fileprivate var endedInteraction: Bool = false
    fileprivate var fitted: Bool = false
    fileprivate var animating: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(wrapperView)
        addGestureRecognizer(panGestureRecognizer)
        addGestureRecognizer(pressGestureRecognizer)
        addGestureRecognizer(pinchGestureRecognizer)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var contentView: UIView? {
        didSet {
            if let contentView = self.contentView {
                contentView.removeFromSuperview()
                wrapperView.addSubview(contentView)
                contentView.frame = CGRect(x: 0, y: 0, width: CGFloat(contentSize.width), height: CGFloat(contentSize.height))
                if mirrored {
                    contentView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                }
                resetAndSetBounds(true)
            }
        }
    }

    public var contentSize: CGSize = CGSize.zero {
        didSet {
            _try_objc({
                self.wrapperView.frame = CGRect(x: 0, y: 0, width: self.contentSize.width, height: self.contentSize.height)
            }, { (_) in
            }) {
            }
        }
    }

    fileprivate lazy var wrapperView: UIView = {
        let view = UIView()
        view.layer.allowsEdgeAntialiasing = true
        return view
    }()

    func contentScale() -> CGFloat {
        return wrapperView.layer.value(forKeyPath: "transform.scale.x") as! CGFloat
    }

    func contentRotation() -> CGFloat {
        return wrapperView.layer.value(forKeyPath: "transform.rotation.z") as! CGFloat
    }

    func availableRect() -> CGRect {
        if contentRotation() < CGFloat.ulpOfOne || contentRotation().isNaN {
            return CGRect(origin: CGPoint.zero, size: contentSize)
        } else {
            return zoomedRect()
        }
    }

    func zoomedRect() -> CGRect {
        if contentRotation().isNaN {
            return CGRect(origin: CGPoint.zero, size: contentSize)
        }
        let rotatedContentSize: CGSize = rotated(contentSize: contentSize, rotation: contentRotation())
        if contentSize.equalTo(CGSize.zero) || rotatedContentSize.equalTo(CGSize.zero) {
            return CGRect.zero
        }
        let rotationScaleRatios = CGSize(width: CGFloat(rotatedContentSize.width / contentSize.width), height: CGFloat(rotatedContentSize.height / contentSize.height))
        let convertView = UIView(frame: CGRect(x: (bounds.size.width - contentSize.width) / 2, y: (bounds.size.height - contentSize.height) / 2, width: contentSize.width, height: contentSize.height))
        let transform = CGAffineTransform(scaleX: wrapperView.frame.size.width / contentSize.width / rotationScaleRatios.width, y: wrapperView.frame.size.height / contentSize.height / rotationScaleRatios.height)
        convertView.transform = transform
        convertView.frame = convertView.frame.offsetBy(dx: CGFloat(wrapperView.frame.origin.x - convertView.frame.origin.x), dy: CGFloat(wrapperView.frame.origin.y - convertView.frame.origin.y))

        addSubview(convertView)
        let rect = convert(CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), to: convertView)
        convertView.removeFromSuperview()
        return rect
    }

    func translateContentView(withOffset offset: CGPoint) {
        var offset = offset
        let scale: CGFloat = contentScale()
        offset.x /= scale
        offset.y /= scale
        let xComp = CGPoint(x: CGFloat(sin(CGFloat.pi / 2 + contentRotation()) * offset.x), y: CGFloat(cos(CGFloat.pi / 2 + contentRotation()) * offset.x))
        let yComp = CGPoint(x: CGFloat(cos(CGFloat.pi / 2 - contentRotation()) * offset.y), y: CGFloat(sin(CGFloat.pi / 2 - contentRotation()) * offset.y))
        wrapperView.transform = wrapperView.transform.translatedBy(x: xComp.x + yComp.x, y: xComp.y + yComp.y)
    }

    func zoom(to rect: CGRect, withFrame frame: CGRect, animated: Bool, completion: (() -> Void)?) {
        let contentRotation: CGFloat = self.contentRotation()
        if !animated {
            resetAndSetBounds(true)
        }
        let sourceAspect: CGFloat = rect.size.height / rect.size.width
        let cropAspect: CGFloat = frame.size.height / frame.size.width
        var scale: CGFloat = 1.0

        if sourceAspect > cropAspect {
            scale = frame.size.width / rect.size.width
        } else {
            scale = frame.size.height / rect.size.height
        }
        let rotatedContentSize: CGSize = rotated(contentSize: contentSize, rotation: self.contentRotation())
        let bounds = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)

        if animated {
            let centerAnimation = POPSpringAnimation(propertyNamed: kPOPViewCenter)
            centerAnimation?.fromValue = NSValue(cgPoint: wrapperView.center)
            centerAnimation?.toValue = NSValue(cgPoint: CGPoint(x: CGFloat(bounds.midX), y: CGFloat(bounds.midY)))
            centerAnimation?.springSpeed = 7
            centerAnimation?.springBounciness = 1

            let translationAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationXY)
            translationAnimation?.fromValue = wrapperView.layer.value(forKeyPath: "transform.translation")
            translationAnimation?.toValue = NSValue(cgPoint: CGPoint(x: CGFloat((rotatedContentSize.width / 2 - rect.midX) * scale), y: CGFloat((rotatedContentSize.height / 2 - rect.midY) * scale)))
            translationAnimation?.springSpeed = 7
            translationAnimation?.springBounciness = 1

            let fromScale: CGFloat = contentScale()
            let scaleAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
            scaleAnimation?.fromValue = NSValue(cgSize: CGSize(width: fromScale, height: fromScale))
            scaleAnimation?.toValue = NSValue(cgSize: CGSize(width: CGFloat(scale), height: CGFloat(scale)))
            scaleAnimation?.springSpeed = 7
            scaleAnimation?.springBounciness = 1
            scaleAnimation?.completionBlock = { _, _ in
                completion?()
            }

            wrapperView.isUserInteractionEnabled = false
            wrapperView.pop_add(centerAnimation, forKey: "position")
            wrapperView.layer.pop_add(translationAnimation, forKey: "translation")
            wrapperView.layer.pop_add(scaleAnimation, forKey: "scale")
        } else {
            wrapperView.center = CGPoint(x: CGFloat(bounds.midX), y: CGFloat(bounds.midY))
            var transform: CATransform3D = CATransform3DIdentity
            transform = CATransform3DScale(transform, scale, scale, 1.0)
            transform = CATransform3DTranslate(transform, (rotatedContentSize.width / 2 - rect.midX), (rotatedContentSize.height / 2 - rect.midY), 0)
            transform = CATransform3DRotate(transform, contentRotation, 0.0, 0.0, 1.0)
            wrapperView.layer.transform = transform

            completion?()
        }
    }

    @objc private func handlePress(gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state
        {
        case .began:

            if !beganInteraction {
                didBeginChanging?()
            }
            isTracking = true
            endedInteraction = false
            beganInteraction = true
            fitted = false
            stopAllContentAnimations()
        case .ended, .cancelled:

            beganInteraction = false
            if !endedInteraction {
                didEndChanging?()
            }
            if !fitted {
                fitContent(insideBoundsAllowScale: true, animated: true)
                fitted = true
            }
            isTracking = false
            endedInteraction = true
        default:
            break
        }
    }

    @objc private func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        let translation: CGPoint = gestureRecognizer.translation(in: wrapperView)
        switch gestureRecognizer.state
        {
        case .began:
            if !beganInteraction {
                didBeginChanging?()
            }
            isTracking = true
            endedInteraction = false
            beganInteraction = true
            fitted = false
            stopAllContentAnimations()
        case .changed:
            wrapperView.layer.transform = CATransform3DTranslate(wrapperView.layer.transform, translation.x, translation.y, 0)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self)
        case .ended, .cancelled:
            beganInteraction = false
            if !endedInteraction {
                didEndChanging?()
            }
            if !fitted {
                fitContent(insideBoundsAllowScale: true, animated: true)
                fitted = true
            }
            isTracking = false
            endedInteraction = true
        default:
            break
        }
    }

    @objc private func handlePinch(gestureRecognizer: UIPinchGestureRecognizer) {
        var scale: CGFloat = gestureRecognizer.scale
        let contentScale: CGFloat = self.contentScale()
        switch gestureRecognizer.state
        {
        case .began:
            pinchCenter = touchCenter
            pinchStartScale = contentScale
            if !beganInteraction && didBeginChanging != nil {
                didBeginChanging!()
            }
            isTracking = true
            endedInteraction = false
            beganInteraction = true
            fitted = false
            stopAllContentAnimations()
        case .changed:
            let delta = CGPoint(x: CGFloat(pinchCenter.x - wrapperView.bounds.size.width / 2.0), y: CGFloat(pinchCenter.y - wrapperView.bounds.size.height / 2.0))
            if pinchStartScale / minimumZoomScale * scale > maximumZoomScale {
                scale = maximumZoomScale / pinchStartScale * minimumZoomScale
            }
            let size: CGFloat = contentSize.width * pinchStartScale
            let newSize: CGFloat = size * scale
            let constrainedSize: CGFloat = max(minimumZoomScale * contentSize.width, min(newSize, maximumZoomScale * contentSize.width))
            let sizeDimension: CGFloat = maximumZoomScale * contentSize.width - minimumZoomScale * contentSize.width
            let rubberBandedSize: CGFloat = rubberBandDistance(offset: newSize - constrainedSize, dimension: sizeDimension)
            let finalSize: CGFloat = max(minimumZoomScale * contentSize.width * 0.25, constrainedSize + rubberBandedSize)

            var transform: CATransform3D = CATransform3DTranslate(wrapperView.layer.transform, delta.x, delta.y, 0.0)
            let scale: CGFloat = finalSize / (contentSize.width * contentScale)
            transform = CATransform3DScale(transform, scale, scale, 1.0)
            transform = CATransform3DTranslate(transform, -delta.x, -delta.y, 0)
            wrapperView.layer.transform = transform
        case .ended, .cancelled:
            beganInteraction = false
            if !endedInteraction {
                didEndChanging?()
            }
            if !fitted {
                fitContent(insideBoundsAllowScale: true, animated: true)
                fitted = true
            }
            isTracking = false
            endedInteraction = true
            break

        default:
            break
        }
    }

    func fitContent(insideBoundsAllowScale allowScale: Bool, animated: Bool, completion: (() -> Void)? = nil) {
        fitContent(insideBoundsAllowScale: allowScale, maximize: false, animated: animated, completion: completion)
    }

    func fitContent(insideBoundsAllowScale allowScale: Bool, maximize: Bool, animated: Bool, completion: (() -> Void)? = nil) {
        let boundsRect: CGRect = boundingBox(for: bounds, withRotation: contentRotation())
        let initialRect = CGRect(origin: CGPoint.zero, size: contentSize)
        let initialOffset = CGPoint(x: (bounds.size.width - contentSize.width) / 2, y: (bounds.size.height - contentSize.height) / 2)
        let currentTransform: CGAffineTransform = cropTransform()
        let centerOffset = CGPoint(x: wrapperView.center.x - boundsRect.midX, y: wrapperView.center.y - boundsRect.midY)
        let xComp = CGPoint(x: sin(CGFloat.pi / 2 + contentRotation()) * centerOffset.x, y: cos(CGFloat.pi / 2 + contentRotation()) * centerOffset.x)
        let yComp = CGPoint(x: cos(CGFloat.pi / 2 - contentRotation()) * centerOffset.y, y: sin(CGFloat.pi / 2 - contentRotation()) * centerOffset.y)

        let contentScale: CGFloat = self.contentScale()
        let r2: MediaCropRectangle = applyTransform(currentTransform.translatedBy(x: (initialOffset.x + xComp.x + yComp.x) / contentScale, y: (initialOffset.y + xComp.y + yComp.y) / contentScale), to: initialRect)
        var t = CGAffineTransform(translationX: contentSize.width / 2, y: contentSize.height / 2)
        t = t.rotated(by: -contentRotation())
        t = t.translatedBy(x: -contentSize.width / 2, y: -contentSize.height / 2)

        let r3: MediaCropRectangle = applyTransform(t, to: r2)
        var contentRect: CGRect = cgRect(from: r3)

        let translationSize = wrapperView.layer.value(forKeyPath: "transform.translation") as! CGSize

        var targetTranslation: CGPoint = CGPoint(x: translationSize.width, y: translationSize.height)
        var targetScale: CGFloat = contentScale
        var targetTransform: CATransform3D = wrapperView.layer.transform

        let fitScaleBlock: ((_: CGFloat) -> Void) = { (_ ratio: CGFloat) -> Void in
            let scaledSize = CGSize(width: CGFloat(contentRect.size.width * ratio), height: CGFloat(contentRect.size.height * ratio))
            let scaledOffset = CGPoint(x: CGFloat((contentRect.size.width - scaledSize.width) / 2), y: CGFloat((contentRect.size.height - scaledSize.height) / 2))
            contentRect = CGRect(x: CGFloat(contentRect.origin.x + scaledOffset.x), y: CGFloat(contentRect.origin.y + scaledOffset.y), width: CGFloat(scaledSize.width), height: CGFloat(scaledSize.height))
            targetTransform = CATransform3DScale(targetTransform, ratio, ratio, 1.0)
            targetScale *= ratio
        }

        let fitTranslationBlock: (() -> Void) = { () -> Void in

            let contentTL = CGPoint(x: CGFloat(contentRect.minX), y: CGFloat(contentRect.minY))
            let contentBR = CGPoint(x: CGFloat(contentRect.maxX), y: CGFloat(contentRect.maxY))
            var frameTL = CGPoint(x: CGFloat(boundsRect.minX), y: CGFloat(boundsRect.minY))
            let frameBR = CGPoint(x: CGFloat(boundsRect.maxX), y: CGFloat(boundsRect.maxY))
            if contentTL.x > frameTL.x {
                frameTL.x = contentTL.x
            }
            if contentTL.y > frameTL.y {
                frameTL.y = contentTL.y
            }
            if contentBR.x < frameBR.x {
                frameTL.x += contentBR.x - frameBR.x
            }
            if contentBR.y < frameBR.y {
                frameTL.y += contentBR.y - frameBR.y
            }

            let validBoundsRect = CGRect(x: CGFloat(frameTL.x), y: CGFloat(frameTL.y), width: CGFloat(boundsRect.size.width), height: CGFloat(boundsRect.size.height))
            let delta = CGPoint(x: CGFloat(boundsRect.midX - validBoundsRect.midX), y: CGFloat(boundsRect.midY - validBoundsRect.midY))
            targetTransform = CATransform3DTranslate(targetTransform, delta.x / targetScale, delta.y / targetScale, 0.0)
            let xComp = CGPoint(x: CGFloat(sin(CGFloat.pi / 2 - self.contentRotation()) * delta.x), y: CGFloat(cos(CGFloat.pi / 2 - self.contentRotation()) * delta.x))
            let yComp = CGPoint(x: CGFloat(cos(CGFloat.pi / 2 + self.contentRotation()) * delta.y), y: CGFloat(sin(CGFloat.pi / 2 + self.contentRotation()) * delta.y))
            targetTranslation.x += xComp.x + yComp.x
            targetTranslation.y += xComp.y + yComp.y
        }

        let applyBlock: (() -> Void) = { () -> Void in
            if animated {
                let translation: CGPoint? = self.wrapperView.layer.value(forKeyPath: "transform.translation") as? CGPoint
                let translationAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationXY)
                translationAnimation?.fromValue = translation
                translationAnimation?.toValue = CGPoint(x: CGFloat(targetTranslation.x), y: CGFloat(targetTranslation.y))
                translationAnimation?.springSpeed = 7
                translationAnimation?.springBounciness = 1

                let scaleAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
                scaleAnimation?.fromValue = CGSize(width: contentScale, height: contentScale)
                scaleAnimation?.toValue = CGSize(width: targetScale, height: targetScale)
                scaleAnimation?.springSpeed = 7
                scaleAnimation?.springBounciness = 1
                scaleAnimation?.completionBlock = { _, _ in
                    completion?()
                }

                self.wrapperView.layer.pop_add(translationAnimation, forKey: "translation")
                self.wrapperView.layer.pop_add(scaleAnimation, forKey: "scale")
            } else {
                self.wrapperView.layer.transform = targetTransform
                completion?()
            }
        }

        if !contentRect.contains(boundsRect) {
            if allowScale && (boundsRect.size.width > contentRect.size.width || boundsRect.size.height > contentRect.size.height) {
                fitScaleBlock(boundsRect.size.width / ImageUtils.scaleToSize(size: boundsRect.size, maxSize: contentRect.size).width)
            }
            fitTranslationBlock()
            applyBlock()
        } else {
            if maximize && rotationStartScale > CGFloat.ulpOfOne {
                var ratio: CGFloat = boundsRect.size.width / ImageUtils.scaleToSize(size: boundsRect.size, maxSize: contentRect.size).width
                let newScale: CGFloat = contentScale * ratio
                if newScale < rotationStartScale {
                    ratio = 1.0
                }
                fitScaleBlock(ratio)
                fitTranslationBlock()
            }
            applyBlock()
        }
    }

    func cgRect(from rect: MediaCropRectangle) -> CGRect {
        var result = CGRect()
        result.origin = rect.tl
        result.size = CGSize()
        result.size.width = rect.tr.x - rect.tl.x
        result.size.height = rect.bl.y - rect.tl.y
        return result
    }

    func applyTransform(_ transform: CGAffineTransform, to rect: CGRect) -> MediaCropRectangle {
        var t = CGAffineTransform(translationX: rect.midX, y: rect.midY)
        t = transform.concatenating(t)
        t = t.translatedBy(x: -rect.midX, y: -rect.midY)
        let r: MediaCropRectangle = rectangle(from: rect)
        return applyTransform(t, to: r)
    }

    func rectangle(from rect: CGRect) -> MediaCropRectangle {
        return MediaCropRectangle(tl: CGPoint(x: rect.origin.x, y: rect.origin.y),
                                  tr: CGPoint(x: rect.maxX, y: rect.origin.y),
                                  bl: CGPoint(x: rect.maxX, y: rect.maxY),
                                  br: CGPoint(x: rect.origin.x, y: rect.maxY))
    }

    func applyTransform(_ t: CGAffineTransform, to r: MediaCropRectangle) -> MediaCropRectangle {
        return MediaCropRectangle(tl: r.tl.applying(t), tr: r.tr.applying(t), bl: r.bl.applying(t), br: r.br.applying(t))
    }

    func boundingBox(for rect: CGRect, withRotation rotation: CGFloat) -> CGRect {
        var t = CGAffineTransform(translationX: rect.midX, y: rect.midY)
        t = t.rotated(by: rotation)
        t = t.translatedBy(x: -rect.midX, y: -rect.midY)
        return rect.applying(t)
    }

    func cropTransform() -> CGAffineTransform {
        let transform3d: CATransform3D = wrapperView.layer.transform
        let currentTransform = CGAffineTransform(a: transform3d.m11, b: transform3d.m12, c: transform3d.m21, d: transform3d.m22, tx: transform3d.m41, ty: transform3d.m42)
        return currentTransform
    }

    func setContentMirrored(_ mirrored: Bool) {
        self.mirrored = mirrored
        contentView?.transform = CGAffineTransform(scaleX: mirrored ? -1.0 : 1.0, y: 1.0)
    }

    private lazy var pressGestureRecognizer: UILongPressGestureRecognizer = {
        let pressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handlePress))
        pressGestureRecognizer.delegate = self
        pressGestureRecognizer.minimumPressDuration = 0.1
        return pressGestureRecognizer
    }()

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panGestureRecognizer.delegate = self
        return panGestureRecognizer
    }()

    private lazy var pinchGestureRecognizer: UIPinchGestureRecognizer = {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        pinchGestureRecognizer.delegate = self
        return pinchGestureRecognizer
    }()
}

extension MediaCropScrollView: UIGestureRecognizerDelegate {

    override func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        var shouldBegin: Bool = true
        if shouldBeginChanging != nil {
            shouldBegin = shouldBeginChanging!()
        }
        return shouldBegin
    }

    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }

    fileprivate func handleTouches(_ touches: Set<UITouch>?) {
        touchCenter = CGPoint.zero
        if let touches = touches {
            if touches.count < 2 {
                return
            }
            for touch in touches {
                let location: CGPoint = touch.location(in: wrapperView)
                touchCenter = CGPoint(x: CGFloat(touchCenter.x + location.x), y: CGFloat(touchCenter.y + location.y))
            }
            touchCenter = CGPoint(x: CGFloat(touchCenter.x / CGFloat(touches.count)), y: CGFloat(touchCenter.y / CGFloat(touches.count)))
        }
    }

    override func touchesBegan(_: Set<UITouch>, with event: UIEvent?) {
        handleTouches(event?.allTouches)
    }

    override func touchesMoved(_: Set<UITouch>, with event: UIEvent?) {
        handleTouches(event?.allTouches)
    }

    override func touchesEnded(_: Set<UITouch>, with event: UIEvent?) {
        handleTouches(event?.allTouches)
    }

    override func touchesCancelled(_: Set<UITouch>, with event: UIEvent?) {
        handleTouches(event?.allTouches)
    }
}

extension MediaCropScrollView {

    func stopAllContentAnimations() {
        wrapperView.layer.pop_removeAnimation(forKey: "translation")
        wrapperView.layer.pop_removeAnimation(forKey: "scale")
        animating = false
    }

    func resetAndSetBounds(_ setBounds: Bool) {
        if contentSize.equalTo(CGSize.zero) || frame.size.equalTo(CGSize.zero) {
            return
        }
        if setBounds {
            wrapperView.center = CGPoint(x: CGFloat(bounds.midX), y: CGFloat(bounds.midY))
            wrapperView.bounds = CGRect(x: 0, y: 0, width: CGFloat(contentSize.width), height: CGFloat(contentSize.height))
        }
        let sourceAspect: CGFloat = contentSize.height / contentSize.width
        let cropAspect: CGFloat = frame.size.height / frame.size.width
        var scale: CGFloat = 1.0
        if sourceAspect > cropAspect {
            scale = frame.size.width / contentSize.width
        } else {
            scale = frame.size.height / contentSize.height
        }
        minimumZoomScale = scale
        wrapperView.layer.transform = CATransform3DMakeScale(scale, scale, 1)
    }

    func resetAnimated(frame: CGRect, completion: (() -> Void)? = nil) {
        let bounds = CGRect(origin: CGPoint.zero, size: frame.size)
        let sourceAspect: CGFloat = contentSize.height / contentSize.width
        let cropAspect: CGFloat = frame.size.height / frame.size.width
        var scale: CGFloat = 1.0
        if sourceAspect > cropAspect {
            scale = frame.size.width / contentSize.width
        } else {
            scale = frame.size.height / contentSize.height
        }

        let centerAnimation = POPSpringAnimation(propertyNamed: kPOPViewCenter)!
        centerAnimation.fromValue = wrapperView.center
        centerAnimation.toValue = CGPoint(x: bounds.midX, y: bounds.midY)
        centerAnimation.springSpeed = 7
        centerAnimation.springBounciness = 1

        let translationAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationXY)!
        translationAnimation.fromValue = wrapperView.layer.value(forKeyPath: "transform.translation")
        translationAnimation.toValue = CGPoint.zero
        translationAnimation.springSpeed = 7
        translationAnimation.springBounciness = 1

        let fromScale: CGFloat = self.contentScale()
        let scaleAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)!
        scaleAnimation.fromValue = CGSize(width: fromScale, height: fromScale)
        scaleAnimation.toValue = CGSize(width: scale, height: scale)
        scaleAnimation.springSpeed = 7
        scaleAnimation.springBounciness = 1

        let rotationAnimation = POPSpringAnimation(propertyNamed: kPOPLayerRotation)!
        rotationAnimation.fromValue = self.contentRotation()
        rotationAnimation.toValue = 0
        rotationAnimation.springSpeed = 7
        rotationAnimation.springBounciness = 1
        wrapperView.isUserInteractionEnabled = false

        popWhenAllAnimatedCompleted(animations: [centerAnimation, translationAnimation, scaleAnimation, rotationAnimation]) { _ in
            completion?()
        }

        wrapperView.pop_add(centerAnimation, forKey: "position")
        wrapperView.layer.pop_add(translationAnimation, forKey: "translation")
        wrapperView.layer.pop_add(scaleAnimation, forKey: "scale")
        wrapperView.layer.pop_add(rotationAnimation, forKey: "rotation")
    }
}
