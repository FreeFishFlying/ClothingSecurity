//
//  MediaAssetType.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 2017/4/4.
//  Copyright © 2017年 kingxt. All rights reserved.
//

import Foundation
import Photos
import ReactiveSwift
import Result
import UIKit
import AVFoundation
import MobileCoreServices

public enum MediaAssetType: Int {
    case any
    case photo
    case video
    case gif
}

public enum MediaAssetImageType {
    case thumbnail
    case aspectRatioThumbnail
    case screen
    case fastScreen
    case largeThumbnail
    case fastLargeThumbnail
    case fullSize
}

public enum RequestImageDataError: Error {
    case inCloud
    case noData
}

public class MediaAssetImageData {
    public var fileURL: URL?
    public var fileName: String?
    public var fileUTI: String?
    public var imageData: Data?
}

func assetMediaType(for type: MediaAssetType) -> PHAssetMediaType {
    switch type {
    case .video:
        return PHAssetMediaType.video
    case .photo:
        return PHAssetMediaType.image
    default:
        return PHAssetMediaType.unknown
    }
}

func optionsForAssetImageType(_ imageType: MediaAssetImageType) -> PHImageRequestOptions {
    let options = PHImageRequestOptions()
    switch imageType {
    case .fastLargeThumbnail:
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
    case .largeThumbnail:
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
    case .aspectRatioThumbnail:
        options.deliveryMode = .highQualityFormat
    case .screen:
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
    case .fastScreen:
        options.deliveryMode = .opportunistic
        options.resizeMode = .exact
    case .fullSize:
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .none
    default:
        break
    }
    return options
}

func assetType(for type: PHAssetMediaType) -> MediaAssetType {
    switch type {
    case .image:
        return .photo
    case .video:
        return MediaAssetType.video
    default:
        return MediaAssetType.any
    }
}

private let imageManager: PHCachingImageManager = PHCachingImageManager()

public class VideoUrlAsset: MediaAsset {
    public let identifier: String
    public let avAsset: AVURLAsset

    public init(url: URL) {
        identifier = url.path
        avAsset = AVURLAsset(url: url)
        super.init(asset: PHAsset())
    }

    public override func isVideo() -> Bool {
        return true
    }

    public override func uniqueIdentifier() -> String {
        return identifier
    }

    public override func isLivePhoto() -> Bool {
        return false
    }

    public override func subtypes() -> PHAssetMediaSubtype {
        return PHAssetMediaSubtype.videoTimelapse
    }

    public override func type() -> MediaAssetType {
        return .video
    }

    public override func isGif() -> Bool {
        return false
    }

    public override func fileName() -> String? {
        return (identifier as NSString).lastPathComponent
    }

    public override func dimensions() -> CGSize {
        guard let track = AVAsset(url: URL(fileURLWithPath: identifier)).tracks(withMediaType: AVMediaType.video).first else { return CGSize.zero }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: fabs(size.width), height: fabs(size.height))
    }

    public override func videoDuration() -> TimeInterval {
        return CMTimeGetSeconds(avAsset.duration)
    }

    public override func imageSignal(imageType _: MediaAssetImageType, size _: CGSize, allowNetworkAccess _: Bool, applyEditorPresentation _: Bool) -> SignalProducer<(UIImage?, Double?), RequestImageDataError> {
        return SignalProducer.empty
    }

    public override func avAssetSignal(allowNetworkAccess _: Bool) -> SignalProducer<(AVAsset?, Double?), RequestImageDataError> {
        return SignalProducer<(AVAsset?, Double?), RequestImageDataError> { observer, _ in
            observer.send(value: (self.avAsset, nil))
            observer.sendCompleted()
        }
    }
}

public class ImageAsset: MediaAsset {

    public let image: UIImage
    public let identifier: String

    public init(image: UIImage) {
        self.image = image
        identifier = UUID().uuidString
        super.init(asset: PHAsset())
    }

    public override func isVideo() -> Bool {
        return false
    }

    public override func uniqueIdentifier() -> String {
        return identifier
    }

    public override func isLivePhoto() -> Bool {
        return false
    }

    public override func subtypes() -> PHAssetMediaSubtype {
        return PHAssetMediaSubtype.photoHDR
    }

    public override func type() -> MediaAssetType {
        if image.kf.gifRepresentation() != nil {
            return .gif
        }
        return .photo
    }

    public override func isGif() -> Bool {
        return type() == .gif
    }

    public override func fileName() -> String? {
        return identifier + ".jpg"
    }

    public override func dimensions() -> CGSize {
        return image.size
    }

    public override func imageSignal(imageType _: MediaAssetImageType, size _: CGSize, allowNetworkAccess _: Bool, applyEditorPresentation: Bool) -> SignalProducer<(UIImage?, Double?), RequestImageDataError> {
        return SignalProducer<(UIImage?, Double?), RequestImageDataError> { observer, _ in
            if applyEditorPresentation {
                var image: UIImage? = self.editorResult?.cropResult?.apply(image: self.image) ?? self.image
                if let filter = self.editorResult?.filterResult {
                    image = filter.apply(image: image)
                }
                observer.send(value: (image, nil))
            } else {
                observer.send(value: (self.image, nil))
            }
            observer.sendCompleted()
        }
    }
}

open class MediaAsset: NSObject, MediaSelectableItem {

    public let asset: PHAsset
    public var cachedType: MediaAssetType?
    public var fileSize: UInt64?
    public var hasEdited = false
    public var editedImage: UIImage?
    public var comment: String?
    public var hasDownloadOriginalImage = false

    public let (eidtorChangeSignal, eidtorChangeObserver) = Signal<MediaEditorResult?, NoError>.pipe()

    public var editorResult: MediaEditorResult?

    public init(asset: PHAsset) {
        self.asset = asset
    }

    open func uniqueIdentifier() -> String {
        return asset.localIdentifier
    }

    private func representsBurst() -> Bool {
        return asset.representsBurst
    }

    open func isVideo() -> Bool {
        return type() == .video
    }

    open func videoDuration() -> TimeInterval {
        return asset.duration
    }

    public var creationDate: Date? {
        return asset.creationDate
    }

    open func fileSizeSignal() -> SignalProducer<UInt64, NoError> {
        return SignalProducer<UInt64, NoError>.init { (observer: Signal<UInt64, NoError>.Observer, _) in
            if self.fileSize != nil {
                observer.send(value: self.fileSize!)
                observer.sendCompleted()
            } else {
                if self.isVideo() {
                    let options = PHVideoRequestOptions()
                    options.version = .original
                    imageManager.requestAVAsset(forVideo: self.asset, options: options, resultHandler: { (avAsset: AVAsset?, _, _) in
                        if avAsset is AVURLAsset {
                            let urlAsset: AVURLAsset? = (avAsset as? AVURLAsset)
                            let size: NSNumber? = try? urlAsset?.url.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).allValues.first?.value as! NSNumber
                            self.fileSize = UInt64(size?.int64Value ?? 0)
                            observer.send(value: self.fileSize!)
                            observer.sendCompleted()
                        } else {
                            observer.send(value: 0)
                            observer.sendCompleted()
                        }
                    })
                } else {
                    if #available(iOS 10.0, *) {
                        let resources = PHAssetResource.assetResources(for: self.asset)
                        var sizeOnDisk: Int64? = 0
                        if let resource = resources.first {
                            let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
                            sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64 ?? 0))
                        }
                        observer.send(value: UInt64(sizeOnDisk ?? 0))
                        observer.sendCompleted()
                    } else {
                        let options = PHContentEditingInputRequestOptions()
                        options.isNetworkAccessAllowed = false
                        self.asset.requestContentEditingInput(with: options, completionHandler: { contentEditingInput, _ in
                            guard let url = contentEditingInput?.fullSizeImageURL else {
                                observer.send(value: 0)
                                return observer.sendCompleted()
                            }
                            guard let fileAttributes = try? FileManager.default.attributesOfItem(atPath: url.path) else {
                                observer.send(value: 0)
                                return observer.sendCompleted()
                            }
                            let fileSizeNumber = fileAttributes[FileAttributeKey.size] as! NSNumber
                            self.fileSize = UInt64(fileSizeNumber.int64Value)
                            observer.send(value: self.fileSize!)
                            observer.sendCompleted()
                        })
                    }
                }
            }
        }
    }

    @available(iOS 9.1, *)
    public func isLivePhoto() -> Bool {
        return asset.mediaSubtypes == .photoLive
    }

    @available(iOS 9.1, *)
    public func livePhoto(targetSize: CGSize) -> SignalProducer<PHLivePhoto?, NoError> {
        let options = PHLivePhotoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .opportunistic
        return SignalProducer<PHLivePhoto?, NoError>.init { (observer: Signal<PHLivePhoto?, NoError>.Observer, _) in
            PHImageManager.default().requestLivePhoto(for: self.asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (livePhoto: PHLivePhoto?, info: [AnyHashable: Any]?) in
                var isDegraded = false
                if let degradedItem = info?[PHImageResultIsDegradedKey] as? NSNumber {
                    isDegraded = degradedItem.boolValue
                }
                observer.send(value: livePhoto)
                if !isDegraded {
                    observer.sendCompleted()
                }
            }
        }
    }

    public func subtypes() -> PHAssetMediaSubtype {
        return asset.mediaSubtypes
    }

    open func type() -> MediaAssetType {
        if cachedType == nil {
            if isGif() {
                cachedType = .gif
            } else {
                cachedType = assetType(for: asset.mediaType)
            }
        }
        return cachedType!
    }

    open func isGif() -> Bool {
        return uniformTypeIdentifier() == kUTTypeGIF as String
    }

    open func uniformTypeIdentifier() -> String {
        return (asset.value(forKey: "uniformTypeIdentifier") as? String) ?? (kUTTypeJPEG as String)
    }

    open func fileName() -> String? {
        return asset.value(forKey: "filename") as? String
    }

    open func dimensions() -> CGSize {
        return CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
    }

    open func imageSignal(imageType: MediaAssetImageType, size: CGSize, allowNetworkAccess: Bool, applyEditorPresentation: Bool = false) -> SignalProducer<(UIImage?, Double?), RequestImageDataError> {
        var imageSize = size
        if imageType == .fullSize {
            imageSize = PHImageManagerMaximumSize
        }
        let isScreenImage = imageType == .fullSize || imageType == .fastScreen
        let options = optionsForAssetImageType(imageType)
        var contentMode: PHImageContentMode = .aspectFill
        if isScreenImage {
            contentMode = .aspectFit
        }
        if editorResult?.hasChanges ?? false {
            return SignalProducer<(UIImage?, Double?), RequestImageDataError>({ [weak self] (observer: Signal<(UIImage?, Double?), RequestImageDataError>.Observer, _) in
                observer.send(value: (size.width < 200 ? self?.editorResult?.thumbnailImage : self?.editorResult?.editorImage, nil))
            })
        }
        if let editorImage = self.editorResult?.editorImage {
            return SignalProducer<(UIImage?, Double?), RequestImageDataError>({ (observer: Signal<(UIImage?, Double?), RequestImageDataError>.Observer, _) in
                observer.send(value: (editorImage, nil))
            })
        }
        let applyEditor: ((UIImage?) -> UIImage?) = { (image: UIImage?) in
            if applyEditorPresentation && self.editorResult != nil {
                guard let image = image else {
                    return nil
                }
                if let editorResult = self.editorResult {
                    return editorResult.applyTo(image: image)
                }
                return image
            }
            return image
        }
        if representsBurst() && (isScreenImage || imageType == .fullSize) {
            let signal = mediaAssetImageDataSignal(allowNetworkAccess: allowNetworkAccess).filter({ (imageData, progress) -> Bool in
                if imageData == nil && progress != nil {
                    return false
                }
                return true
            }).filterMap({ (data: (MediaAssetImageData?, Double?)) -> (UIImage?, Double?)? in
                if let imageData = data.0?.imageData {
                    let image: UIImage? = UIImage(data: imageData)
                    return (image, data.1)
                }
                return nil
            })
            if imageType == .fastScreen {
                let fastFetchSignal = imageSignal(imageType: .aspectRatioThumbnail, size: CGSize(width: 128, height: 128), allowNetworkAccess: true)
                return fastFetchSignal.then(signal)
            }
            return signal
        } else if isVideo() && asset.mediaSubtypes == .videoHighFrameRate && isScreenImage {
            // TODO:
        } else {
            return SignalProducer<(UIImage?, Double?), RequestImageDataError>({ (observer: Signal<(UIImage?, Double?), RequestImageDataError>.Observer, disposable) in
                var requestOptions = options
                if allowNetworkAccess {
                    if imageType == .fastScreen {
                        requestOptions = optionsForAssetImageType(.screen)
                    } else {
                        requestOptions = options.copy() as! PHImageRequestOptions
                    }
                    requestOptions.isNetworkAccessAllowed = true
                    requestOptions.progressHandler = { (progress, _: Error?, _, _: Dictionary?) in
                        observer.send(value: (nil, progress))
                    }
                }
                let token = imageManager.requestImage(for: self.asset, targetSize: imageSize, contentMode: contentMode, options: requestOptions, resultHandler: { (image: UIImage?, info: Dictionary?) in
                    if let cancelled = info?[PHImageCancelledKey] as? NSNumber {
                        if cancelled.boolValue {
                            return
                        }
                    }
                    var isDegraded = false
                    if let degradedItem = info?[PHImageResultIsDegradedKey] as? NSNumber {
                        isDegraded = degradedItem.boolValue
                    }
                    if image == nil && !allowNetworkAccess {
                        observer.send(error: .noData)
                        return
                    }
                    if image != nil {
                        if allowNetworkAccess {
                            observer.send(value: (nil, 1))
                        }
                        observer.send(value: (applyEditor(image), isDegraded ? 0 : nil))
                        if !isDegraded {
                            observer.sendCompleted()
                        }
                    } else {
                        observer.send(error: .noData)
                    }
                })

                disposable.observeEnded {
                    imageManager.cancelImageRequest(token)
                }
            })
        }
        return SignalProducer.empty
    }

    open func playerItemSignal() -> SignalProducer<(AVPlayerItem?, Double?), NoError> {
        return SignalProducer<(AVPlayerItem?, Double?), NoError>.init { (observer: Signal<(AVPlayerItem?, Double?), NoError>.Observer, disposable) in
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            options.progressHandler = { (progress, _: Error?, _, _: Dictionary?) in
                observer.send(value: (nil, progress))
            }
            let token: PHImageRequestID = imageManager.requestPlayerItem(forVideo: self.asset, options: options, resultHandler: { (playerItem: AVPlayerItem?, info: [AnyHashable: Any]?) in
                if let cancelled = info?[PHImageCancelledKey] as? NSNumber {
                    if cancelled.boolValue {
                        return
                    }
                }
                observer.send(value: (playerItem, nil))
                observer.sendCompleted()
            })
            disposable.observeEnded {
                imageManager.cancelImageRequest(token)
            }
        }
    }

    open func mediaAssetImageDataSignal(allowNetworkAccess: Bool) -> SignalProducer<(MediaAssetImageData?, Double?), RequestImageDataError> {
        return SignalProducer<(MediaAssetImageData?, Double?), RequestImageDataError>({ (observer: Signal<(MediaAssetImageData?, Double?), RequestImageDataError>.Observer, disposable: Lifetime) in
            let options = optionsForAssetImageType(.fullSize)
            if allowNetworkAccess {
                options.isNetworkAccessAllowed = true
                options.progressHandler = { (progress, _: Error?, _, _: Dictionary?) in
                    observer.send(value: (nil, progress))
                }
            }
            let token: PHImageRequestID = imageManager.requestImageData(for: self.asset, options: options, resultHandler: { (imageData: Data?, dataUTI: String?, _: UIImage.Orientation, info: Dictionary?) in
                let inCloud: Bool = (info?[PHImageResultIsInCloudKey] as? NSNumber)?.boolValue ?? false
                if inCloud && imageData?.count == 0 && !allowNetworkAccess {
                    observer.send(error: RequestImageDataError.inCloud)
                }
                let fileURL = info?["PHImageFileURLKey"] as? URL
                var pathExtension: String = ""
                var fileName: String?
                if let fileURL = fileURL {
                    let newURL = NSURL(fileURLWithPath: fileURL.path)
                    fileName = newURL.lastPathComponent
                    pathExtension = newURL.pathExtension ?? ""
                }
                if fileName == "FullSizeRender.\(pathExtension)" {
                    let components = fileURL!.absoluteString.components(separatedBy: "/")
                    var found = false
                    for component: String in components {
                        if component.hasPrefix("IMG_") {
                            fileName = "\(component).\(pathExtension)"
                            found = true
                            break
                        }
                    }
                    if found == false {
                        fileName = self.fileName()
                    }
                }
                let mediaData: MediaAssetImageData = MediaAssetImageData()
                mediaData.fileURL = fileURL
                mediaData.fileName = fileName
                mediaData.fileUTI = dataUTI
                mediaData.imageData = imageData

                var isDegraded = false
                if let degradedItem = info?[PHImageResultIsDegradedKey] as? NSNumber {
                    isDegraded = degradedItem.boolValue
                }

                if !isDegraded {
                    observer.send(value: (mediaData, 1))
                    observer.sendCompleted()
                }
            })

            disposable.observeEnded {
                imageManager.cancelImageRequest(token)
            }
        })
    }

    open func avAssetSignal(allowNetworkAccess: Bool) -> SignalProducer<(AVAsset?, Double?), RequestImageDataError> {
        return SignalProducer<(AVAsset?, Double?), RequestImageDataError>.init { (observer: Signal<(AVAsset?, Double?), RequestImageDataError>.Observer, disposable: Lifetime) in
            let requestOptions = PHVideoRequestOptions()
            requestOptions.isNetworkAccessAllowed = allowNetworkAccess
            if allowNetworkAccess {
                requestOptions.deliveryMode = .highQualityFormat
                requestOptions.progressHandler = { (progress, _: Error?, _, _: Dictionary?) in
                    observer.send(value: (nil, progress))
                }
            }
            let token: PHImageRequestID = imageManager.requestAVAsset(forVideo: self.asset, options: requestOptions, resultHandler: { (avAsset: AVAsset?, _, info: [AnyHashable: Any]?) in
                if let cancelled = info?[PHImageCancelledKey] as? NSNumber {
                    if cancelled.boolValue {
                        return
                    }
                }
                if avAsset == nil && !allowNetworkAccess {
                    observer.send(error: .noData)
                    return
                }
                if avAsset != nil {
                    observer.send(value: (avAsset, nil))
                    observer.sendCompleted()
                } else {
                    observer.send(error: .noData)
                }
            })

            disposable.observeEnded {
                imageManager.cancelImageRequest(token)
            }
        }
    }

    open func videoThumbnailsSignal(avAsset: AVAsset, size: CGSize, timestamps: [TimeInterval]) -> SignalProducer<[UIImage], NoError> {
        return SignalProducer<[UIImage], NoError>.init { (observer: Signal<[UIImage], NoError>.Observer, _: Lifetime) in
            var images = [UIImage]()
            let generator = AVAssetImageGenerator(asset: avAsset)
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = size
            let values = timestamps.map({ (time) -> NSValue in
                NSNumber(value: time)
            })
            generator.generateCGImagesAsynchronously(forTimes: values, completionHandler: { (_: CMTime, imageRef: CGImage?, _: CMTime, result: AVAssetImageGenerator.Result, _: Error?) in
                guard let imageRef = imageRef else {
                    observer.sendInterrupted()
                    return
                }
                let image = UIImage(cgImage: imageRef)
                if result == .succeeded {
                    images.append(image)
                }
                if images.count == timestamps.count {
                    observer.send(value: images)
                    observer.sendCompleted()
                }
            })
        }
    }
}
