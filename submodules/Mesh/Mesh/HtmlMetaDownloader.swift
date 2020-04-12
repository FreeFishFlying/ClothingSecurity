//
//  HtmlMetaDownloader.swift
//  Mesh
//
//  Created by Dylan on 06/07/2017.
//  Copyright © 2017 liao. All rights reserved.
//

import UIKit

private let HtmlMetaFileLengthLimit: Int64 = 300 * 1024
private var FiledUrlCached: [URL] = [URL]()

public typealias HtmlMetaDownloaderCompletionHandler = ((_ result: String?, _ dest: URL?, _ error: Error?) -> Void)

public class HtmlMetaDownloader {

    public static let `default` = HtmlMetaDownloader()

    public let barrierQueue = DispatchQueue(label: "com.xhb.HtmlMetaDownloader.Barrier", attributes: .concurrent)

    public var maxConcurrentOperationCount: Int = 2 {
        didSet {
            queue.maxConcurrentOperationCount = maxConcurrentOperationCount
        }
    }

    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 2
        return queue
    }()

    @discardableResult
    public func download(with url: URL, completionHandler: @escaping HtmlMetaDownloaderCompletionHandler) -> Operation {
        for operation in queue.operations {
            if !operation.isCancelled && !operation.isFinished {
                if let operation = operation as? HtmlMetaDownloaderOperation {
                    if url == operation.url {
                        operation.append(completionHandler: completionHandler)
                        return operation
                    }
                }
            }
        }
        let newOperation = HtmlMetaDownloaderOperation(url: url)
        newOperation.append(completionHandler: completionHandler)
        queue.addOperation(newOperation)
        return newOperation
    }
}

private class HtmlMetaDownloaderOperation: AsynchronousOperation {

    fileprivate let url: URL

    private var downloadTask: DataRequest?
    private var completionHandlers: [HtmlMetaDownloaderCompletionHandler] = [HtmlMetaDownloaderCompletionHandler]()

    init(url: URL) {
        self.url = url
    }

    public func append(completionHandler: @escaping HtmlMetaDownloaderCompletionHandler) {
        HtmlMetaDownloader.default.barrierQueue.sync(flags: .barrier) {
            self.completionHandlers.append(completionHandler)
        }
    }

    override func execute() {
        if isCancelled {
            finish()
            return
        }

        var filedUrlCached = false
        HtmlMetaDownloader.default.barrierQueue.sync(flags: .barrier) {
            filedUrlCached = FiledUrlCached.contains(url)
        }
        if filedUrlCached {
            finish()
            var items: [HtmlMetaDownloaderCompletionHandler] = []
            HtmlMetaDownloader.default.barrierQueue.sync(flags: .barrier) {
                items.append(contentsOf: completionHandlers)
            }
            for comption in items {
                comption(nil, url, nil)
            }
            return
        }
        downloadTask = request(url).downloadProgress(queue: DispatchQueue.global()) {[weak self] (progress) in
            if let strongSelf = self {
                strongSelf.handleProcess(received: progress.completedUnitCount, total: progress.totalUnitCount)
            }
        }.responseString(queue: DispatchQueue.global(), encoding: String.Encoding.utf8, completionHandler: {[weak self] (response) in
            if let strongSelf = self {
                strongSelf.handleCompletion(response: response)
                if response.value == nil {
                    HtmlMetaDownloader.default.barrierQueue.sync(flags: .barrier) {
                        FiledUrlCached.append(strongSelf.url)
                    }
                }
            }
        })
    }

    override func cancel() {
        super.cancel()
        downloadTask?.cancel()
        downloadTask = nil
    }

    private func handleProcess(received: Int64, total: Int64) {
        if total > HtmlMetaFileLengthLimit {
            downloadTask?.cancel()
            downloadTask = nil
            finish()
            var items: [HtmlMetaDownloaderCompletionHandler] = []
            HtmlMetaDownloader.default.barrierQueue.sync(flags: .barrier) {
                items.append(contentsOf: completionHandlers)
            }
            for comption in items {
                comption(nil, url, nil)
            }
        }
    }

    private func handleCompletion(response: DataResponse<String>) {
        finish()
        downloadTask?.cancel()
        downloadTask = nil

        var items: [HtmlMetaDownloaderCompletionHandler] = []
        HtmlMetaDownloader.default.barrierQueue.sync(flags: .barrier) {
            items.append(contentsOf: completionHandlers)
        }
        for comption in items {
            if response.response?.statusCode != 200 {
                comption(nil, response.request?.url, nil)
            } else {
                comption(response.value, response.request?.url, response.error)
            }
        }
        HtmlMetaDownloader.default.barrierQueue.sync(flags: .barrier) {
            completionHandlers.removeAll()
        }
    }
}
