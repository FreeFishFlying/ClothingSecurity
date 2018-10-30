//
//  MeidaCropController.swift
//  Components-Swift
//
//  Created by kingxt on 5/17/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import Result
import pop
import Core
import AlertController

public class MediaCropResult {
    public let cropRect: CGRect // applyed zoomed
    public let originalCropRect: CGRect
    public let cropOrientation: UIImage.Orientation
    public let rotation: CGFloat
    public let mirrored: Bool

    init(cropRect: CGRect, originalCropRect: CGRect, cropOrientation: UIImage.Orientation, rotation: CGFloat, mirrored: Bool) {
        self.cropRect = cropRect
        self.originalCropRect = originalCropRect
        self.cropOrientation = cropOrientation
        self.rotation = rotation
        self.mirrored = mirrored
    }

    public func apply(image: UIImage?, maxSize: CGSize? = nil) -> UIImage? {
        if let inputImage = image {
            let maxSize: CGSize = maxSize != nil ? maxSize! : inputImage.size
            var rect = cropRect

            let ratio: CGFloat = inputImage.size.width / originalCropRect.width
            rect.origin.x = rect.origin.x * ratio
            rect.origin.y = rect.origin.y * ratio
            rect.size.width = rect.size.width * ratio
            rect.size.height = rect.size.height * ratio

            let fittedImageSize: CGSize = ImageUtils.fitSize(size: rect.size, maxSize: maxSize)
            var outputImageSize: CGSize = fittedImageSize
            outputImageSize.width = outputImageSize.width.rounded(.down)
            outputImageSize.height = outputImageSize.height.rounded(.down)
            if orientationIsSideward(orientation: cropOrientation).sideward {
                outputImageSize = CGSize(width: outputImageSize.height, height: outputImageSize.width)
            }

            UIGraphicsBeginImageContextWithOptions(CGSize(width: outputImageSize.width, height: outputImageSize.height), false, 1.0)
            guard let context: CGContext = UIGraphicsGetCurrentContext() else {
                return nil
            }
            context.setFillColor(UIColor.clear.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: outputImageSize.width, height: outputImageSize.height))
            context.interpolationQuality = .high

            let scales = CGSize(width: CGFloat(fittedImageSize.width / rect.size.width), height: CGFloat(fittedImageSize.height / rect.size.height))
            let rotatedContentSize: CGSize = rotated(contentSize: inputImage.size, rotation: rotation)
            var transform = CGAffineTransform.identity
            transform = transform.translatedBy(x: outputImageSize.width / 2, y: outputImageSize.height / 2)
            transform = transform.rotated(by: rotationForOrientation(cropOrientation))
            transform = transform.translatedBy(x: (rotatedContentSize.width / 2 - rect.midX) * scales.width, y: (rotatedContentSize.height / 2 - rect.midY) * scales.height)
            transform = transform.rotated(by: rotation)
            context.concatenate(transform)

            let referenceSize: CGSize = inputImage.size
            let resizedSize = CGSize(width: referenceSize.width * fittedImageSize.width / rect.size.width, height: referenceSize.height * fittedImageSize.height / rect.size.height)
            let resizedImage = inputImage.scaled(to: resizedSize)

            if mirrored {
                context.scaleBy(x: -1.0, y: 1.0)
            }

            resizedImage.draw(at: CGPoint(x: -resizedImage.size.width / 2, y: -resizedImage.size.height / 2))

            let croppedImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return croppedImage
        }
        return nil
    }
}

public class MeidaCropController: UIViewController, MediaEditor {

    private let editorContext: MediaEditorContext
    let animationContext: AnimationTranslationContext
    fileprivate let lockedAspectRatio: CGFloat?

    public init(editorContext: MediaEditorContext, animationContext: AnimationTranslationContext, lockedAspectRatio: CGFloat? = nil) {
        self.editorContext = editorContext
        self.animationContext = animationContext
        self.lockedAspectRatio = lockedAspectRatio
        super.init(nibName: nil, bundle: nil)
    }

    public func tabBarImage() -> UIImage? {
        return MediaEditorImageNamed("PhotoEditorCrop")
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func animationTranslationInView() -> UIView {
        return cropView
    }

    public func animationTranslationOutView(isCancelled: Bool) -> UIView? {
        if isCancelled {
            let view = cropView.imageView.snapshotView(afterScreenUpdates: false)
            view?.frame = cropView.imageView.convert(cropView.imageView.frame, to: view)
            return view
        }
        let snapshotView = UIImageView(frame: cropView.areaView.convert(cropView.areaView.frame, to: view.window!))
        snapshotView.image = editorContext.editorResult.editorImage ?? outputResultRepresentation().apply(image: cropView.imageView.image)
        return snapshotView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        animationContext.stateChangeSignal().startWithValues { [weak self] state in
            switch state {
            case .willTranslationIn:
                self?.buttonsWrapperView.alpha = 0
                UIView.animate(withDuration: 0.3) {
                    self?.buttonsWrapperView.alpha = 1
                }
                self?.cropView.willTranslationIn()
            case .didTranslationIn:
                self?.cropView.didTranslationIn()
            case .willTranslationOut:
                UIView.animate(withDuration: 0.2) {
                    self?.buttonsWrapperView.alpha = 0
                }
                self?.cropView.isHidden = true
            default: break
            }
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cropView.loadImage { () in
            if let lockedAspectRatio = self.lockedAspectRatio {
                self.cropView.lockedAspectRatio(lockedAspectRatio, performResize: true, animated: true)
            }
        }
    }

    public override func loadView() {
        super.loadView()

        view.addSubview(wrapperView)
        wrapperView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        wrapperView.addSubview(cropView)
        wrapperView.addSubview(buttonsWrapperView)

        buttonsWrapperView.addSubview(rotateButton)
        buttonsWrapperView.addSubview(mirrorButton)
        buttonsWrapperView.addSubview(aspectRatioButton)
        buttonsWrapperView.addSubview(resetButton)

        layout()
    }

    public func layout() {
        cropView.snp.makeConstraints { (make) in
            make.left.equalTo(MediaEditorController.previewImageViewGap)
            make.right.equalTo(-MediaEditorController.previewImageViewGap)
            make.top.equalTo(0)
            make.bottom.equalTo(-MediaEditorController.operationViewHeight)
        }
        let buttonsWrapperHeight: CGFloat = 40
        buttonsWrapperView.snp.remakeConstraints { ( make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-50)
            make.height.equalTo(buttonsWrapperHeight)
        }
        rotateButton.snp.remakeConstraints { make in
            make.left.equalTo(25)
            make.centerY.equalTo(buttonsWrapperView)
        }
        mirrorButton.snp.remakeConstraints { make in
            make.left.equalTo(rotateButton.snp.right).offset(30)
            make.centerY.equalTo(buttonsWrapperView)
        }
        aspectRatioButton.snp.remakeConstraints { make in
            make.right.equalTo(-25)
            make.centerY.equalTo(buttonsWrapperView)
        }
        resetButton.snp.remakeConstraints { make in
            make.center.equalTo(buttonsWrapperView)
        }
        aspectRatioButton.isHidden = lockedAspectRatio != nil
        resetButton.isHidden = lockedAspectRatio != nil
    }

    private lazy var wrapperView: UIView = {
        let view = UIView(frame: self.view.bounds)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()

    fileprivate let buttonsWrapperView: UIView = {
        UIView(frame: CGRect.zero)
    }()

    lazy var cropView: MediaCropView = {
        let cropView = MediaCropView(editorContext: self.editorContext)
        return cropView
    }()

    fileprivate lazy var rotateButton: UIButton = {
        let rotateButton = UIButton(frame: CGRect.zero)
        rotateButton.isExclusiveTouch = true
        rotateButton.autoHighlight = true
        rotateButton.hitTestEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        rotateButton.addTarget(self, action: #selector(self.rotate), for: .touchUpInside)
        rotateButton.setImage(MediaEditorImageNamed("PhotoEditorRotateIcon"), for: .normal)
        return rotateButton
    }()

    fileprivate lazy var mirrorButton: UIButton = {
        let mirrorButton = UIButton(frame: CGRect.zero)
        mirrorButton.isExclusiveTouch = true
        mirrorButton.autoHighlight = true
        mirrorButton.imageEdgeInsets = UIEdgeInsets(top: 4.0, left: 0.0, bottom: 0.0, right: 0.0)
        mirrorButton.hitTestEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        mirrorButton.addTarget(self, action: #selector(self.mirror), for: .touchUpInside)
        mirrorButton.setImage(MediaEditorImageNamed("PhotoEditorMirrorIcon"), for: .normal)
        return mirrorButton
    }()

    fileprivate lazy var aspectRatioButton: UIButton = {
        let aspectRatioButton = UIButton(frame: CGRect.zero)
        aspectRatioButton.isExclusiveTouch = true
        aspectRatioButton.autoHighlight = true
        aspectRatioButton.hitTestEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        aspectRatioButton.addTarget(self, action: #selector(self.aspectRatioButtonPressed), for: .touchUpInside)
        aspectRatioButton.setImage(MediaEditorImageNamed("PhotoEditorAspectRatioIcon"), for: .normal)
        aspectRatioButton.setImage(MediaEditorImageNamed("PhotoEditorAspectRatioIcon_Applied"), for: .selected)
        aspectRatioButton.setImage(MediaEditorImageNamed("PhotoEditorAspectRatioIcon_Applied"), for: [.selected, .highlighted])
        return aspectRatioButton
    }()

    private lazy var resetButton: UIButton = {
        let resetButton = UIButton()
        resetButton.isExclusiveTouch = true
        resetButton.autoHighlight = true
        resetButton.hitTestEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        resetButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        resetButton.addTarget(self, action: #selector(self.resetButtonPressed), for: .touchUpInside)
        resetButton.setTitle(SLLocalized("MediaEditor.Reset"), for: .normal)
        resetButton.setTitleColor(UIColor.white, for: .normal)
        resetButton.sizeToFit()
        resetButton.frame = CGRect.zero
        return resetButton
    }()
}

public extension MeidaCropController {

    public func outputResultRepresentation() -> MediaCropResult {
        return cropView.outputResultRepresentation()
    }

    public func fillResult(result: MediaEditorResult) {
        if isViewLoaded {
            result.cropResult = outputResultRepresentation()
        }
    }

    @objc public func rotate() {
        cropView.rotation90Degree(animated: true)
    }

    @objc public func mirror() {
        cropView.mirror()
    }

    @objc public func aspectRatioButtonPressed() {
        if aspectRatioButton.isSelected {
            aspectRatioButton.isSelected = false
            cropView.unlockAspectRatio()
        } else {
            presentAspectRatioActionSheet(completion: { [weak self] ratioString in
                if let strongSelf = self {
                    strongSelf.aspectRatioButton.isSelected = true
                    var aspectRatio = CGFloat(ratioString)
                    if aspectRatio == 0 {
                        aspectRatio = strongSelf.cropView.originalImageSize.height / strongSelf.cropView.originalImageSize.width
                    } else {
                        if strongSelf.cropView.cropOrientation == .left || strongSelf.cropView.cropOrientation == .right {
                            aspectRatio = 1.0 / aspectRatio
                        }
                    }
                    strongSelf.cropView.lockedAspectRatio(aspectRatio, performResize: true, animated: true)
                }
            })
        }
    }

    @objc public func resetButtonPressed() {
        cropView.reset(animated: true)
        aspectRatioButton.isSelected = false
    }

    func presentAspectRatioActionSheet(completion: @escaping ((CGFloat) -> Void)) {
        var croppedImageSize: CGSize = cropView.cropRect.size
        if cropView.cropOrientation == .left || cropView.cropOrientation == .right {
            croppedImageSize = CGSize(width: croppedImageSize.height, height: croppedImageSize.width)
        }

        let actionSheet = AlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.add(title: SLLocalized("MediaEditor.Original"), style: .normal) { () -> Void in
            completion(0)
        }
        actionSheet.add(title: SLLocalized("MediaEditor.Square"), style: .normal) { () -> Void in
            completion(1)
        }
        var points: [CGPoint] = [CGPoint]()
        points.append(CGPoint(x: 3, y: 2))
        points.append(CGPoint(x: 5, y: 3))
        points.append(CGPoint(x: 4, y: 3))
        points.append(CGPoint(x: 5, y: 4))
        points.append(CGPoint(x: 7, y: 5))
        points.append(CGPoint(x: 16, y: 9))
        for point in points {
            var widthComponent: CGFloat = 0
            var heightComponent: CGFloat = 0
            var ratio: CGFloat = 0.0
            if croppedImageSize.width >= croppedImageSize.height {
                widthComponent = point.x
                heightComponent = point.y
            } else {
                widthComponent = point.y
                heightComponent = point.x
            }
            ratio = heightComponent / widthComponent
            actionSheet.add(title: "\(Int(widthComponent)):\(Int(heightComponent))", style: .normal, handler: { () -> Void in
                completion(ratio)
            })
        }
        actionSheet.add(title: SLLocalized("MediaEditor.Cancel"), style: .preferred, handler: nil)
        present(actionSheet, animated: true, completion: nil)
    }
}

public class LockRatioMeidaCropController: MeidaCropController {
    public override func loadView() {
        super.loadView()
        buttonsWrapperView.addSubview(cancelButton)
        buttonsWrapperView.addSubview(confirmButton)

        cancelButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        }
        confirmButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        cropView.loadImage { () in
            if let lockedAspectRatio = self.lockedAspectRatio {
                self.cropView.lockedAspectRatio(lockedAspectRatio, performResize: true, animated: false)
                
                self.animationTranslationIn()
            }
        }
    }

    private func animationTranslationIn() {
        let targetView = animationTranslationInView()
        animationContext.stateChangeSignal().startWithValues { [weak self] state in
            switch state {
            case .willTranslationIn:
                self?.buttonsWrapperView.alpha = 0
                UIView.animate(withDuration: 0.3) {
                    self?.buttonsWrapperView.alpha = 1
                }
            default: break
            }
        }
        if !animationContext.translationIn(on: view, toRect: targetView.frame, contentMode: .scaleAspectFit) {
            print("animated in error")
        }
    }
    
    public override func layout() {
        super.layout()
        rotateButton.snp.remakeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().multipliedBy(0.75).offset(-5)
        }
        mirrorButton.snp.remakeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().multipliedBy(1.25)
        }
    }

    let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle(SLLocalized("Common.Done"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        button.autoHighlight = true
        button.hitTestEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        return button
    }()

    let cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.setTitle(SLLocalized("MediaAssetsPicker.Cancel"), for: .normal)
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.setTitleColor(.gray, for: .disabled)
        cancelButton.autoHighlight = true
        cancelButton.hitTestEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        return cancelButton
    }()

    @discardableResult public static func show(fromView: UIView, imageSignal: SignalProducer<UIImage?, NoError>,
                                               lockedAspectRatio: CGFloat?,
                                               confirmCallback: ((UIImage?) -> Void)?) -> LockRatioMeidaCropController {
        let editorResult = MediaEditorResult()
        let editorContext = MediaEditorContext(editorResult: editorResult)
        let animationContext = AnimationTranslationContext()
        if let aspectRatio = lockedAspectRatio, let window = fromView.window {
            let newSize = ImageUtils.scaleToSize(size: CGSize(width: 1, height: 1 * aspectRatio), maxSize: fromView.frame.size)
            let newFrame: CGRect = CGRect(origin: CGPoint(x: (fromView.frame.size.width - newSize.width) / 2, y: (fromView.frame.size.height - newSize.height) / 2), size: newSize)
            let animationImage = UIImage(view: fromView)
            let animationView = UIImageView(image: animationImage)
            animationView.contentMode = .scaleAspectFill
            animationView.frame = fromView.convert(newFrame, to: window)
            animationContext.fromView = animationView
        } else {
            animationContext.fromView = fromView
        }
        animationContext.dismissTargetRect = { (_: Int?) -> (CGRect, UIView.ContentMode?) in
            (CGRect.zero, .scaleAspectFit)
        }
        editorContext.thumbnailSignal = imageSignal
        let controller = LockRatioMeidaCropController(editorContext: editorContext, animationContext: animationContext, lockedAspectRatio: lockedAspectRatio)
        if UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height {
            controller.preferredContentSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        } else {
            controller.preferredContentSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        }
        let window = OverlayControllerWindow(frame: UIScreen.main.bounds)
        controller.cancelButton.reactive.controlEvents(.touchUpInside).observeValues({ _ in
            animationContext.translationOut(on: UIView())
            window.rootViewController?.dismiss(animated: true, completion: { () in
                window.dismiss()
            })
        })
        controller.confirmButton.reactive.controlEvents(.touchUpInside).observeValues({ _ in
            animationContext.translationOut(on: UIView())

            let cropper = (window.rootViewController?.presentedViewController as! LockRatioMeidaCropController)
            if let image = cropper.outputResultRepresentation().apply(image: cropper.cropView.imageView.image) {
                confirmCallback?(image)
            }
            window.rootViewController?.dismiss(animated: true, completion: { () in
                window.dismiss()
            })
        })
        window.present(controller: controller, animated: false)
        return controller
    }
}
