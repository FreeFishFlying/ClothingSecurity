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

    let path: String?

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
                asset.avAssetSignal(allowNetworkAccess: false).take(first: 1).startWithResult({ (result: Result<(AVAsset?, Double?), RequestImageDataError>) in
                    if disposable.hasEnded {
                        observer.sendInterrupted()
                        return
                    }
                    if let value = result.value, let avAsset = value.0 {
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
                                        progressView.setProgress(Float(progress), animated: progressView.progress < Float(progress))
                                    }
                                }
                            }
                        })
                        disposable += cancelTask
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
    } else {
        completedHandler(assets)
    }
}

public class MediaSelectionContext: SelectionContext {

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
}
