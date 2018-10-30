//
//  VideoConverter.swift
//  Components-Swift
//
//  Created by kingxt on 5/23/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import ReactiveSwift
import Result
import Core

public class MediaVideoSettings {
    public enum Present: Int {
        case `default`
        case veryLow
        case low
        case medium
        case high
        case veryHigh
        case animation
    }

    public enum PlayRate: Float {
        case verySlow = 0.5
        case slow = 0.75
        case normal = 1.0
        case fast = 2
        case veryFast = 3
    }

    public class func maximumSize(preset: Present) -> CGSize {
        switch preset {
        case .veryLow:
            return CGSize(width: 480, height: 480)
        case .low:
            return CGSize(width: 640.0, height: 640.0)
        case .medium:
            return CGSize(width: 848.0, height: 848.0)
        case .high:
            return CGSize(width: 1280.0, height: 1280.0)
        case .veryHigh:
            return CGSize(width: 1920.0, height: 1920.0)
        default:
            return CGSize(width: 640.0, height: 640.0)
        }
    }

    public class func audioSettings(preset: Present) -> [String: Any] {
        let bitrate: Int = MediaVideoSettings.audioBitrateKbps(preset: preset)
        let channels: Int = MediaVideoSettings.audioChannelsCount(preset: preset)
        var acl: AudioChannelLayout = AudioChannelLayout()
        acl.mChannelLayoutTag = channels > 1 ? kAudioChannelLayoutTag_Stereo : kAudioChannelLayoutTag_Mono
        return [AVFormatIDKey: kAudioFormatMPEG4AAC, AVSampleRateKey: 44100.0, AVEncoderBitRateKey: (bitrate * 1000), AVNumberOfChannelsKey: channels, AVChannelLayoutKey: NSData(bytes: &acl, length: MemoryLayout<AudioChannelLayout>.size)]
    }

    public class func audioBitrateKbps(preset: Present) -> Int {
        switch preset {
        case .veryLow:
            return 32
        case .low:
            return 32
        case .medium:
            return 64
        case .high:
            return 64
        case .veryHigh:
            return 64
        default:
            return 32
        }
    }

    public class func audioChannelsCount(preset: Present) -> Int {
        switch preset {
        case .veryLow:
            return 1
        case .low:
            return 1
        case .medium:
            return 2
        case .high:
            return 2
        case .veryHigh:
            return 2
        default:
            return 1
        }
    }

    public class func videoOrientation(asset: AVAsset) -> (orientation: UIImage.Orientation, mirrored: Bool) {
        if let videoTrack: AVAssetTrack = asset.tracks(withMediaType: AVMediaType.video).first {
            let t: CGAffineTransform = videoTrack.preferredTransform
            let videoRotation: Double = atan2(Double(t.b), Double(t.a))
            // TODO: UI Thread           let tempView = UIView()
            //            tempView.transform = t
            //            let scale = CGSize(width: (tempView.layer.value(forKeyPath: "transform.scale.x") as! CGFloat), height: tempView.layer.value(forKeyPath: "transform.scale.y") as! CGFloat)
            let mirrored = false // (scale.width < 0)
            if fabs(videoRotation - Double.pi) < Double.ulpOfOne {
                return (.left, mirrored)
            } else if fabs(videoRotation - Double.pi / 2) < Double.ulpOfOne {
                return (.up, mirrored)
            } else if fabs(videoRotation + Double.pi / 2) < Double.ulpOfOne {
                return (.down, mirrored)
            } else {
                return (.right, mirrored)
            }
        }
        return (.up, false)
    }

    public class func videoTransformForOrientation(_ orientation: UIImage.Orientation, size: CGSize, cropRect: CGRect, mirror: Bool) -> CGAffineTransform {
        var cropRect = cropRect
        var transform = CGAffineTransform.identity
        if mirror {
            if orientationIsSideward(orientation: orientation).sideward {
                cropRect.origin.y *= -1
                transform = transform.translatedBy(x: 0, y: size.height)
                transform = transform.scaledBy(x: 1.0, y: -1.0)
            } else {
                cropRect.origin.x = size.height - cropRect.origin.x
                transform = transform.scaledBy(x: -1.0, y: 1.0)
            }
        }
        switch orientation {
        case .up:
            transform = transform.translatedBy(x: size.height - cropRect.origin.x, y: 0 - cropRect.origin.y).rotated(by: CGFloat.pi / 2)
        case .down:
            transform = transform.translatedBy(x: 0 - cropRect.origin.x, y: size.width - cropRect.origin.y).rotated(by: -CGFloat.pi / 2)
        case .right:
            transform = transform.translatedBy(x: 0 - cropRect.origin.x, y: 0 - cropRect.origin.y).rotated(by: 0)
        case .left:
            transform = transform.translatedBy(x: size.width - cropRect.origin.x, y: size.height - cropRect.origin.y).rotated(by: CGFloat.pi)
        default:
            break
        }
        return transform
    }

    public class func videoTransformForCrop(orientation: UIImage.Orientation, size: CGSize, mirrored: Bool) -> CGAffineTransform {
        var size = size
        if orientationIsSideward(orientation: orientation).sideward {
            size = CGSize(width: size.height, height: size.width)
        }
        var transform = CGAffineTransform(translationX: size.width / 2.0, y: size.height / 2.0)
        switch orientation {
        case .down:
            transform = transform.rotated(by: CGFloat.pi)
        case .right:
            transform = transform.rotated(by: CGFloat.pi / 2)
        case .left:
            transform = transform.rotated(by: -CGFloat.pi / 2)
        default:
            break
        }

        if mirrored {
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        }
        if orientationIsSideward(orientation: orientation).sideward {
            size = CGSize(width: size.height, height: size.width)
        }
        transform = transform.translatedBy(x: -size.width / 2.0, y: -size.height / 2.0)
        return transform
    }

    public class func videoSettings(preset: Present, dimensions: CGSize) -> [String: Any] {
        let videoCleanApertureSettings: [String: Any] = [AVVideoCleanApertureWidthKey: Int(dimensions.width), AVVideoCleanApertureHeightKey: Int(dimensions.height), AVVideoCleanApertureHorizontalOffsetKey: 10, AVVideoCleanApertureVerticalOffsetKey: 10]

        let videoAspectRatioSettings: [String: Any] = [AVVideoPixelAspectRatioHorizontalSpacingKey: 3, AVVideoPixelAspectRatioVerticalSpacingKey: 3]

        let codecSettings: [String: Any] = [AVVideoAverageBitRateKey: (MediaVideoSettings.videoBitrateKbps(preset: preset) * 1000), AVVideoCleanApertureKey: videoCleanApertureSettings, AVVideoPixelAspectRatioKey: videoAspectRatioSettings]

        return [AVVideoCodecKey: AVVideoCodecH264, AVVideoCompressionPropertiesKey: codecSettings, AVVideoWidthKey: Int(dimensions.width), AVVideoHeightKey: Int(dimensions.height)]
    }

    public class func videoBitrateKbps(preset: Present) -> Int {
        switch preset {
        case .veryLow:
            return 400
        case .low:
            return 700
        case .medium:
            return 1100
        case .high:
            return 2400
        case .veryHigh:
            return 3600
        default:
            return 700
        }
    }
}

public class MediaVideoEditAdjustments {

    public private(set) var cropRect: CGRect? // applyed zoomed
    public private(set) var originalCropRect: CGRect?
    public private(set) var cropOrientation: UIImage.Orientation?

    public private(set) var mirrored: Bool = false

    public let trimStartValue: TimeInterval
    public let trimEndValue: TimeInterval

    public private(set) var present: MediaVideoSettings.Present = .default
    public private(set) var overlayImage: UIImage?
    public private(set) var inhibitAudio: Bool = false
    public private(set) var playRate: MediaVideoSettings.PlayRate = .normal

    public init(trimStartValue: TimeInterval,
                trimEndValue: TimeInterval,
                cropRect: CGRect? = nil,
                originalCropRect: CGRect? = nil,
                cropOrientation: UIImage.Orientation? = nil,
                mirrored: Bool = false,
                present: MediaVideoSettings.Present = .default,
                overlayImage: UIImage? = nil,
                inhibitAudio: Bool = false,
                playRate: MediaVideoSettings.PlayRate = .normal) {
        self.cropRect = cropRect
        self.originalCropRect = originalCropRect
        self.cropOrientation = cropOrientation
        self.mirrored = mirrored
        self.trimStartValue = trimStartValue
        self.trimEndValue = trimEndValue
        self.present = present
        self.overlayImage = overlayImage
        self.inhibitAudio = inhibitAudio
        self.playRate = playRate
    }

    func trimApplied() -> Bool {
        return trimStartValue > Double.ulpOfOne || trimEndValue > Double.ulpOfOne
    }

    func trimTimeRange() -> CMTimeRange {
        return CMTimeRangeMake(start: CMTimeMakeWithSeconds(trimStartValue, preferredTimescale: Int32(Double(NSEC_PER_SEC))), duration: CMTimeMakeWithSeconds((trimEndValue - trimStartValue), preferredTimescale: Int32(Double(NSEC_PER_SEC))))
    }
}

public class VideoConverter {
    
    static let error: NSError = NSError(domain: "compress.video.error", code:-1, userInfo: nil)

    public init() {
    }

    private class MediaVideoConversionContext {
        var isCancelled = false
        var assetReader: AVAssetReader?
        var assetWriter: AVAssetWriter?
        var videoProcessor: MediaSampleBufferProcessor?
        var audioProcessor: MediaSampleBufferProcessor?
        var timeRange: CMTimeRange?
        var dimensions: CGSize?

        let queue: DispatchQueue

        init(queue: DispatchQueue) {
            self.queue = queue
        }
    }

    private class MediaSampleBufferProcessor {
        let assetReaderOutput: AVAssetReaderOutput
        let assetWriterInput: AVAssetWriterInput
        let queue: DispatchQueue
        private(set) var finished: Bool = false
        private(set) var succeed: Bool = false

        private var completionBlock: ((Bool) -> Void)?

        init(assetReaderOutput: AVAssetReaderOutput, assetWriterInput: AVAssetWriterInput) {
            self.assetReaderOutput = assetReaderOutput
            self.assetWriterInput = assetWriterInput
            queue = DispatchQueue(label: NSUUID().uuidString)
        }

        func start(timeRange: CMTimeRange, progressBlock: ((_ progress: CGFloat) -> Void)?, completionBlock: @escaping (Bool) -> Void) {
            self.completionBlock = completionBlock
            assetWriterInput.requestMediaDataWhenReady(on: queue) {
                if self.finished {
                    return
                }
                var ended: Bool = false
                var failed: Bool = false
                while self.assetWriterInput.isReadyForMoreMediaData && !ended && !failed {
                    if let sampleBuffer: CMSampleBuffer = self.assetReaderOutput.copyNextSampleBuffer() {
                        progressBlock?(self.progressOfSampleBufferInTimeRange(sampleBuffer, timeRange: timeRange))
                        let success = self.assetWriterInput.append(sampleBuffer)
                        failed = !success
                    } else {
                        ended = true
                    }
                }
                if ended || failed {
                    self.succeed = !failed
                    self.finish()
                }
            }
        }

        func finish() {
            let didFinish: Bool = finished
            finished = true
            if !didFinish {
                if succeed {
                    assetWriterInput.markAsFinished()
                }
                completionBlock?(succeed)
                completionBlock = nil
            }
        }

        func cancel() {
            queue.async {
                self.finish()
            }
        }

        func progressOfSampleBufferInTimeRange(_ sampleBuffer: CMSampleBuffer, timeRange: CMTimeRange) -> CGFloat {
            var progressTime: CMTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            let sampleDuration: CMTime = CMSampleBufferGetDuration(sampleBuffer)
            if CMTIME_IS_NUMERIC(sampleDuration) {
                progressTime = CMTimeAdd(progressTime, sampleDuration)
            }
            return CGFloat(max(0.0, min(1.0, CMTimeGetSeconds(progressTime) / CMTimeGetSeconds(timeRange.duration))))
        }
    }

    public class ConverterResult {
        public fileprivate(set) var progress: CGFloat?
        public fileprivate(set) var coverImage: UIImage?
        public fileprivate(set) var fileURL: URL?
        public fileprivate(set) var duration: TimeInterval?
        public fileprivate(set) var dimensions: CGSize?

        init(progress: CGFloat? = nil) {
            self.progress = progress
        }
    }

    public func convert(avAsset: AVAsset, adjustments: MediaVideoEditAdjustments) -> SignalProducer<ConverterResult, NSError> {
        let queue = DispatchQueue(label: "com.liao.videoconverter")
        return SignalProducer<ConverterResult, NSError>.init({ (observer: Signal<VideoConverter.ConverterResult, NSError>.Observer, disposable) in
            let context: Atomic = Atomic(MediaVideoConversionContext(queue: queue))
            let outputUrl: URL = randomTemporaryURL(extension: "mp4")

            let requiredKeys: [String] = ["tracks", "duration"]
            avAsset.loadValuesAsynchronously(forKeys: requiredKeys, completionHandler: {
                queue.async {
                    if context.value.isCancelled {
                        return
                    }

                    guard let dimensions = avAsset.tracks(withMediaType: AVMediaType.video).first?.naturalSize else {
                        return observer.send(error: VideoConverter.error)
                    }
                    var preset: MediaVideoSettings.Present = adjustments.present == .default ? .medium : adjustments.present
                    if !dimensions.equalTo(CGSize.zero) && preset != .animation {
                        let bestPreset: MediaVideoSettings.Present = self.bestAvailablePreset(dimensions: dimensions)
                        if preset.rawValue > bestPreset.rawValue {
                            preset = bestPreset
                        }
                    }

                    var error: NSError?
                    for key: String in requiredKeys {
                        if avAsset.statusOfValue(forKey: key, error: &error) != .loaded {
                            observer.send(error: error != nil ? error! : VideoConverter.error)
                            return
                        }
                        if error != nil {
                            observer.send(error: error!)
                            return
                        }
                    }

                    let outputPath: String = outputUrl.path
                    let fileManager = FileManager.default
                    if fileManager.fileExists(atPath: outputPath) {
                        do {
                            try fileManager.removeItem(atPath: outputPath)
                        } catch let error as NSError {
                            observer.send(error: error)
                            return
                        }
                    }

                    if !VideoConverter.setupAssetReaderWriter(avAsset: avAsset, outputURL: outputUrl, preset: preset, adjustments: adjustments, inhibitAudio: adjustments.inhibitAudio, conversionContext: context) {
                        observer.send(error: VideoConverter.error)
                        return
                    }

                    VideoConverter.process(context: context, observer: observer, completionBlock: { () in
                        let metadata = videoMetadata(url: outputUrl)
                        let coverImage: UIImage? = metadata.image
                        let converterResult = ConverterResult()
                        context.modify({ (context: inout VideoConverter.MediaVideoConversionContext) -> Result<Bool, NoError> in
                            converterResult.coverImage = coverImage
                            converterResult.fileURL = outputUrl
                            converterResult.dimensions = context.dimensions
                            converterResult.duration = metadata.duration
                            return .success(true)
                        })
                        observer.send(value: converterResult)
                        observer.sendCompleted()
                    })

                    disposable.observeEnded {
                        context.value.isCancelled = true
                        context.value.videoProcessor?.cancel()
                        context.value.audioProcessor?.cancel()
                    }
                }
            })
        })
    }

    private class func process(context: Atomic<MediaVideoConversionContext>, observer: Signal<VideoConverter.ConverterResult, NSError>.Observer, completionBlock: @escaping () -> Void) {
        let contextValue: MediaVideoConversionContext = context.value
        if !(contextValue.assetReader?.startReading() ?? false) {
            observer.send(error: error)
            return
        }
        if !(contextValue.assetWriter?.startWriting() ?? false) {
            observer.send(error: error)
            return
        }
        contextValue.assetWriter?.startSession(atSourceTime: CMTime.zero)
        let dispatchGroup = DispatchGroup()

        if let audioProcessor = contextValue.audioProcessor, let timeRange = contextValue.timeRange {
            dispatchGroup.enter()
            audioProcessor.start(timeRange: timeRange, progressBlock: nil, completionBlock: { (successful) -> Void in
                dispatchGroup.leave()
            })
        }

        if let videoProcessor = contextValue.videoProcessor, let timeRange = contextValue.timeRange {
            dispatchGroup.enter()
            videoProcessor.start(timeRange: timeRange, progressBlock: { (_ progress: CGFloat) -> Void in
                observer.send(value: VideoConverter.ConverterResult(progress: progress))
            }, completionBlock: { (successful) -> Void in
                dispatchGroup.leave()
            })
        }

        dispatchGroup.notify(queue: contextValue.queue) {

            if contextValue.isCancelled {
                contextValue.assetReader?.cancelReading()
                contextValue.assetWriter?.cancelWriting()
            } else {
                var audioProcessorFailed = false
                if let processor = contextValue.audioProcessor {
                    audioProcessorFailed = !processor.succeed
                }
                if contextValue.assetReader?.status != .failed && (contextValue.videoProcessor?.succeed ?? false) && !audioProcessorFailed {
                    contextValue.assetWriter?.finishWriting(completionHandler: {
                        if contextValue.assetWriter?.status != .failed {
                            completionBlock()
                        } else {
                            observer.send(error: VideoConverter.error)
                        }
                    })
                } else {
                    observer.send(error: VideoConverter.error)
                }
            }
        }
    }

    private class func setupAssetReaderWriter(avAsset: AVAsset, outputURL: URL, preset: MediaVideoSettings.Present, adjustments: MediaVideoEditAdjustments, inhibitAudio: Bool, conversionContext: Atomic<MediaVideoConversionContext>) -> Bool {

        let audioTrack: AVAssetTrack? = avAsset.tracks(withMediaType: AVMediaType.audio).first
        guard let videoTrack: AVAssetTrack = avAsset.tracks(withMediaType: AVMediaType.video).first else {
            return false
        }

        var timeRange: CMTimeRange = videoTrack.timeRange
        if adjustments.trimApplied() {
            let duration: TimeInterval = CMTimeGetSeconds(videoTrack.timeRange.duration)
            if adjustments.trimEndValue < duration {
                timeRange = adjustments.trimTimeRange()
            } else {
                timeRange = CMTimeRangeMake(start: CMTimeMakeWithSeconds(adjustments.trimStartValue, preferredTimescale: Int32(Double(NSEC_PER_SEC))), duration: CMTimeMakeWithSeconds(duration - adjustments.trimStartValue, preferredTimescale: Int32(Double(NSEC_PER_SEC))))
            }
        }

        timeRange = CMTimeRangeMake(start: CMTimeAdd(timeRange.start, CMTimeMake(value: 10, timescale: 100)), duration: CMTimeSubtract(timeRange.duration, CMTimeMake(value: 10, timescale: 100)))

        let composition = AVMutableComposition()
        guard let (output, outputSettings, dimensions) = setupVideoCompositionOutput(avAsset: avAsset, composition: composition, videoTrack: videoTrack, preset: preset, adjustments: adjustments, timeRange: timeRange, conversionContext: conversionContext) else {
            return false
        }

        guard let assetReader = try? AVAssetReader(asset: composition) else {
            return false
        }
        guard let assetWriter = try? AVAssetWriter(url: outputURL, fileType: AVFileType.mp4) else {
            return false
        }
        assetReader.add(output)
        let input = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: outputSettings)
        if assetWriter.canAdd(input) {
            assetWriter.add(input)
        }

        let videoProcessor = MediaSampleBufferProcessor(assetReaderOutput: output, assetWriterInput: input)
        var audioProcessor: MediaSampleBufferProcessor?
        if !inhibitAudio && preset != .animation && audioTrack != nil {
            let trimAudioTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
            try? trimAudioTrack.insertTimeRange(timeRange, of: audioTrack!, at: CMTime.zero)
            // setup play rate
            if adjustments.playRate != .normal {
                let duration: CMTime = timeRange.duration
                trimAudioTrack.scaleTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: timeRange.duration), toDuration: CMTimeMultiplyByFloat64(duration, multiplier: Float64(1 / adjustments.playRate.rawValue)))
            }
            let output: AVAssetReaderOutput = AVAssetReaderTrackOutput(track: trimAudioTrack, outputSettings: [AVFormatIDKey: kAudioFormatLinearPCM])
            if assetReader.canAdd(output) {
                assetReader.add(output)
            }
            let input = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: MediaVideoSettings.audioSettings(preset: preset))
            if assetWriter.canAdd(input) {
                assetWriter.add(input)
            }
            audioProcessor = MediaSampleBufferProcessor(assetReaderOutput: output, assetWriterInput: input)
        }

        conversionContext.modify { (value: inout VideoConverter.MediaVideoConversionContext) -> Result<Bool, NoError> in
            value.assetReader = assetReader
            value.assetWriter = assetWriter
            value.videoProcessor = videoProcessor
            value.audioProcessor = audioProcessor
            value.dimensions = dimensions
            value.timeRange = timeRange
            return .success(true)
        }
        return true
    }

    private class func adjustCropRect(size: CGSize, adjustments: MediaVideoEditAdjustments) -> CGRect {
        var cropRect = adjustments.cropRect!
        if adjustments.originalCropRect == nil {
            return cropRect
        }
        let ratio: CGFloat = size.width / adjustments.originalCropRect!.width
        cropRect.origin.x = cropRect.origin.x * ratio
        cropRect.origin.y = cropRect.origin.y * ratio
        cropRect.size.width = cropRect.size.width * ratio
        cropRect.size.height = cropRect.size.height * ratio
        return cropRect
    }

    //
    /// http://www.mikitamanko.com/blog/2017/05/21/swift-how-to-insert-animated-watermark-into-the-video-or-how-to-merge-two-videos/
    ///
    /// - Parameters:
    ///   - avAsset: avAsset
    ///   - composition: composition
    ///   - videoTrack: videoTrack
    ///   - preset: preset
    ///   - adjustments: adjustments
    ///   - timeRange: timeRange
    ///   - conversionContext: conversionContext
    /// - Returns: return value
    private class func setupVideoCompositionOutput(avAsset: AVAsset, composition: AVMutableComposition, videoTrack: AVAssetTrack, preset: MediaVideoSettings.Present, adjustments: MediaVideoEditAdjustments, timeRange: CMTimeRange, conversionContext: Atomic<MediaVideoConversionContext>) -> (output: AVAssetReaderVideoCompositionOutput, outputSettings: [String: Any], dimensions: CGSize)? {

        // setup crop rect
        let transformedSize: CGSize = CGRect(origin: CGPoint.zero, size: videoTrack.naturalSize).applying(videoTrack.preferredTransform).size
        var transformedRect = CGRect(origin: CGPoint.zero, size: transformedSize)
        if transformedRect.size.equalTo(CGSize.zero) {
            transformedRect = CGRect(origin: CGPoint.zero, size: videoTrack.naturalSize)
        }
        let cropRect: CGRect = adjustments.cropRect != nil ? adjustCropRect(size: transformedSize, adjustments: adjustments).integral : transformedRect
        let maxDimensions: CGSize = MediaVideoSettings.maximumSize(preset: preset)
        var outputDimensions: CGSize = ImageUtils.fitSize(size: cropRect.size, maxSize: maxDimensions)
        outputDimensions = CGSize(width: CGFloat(ceil(outputDimensions.width)), height: CGFloat(ceil(outputDimensions.height)))
        outputDimensions = renderSize(cropSize: outputDimensions)
        if orientationIsSideward(orientation: adjustments.cropOrientation).sideward {
            outputDimensions = CGSize(width: CGFloat(outputDimensions.height), height: CGFloat(outputDimensions.width))
        }

        // setup video composition
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: Int32(videoTrack.nominalFrameRate))
        guard let trimVideoTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            return nil
        }
        try? trimVideoTrack.insertTimeRange(timeRange, of: videoTrack, at: CMTime.zero)
        if orientationIsSideward(orientation: adjustments.cropOrientation).sideward {
            videoComposition.renderSize = renderSize(cropSize: CGSize(width: cropRect.size.height, height: cropRect.size.width))
        } else {
            videoComposition.renderSize = renderSize(cropSize: cropRect.size)
        }

        // setup play rate
        if adjustments.playRate != .normal {
            let duration: CMTime = timeRange.duration
            trimVideoTrack.scaleTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: timeRange.duration), toDuration: CMTimeMultiplyByFloat64(duration, multiplier: Float64(1 / adjustments.playRate.rawValue)))
        }

        // setup transform
        let (videoOrientation, mirrored) = MediaVideoSettings.videoOrientation(asset: avAsset)
        let transform: CGAffineTransform = MediaVideoSettings.videoTransformForOrientation(videoOrientation, size: videoTrack.naturalSize, cropRect: cropRect, mirror: mirrored)
        var finalTransform: CGAffineTransform = transform
        if let cropOrientation = adjustments.cropOrientation {
            let rotationTransform: CGAffineTransform = MediaVideoSettings.videoTransformForCrop(orientation: cropOrientation, size: cropRect.size, mirrored: adjustments.mirrored)
            finalTransform = transform.concatenating(rotationTransform)
        }
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: trimVideoTrack)
        transformer.setTransform(finalTransform, at: CMTime.zero)
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: timeRange.duration)
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]

        // setup overlay image
        if let overlayImage = adjustments.overlayImage {
            let parentLayer = CALayer()
            parentLayer.frame = CGRect(origin: CGPoint.zero, size: videoComposition.renderSize)
            let videoLayer = CALayer()
            videoLayer.frame = parentLayer.frame
            parentLayer.addSublayer(videoLayer)
            var parentSize: CGSize = parentLayer.bounds.size
            if orientationIsSideward(orientation: adjustments.cropOrientation).sideward {
                parentSize = CGSize(width: CGFloat(parentSize.height), height: CGFloat(parentSize.width))
            }

            let size = CGSize(width: CGFloat(parentSize.width * transformedSize.width / cropRect.size.width), height: CGFloat(parentSize.height * transformedSize.height / cropRect.size.height))
            let origin = CGPoint(x: CGFloat(-parentSize.width / cropRect.size.width * cropRect.origin.x), y: CGFloat(-parentSize.height / cropRect.size.height * (transformedSize.height - cropRect.size.height - cropRect.origin.y)))
            let rotationLayer = CALayer()
            rotationLayer.frame = CGRect(origin: CGPoint.zero, size: parentSize)
            parentLayer.addSublayer(rotationLayer)

            if let cropOrientation = adjustments.cropOrientation {
                let orientation: UIImage.Orientation = mirrorSidewardOrientation(cropOrientation)
                var layerTransform: CATransform3D = CATransform3DMakeTranslation(rotationLayer.frame.size.width / 2.0, rotationLayer.frame.size.height / 2.0, 0.0)
                layerTransform = CATransform3DRotate(layerTransform, rotationForOrientation(orientation), 0.0, 0.0, 1.0)
                layerTransform = CATransform3DTranslate(layerTransform, -parentLayer.bounds.size.width / 2.0, -parentLayer.bounds.size.height / 2.0, 0.0)
                rotationLayer.transform = layerTransform
            }

            rotationLayer.frame = parentLayer.frame

            let overlayLayer = CALayer()
            overlayLayer.contents = overlayImage.cgImage
            overlayLayer.frame = CGRect(origin: origin, size: size)
            rotationLayer.addSublayer(overlayLayer)
            videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        }

        let output = AVAssetReaderVideoCompositionOutput(videoTracks: composition.tracks(withMediaType: AVMediaType.video), videoSettings: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange])
        output.videoComposition = videoComposition
        
        let outputSettings = MediaVideoSettings.videoSettings(preset: preset, dimensions: outputDimensions)

        return (output, outputSettings, outputDimensions)
    }

    private class func renderSize(cropSize: CGSize) -> CGSize {
        let blockSize: CGFloat = 16.0
        let renderWidth: CGFloat = (cropSize.width / blockSize).rounded(.down) * blockSize
        var renderHeight: CGFloat = (cropSize.height * renderWidth / cropSize.width).rounded(.down)
        if fmod(renderHeight, blockSize) != 0 {
            renderHeight = (cropSize.height / blockSize).rounded(.down) * blockSize
        }
        return CGSize(width: renderWidth, height: renderHeight)
    }

    private func bestAvailablePreset(dimensions: CGSize) -> MediaVideoSettings.Present {
        var preset: MediaVideoSettings.Present = .veryHigh
        let maxSide: CGFloat = max(dimensions.width, dimensions.height)
        var i = MediaVideoSettings.Present.veryHigh.rawValue
        while i >= MediaVideoSettings.Present.medium.rawValue {
            let presetMaxSide: CGFloat = MediaVideoSettings.maximumSize(preset: MediaVideoSettings.Present(rawValue: i)!).width
            if maxSide >= presetMaxSide {
                break
            }
            preset = MediaVideoSettings.Present(rawValue: i)!
            i -= 1
        }
        return preset
    }
}
