//
//  MediaSelectionContext.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 2017/4/8.
//  Copyright © 2017年 kingxt. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result
import AVFoundation
import Core
import MediaEditorKit
import HUD

public protocol MediaSelectableItem: SelectableItem {
    func type() -> MediaAssetType
}

public struct MediaConcreteItem: MediaSelectableItem {

    let mediaType: MediaAssetType

    public let path: String?

    public var image: UIImage?

    public var videoDuration: TimeInterval?

    public func type() -> MediaAssetType {
        return mediaType
    }

    public func uniqueIdentifier() -> String {
        return path ?? UUID().description
    }

    public init(mediaType: MediaAssetType, path: String?) {
        self.mediaType = mediaType
        self.path = path
    }

    public init(mediaType: MediaAssetType, path: String?, image: UIImage?, videoDuration: TimeInterval?) {
        self.mediaType = mediaType
        self.path = path
        self.image = image
        self.videoDuration = videoDuration
    }
}

public func handleVideo(assets: [MediaAsset], completedHandler: @escaping ([MediaSelectableItem]) -> Void) {
    var results = [MediaSelectableItem]()

    var hasVideo = false
    for asset in assets {
        hasVideo = asset.isVideo()
        if hasVideo {
            break
        }
    }
    if hasVideo {
        var producers = [SignalProducer<Void, NoError>]()
        let compressSignal: (_ asset: MediaAsset) -> SignalProducer<Void, NoError> = { (asset: MediaAsset) in
            SignalProducer<Void, NoError> { observer, _ in
                let requestOptions = PHVideoRequestOptions()
                requestOptions.isNetworkAccessAllowed = true
                requestOptions.version = .current
                requestOptions.deliveryMode = .automatic
                let token = PHImageManager.default().requestAVAsset(forVideo: asset.asset, options: requestOptions, resultHandler: { (avAsset: AVAsset?, _, _: [AnyHashable: Any]?) in
                    if let avAsset = avAsset, let urlAsset = avAsset as? AVURLAsset {
                        var url: URL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(UUID().uuidString).tmp")
                        url = url.deletingPathExtension().appendingPathExtension(urlAsset.url.pathExtension)
                        do {
                            try FileManager.default.copyItem(at: urlAsset.url, to: url)

                            let duration = TimeInterval(CMTimeGetSeconds(urlAsset.duration))
                            let imgGenerator = AVAssetImageGenerator(asset: urlAsset)
                            imgGenerator.appliesPreferredTrackTransform = true
                            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                            let thumbnail = UIImage(cgImage: cgImage)
                            results.append(MediaConcreteItem(mediaType: .video, path: url.path, image: thumbnail, videoDuration: duration))
                            observer.sendCompleted()
                        } catch {
                            observer.sendCompleted()
                        }
                    }
                })
            }
        }

        for asset in assets {
            if asset.type() == .video {
                producers.append(compressSignal(asset))
            } else {
                results.append(asset)
            }
        }

        let fsp = SignalProducer<SignalProducer<Void, NoError>, NoError>(producers)
        let tasks = fsp.flatten(.concat)
            .on(completed: {
                DispatchQueue.main.async {
                    completedHandler(results)
                }
            }, value: {}).start()
    } else {
        completedHandler(assets)
    }
}

public func compressVideo(assets: [MediaAsset], cancelHandler: (() -> Void)? = nil, completedHandler: @escaping ([MediaSelectableItem]) -> Void) {
    var results = [MediaSelectableItem]()

    var hasVideo = false
    for asset in assets {
        hasVideo = asset.isVideo()
        if hasVideo {
            break
        }
    }
    if hasVideo {
        let progressView = UIProgressView()
        let alertController = UIAlertController(title: SLLocalized("MediaEditor.CompressingVideo"), message: nil, progressView: progressView)
        let controller = OverlayViewController()
        controller.show()
        var producers = [SignalProducer<Void, NoError>]()

        let compressSignal: (_ asset: MediaAsset) -> SignalProducer<Void, NoError> = { (asset: MediaAsset) in
            SignalProducer<Void, NoError> { observer, disposable in
                asset.avAssetSignal(allowNetworkAccess: true).startWithResult({ (result: Result<(AVAsset?, Double?), RequestImageDataError>) in
                    if disposable.hasEnded {
                        observer.sendInterrupted()
                        return
                    }
                    if let value = result.value {
                        if let avAsset = value.0 {
                            let adjustments: MediaVideoEditAdjustments
                            if let editorResult = asset.editorResult {
                                let trimStartValue: TimeInterval = editorResult.videoTrimResult == nil ? 0 : CMTimeGetSeconds(editorResult.videoTrimResult!.start)
                                let trimEndValue: TimeInterval = editorResult.videoTrimResult == nil ? asset.videoDuration() : CMTimeGetSeconds(editorResult.videoTrimResult!.start + editorResult.videoTrimResult!.duration)

                                adjustments = MediaVideoEditAdjustments(trimStartValue: trimStartValue,
                                                                        trimEndValue: trimEndValue,
                                                                        cropRect: editorResult.cropResult?.cropRect,
                                                                        originalCropRect: editorResult.cropResult?.originalCropRect,
                                                                        cropOrientation: editorResult.cropResult?.cropOrientation,
                                                                        mirrored: editorResult.cropResult?.mirrored ?? false,
                                                                        playRate: editorResult.playRate ?? .normal)
                            } else {
                                adjustments = MediaVideoEditAdjustments(trimStartValue: 0, trimEndValue: asset.videoDuration())
                            }
                            let cancelTask = VideoConverter().convert(avAsset: avAsset, adjustments: adjustments).startWithResult({ (result: Result<VideoConverter.ConverterResult, NSError>) in
                                if let url = result.value?.fileURL, let converImage = result.value?.coverImage, let videoDuration = result.value?.duration {
                                    results.append(MediaConcreteItem(mediaType: .video, path: url.path, image: converImage, videoDuration: videoDuration))
                                    observer.sendCompleted()
                                }
                                if result.error != nil {
                                    DispatchQueue.main.async {
                                        HUD.tip(text: SLLocalized("Video.CompressError"), onView: UIApplication.shared.keyWindow!)
                                    }
                                    observer.sendCompleted()
                                }
                                if let value = result.value {
                                    if let progress = value.progress {
                                        DispatchQueue.main.async {
                                            alertController.title = SLLocalized("MediaEditor.CompressingVideo")
                                            progressView.setProgress(Float(progress), animated: progressView.progress < Float(progress))
                                        }
                                    }
                                }
                            })
                            disposable += cancelTask
                        } else if let progress = value.1 {
                            print(progress)
                            DispatchQueue.main.async {
                                alertController.title = SLLocalized("MediaEditor.DownloadVideo")
                                progressView.setProgress(Float(progress), animated: progressView.progress < Float(progress))
                            }
                        }
                    } else {
                        observer.sendCompleted() // load av error and ignore
                    }
                })
            }
        }

        for asset in assets {
            if asset.type() == .video {
                producers.append(compressSignal(asset))
            } else {
                results.append(asset)
            }
        }

        let fsp = SignalProducer<SignalProducer<Void, NoError>, NoError>(producers)
        let tasks = fsp.flatten(.concat)
            .on(completed: {
                DispatchQueue.main.async {
                    controller.dismiss()
                    completedHandler(results)
                }
            }, value: {}).start()
        alertController.addAction(UIAlertAction(title: SLLocalized("MediaAssetsPicker.Cancel"), style: .cancel, handler: { _ in
            cancelHandler?()
            tasks.dispose()
            controller.dismiss()
        }))
        controller.present(alertController, animated: true, completion: nil)

        _ = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { _ in
            cancelHandler?()
            tasks.dispose()
            controller.dismiss()
        }
    } else {
        completedHandler(assets)
    }
}

open class MediaSelectionContext: SelectionContext {

    public var videoMaxCount: Int?
    public var imageMaxCount: Int?
    private lazy var images = [MediaSelectableItem]()
    private lazy var videos = [MediaSelectableItem]()

    private var setItemLimitErrorPipe = Signal<MediaAssetType, NoError>.pipe()

    public var isSelectOriginalImage = MutableProperty<Bool>(false)

    var editingContext: MKMediaEditingContext?

    public func selectedAssetFileSizeSignal() -> SignalProducer<UInt64, NoError> {
        let values: [MediaAsset] = selectedValues()
        var signals: [SignalProducer<UInt64, NoError>] = [SignalProducer<UInt64, NoError>]()
        for item in values {
            signals.append(item.fileSizeSignal())
        }

        return SignalProducer(signals).flatten(.merge).collect().filterMap({ (sizeItems) -> UInt64 in
            let total = sizeItems.reduce(0, { $0 + $1 })
            return total
        }).observe(on: UIScheduler())
    }

    public func setItemLimitErrorSignl() -> Signal<MediaAssetType, NoError> {
        return setItemLimitErrorPipe.output
    }

    @discardableResult override open func setItem(_ item: SelectableItem, selected: Bool, animated: Bool = true) -> Bool {
        if selected {
            if let maxVideo = videoMaxCount, let item = item as? MediaSelectableItem, item.type() == .video {
                if !videos.contains(where: { (video) -> Bool in
                    video.uniqueIdentifier() == item.uniqueIdentifier()
                }), videos.count == maxVideo {
                    setItemLimitErrorPipe.input.send(value: .video)
                    return false
                } else {
                    videos.append(item)
                }
            }
            if let maxImage = imageMaxCount, let item = item as? MediaSelectableItem, item.type() == .photo {
                if !images.contains(where: { (image) -> Bool in
                    image.uniqueIdentifier() == item.uniqueIdentifier()
                }), images.count == maxImage {
                    setItemLimitErrorPipe.input.send(value: .photo)
                    return false
                } else {
                    images.append(item)
                }
            }
        } else {
            if let index = videos.firstIndex(where: { (media) -> Bool in
                media.uniqueIdentifier() == item.uniqueIdentifier()
            }) {
                videos.remove(at: index)
            }
            if let index = images.firstIndex(where: { (media) -> Bool in
                media.uniqueIdentifier() == item.uniqueIdentifier()
            }) {
                images.remove(at: index)
            }
        }
        return super.setItem(item, selected: selected, animated: animated)
    }
}
