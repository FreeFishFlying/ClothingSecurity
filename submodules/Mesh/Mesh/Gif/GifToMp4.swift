//
//  GIF2MP4.swift
//  Components
//
//  Created by kingxt on 7/26/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import UIKit
import Foundation
import AVFoundation

private let GifConverterFPS: Int32 = 600

class GIF2MP4 {
    
    private(set) var gif: GIF
    private var outputURL: URL!
    private(set) var videoWriter: AVAssetWriter!
    private(set) var videoWriterInput: AVAssetWriterInput!
    private(set) var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor!
    var videoSize : CGSize {
        //The size of the video must be a multiple of 16
        return CGSize(width: floor(gif.size.width / 16) * 16, height: floor(gif.size.height / 16) * 16)
    }
    
    init?(data : Data) {
        guard let gif = GIF(data: data) else { return nil }
        self.gif = gif
    }
    
    private func prepare() -> Bool {
        
        try? FileManager.default.removeItem(at: outputURL)
        let videoSize = self.videoSize
        if videoSize.width < 16 || videoSize.height < 16 {
            return false
        }
        let avOutputSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecH264,
            AVVideoWidthKey: NSNumber(value: Float(videoSize.width)),
            AVVideoHeightKey: NSNumber(value: Float(videoSize.height))
        ]
        
        let sourcePixelBufferAttributesDictionary = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32ARGB),
            kCVPixelBufferWidthKey as String: NSNumber(value: Float(videoSize.width)),
            kCVPixelBufferHeightKey as String: NSNumber(value: Float(videoSize.height)),
            kCVPixelBufferCGImageCompatibilityKey as String: NSNumber(value: true),
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: NSNumber(value: true)
        ]
        
        guard let videoWriter = try? AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mp4) else {
            return false
        }
        self.videoWriter = videoWriter
        videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: avOutputSettings)
        if !videoWriter.canAdd(videoWriterInput) {
            return false
        }
        videoWriter.add(videoWriterInput)
        
        pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
        videoWriter.startWriting()
        videoWriter.startSession(atSourceTime: CMTimeMakeWithSeconds(0, preferredTimescale: GifConverterFPS))
        return true
    }
    
    func convertAndExport(to url :URL, completion: @escaping (Bool) -> Void ) {
        outputURL = url
        if !prepare() {
            completion(false)
            return
        }
        
        var index = 0
        var delay = 0.0 - gif.frameDurations[0]
        let queue = DispatchQueue(label: "mediaInputQueue")
        videoWriterInput.requestMediaDataWhenReady(on: queue) {
            var isFinished = true
            
            while index < self.gif.frames.count {
                if self.videoWriterInput.isReadyForMoreMediaData == false {
                    isFinished = false
                    break
                }
                
                if let cgImage = self.gif.getFrame(at: index) {
                    let frameDuration = self.gif.frameDurations[index]
                    delay += Double(frameDuration)
                    let presentationTime = CMTime(seconds: delay, preferredTimescale: GifConverterFPS)
                    _ = self.addImage(image: UIImage(cgImage: cgImage), withPresentationTime: presentationTime)
                    index += 1
                }
            }
            
            if isFinished {
                self.videoWriterInput.markAsFinished()
                self.videoWriter.finishWriting() {
                    completion(true)
                }
            }
        }
    }
    
    func addImage(image: UIImage, withPresentationTime presentationTime: CMTime) -> Bool {
        guard let pixelBufferPool = pixelBufferAdaptor.pixelBufferPool else {
            return false
        }
        if let pixelBuffer = pixelBufferFromImage(image: image, pixelBufferPool: pixelBufferPool, size: videoSize) {
            return pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
        } else {
            return false
        }
    }
    
    func pixelBufferFromImage(image: UIImage, pixelBufferPool: CVPixelBufferPool, size: CGSize) -> CVPixelBuffer? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        var pixelBufferOut: CVPixelBuffer?
        let status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, &pixelBufferOut)
        if status != kCVReturnSuccess {
            return nil
        }
        let pixelBuffer = pixelBufferOut!
        
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        
        let data = CVPixelBufferGetBaseAddress(pixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: data, width: Int(size.width), height: Int(size.height),
                                bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        context!.clear(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let horizontalRatio = size.width / image.size.width
        let verticalRatio = size.height / image.size.height
        let aspectRatio = max(horizontalRatio, verticalRatio)
        
        let newSize = CGSize(width: image.size.width * aspectRatio, height: image.size.height * aspectRatio)
        
        let x = newSize.width < size.width ? (size.width - newSize.width) / 2 : -(newSize.width-size.width)/2
        let y = newSize.height < size.height ? (size.height - newSize.height) / 2 : -(newSize.height-size.height)/2
        
        context!.draw(cgImage, in: CGRect(x:x, y:y, width:newSize.width, height:newSize.height))
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        
        return pixelBuffer
    }
}


import ImageIO
import MobileCoreServices

class GIF {
    
    private let frameDelayThreshold = 0.02
    private(set) var duration = 0.0
    private(set) var imageSource: CGImageSource!
    private(set) var frames: [CGImage?]!
    private(set) lazy var frameDurations = [TimeInterval]()
    var size : CGSize {
        guard let f = frames.first, let cgImage = f else { return .zero }
        return CGSize(width: cgImage.width, height: cgImage.height)
    }
    private lazy var getFrameQueue: DispatchQueue = DispatchQueue(label: "gif.frame.queue", qos: .userInteractive)
    
    
    init?(data: Data) {
        guard let imgSource = CGImageSourceCreateWithData(data as CFData, nil), let imgType = CGImageSourceGetType(imgSource) , UTTypeConformsTo(imgType, kUTTypeGIF) else {
            return nil
        }
        self.imageSource = imgSource
        let imgCount = CGImageSourceGetCount(imageSource)
        frames = [CGImage?](repeating: nil, count: imgCount)
        for i in 0..<imgCount {
            let delay = getGIFFrameDuration(imgSource: imageSource, index: i)
            frameDurations.append(delay)
            duration += delay
            getFrameQueue.async {
                self.frames[i] = CGImageSourceCreateImageAtIndex(self.imageSource, i, nil)
            }
        }
    }
    
    func getFrame(at index: Int) -> CGImage? {
        if index >= CGImageSourceGetCount(imageSource) {
            return nil
        }
        if let frame = frames[index] {
            return frame
        } else {
            let frame = CGImageSourceCreateImageAtIndex(imageSource, index, nil)
            frames[index] = frame
            return frame
        }
    }
    
    private func getGIFFrameDuration(imgSource: CGImageSource, index: Int) -> TimeInterval {
        guard let frameProperties = CGImageSourceCopyPropertiesAtIndex(imgSource, index, nil) as Dictionary?,
            let gifProperties = frameProperties[kCGImagePropertyGIFDictionary] as? [String: Double],
            let unclampedDelay = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String]
            else { return 0.02 }
        
        var frameDuration = TimeInterval(0)
        
        if unclampedDelay < 0 {
            frameDuration = gifProperties[kCGImagePropertyGIFDelayTime as String] ?? 0.0
        } else {
            frameDuration = unclampedDelay
        }
        
        /* Implement as Browsers do: Supports frame delays as low as 0.02 s, with anything below that being rounded up to 0.10 s.
         http://nullsleep.tumblr.com/post/16524517190/animated-gif-minimum-frame-delay-browser-compatibility */
        
        if (frameDuration < frameDelayThreshold - Double.ulpOfOne) {
            frameDuration = 0.1;
        }
        
        return frameDuration
    }
}
