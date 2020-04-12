//
//  MediaEditorBridge.swift
//  Album
//
//  Created by kingxt on 2018/1/8.
//

import Foundation
import MediaEditorKit
import ReactiveSwift
import Core
import Result

public class MediaEditorBridge {
    
    public enum EditorType {
        case crop
        case paint
    }
    
    public enum TransitionStatus {
        case beginTransitionOut
        case finishedTransitionOut
        case beginTransitionIn
        case finishedTransitionIn
    }

    public class func editor(asset: MediaAsset, type: EditorType, fromView: UIView?, onViewController: UIViewController, context: MediaSelectionContext, lockAspectRatio: CGFloat? = nil, onFinished: ((_: MediaAsset) -> Void)? = nil) -> SignalProducer<TransitionStatus, NoError> {
        return SignalProducer<TransitionStatus, NoError>({ (observer, lifetime) in
            func animationTargetFrame() -> CGRect {
                if let imageView = fromView as? UIImageView, let image = imageView.image {
                    let containerView = onViewController.view!
                    let displaySize = ImageUtils.scaleToSize(size: image.size, maxSize: containerView.frame.size)
                    let displayFrame = CGRect(origin: CGPoint(x: (containerView.frame.size.width - displaySize.width) / 2, y: (containerView.frame.size.height - displaySize.height) / 2), size: displaySize)
                    return displayFrame
                } else {
                    return fromView?.frame ?? CGRect.zero
                }
            }
            var maskView: UIView? = nil
            if fromView != nil {
                maskView = UIView(frame: onViewController.view.bounds)
                maskView?.backgroundColor = UIColor.black
                maskView?.alpha = 0
                maskView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                onViewController.view.addSubview(maskView!)
            }
            
            if context.editingContext == nil {
                context.editingContext = MKMediaEditingContext()
            }
            var mediaAsset: TGMediaAsset?
            let source = FileVisitSource.from(string: asset.uniqueIdentifier())
            switch source {
            case .remotePath:
                if let imageView = fromView as? UIImageView, let image = imageView.image {
                    mediaAsset = TGMediaAsset(image: image)
                }
            case .unknown:
                if let ast = asset as? ImageAsset {
                    mediaAsset = TGMediaAsset(image: ast.image)
                } else if let imageAsset = PHAsset.fetchAssets(withLocalIdentifiers: [asset.uniqueIdentifier()], options: nil).firstObject {
                    mediaAsset = TGMediaAsset(phAsset: imageAsset)
                }
            case .filePath:
                if let ast = asset as? MediaAsset {
                    if let editorResult = ast.editorResult, editorResult.hasChanges {
                        if let image = editorResult.editorImage {
                            mediaAsset = TGMediaAsset(image: image)
                        }
                    } else if FileManager.default.fileExists(atPath: ast.uniqueIdentifier()) {
                        if let url = URL(string: ast.uniqueIdentifier()) {
                            mediaAsset = TGMediaAsset(image: UIImage(contentsOfFile: url.path))
                        }
                    }
                }
            default:
                mediaAsset = TGMediaAsset(phAsset: asset.asset)
            }
            guard let mediaasset = mediaAsset else {
                return
            }
            let controller = MKPhotoEditorController(asset: mediaAsset as! TGMediaEditableItem, intent: asset.isVideo() ? MKPhotoEditorControllerVideoIntent :  MKPhotoEditorControllerGenericIntent, adjustments: asset.editorResult?.adjustments as? MKMediaEditAdjustments, caption: nil, screenImage: nil, availableTabs: MKPhotoEditorCropTab, selectedTab: type == .crop ? MKPhotoEditorCropTab : MKPhotoEditorPaintTab)!
            controller.editingContext = context.editingContext
            if let lockAspectRatio = lockAspectRatio {
                controller.cropLockedAspectRatio = lockAspectRatio
            }
            controller.requestImage = {
                if let imageView = fromView as? UIImageView {
                    return imageView.image
                }
                return nil
            }
            controller.requestThumbnailImage = { editableItem in
                return editableItem!.thumbnailImageSignal!()
            }
            controller.requestOriginalScreenSizeImage = { (editableItem, position) in
                return editableItem!.screenImageSignal!(position)
            }
            controller.requestOriginalFullSizeImage = { (editableItem, position) in
                return editableItem!.originalImageSignal!(position)
            }
            controller.beginTransitionIn = { referenceFrame, _ in
                fromView?.alpha = 0.001
                referenceFrame?.pointee = animationTargetFrame()
                observer.send(value: .beginTransitionIn)
                return fromView
            }
            controller.finishedTransitionIn = {
                maskView?.alpha = 1
                observer.send(value: .finishedTransitionIn)
            }
            controller.beginTransitionOut = { referenceFrame, parentView in
                maskView?.removeFromSuperview()
                referenceFrame?.pointee = animationTargetFrame()
                parentView?.pointee = fromView?.superview
                observer.send(value: .beginTransitionOut)
                return fromView
            }
            controller.finishedTransitionOut = { _ in
                fromView?.alpha = 1
                maskView?.alpha = 0
                maskView?.removeFromSuperview()
                observer.send(value: .finishedTransitionOut)
                observer.sendCompleted()
            }
            
            controller.willFinishEditing = { adjustments, p, hasChanges in
                if let image = p as? UIImage, let imageView = fromView as? UIImageView {
                    imageView.image = image
                }
            }

            controller.didCancelEditing = {
                fromView?.alpha = 1
                maskView?.alpha = 0
                maskView?.removeFromSuperview()
                observer.sendCompleted()
            }

            controller.didFinishEditing = { adjustments, resultImage, thumbnailImage, hasChanges in
                if hasChanges {
                    if adjustments == nil {
                        asset.editorResult = nil
                        asset.eidtorChangeObserver.send(value: nil)
                        onFinished?(asset)
                    } else {
                        let result = MediaEditorResult()
                        result.adjustments = adjustments
                        result.editorImage = resultImage
                        result.thumbnailImage = thumbnailImage
                        result.hasChanges = hasChanges
                        asset.editorResult = result
                        asset.eidtorChangeObserver.send(value: result)
                        onFinished?(asset)
                        context.setItem(asset, selected: true)
                    }
                }
            }
            if lockAspectRatio == nil {
                onViewController.addChild(controller)
                onViewController.view.addSubview(controller.view)
            } else {
                controller.skipInitialTransition = true
                controller.modalPresentationStyle = .fullScreen
                onViewController.present(controller, animated: true, completion: nil)
            }
        })
    }
}

