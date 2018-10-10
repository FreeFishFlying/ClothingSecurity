//
//  MeshUploadManager.swift
//  Mesh
//
//  Created by kingxt on 6/22/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

public class MeshUploaderManager {
    
    public static let `default` = MeshUploaderManager()
    
    public let barrierQueue = DispatchQueue(label: "com.liao.MeshUploaderManager.Barrier", attributes: .concurrent)
    
    private var uploaderPresent: [String : MeshUploader] = [:]
    
    private var watchObservers: [(String, Signal<FileUploadChange, UploadError>.Observer)] = []
    
    private var currentUploadCount = 0
    
    public var maxConcurrentUploadCount = 3
    
    private var priorityIncrement: Float = 0.5
    
    public func upload(fileURL: URL, sessionId: String, mediaType: MeshUploadType, options: MeshUploaderOptionsInfo = MeshUpLoaderEmptyOptionsInfo) {
        var options = options;
        if options.lastMatchIgnoringAssociatedValue(.uploadPriority(0)) == nil {
            decrementPriority()
            options.append(.uploadPriority(priorityIncrement))
        }
        barrierQueue.sync(flags: .barrier) {
            if uploaderPresent[sessionId] != nil {
                return
            }
            let uploader = MeshUploader(fileURL: fileURL, sessionId: sessionId, mediaType: mediaType, options: options)
            uploaderPresent[sessionId] = uploader
        }
        uploadNext()
    }
    
    public func upload(phAssetLocalIdentifier: String, sessionId: String, mediaType: MeshUploadType, options: MeshUploaderOptionsInfo = MeshUpLoaderEmptyOptionsInfo) {
        var options = options;
        if options.lastMatchIgnoringAssociatedValue(.uploadPriority(0)) == nil {
            decrementPriority()
            options.append(.uploadPriority(priorityIncrement))
        }
        barrierQueue.sync(flags: .barrier) {
            let uploader = MeshUploader(phAssetLocalIdentifier: phAssetLocalIdentifier, sessionId: sessionId, mediaType: mediaType, options: options)
            if uploaderPresent[sessionId] != nil {
                return
            }
            uploaderPresent[sessionId] = uploader
        }
        uploadNext()
    }
    
    private func decrementPriority() {
        priorityIncrement -= 0.000001
    }
    
    public func watch(sessionId: String) -> SignalProducer<FileUploadChange, UploadError> {
        return SignalProducer<FileUploadChange, UploadError>{ (observer, lifetime) in
            var uploader: MeshUploader? = nil
            self.barrierQueue.sync(flags: .barrier) {
                uploader = self.uploaderPresent[sessionId]
            }
            if uploader != nil {
                observer.send(value: uploader!.currentUploadChange)
                uploader?.watchDog().observe(observer)
            } else {
                self.addObserver(sessionId: sessionId, observer: observer)
            }
            lifetime.observeEnded {
                self.removeObserver(observer: observer)
            }
        }
    }
    
    public func cancelUpload(sessionId: String) {
        barrierQueue.sync(flags: .barrier) {
            uploaderPresent.removeValue(forKey: sessionId)?.cancel()
        }
        removeObservers(sessionId: sessionId)
    }
    
    private func uploadNext() {
        if currentUploadCount < maxConcurrentUploadCount {
            if let uploader = highestPendingUploader() {
                let sessionId = uploader.sessionId
                uploader.watchDog().observe({ (event) in
                    switch event {
                    case .completed, .interrupted, .failed(_):
                        _ = self.barrierQueue.sync(flags: .barrier) {
                            self.uploaderPresent.removeValue(forKey: sessionId)
                        }
                        self.removeObservers(sessionId: sessionId)
                        self.currentUploadCount -= 1
                        self.uploadNext()
                    default: break
                    }
                })
                for observer in sessionIdObervers(sessionId: sessionId) {
                    uploader.watchDog().observe(observer)
                }
                uploader.resume()
                currentUploadCount += 1
            }
        }
    }
    
    private func addObserver(sessionId: String, observer: Signal<FileUploadChange, UploadError>.Observer) {
        barrierQueue.sync(flags: .barrier) {
            self.watchObservers.append((sessionId, observer))
        }
    }
    
    private func removeObserver(observer: Signal<FileUploadChange, UploadError>.Observer) {
        barrierQueue.sync(flags: .barrier) {
            var result: [(String, Signal<FileUploadChange, UploadError>.Observer)] = []
            for (id, item) in watchObservers {
                if observer !== item {
                    result.append((id, item))
                }
            }
            self.watchObservers = result
        }
    }
    
    private func removeObservers(sessionId: String) {
        barrierQueue.sync(flags: .barrier) {
            var result: [(String, Signal<FileUploadChange, UploadError>.Observer)] = []
            for (id, observer) in watchObservers {
                if sessionId != id {
                    result.append((id, observer))
                }
            }
            self.watchObservers = result
        }
    }
    
    private func sessionIdObervers(sessionId: String) -> [Signal<FileUploadChange, UploadError>.Observer] {
        var result: [Signal<FileUploadChange, UploadError>.Observer] = []
        barrierQueue.sync(flags: .barrier) {
            for (id, observer) in watchObservers {
                if sessionId == id {
                    result.append(observer)
                }
            }
        }
        return result
    }
    
    private func highestPendingUploader() -> MeshUploader? {
        var result: MeshUploader? = nil
        barrierQueue.sync(flags: .barrier) {
            let pendingUploaders = uploaderPresent.values.filter { $0.status == .pending }
            result = pendingUploaders.sorted{ $0.options.uploadPriority > $1.options.uploadPriority }.first
        }
        return result
    }
}
