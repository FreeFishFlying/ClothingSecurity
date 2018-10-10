//
//  FixedConcurrentDownloader.swift
//  Mesh
//
//  Created by kingxt on 2017/6/24.
//  Copyright © 2017年 liao. All rights reserved.
//

import Foundation

private class DownloadOperation: AsynchronousOperation {
    
    fileprivate let url: URL
    private let options: KingfisherOptionsInfo?
    private let progressBlock: DownloadProgressBlock?
    private let completionHandler: CompletionHandler?
    
    private var task: RetrieveImageTask?
    
    init(url: URL,
         options: KingfisherOptionsInfo?,
         progressBlock: DownloadProgressBlock?,
         completionHandler: CompletionHandler?) {
        self.url = url
        self.options = options
        self.progressBlock = progressBlock
        self.completionHandler = completionHandler
    }
    
    override open func execute() {
        if isCancelled {
            finish()
            return
        }
        task = KingfisherManager.shared.retrieveImage(with: url, options: options, progressBlock: progressBlock) { (image, error, cacheType, url) in
            self.finish()
            self.completionHandler?(image, error, cacheType, url)
        }
    }
    
    override func cancel() {
        super.cancel()
        task?.cancel()
    }
}

public class FixedConcurrentImageManager {
    
    public static let shared = FixedConcurrentImageManager()
    
    private let queue = OperationQueue()
    
    public var maxConcurrentOperationCount: Int = 2 {
        didSet {
            queue.maxConcurrentOperationCount = maxConcurrentOperationCount
        }
    }
    
    public init() {
        queue.maxConcurrentOperationCount = maxConcurrentOperationCount
    }
    
    @discardableResult
    public func retrieveImage(url: URL,
                              options: KingfisherOptionsInfo?,
                              progressBlock: DownloadProgressBlock?,
                              completionHandler: CompletionHandler?) -> Operation
    {
        let operation = DownloadOperation(url: url, options: options, progressBlock: progressBlock, completionHandler: completionHandler)
        queue.addOperation(operation)
        return operation
    }
    
    public func cancel(url: URL) {
        for opt in queue.operations {
            if url == (opt as! DownloadOperation).url {
                opt.cancel()
            }
        }
    }
}
