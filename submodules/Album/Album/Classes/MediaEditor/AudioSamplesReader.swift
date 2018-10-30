//
//  AudioSamplesReader.swift
//  Components-Swift
//
//  Created by kingxt on 5/24/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import AVFoundation
import ReactiveSwift
import Result
import Accelerate

private let noiseFloor: Float = -50

public class AudioSamplesReader {

    public func readSamples(file: URL, targetSampleCount: Int) -> SignalProducer<[CGFloat], NoError> {

        return SignalProducer<[CGFloat], NoError>.init({ (observer: Signal<[CGFloat], NoError>.Observer, disposable) in
            DispatchQueue.global().sync {
                let asset = AVURLAsset(url: file, options: [AVURLAssetPreferPreciseDurationAndTimingKey: NSNumber(value: true as Bool)])
                guard let audioTrack: AVAssetTrack = asset.tracks(withMediaType: AVMediaType.audio).first else {
                    return observer.sendInterrupted()
                }
                asset.loadValuesAsynchronously(forKeys: ["duration"]) {
                    var error: NSError?
                    let status = asset.statusOfValue(forKey: "duration", error: &error)
                    switch status {
                    case .loaded:
                        guard
                            let formatDescriptions = audioTrack.formatDescriptions as? [CMAudioFormatDescription],
                            let audioFormatDesc = formatDescriptions.first,
                            let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(audioFormatDesc)
                        else { break }

                        let totalSamples = Int((asbd.pointee.mSampleRate) * Float64(asset.duration.value) / Float64(asset.duration.timescale))
                        self.loadSamples(asset: asset, audioTrack: audioTrack, targetSampleCount: targetSampleCount, totalSamplesCount: totalSamples, observer: observer, disposable: disposable)
                        return

                    case .failed, .cancelled, .loading, .unknown:
                        observer.sendInterrupted()
                    }
                }
            }
        })
    }

    private func loadSamples(asset: AVAsset, audioTrack: AVAssetTrack, targetSampleCount: Int, totalSamplesCount: Int, observer: Signal<[CGFloat], NoError>.Observer, disposable: Lifetime) {
        guard let assetReader = try? AVAssetReader(asset: asset) else {
            return observer.sendInterrupted()
        }

        let outputSettingsDict: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsNonInterleaved: false,
        ]
        let output: AVAssetReaderOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: outputSettingsDict)
        output.alwaysCopiesSampleData = false
        assetReader.add(output)

        var channelCount = 1
        let formatDescriptions = audioTrack.formatDescriptions as! [CMAudioFormatDescription]
        for item in formatDescriptions {
            guard let fmtDesc = CMAudioFormatDescriptionGetStreamBasicDescription(item) else {
                return observer.sendInterrupted()
            }
            channelCount = Int(fmtDesc.pointee.mChannelsPerFrame)
        }

        let samplesPerPixel = max(1, channelCount * totalSamplesCount / targetSampleCount)
        let filter = [Float](repeating: 1.0 / Float(samplesPerPixel), count: samplesPerPixel)

        if !(assetReader.startReading()) {
            observer.sendInterrupted()
            return
        }
        defer { assetReader.cancelReading() }

        var sampleBuffer = Data()
        var outputSamples = [CGFloat]()
        var isCancelled = false

        while assetReader.status == .reading {
            if isCancelled {
                return observer.sendInterrupted()
            }
            guard let readSampleBuffer: CMSampleBuffer = output.copyNextSampleBuffer(),
                let readBuffer: CMBlockBuffer = CMSampleBufferGetDataBuffer(readSampleBuffer) else {
                break
            }

            var readBufferLength = 0
            var readBufferPointer: UnsafeMutablePointer<Int8>?
            CMBlockBufferGetDataPointer(readBuffer, atOffset: 0, lengthAtOffsetOut: &readBufferLength, totalLengthOut: nil, dataPointerOut: &readBufferPointer)
            sampleBuffer.append(UnsafeBufferPointer(start: readBufferPointer, count: readBufferLength))
            CMSampleBufferInvalidate(readSampleBuffer)

            let totalSamples = sampleBuffer.count / MemoryLayout<Int16>.size
            let downSampledLength = totalSamples / samplesPerPixel
            let samplesToProcess = downSampledLength * samplesPerPixel

            guard samplesToProcess > 0 else { continue }

            processSamples(fromData: &sampleBuffer,
                           outputSamples: &outputSamples,
                           samplesToProcess: samplesToProcess,
                           downSampledLength: downSampledLength,
                           samplesPerPixel: samplesPerPixel,
                           filter: filter)
        }

        // Process the remaining samples at the end which didn't fit into samplesPerPixel
        let samplesToProcess = sampleBuffer.count / MemoryLayout<Int16>.size
        if samplesToProcess > 0 {
            guard !isCancelled else { return observer.sendInterrupted() }

            let downSampledLength = 1
            let samplesPerPixel = samplesToProcess
            let filter = [Float](repeating: 1.0 / Float(samplesPerPixel), count: samplesPerPixel)

            processSamples(fromData: &sampleBuffer,
                           outputSamples: &outputSamples,
                           samplesToProcess: samplesToProcess,
                           downSampledLength: downSampledLength,
                           samplesPerPixel: samplesPerPixel,
                           filter: filter)
        }
        observer.send(value: outputSamples)
        disposable.observeEnded {
            isCancelled = true
        }
    }

    private func processSamples(fromData sampleBuffer: inout Data, outputSamples: inout [CGFloat], samplesToProcess: Int, downSampledLength: Int, samplesPerPixel: Int, filter: [Float]) {
        sampleBuffer.withUnsafeBytes { (samples: UnsafePointer<Int16>) in
            var processingBuffer = [Float](repeating: 0.0, count: samplesToProcess)

            let sampleCount = vDSP_Length(samplesToProcess)

            // Convert 16bit int samples to floats
            vDSP_vflt16(samples, 1, &processingBuffer, 1, sampleCount)

            // Take the absolute values to get amplitude
            vDSP_vabs(processingBuffer, 1, &processingBuffer, 1, sampleCount)

            self.process(normalizedSamples: &processingBuffer)

            // Downsample and average
            var downSampledData = [Float](repeating: 0.0, count: downSampledLength)
            vDSP_desamp(processingBuffer,
                        vDSP_Stride(samplesPerPixel),
                        filter, &downSampledData,
                        vDSP_Length(downSampledLength),
                        vDSP_Length(samplesPerPixel))

            let downSampledDataCG = downSampledData.map { (value: Float) -> CGFloat in
                let element = CGFloat(value)
                return element
            }

            // Remove processed samples
            sampleBuffer.removeFirst(samplesToProcess * MemoryLayout<Int16>.size)
            print(downSampledDataCG)
            outputSamples += downSampledDataCG
        }
    }

    private func process(normalizedSamples: inout [Float]) {
        var zero: Float = 32768.0
        vDSP_vdbcon(normalizedSamples, 1, &zero, &normalizedSamples, 1, vDSP_Length(normalizedSamples.count), 1)

        // Clip to [noiseFloor, 0]
        var ceil: Float = 0.0
        var noiseFloorFloat = Float(noiseFloor)
        vDSP_vclip(normalizedSamples, 1, &noiseFloorFloat, &ceil, &normalizedSamples, 1, vDSP_Length(normalizedSamples.count))
    }
}
