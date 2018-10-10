//
//  AcceleratedVideoView.swift
//  Components
//
//  Created by kingxt on 2017/7/26.
//  Copyright © 2017年 liao. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import ObjcExceptionBridging

class AcceleratedVideoFrame {
    
    let buffer: CVImageBuffer
    let timestamp: CMTime
    let angle: CGFloat
    let formatDescription: CMFormatDescription
    var sampleBuffer: CMSampleBuffer?

    init(buffer: CVImageBuffer, timestamp: CMTime, angle: CGFloat, formatDescription: CMFormatDescription) {
        self.buffer = buffer
        self.timestamp = timestamp
        self.angle = angle
        self.formatDescription = formatDescription
    }
    
    func prepareSampleBuffer() -> Bool {
        var timingInfo: CMSampleTimingInfo = CMSampleTimingInfo(duration: CMTime.invalid, presentationTimeStamp: self.timestamp, decodeTimeStamp: CMTime.invalid)
        let status = CMSampleBufferCreateForImageBuffer(allocator: nil, imageBuffer: self.buffer, dataReady: true, makeDataReadyCallback: nil, refcon: nil, formatDescription: self.formatDescription, sampleTiming: &timingInfo, sampleBufferOut: &sampleBuffer)
        return status == noErr
    }
}

class AcceleratedVideoFrameQueueItem {
    let queue: AcceleratedVideoFrameQueue
    var guards: [AcceleratedVideoFrameQueueGuardItem] = [AcceleratedVideoFrameQueueGuardItem]()
    
    init(queue: AcceleratedVideoFrameQueue) {
        self.queue = queue
    }
}

class AcceleratedVideoFrameQueueGuardItem {
    weak var `guard` : AcceleratedVideoFrameQueueGuard?
    let key: String
    
    init(key: String) {
        self.key = key
    }
}

class AcceleratedVideoFrameQueueGuard {
    static let controlQueue = DispatchQueue(label: "acceleratedvideoguard")
    static var queueItemsByPath: [String : AcceleratedVideoFrameQueueItem] = [:]

    
    let key: String = UUID().uuidString
    let drawCallback: (AcceleratedVideoFrame) -> Void
    let path: String
    
    init(path: String, draw: @escaping (AcceleratedVideoFrame) -> Void) {
        self.drawCallback = draw
        self.path = path
    }
    
    class func addGuard(path: String, guard queueGuard: AcceleratedVideoFrameQueueGuard) {
        if nil == AcceleratedVideoFrameQueueGuard.queueItemsByPath[path] {
            let item = AcceleratedVideoFrameQueueItem(queue: AcceleratedVideoFrameQueue(path: path, frameReady: { (frame) in
                AcceleratedVideoFrameQueueGuard.controlQueue.async {
                    if let value = AcceleratedVideoFrameQueueGuard.queueItemsByPath[path] {
                        for guardItem in value.guards {
                            guardItem.guard?.draw(frame: frame)
                        }
                    }
                }
            }))
            AcceleratedVideoFrameQueueGuard.queueItemsByPath[path] = item
            item.queue.beginRequests()
            let guardItem = AcceleratedVideoFrameQueueGuardItem(key: queueGuard.key)
            guardItem.guard = queueGuard
            item.guards.append(guardItem)
        } else {
            let guardItem = AcceleratedVideoFrameQueueGuardItem(key: queueGuard.key)
            guardItem.guard = queueGuard
            AcceleratedVideoFrameQueueGuard.queueItemsByPath[path]?.guards.append(guardItem)
        }
    }
    
    class func removeGuard(path: String, key: String) {
        AcceleratedVideoFrameQueueGuard.controlQueue.async {
            guard let item = AcceleratedVideoFrameQueueGuard.queueItemsByPath[path] else {
                return
            }
            var guards: [AcceleratedVideoFrameQueueGuardItem] = [AcceleratedVideoFrameQueueGuardItem]()
            for guardItem in item.guards {
                if guardItem.key != key && guardItem.guard != nil {
                    guards.append(guardItem)
                }
            }
            item.guards = guards
            if guards.count == 0 {
                queueItemsByPath.removeValue(forKey: path)
                item.queue.pauseRequest()
            }
        }
    }
    
    func draw(frame: AcceleratedVideoFrame) {
        drawCallback(frame)
    }
    
    deinit {
        AcceleratedVideoFrameQueueGuard.removeGuard(path: path, key: key)
    }
}

class AcceleratedVideoFrameQueue {
    
    private let path: String
    private let frameReady: (AcceleratedVideoFrame) -> Void
    private let fillFrames = 1
    private let maxFrames = 2
    
    public var angle: CGFloat = 0
    private var epoch: Int64 = 0
    private var reader: AVAssetReader?
    private var output: AVAssetReaderTrackOutput?
    private var failed: Bool = false
    private var timeRange: CMTimeRange?
    private var previousFrameTimestamp: CMTime = CMTime.zero
    private var formatDescription: CMFormatDescription?
    
    static let queue = DispatchQueue(label: "acceleratedvideoqueue")
    
    public private(set) var pendingFrames: [AcceleratedVideoFrame] = [AcceleratedVideoFrame]()
    public private(set) var frames: [AcceleratedVideoFrame] = [AcceleratedVideoFrame]()
    
    private var timer: DispatchTimer?
    
    init(path: String, frameReady: @escaping (AcceleratedVideoFrame) -> Void) {
        self.path = path
        self.frameReady = frameReady
    }
    
    func beginRequests() {
        AcceleratedVideoFrameQueue.queue.async {
            self.timer?.stop()
            self.timer = nil
            self.checkQueue()
        }
    }
    
    func pauseRequest() {
        AcceleratedVideoFrameQueue.queue.async {
            self.timer?.stop()
            self.timer = nil
            self.previousFrameTimestamp = CMTime.zero
            self.frames.removeAll()
            self.reader?.cancelReading()
            self.output = nil
            self.reader = nil
        }
    }
    
    func checkQueue() {
        var nextDelay: TimeInterval = 0.0
        if frames.count != 0 {
            nextDelay = 1.0
            let firstFrame: AcceleratedVideoFrame = frames[0]
            frames.remove(at: 0)
            var comparison = CMTimeCompare(firstFrame.timestamp, previousFrameTimestamp)
            if comparison <= 0 {
                nextDelay = 0.05
            } else {
                nextDelay = min(5.0, CMTimeGetSeconds(firstFrame.timestamp) - CMTimeGetSeconds(previousFrameTimestamp))
            }
            previousFrameTimestamp = firstFrame.timestamp
            comparison = CMTimeCompare(firstFrame.timestamp, CMTimeMakeWithSeconds(Double.ulpOfOne, preferredTimescale: 1000))
            if comparison <= 0 {
                nextDelay = 0.0
            }
            frameReady(firstFrame)
        }
        
        if frames.count <= fillFrames {
            while frames.count < maxFrames {
                guard let frame: AcceleratedVideoFrame = requestFrame() else {
                    if failed {
                        nextDelay = 1.0
                    } else {
                        nextDelay = 0.0
                    }
                    break
                }
                frames.append(frame)
            }
        }
        timer = DispatchTimer(timeout: .milliseconds(Int(nextDelay * 1000)), isRepeat: false, queue: AcceleratedVideoFrameQueue.queue)
        timer?.start { [weak self] in
            self?.checkQueue()
        }
    }
    
    func requestFrame() -> AcceleratedVideoFrame? {
        for _ in 0 ..< 3 {
            if self.reader == nil {
                let asset = AVURLAsset(url: URL(fileURLWithPath: path), options: nil)
                guard let track: AVAssetTrack = asset.tracks(withMediaType: AVMediaType.video).first else {
                    return nil
                }
                timeRange = track.timeRange
                let transform: CGAffineTransform = track.preferredTransform
                angle = atan2(transform.b, transform.a)
                var tractOutput: AVAssetReaderTrackOutput?
                _try_objc({
                    tractOutput = AVAssetReaderTrackOutput(track: track, outputSettings: [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange])
                }, { (_) in
                }, {
                })
                guard let output = tractOutput else {
                    return nil
                }
                output.alwaysCopiesSampleData = false;
                guard let reader = try? AVAssetReader(asset: asset) else {
                    return nil
                }
                self.reader = reader
                if reader.canAdd(output) {
                    reader.add(output)
                    if !reader.startReading() {
                        print("Failed to begin reading video frames")
                        self.reader = nil
                        self.output = nil
                        failed = true
                        return nil
                    }
                } else {
                    print("Failed to add output")
                    self.reader = nil
                    self.output = nil
                    failed = true
                    return nil
                }
                self.output = output
            }
            
            guard let reader = self.reader else {
                return nil
            }
            guard let output = self.output else {
                return nil
            }
        
            if reader.status == .reading {
                guard let sampleVideo = output.copyNextSampleBuffer() else {
                    return nil
                }
                var videoFrame: AcceleratedVideoFrame? = nil
                var presentationTime: CMTime = CMSampleBufferGetPresentationTimeStamp(sampleVideo)
                presentationTime.epoch = epoch
                guard let imageBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleVideo) else {
                    return nil
                }
                if formatDescription == nil || !CMVideoFormatDescriptionMatchesImageBuffer(formatDescription!, imageBuffer: imageBuffer) {
                    var error: OSStatus = noErr
                    var formatDescription: CMVideoFormatDescription? = nil
                    error = CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil, imageBuffer: imageBuffer, formatDescriptionOut: &formatDescription)
                    if error == noErr {
                        self.formatDescription = formatDescription
                    } else {
                        print("CMVideoFormatDescriptionCreateForImageBuffer error")
                    }
                }
                if let formatDescription = self.formatDescription {
                    videoFrame = AcceleratedVideoFrame(buffer: imageBuffer, timestamp: presentationTime, angle: angle, formatDescription: formatDescription)
                    return videoFrame
                }
            } else {
                var earliestFrame: AcceleratedVideoFrame? = nil
                var earliestFrameIndex = -1
                for (index, frame) in pendingFrames.enumerated() {
                    if earliestFrame == nil || CMTimeCompare(earliestFrame!.timestamp, frame.timestamp) == 1 {
                        earliestFrame = frame
                        earliestFrameIndex = index
                    }
                }
                if earliestFrameIndex > 0 {
                    pendingFrames.remove(at: earliestFrameIndex)
                }
                if earliestFrame != nil {
                    return earliestFrame
                } else {
                    epoch += 1
                    reader.cancelReading()
                    self.reader = nil
                    self.output = nil
                }
            }
        }
        return nil
    }
}

class AcceleratedVideoView: UIView {
    
    private var displayLayer: AVSampleBufferDisplayLayer
    private var pendingFrames: [AcceleratedVideoFrame] = [AcceleratedVideoFrame]()
    private var frameQueueGuard: AcceleratedVideoFrameQueueGuard?
    private var inBackground = false
    private var previousEpoch: CMTimeEpoch = 0
    private var angle: CGFloat = 0
    override init(frame: CGRect) {
        displayLayer = AVSampleBufferDisplayLayer()
        
        super.init(frame: frame)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActiveNotification), name: UIApplication.didEnterBackgroundNotification , object: nil)
        
        displayLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        layer.addSublayer(displayLayer)
    }
    
    override var contentMode: UIView.ContentMode {
        didSet {
            if contentMode == .scaleAspectFit {
                displayLayer.videoGravity = AVLayerVideoGravity.resizeAspect
            } else {
                displayLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        displayLayer.frame = bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func applicationDidBecomeActiveNotification() {
        inBackground = false
    }
    
    @objc func applicationWillResignActiveNotification() {
        inBackground = true
    }
    
    public func prepareForRecycle() {
        DispatchQueue.main.safeAsync {
            self.displayLayer.flushAndRemoveImage()
            self.previousEpoch = 0
            self.frameQueueGuard = nil
        }
    }
    
    func displayFrame(frame: AcceleratedVideoFrame) {
        if !inBackground {
            if displayLayer.status == .failed {
                displayLayer.flushAndRemoveImage()
            }
            if previousEpoch != frame.timestamp.epoch {
                previousEpoch = frame.timestamp.epoch
                displayLayer.flush()
            }
            if displayLayer.isReadyForMoreMediaData {
                if let sampleBuffer = frame.sampleBuffer {
                    displayLayer.enqueue(sampleBuffer)
                }
            }
            if angle != frame.angle {
                angle = frame.angle
                transform = CGAffineTransform(rotationAngle: frame.angle)
            }
        }
    }
    
    public var path: String? = nil {
        willSet {
            if newValue == path {
                return
            }
            prepareForRecycle()
            guard let path = newValue else {
                return
            }
            AcceleratedVideoFrameQueueGuard.controlQueue.async {
                var realPath = path
                if FileManager.default.fileExists(atPath: path) {
                    realPath = (path as NSString).appendingPathExtension("mov")!
                    if !FileManager.default.fileExists(atPath: realPath) {
                        try? FileManager.default.removeItem(atPath: realPath)
                        try? FileManager.default.createSymbolicLink(atPath: realPath, withDestinationPath: (path as NSString).pathComponents.last!)
                    }
                }
                if !FileManager.default.fileExists(atPath: realPath) {
                    return
                }
                let frameQueueGuard = AcceleratedVideoFrameQueueGuard(path: realPath, draw: { [weak self] (frame) in
                    if let strongSelf = self {
                        if frame.prepareSampleBuffer() {
                            DispatchQueue.main.safeAsync {
                                strongSelf.displayFrame(frame: frame)
                            }
                        }
                    }
                })
                self.frameQueueGuard = frameQueueGuard
                AcceleratedVideoFrameQueueGuard.controlQueue.async {
                    AcceleratedVideoFrameQueueGuard.addGuard(path: realPath, guard: frameQueueGuard)
                }
            }
        }
    }
}
