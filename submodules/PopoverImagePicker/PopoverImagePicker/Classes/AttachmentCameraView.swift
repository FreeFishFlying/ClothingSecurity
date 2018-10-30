//
//  AdvancedCameraCell.swift
//  Components-Swift
//
//  Created by Dylan on 15/05/2017.
//  Copyright © 2017 liao. All rights reserved.
//

import UIKit
import pop
import MobileCoreServices
import ReactiveSwift
import Result
import Photos
import AVFoundation
import Album
import Core

class AttachmentCameraView: UIView {
    
    private lazy var cameraView: UIView = {
        let cameraView = UIView()
        cameraView.backgroundColor = UIColor.black
        cameraView.layer.masksToBounds = true
        cameraView.clipsToBounds = true
        return cameraView
    }()
    
    private lazy var cameraIcon: UIImageView = {
        let cameraIcon = UIImageView()
        cameraIcon.image = ImageNamed("AdvanceCameraItem")
        return cameraIcon
    }()
    
    fileprivate lazy var hiddenView: UIView = {
        let hiddenView = UIView(frame: CGRect(x: 100, y: 100, width: 0, height: 0))
        hiddenView.layer.masksToBounds = true
        hiddenView.clipsToBounds = true
        return hiddenView
    }()
    
    fileprivate lazy var imagePicker: AttachmentImagePickerController = {
        let picker = AttachmentImagePickerController()
        picker.advancedCell = self
        picker.modalTransitionStyle = .coverVertical
        picker.allowsEditing = false
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        }
        picker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
        picker.delegate = self
        return picker
    }()
    
    public lazy var cornersView: UIImageView = UIImageView(image: AttachmentAssetCell.CornersImage) 
    public let (cameraPickAssetSignal, cameraPickAssetObserver) = Signal<MediaSelectableItem, NoError>.pipe()
    private var onlyCrop: Bool
    
    init(frame: CGRect, onlyTakeImage: Bool, isOnlyCrop: Bool) {
        onlyCrop = isOnlyCrop
        super.init(frame: frame)
        
        addSubview(hiddenView)
        addSubview(cameraView)
        addSubview(cameraIcon)
        addSubview(cornersView)
        cornersView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        refreshSubviewFrame()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { 
            self.displayCameraView()
        }
        if onlyTakeImage {
            imagePicker.mediaTypes = [kUTTypeImage as String]
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandle))
        addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        refreshSubviewFrame()
    }
    
    private func refreshSubviewFrame() {
        cameraView.frame = bounds
        cameraView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        cameraIcon.bounds = CGRect(x: 0, y: 0, width: 30, height: 26)
        cameraIcon.center = cameraView.center
        cameraIcon.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin]
    }
    
    private func displayCameraView() {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.denied {
            return
        }
        if imagePicker.view.superview != nil {
            return
        }
        
        hiddenView.addSubview(imagePicker.view)
        DispatchQueue.main.async {
            DispatchQueue.main.async {
                self.resetCameraView()
            }
        }
    }
    
    fileprivate func resetCameraView() {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.denied {
            return
        }
        if let previewView = imagePicker.getCameraPreview() {
            cameraView.addSubview(previewView)
            previewView.frame = cameraView.bounds
            previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
    
    @objc private func tapHandle(tap: UITapGestureRecognizer) {
        showPickerController()
    }
    
    func showPickerController() {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.denied {
            return
        }
        
        let window = OverlayControllerWindow(frame: UIScreen.main.bounds)
        imagePicker.rootBaseView = window
        window.show()
        imagePicker.showPickerController()
    }
}

extension AttachmentCameraView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.hidePickerController(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.hidePickerController(animated: false)
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if mediaType == (kUTTypeMovie as String) {
                if let videoFileURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                    DispatchQueue.main.async {
                        self.compressVideo(url: videoFileURL, callback: { (result) in
                            let item = MediaConcreteItem(mediaType: .video, path: result.fileURL?.path, image: result.coverImage, videoDuration: result.duration ?? 0)
                            self.cameraPickAssetObserver.send(value: item)
                        })
                    }
                }
            } else if mediaType == (kUTTypeImage as String) {
                if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    let asset = ImageAsset(image: image)
                    let overlayViewController = OverlayViewController()
                    overlayViewController.show()
                    let frameView = UIView()
                    frameView.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
                    MediaEditorBridge.editor(asset: asset, type: MediaEditorBridge.EditorType.crop, fromView: frameView, onViewController: overlayViewController, context: MediaSelectionContext(), lockAspectRatio: nil) { [weak self] (assert) in
                        self?.cameraPickAssetObserver.send(value: assert)
                        }.startWithValues { (status) in
                            switch status {
                            case .beginTransitionOut:
                                overlayViewController.dismiss()
                            default: break
                            }
                    }
                }
            }
        }
    }
    
    func compressVideo(url: URL, callback: @escaping (VideoConverter.ConverterResult) -> Void) {
        let avAsset = AVAsset(url: url)
        let progressView = UIProgressView()
        let alertController = UIAlertController(title: SLLocalized("MediaEditor.CompressingVideo"), message: nil, progressView: progressView)
        let controller = OverlayViewController()
        controller.show()
        let adjustments = MediaVideoEditAdjustments(trimStartValue: 0, trimEndValue: CMTimeGetSeconds(avAsset.duration))
        let cancelTask = VideoConverter().convert(avAsset: avAsset, adjustments: adjustments).observe(on: UIScheduler()).startWithResult({ (result: Result<VideoConverter.ConverterResult, NSError>) in
            if let _ = result.value?.fileURL {
                controller.dismiss()
                callback(result.value!)
            }
            if result.error != nil {
                controller.dismiss()
            }
            if let value = result.value {
                if let progress = value.progress {
                    progressView.setProgress(Float(progress), animated: progressView.progress < Float(progress))
                }
            }
        })
        alertController.addAction(UIAlertAction(title: SLLocalized("MediaAssetsPicker.Cancel"), style: .cancel, handler: { (_) in
            cancelTask.dispose()
            controller.dismiss()
        }))
        controller.present(alertController, animated: true, completion: nil)
    }
}

class AttachmentImagePickerController: UIImagePickerController {
    
    public weak var rootBaseView: OverlayControllerWindow?
    fileprivate weak var advancedCell: AttachmentCameraView?
    
    private var previewFrame: CGRect?
    private var previewSuperView: UIView?
    private var cameraPreview: UIView?
    
    private var origianlFromFrame: CGRect?
    
    private lazy var translationView: UIView = {
        let translationView = UIView()
        return translationView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let pan = DirectionPanGestureRecognizer(direction: .vertical, target: self, action: #selector(handlePanGesture))
        self.view.addGestureRecognizer(pan)
    }

    public func getCameraPreviewClassNamePre() -> String? {
        if #available(iOS 10.0, *) {
            return "CAM"
        } else if #available(iOS 9.0, *) {
            return "CMK"
        } else if #available(iOS 8.0, *) {
            return "CAM"
        } else {
            return nil
        }
    }
    
    public func getCameraPreview() -> UIView? {
        if cameraPreview != nil {
            return cameraPreview
        }
        var c: AnyClass? = nil
        if let classNamePre = getCameraPreviewClassNamePre() {
            c = NSClassFromString(classNamePre + "VideoPreviewView")
        }
        if c == nil {
            return nil
        }
        
        cameraPreview = findPreview(classType: c!)
        storeCurrentStats()
        return cameraPreview
    }
    
    private func storeCurrentStats() {
        previewFrame = cameraPreview?.frame
        previewSuperView = cameraPreview?.superview
    }
    
    fileprivate func findPreview(classType: AnyClass) -> UIView? {
        if self.view.isKind(of: classType) {
            return self.view
        }
        
        var pendingView = [UIView]()
        pendingView.append(self.view)
        while !pendingView.isEmpty {
            let v = pendingView.removeFirst()
            for subview in v.subviews {
                if subview.isKind(of: classType) {
                    return subview
                } else {
                    pendingView.append(subview)
                }
            }
        }
        return nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    public func showPickerController() {
        if let rootBaseView = rootBaseView,
            let cameraPreview = cameraPreview,
            let cameraPreviewSuperView = cameraPreview.superview {

            let fromRect = cameraPreviewSuperView.convert(cameraPreviewSuperView.bounds, to: UIApplication.shared.keyWindow)
            origianlFromFrame = fromRect
            translationView.frame = rootBaseView.bounds
            rootBaseView.addSubview(translationView)
            translationView.addSubview(cameraPreview)
            
            if let animation = POPBasicAnimation(propertyNamed: kPOPViewFrame) {
                animation.fromValue = fromRect
                animation.toValue = previewSuperView?.convert(previewFrame!, to: self.view) ?? CGRect.zero
                animation.completionBlock = { (animation, finished) in
                    UIApplication.shared.isStatusBarHidden = true
                    self.view.isHidden = false
                    rootBaseView.addSubview(self.view)
                    self.resetState()
                    self.translationView.removeFromSuperview()
                }
                animation.duration = 0.25
                cameraPreview.pop_add(animation, forKey: "frameAnimation")
                
                translationView.backgroundColor = UIColor.clear
                UIView.animate(withDuration: 0.25, animations: { 
                    self.translationView.backgroundColor = UIColor.black
                })
            }
        } else {
            rootBaseView?.dismiss()
        }
    }
    
    private func resetState() {
        if let previewFrame = previewFrame,
            let previewSuperView = previewSuperView,
            let cameraPreview = cameraPreview {
            cameraPreview.frame = previewFrame
            previewSuperView.addSubview(cameraPreview)
        }
    }
    
    public func hidePickerController(animated: Bool) {
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
        if animated {
            if let rootBaseView = rootBaseView,
                let cameraPreview = cameraPreview {
                advancedCell?.hiddenView.addSubview(self.view)
                translationView.frame = rootBaseView.bounds
                rootBaseView.addSubview(translationView)
                translationView.addSubview(cameraPreview)
                
                if let animation = POPBasicAnimation(propertyNamed: kPOPViewFrame) {
                    animation.fromValue = cameraPreview.convert(previewFrame ?? CGRect.zero, to: rootBaseView)
                    animation.toValue = origianlFromFrame ?? CGRect.zero
                    animation.duration = 0.25
                    animation.completionBlock = { (animation, finished) in
                        self.advancedCell?.resetCameraView()
                        self.translationView.removeFromSuperview()
                        self.destoryRootBaseWindow()
                    }
                    cameraPreview.pop_add(animation, forKey: "frameAnimation")
                    
                    translationView.backgroundColor = UIColor.black
                    UIView.animate(withDuration: 0.25, animations: { 
                        self.translationView.backgroundColor = UIColor.clear
                    })
                }
            }
        } else {
            advancedCell?.hiddenView.addSubview(self.view)
            advancedCell?.resetCameraView()
            self.destoryRootBaseWindow()
        }
    }
    
    @objc private func handlePanGesture(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            storeCurrentStats()
            prepareForDismissAnimation()
        case .changed:
            let translation = pan.translation(in: self.view)
            dismissAnimation(offSet: translation.y)
        case .cancelled:
            cancelAnimation()
        case .ended:
            let translation = pan.translation(in: self.view)
            if abs(translation.y) > 50 {
                finishAnimation()
            } else {
                cancelAnimation()
            }
        default:
            break
        }
    }
    
    private func prepareForDismissAnimation() {
        if let rootBaseView = rootBaseView,
            let cameraPreview = cameraPreview {
            translationView.frame = rootBaseView.bounds
            rootBaseView.addSubview(translationView)
            
            translationView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            self.view.isHidden = true
            UIApplication.shared.isStatusBarHidden = false
            
            translationView.addSubview(cameraPreview)
            let fromRect = previewSuperView?.convert(previewFrame ?? CGRect.zero, to: rootBaseView) ?? CGRect.zero
            cameraPreview.frame = fromRect
        }
    }
    
    private func dismissAnimation(offSet: CGFloat) {
        if let rootBaseView = rootBaseView,
            let cameraPreview = cameraPreview {
            var fromRect = previewSuperView?.convert(previewFrame ?? CGRect.zero, to: rootBaseView) ?? CGRect.zero
            fromRect.origin.y += offSet
            cameraPreview.frame = fromRect
        }
    }
    
    private func cancelAnimation() {
        if let rootBaseView = rootBaseView,
            let cameraPreview = cameraPreview {
            if let animation = POPBasicAnimation(propertyNamed: kPOPViewFrame) {
                animation.duration = 0.25
                animation.fromValue = cameraPreview.frame
                animation.toValue = previewSuperView?.convert(previewFrame ?? CGRect.zero, to: rootBaseView) ?? CGRect.zero
                animation.completionBlock = { (animation, finished) in
                    UIApplication.shared.isStatusBarHidden = true
                    self.resetState()
                    self.view.isHidden = false
                    self.translationView.removeFromSuperview()
                }
                cameraPreview.pop_add(animation, forKey: "frameAnimation")
                
                UIView.animate(withDuration: 0.25, animations: { 
                    self.translationView.backgroundColor = UIColor.black
                })
            }
        }
    }
    
    private func finishAnimation() {
        if let cameraPreview = cameraPreview {
            if let animation = POPBasicAnimation(propertyNamed: kPOPViewFrame) {
                animation.duration = 0.25
                animation.fromValue = cameraPreview.frame
                animation.toValue = self.origianlFromFrame
                animation.completionBlock = { (_, _) in
                    self.advancedCell?.resetCameraView()
                    self.translationView.removeFromSuperview()
                    self.view.isHidden = true
                    self.advancedCell?.hiddenView.addSubview(self.view)
                    self.destoryRootBaseWindow()
                }
                cameraPreview.pop_add(animation, forKey: "frameAnimation")
                
                UIView.animate(withDuration: 0.25, animations: { 
                    self.translationView.backgroundColor = UIColor.clear
                })
            }
        }
    }
    
    private func destoryRootBaseWindow() {
        if let rootBaseView = rootBaseView {
            rootBaseView.dismiss()
            self.rootBaseView = nil
        }
    }
}
