//
//  MediaCropView.swift
//  Components-Swift
//
//  Created by kingxt on 5/18/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import Result
import pop
import Core

private let mediaCropViewOverscreenSize: CGFloat = 1000

class MediaCropView: UIView {

    public fileprivate(set) var cropOrientation: UIImage.Orientation = .up
    public fileprivate(set) var mirrored: Bool = false
    public fileprivate(set) var cropRect: CGRect = CGRect.zero
    public fileprivate(set) var originalImageSize: CGSize = CGSize(width: 1, height: 1) {
        didSet {
            contentWrapperView.frame = CGRect(origin: CGPoint.zero, size: ImageUtils.scaleToSize(size: originalImageSize, maxSize: frame.size))
        }
    }

    fileprivate var previousAreaFrame: CGRect = CGRect.zero
    fileprivate var animatingChange: Bool = false

    fileprivate var lockedAspectRatio: CGFloat? {
        didSet {
            areaView.aspectRatio = lockedAspectRatio
        }
    }

    private let editorContext: MediaEditorContext

    init(editorContext: MediaEditorContext) {
        self.editorContext = editorContext
        lockedAspectRatio = editorContext.lockedAspectRatio
        super.init(frame: CGRect.zero)
        if let editor = editorContext.editorResult.cropResult {
            cropOrientation = editor.cropOrientation
            cropRect = editor.cropRect
            mirrored = editor.mirrored
        }

        addSubview(areaWrapperView)
        areaWrapperView.addSubview(scrollView)
        scrollView.contentView = contentWrapperView
        contentWrapperView.addSubview(imageView)

        areaWrapperView.addSubview(blurView)
        areaWrapperView.addSubview(overlayWrapperView)

        overlayWrapperView.addSubview(topOverlayView)
        overlayWrapperView.addSubview(leftOverlayView)
        overlayWrapperView.addSubview(bottomOverlayView)
        overlayWrapperView.addSubview(rightOverlayView)

        areaWrapperView.addSubview(areaView)
        areaView.aspectRatio = editorContext.lockedAspectRatio
        areaView.setGridMode(.none, animated: false)

        scrollView.setContentMirrored(mirrored)
    }

    public func loadImage(completion: (() -> Void)? = nil) {
        if let thumbnailSignal = editorContext.thumbnailSignal {
            thumbnailSignal.take(during: reactive.lifetime).observe(on: UIScheduler()).startWithValues({ [weak self] image in
                if let strongSelf = self {
                    strongSelf.onLoadImage(image: image)
                    completion?()
                }
            })
        }
    }

    private func onLoadImage(image: UIImage?) {
        if editorContext.editorResult.paintHostImage == nil {
            editorContext.editorResult.paintHostImage = image
        }
        if frame.size.width > 0 && frame.size.height > 0 && image != nil {
            imageView.image = self.editorContext.editorResult.applyTo(image: image!, withCrop: false)
            let imageSize = image!.size
            let scaledSize = ImageUtils.scaleToSize(size: imageSize, maxSize: frame.size)
            scrollView.contentSize = scaledSize
            if editorContext.editorResult.cropResult == nil {
                cropRect = CGRect(origin: CGPoint.zero, size: scaledSize)
            }
            originalImageSize = imageSize
            layoutSubviews()
        }
    }

    func willTranslationIn() {
        scrollView.isHidden = true
        areaView.isHidden = true
    }

    func didTranslationIn() {
        scrollView.isHidden = false
        areaView.isHidden = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !animatingChange {
            _ = layoutAreaView(animated: false, completion: nil)
            evenlyFillAreaView(animated: false, isReset: false)
        }
    }

    func setCropAreaHidden(_ hidden: Bool, animated: Bool) {
        if animated {
            areaView.isHidden = false
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: { () -> Void in
                self.areaView.alpha = hidden ? 0.0 : 1.0
            }, completion: { (_ finished: Bool) -> Void in
                if finished {
                    self.areaView.isHidden = hidden
                }
            })
        } else {
            areaView.isHidden = hidden
            areaView.alpha = hidden ? 0.0 : 1.0
        }
    }

    private func areaSize(forCropRect cropRect: CGRect, orientation: UIImage.Orientation) -> CGSize {
        let resultSize: CGSize = cropRect.size
        var rotatedSize: CGSize = resultSize
        if orientation == .left || orientation == .right {
            rotatedSize = CGSize(width: CGFloat(rotatedSize.height), height: CGFloat(rotatedSize.width))
        }
        let areaSize: CGSize = ImageUtils.scaleToSize(size: rotatedSize, maxSize: bounds.size)
        return areaSize
    }

    func evenlyFillAreaView(animated: Bool, isReset: Bool, completed: (() -> Void)? = nil) {
        if animated {
            animatingChange = true
            var animationSteps = [String]()
            let onAnimationCompletion = { (step: String) in
                animationSteps.remove(object: step)
                if animationSteps.count == 0 {
                    self.animatingChange = false
                    self.scrollView.fitContent(insideBoundsAllowScale: false, animated: true, completion: completed)
                }
            }
            animationSteps.append("1")
            let frame = layoutAreaView(animated: true, completion: {
                onAnimationCompletion("1")
            })
            if isReset {
                animationSteps.append("2")
                scrollView.resetAnimated(frame: frame, completion: { () in
                    onAnimationCompletion("2")
                })
            } else {
                animationSteps.append("2")
                zoomToCropRect(frame: frame, animated: true, completion: {
                    onAnimationCompletion("2")
                })
            }
        } else {
            layoutAreaView(animated: false, completion: nil)
            if isReset {
                scrollView.resetAndSetBounds(true)
            } else {
                zoomToCropRect(frame: scrollView.bounds, animated: false, completion: nil)
            }
            completed?()
        }
    }

    @discardableResult fileprivate func layoutAreaView(animated: Bool, completion: (() -> Void)?) -> CGRect {
        if cropRect.size.width == 0 || cropRect.size.height == 0 {
            return CGRect.zero
        }
        animatingChange = true
        let areaSize: CGSize = self.areaSize(forCropRect: cropRect, orientation: cropOrientation)
        let areaWrapperFrame = CGRect(x: (frame.size.width - areaSize.width) / 2, y: (frame.size.height - areaSize.height) / 2, width: areaSize.width, height: areaSize.height)
        var areaWrapperBounds = CGRect(x: 0, y: 0, width: areaWrapperFrame.size.width, height: areaWrapperFrame.size.height)

        switch cropOrientation {
        case .up:
            areaWrapperView.transform = CGAffineTransform.identity
        case .down:
            areaWrapperView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        case .left:
            areaWrapperView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
            areaWrapperBounds = CGRect(x: 0, y: 0, width: areaWrapperBounds.size.height, height: areaWrapperBounds.size.width)
        case .right:
            areaWrapperView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
            areaWrapperBounds = CGRect(x: 0, y: 0, width: areaWrapperBounds.size.height, height: areaWrapperBounds.size.width)
        default:
            break
        }

        if animated {
            let wrapperAnimation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
            wrapperAnimation?.fromValue = areaWrapperView.frame
            wrapperAnimation?.toValue = areaWrapperFrame
            wrapperAnimation?.springSpeed = 7
            wrapperAnimation?.springBounciness = 1

            let areaAnimation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
            areaAnimation?.fromValue = areaView.frame
            areaAnimation?.toValue = areaWrapperBounds
            areaAnimation?.springSpeed = 7
            areaAnimation?.springBounciness = 1

            let scrollViewAnimation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
            scrollViewAnimation?.fromValue = NSValue(cgRect: scrollView.frame)
            scrollViewAnimation?.toValue = NSValue(cgRect: areaWrapperBounds)
            scrollViewAnimation?.springSpeed = 7
            scrollViewAnimation?.springBounciness = 1

            popWhenAllAnimatedCompleted(animations: [wrapperAnimation!, areaAnimation!, scrollViewAnimation!], completed: { _ in
                self.animatingChange = false
                completion?()
            })

            areaWrapperView.pop_add(wrapperAnimation, forKey: "frameAnimation")
            areaView.pop_add(areaAnimation, forKey: "frameAnimation")
            scrollView.pop_add(scrollViewAnimation, forKey: "frameAnimation")
        } else {
            areaWrapperView.frame = areaWrapperFrame
            areaView.frame = areaWrapperBounds
            scrollView.frame = areaWrapperBounds
            animatingChange = false
            completion?()
        }

        layoutOverlayViews(frame: areaWrapperBounds, animated: animated)
        return areaWrapperBounds
    }

    func layoutOverlayViews(frame: CGRect, animated: Bool) {
        let overlayWrapperFrame: CGRect = frame
        let topOverlayFrame = CGRect(x: 0, y: -mediaCropViewOverscreenSize, width: overlayWrapperFrame.size.width, height: mediaCropViewOverscreenSize)
        let leftOverlayFrame = CGRect(x: -mediaCropViewOverscreenSize, y: -mediaCropViewOverscreenSize, width: mediaCropViewOverscreenSize, height: overlayWrapperFrame.size.height + 2 * mediaCropViewOverscreenSize)
        let rightOverlayFrame = CGRect(x: overlayWrapperFrame.size.width, y: -mediaCropViewOverscreenSize, width: mediaCropViewOverscreenSize, height: overlayWrapperFrame.size.height + 2 * mediaCropViewOverscreenSize)
        let bottomOverlayFrame = CGRect(x: 0, y: overlayWrapperFrame.size.height, width: overlayWrapperFrame.size.width, height: mediaCropViewOverscreenSize)

        if animated {
            let wrapperAnimation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
            wrapperAnimation?.fromValue = NSValue(cgRect: overlayWrapperView.frame)
            wrapperAnimation?.toValue = NSValue(cgRect: overlayWrapperFrame)
            wrapperAnimation?.springSpeed = 7
            wrapperAnimation?.springBounciness = 1
            overlayWrapperView.pop_add(wrapperAnimation, forKey: "frameAnimation")

            let topAnimation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
            topAnimation?.fromValue = NSValue(cgRect: topOverlayView.frame)
            topAnimation?.toValue = NSValue(cgRect: topOverlayFrame)
            topAnimation?.springSpeed = 7
            topAnimation?.springBounciness = 1
            topOverlayView.pop_add(topAnimation, forKey: "frameAnimation")

            let leftAnimation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
            leftAnimation?.fromValue = NSValue(cgRect: leftOverlayView.frame)
            leftAnimation?.toValue = NSValue(cgRect: leftOverlayFrame)
            leftAnimation?.springSpeed = 7
            leftAnimation?.springBounciness = 1
            leftOverlayView.pop_add(leftAnimation, forKey: "frameAnimation")

            let bottomAnimation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
            bottomAnimation?.fromValue = NSValue(cgRect: bottomOverlayView.frame)
            bottomAnimation?.toValue = NSValue(cgRect: bottomOverlayFrame)
            bottomAnimation?.springSpeed = 7
            bottomAnimation?.springBounciness = 1
            bottomOverlayView.pop_add(bottomAnimation, forKey: "frameAnimation")

            let rightAnimation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
            rightAnimation?.fromValue = NSValue(cgRect: rightOverlayView.frame)
            rightAnimation?.toValue = NSValue(cgRect: rightOverlayFrame)
            rightAnimation?.springSpeed = 7
            rightAnimation?.springBounciness = 1
            rightOverlayView.pop_add(rightAnimation, forKey: "frameAnimation")
        } else {
            overlayWrapperView.frame = overlayWrapperFrame
            topOverlayView.frame = topOverlayFrame
            leftOverlayView.frame = leftOverlayFrame
            rightOverlayView.frame = rightOverlayFrame
            bottomOverlayView.frame = bottomOverlayFrame
        }
    }

    private func performCropConfirm(animated: Bool) {
        areaView.setGridMode(.none, animated: true)

        cropRect = scrollView.zoomedRect()
        let minimumSizes = CGSize(width: originalImageSize.width / scrollView.maximumZoomScale, height: originalImageSize.height / scrollView.maximumZoomScale)
        var constrainedCropRect = cropRect
        if cropRect.size.width < minimumSizes.width && cropRect.size.height < minimumSizes.height {
            if cropRect.size.width > cropRect.size.height {
                constrainedCropRect.size.width = minimumSizes.width
                constrainedCropRect.size.height = cropRect.size.height * constrainedCropRect.size.width / cropRect.size.width
            } else {
                constrainedCropRect.size.height = minimumSizes.height
                constrainedCropRect.size.width = cropRect.size.width * constrainedCropRect.size.height / cropRect.size.height
            }
            let rotatedContentSize: CGSize = rotated(contentSize: scrollView.contentSize, rotation: scrollView.contentRotation())
            if constrainedCropRect.maxX > rotatedContentSize.width {
                constrainedCropRect.origin.x = rotatedContentSize.width - constrainedCropRect.size.width
            }
            if constrainedCropRect.maxY > rotatedContentSize.height {
                constrainedCropRect.origin.y = rotatedContentSize.height - constrainedCropRect.size.height
            }
        }
        cropRect = constrainedCropRect
        evenlyFillAreaView(animated: animated, isReset: false)
    }

    func zoomToCropRect(frame: CGRect, animated: Bool, completion: (() -> Void)?) {
        scrollView.zoom(to: cropRect, withFrame: frame, animated: animated, completion: completion)
    }

    func handleCropAreaChanged(areaViewFrame: CGRect? = nil) {
        areaView.frame = cappedAreaViewRect(cropRect: areaViewFrame ?? areaView.frame)
        let translationOffset = CGPoint(x: previousAreaFrame.origin.x - areaView.frame.origin.x, y: previousAreaFrame.origin.y - areaView.frame.origin.y)
        scrollView.translateContentView(withOffset: translationOffset)
        previousAreaFrame = areaView.frame
        scrollView.frame = areaView.frame
        scrollView.fitContent(insideBoundsAllowScale: true, animated: false)
        layoutOverlayViews(frame: areaView.frame, animated: false)
    }

    func cappedAreaViewRect(cropRect: CGRect) -> CGRect {
        var cappedRect: CGRect = convert(cropRect, from: areaWrapperView)
        var aspectRatio = lockedAspectRatio != nil ? lockedAspectRatio! : 0
        if aspectRatio > 0 && (cropOrientation == .left || cropOrientation == .right) {
            aspectRatio = 1.0 / aspectRatio
        }
        if cappedRect.maxX > frame.size.width {
            cappedRect.origin.x = min(frame.size.width - mediaCropCornerControlSize.width, cappedRect.origin.x)
            cappedRect.size.width = max(mediaCropCornerControlSize.width, frame.size.width - cappedRect.origin.x)
            if aspectRatio > 0 {
                cappedRect.size.height = cappedRect.size.width * aspectRatio
            }
        } else if cappedRect.minX < 0 {
            cappedRect.size.width = cappedRect.maxX
            if aspectRatio > 0 {
                cappedRect.size.height = cappedRect.size.width * aspectRatio
            }
            cappedRect.origin.x = 0
        }

        if cappedRect.maxY > frame.size.height {
            cappedRect.origin.y = min(frame.size.height - mediaCropCornerControlSize.height, cappedRect.origin.y)
            cappedRect.size.height = max(mediaCropCornerControlSize.height, frame.size.height - cappedRect.origin.y)
            if aspectRatio > 0 {
                cappedRect.size.width = cappedRect.size.height / aspectRatio
            }
        } else if cappedRect.minY < 0 {
            cappedRect.size.height = cappedRect.maxY
            if aspectRatio > 0 {
                cappedRect.size.width = cappedRect.size.height / aspectRatio
            }
            cappedRect.origin.y = 0
        }
        return convert(cappedRect, to: areaWrapperView)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - subviews
    public fileprivate(set) lazy var areaView: MediaCropAreaView = {
        let view = MediaCropAreaView()
        view.shouldBeginEditing = { [weak self] () -> Bool in
            if let strongSelf = self {
                return !strongSelf.scrollView.isTracking
            }
            return true
        }
        view.didBeginEditing = { [weak self] () in
            if let strongSelf = self {
                strongSelf.previousAreaFrame = strongSelf.areaView.frame
                strongSelf.areaView.setGridMode(.major, animated: true)
            }
        }
        view.areaChanged = { [weak self] () in
            if let strongSelf = self {
                strongSelf.handleCropAreaChanged()
            }
        }
        view.didEndEditing = { [weak self] () in
            if let strongSelf = self {
                strongSelf.performCropConfirm(animated: true)
            }
        }
        return view
    }()

    fileprivate lazy var scrollView: MediaCropScrollView = {
        let view = MediaCropScrollView()
        return view
    }()

    fileprivate lazy var areaWrapperView: UIControl = {
        let areaWrapperView = UIControl(frame: CGRect.zero)
        areaWrapperView.hitTestEdgeInsets = UIEdgeInsets(top: -16, left: -100, bottom: -100, right: -100)
        return areaWrapperView
    }()

    public private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: self.bounds)
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    fileprivate lazy var overlayWrapperView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var topOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColorRGBA(0x000000, 0.7)
        return view
    }()

    private lazy var leftOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColorRGBA(0x000000, 0.7)
        return view
    }()

    private lazy var bottomOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColorRGBA(0x000000, 0.7)
        return view
    }()

    private lazy var rightOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColorRGBA(0x000000, 0.7)
        return view
    }()

    private lazy var blurView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.alpha = 0.0
        blurView.isUserInteractionEnabled = false
        return blurView
    }()

    private lazy var contentWrapperView: UIView = {
        let view = UIView()
        return view
    }()
}

extension MediaCropView {

    public func outputResultRepresentation() -> MediaCropResult {
        return MediaCropResult(cropRect: scrollView.zoomedRect(), originalCropRect: CGRect(origin: CGPoint.zero, size: ImageUtils.scaleToSize(size: originalImageSize, maxSize: frame.size)), cropOrientation: cropOrientation, rotation: scrollView.contentRotation(), mirrored: mirrored)
    }

    public func unlockAspectRatio() {
        lockedAspectRatio = nil
    }

    public func lockedAspectRatio(_ aspectRatio: CGFloat, performResize: Bool, animated: Bool) {
        if animatingChange {
            return
        }
        lockedAspectRatio = aspectRatio

        let currentCenter = CGPoint(x: cropRect.midX, y: cropRect.midY)
        let availableRect: CGRect = scrollView.availableRect()
        var newCropRect: CGRect = cropRect
        newCropRect.size.height = newCropRect.size.width * aspectRatio
        if newCropRect.size.height > availableRect.size.height {
            newCropRect.size.height = availableRect.size.height
            newCropRect.size.width = newCropRect.size.height / aspectRatio
        }

        newCropRect.origin.x = currentCenter.x - newCropRect.size.width / 2
        newCropRect.origin.y = currentCenter.y - newCropRect.size.height / 2

        if newCropRect.origin.x < availableRect.origin.x {
            newCropRect.origin.x = availableRect.origin.x
        }
        if newCropRect.origin.y < availableRect.origin.y {
            newCropRect.origin.y = availableRect.origin.y
        }
        if newCropRect.maxX > availableRect.maxX {
            newCropRect.origin.x = availableRect.maxX - newCropRect.size.width
        }
        if newCropRect.maxY > availableRect.maxY {
            newCropRect.origin.y = availableRect.maxY - newCropRect.size.height
        }
        cropRect = newCropRect
        if performResize {
            evenlyFillAreaView(animated: animated, isReset: false)
        }
    }

    public func reset(animated: Bool) {
        if animatingChange {
            return
        }
        animatingChange = true
        let originalCropRect = CGRect(origin: CGPoint.zero, size: ImageUtils.scaleToSize(size: originalImageSize, maxSize: self.frame.size))
        cropRect = originalCropRect
        lockedAspectRatio = nil
        areaView.setGridMode(.none, animated: animated)
        cropOrientation = .up
        mirrored = false
        scrollView.setContentMirrored(mirrored)
        if animated {
            setCropAreaHidden(true, animated: false)
        }
        evenlyFillAreaView(animated: animated, isReset: true, completed: { () in
            self.setCropAreaHidden(false, animated: true)
            self.animatingChange = false
        })
    }

    public func mirror() {
        if animatingChange {
            return
        }
        mirrored = !mirrored
        cropRect = scrollView.zoomedRect()
        scrollView.setContentMirrored(mirrored)
        layoutAreaView(animated: false, completion: nil)
        zoomToCropRect(frame: scrollView.bounds, animated: false, completion: nil)
    }

    public func rotation90Degree(animated: Bool) {
        if animatingChange {
            return
        }
        guard let snapshotView = cropSnapshotView() else {
            return
        }
        snapshotView.transform = areaWrapperView.transform
        snapshotView.frame = convert(scrollView.frame, from: areaWrapperView)
        addSubview(snapshotView)

        cropRect = scrollView.zoomedRect()
        scrollView.isHidden = true
        setCropAreaHidden(true, animated: false)

        cropOrientation = nextOrientationForOrientation(cropOrientation)

        let areaSize: CGSize = orientationAreaSize(cropRect: cropRect, orientation: cropOrientation)
        var areaBounds = CGRect(origin: CGPoint.zero, size: areaSize)
        if cropOrientation == .left || cropOrientation == .right {
            areaBounds = CGRect(x: 0, y: 0, width: areaSize.height, height: areaSize.width)
        }
        if animated {
            animatingChange = true
            let centerAnimation = POPSpringAnimation(propertyNamed: kPOPViewCenter)!
            centerAnimation.fromValue = snapshotView.center
            centerAnimation.toValue = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
            centerAnimation.springSpeed = 7
            centerAnimation.springBounciness = 1
            snapshotView.pop_add(centerAnimation, forKey: "center")

            let boundsAnimation = POPSpringAnimation(propertyNamed: kPOPViewBounds)!
            boundsAnimation.fromValue = snapshotView.bounds
            boundsAnimation.toValue = areaBounds
            boundsAnimation.springSpeed = 7
            boundsAnimation.springBounciness = 1
            snapshotView.pop_add(boundsAnimation, forKey: "bounds")

            let currentRotation: CGFloat = snapshotView.layer.value(forKeyPath: "transform.rotation.z") as! CGFloat
            var targetRotation: CGFloat = rotationForOrientation(cropOrientation)
            if fabs(currentRotation - targetRotation) > CGFloat.pi {
                targetRotation = -2 * CGFloat.pi + targetRotation
            }

            let rotationAnimation = POPSpringAnimation(propertyNamed: kPOPLayerRotation)!
            rotationAnimation.fromValue = currentRotation
            rotationAnimation.toValue = targetRotation
            rotationAnimation.springSpeed = 7
            rotationAnimation.springBounciness = 1
            snapshotView.layer.pop_add(rotationAnimation, forKey: "rotation")

            popWhenAllAnimatedCompleted(animations: [centerAnimation, boundsAnimation, rotationAnimation], completed: { allFinished in
                if !allFinished {
                    return
                }
                self.animatingChange = false

                snapshotView.removeFromSuperview()
                self.evenlyFillAreaView(animated: false, isReset: false)

                self.scrollView.isHidden = false
                self.setCropAreaHidden(false, animated: true)
            })
        } else {
            snapshotView.removeFromSuperview()
            areaWrapperView.backgroundColor = UIColor.clear
            layoutAreaView(animated: false, completion: nil)
            zoomToCropRect(frame: scrollView.bounds, animated: false, completion: nil)
            scrollView.isHidden = false
            setCropAreaHidden(false, animated: false)
        }
    }

    func orientationAreaSize(cropRect: CGRect, orientation: UIImage.Orientation) -> CGSize {
        let resultSize: CGSize = cropRect.size
        var rotatedSize: CGSize = resultSize
        if orientation == .left || orientation == .right {
            rotatedSize = CGSize(width: rotatedSize.height, height: rotatedSize.width)
        }
        let areaSize: CGSize = ImageUtils.scaleToSize(size: rotatedSize, maxSize: bounds.size)
        return areaSize
    }

    func cropSnapshotView() -> UIView? {
        let snapshotView = scrollView.snapshotView(afterScreenUpdates: false)
        snapshotView?.transform = CGAffineTransform(rotationAngle: rotationForOrientation(cropOrientation))
        return snapshotView
    }
}
