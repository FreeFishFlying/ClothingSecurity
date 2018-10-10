//
//  FileDownloader.swift
//  Mesh
//
//  Created by kingxt on 2017/6/17.
//  Copyright © 2017年 liao. All rights reserved.
//

import Foundation
import ReactiveSwift

public typealias FileDownloadChange = (url: URL, percent: Double?, destination: URL?, completed: Bool)

public class FileDownloader {
    
    public static let `default` = FileDownloader()
    
    public let barrierQueue = DispatchQueue(label: "com.liao.FileDownloadChange.Barrier", attributes: .concurrent)
    
    private let downloader = MeshDownloader(name: "FileDownloader")
    
    private var downloadChangePresent: [URL : FileDownloadChange] = [:]
    private var downloadTaskPresent: [URL : MeshDownloadTask] = [:]
    
    
    /// Download a url to destination
    ///
    /// - Parameters:
    ///   - url: a url to download
    ///   - destination: url download to distination
    ///   - options: download options
    ///   - progressBlock: download percent
    ///   - completionHandler: completion callback
    /// - Returns: download task
    @discardableResult
    public func download(with url: URL,
                         destination: URL,
                            options: MeshLoaderOptionsInfo? = nil,
                            progressBlock: MeshDownloaderProgressBlock? = nil,
                            completionHandler: MeshDownloaderCompletionHandler? = nil) -> MeshDownloadTask? {
        var existTask: MeshDownloadTask? = nil
        barrierQueue.sync(flags: .barrier) {
            existTask = downloadTaskPresent[url]
        }
        if existTask != nil {
            return existTask
        }
        
        self.watcher.input.send(value: (url: url, percent: 0.01, destination: nil, completed: false))
        let task = downloader.requestUrl(with: url, destination: destination, options: options, progressBlock: { (receivedSize: Int64,  totalSize: Int64) in
            progressBlock?(receivedSize, totalSize)
            self.updateLatestChange((url: url, percent: Double(receivedSize)/Double(totalSize), destination: nil, completed: false))
        }) { (data: Data?, destUrl: URL?, error: NSError?) in
            completionHandler?(data, destUrl, error)
            self.updateLatestChange((url: url, percent: nil, destination: error == nil ? destUrl : nil, completed: true))
        }
        barrierQueue.sync(flags: .barrier) {
            downloadTaskPresent[url] = task
        }
        return task
    }
    
    private func updateLatestChange(_ change: FileDownloadChange) {
        barrierQueue.sync(flags: .barrier) {
            if change.completed {
                downloadChangePresent.removeValue(forKey: change.url)
                downloadTaskPresent.removeValue(forKey: change.url)
            } else {
                downloadChangePresent[change.url] = change
            }
        }
        watcher.input.send(value: change)
    }
    
    /// Watch a file download
    ///
    /// - Parameter url: download url
    /// - Returns: A truple represent the (downloadUrl, percent, destination, completed)
    public func watch(url: URL) -> SignalProducer<FileDownloadChange, NSError> {
        return SignalProducer<FileDownloadChange, NSError> { (observer, lifetime) in
            self.barrierQueue.sync(flags: .barrier) {
                if let latestValue = self.downloadChangePresent[url] {
                    observer.send(value: latestValue)
                }
            }
            let task =  self.watcher.output.filter({ (data) -> Bool in
                return data.url == url
            }).observe(observer)
            lifetime += task
        }
    }
    
    public func isDownloading(url: URL) -> Bool {
        return downloadTaskPresent[url] != nil
    }
    
    public func cancelDownloading(url: URL) {
        barrierQueue.sync(flags: .barrier) {
            if let task = downloadTaskPresent[url] {
                task.cancel()
            }
            downloadTaskPresent.removeValue(forKey: url)
            downloadChangePresent.removeValue(forKey: url)
        }
    }
    
    private lazy var watcher: (output: Signal<FileDownloadChange, NSError>, input: Signal<FileDownloadChange, NSError>.Observer) = {
        return Signal<FileDownloadChange, NSError>.pipe()
    }()
}
