//
//  MeshLoader.swift
//  Mesh
//
//  Created by kingxt on 6/16/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation

public typealias MeshLoaderOptionsInfo = [MeshLoaderOptionsInfoItem]
public typealias MeshDownloaderCompletionHandler = ((_ data: Data?, _ dest: URL?, _ error: NSError?) -> ())
public typealias MeshDownloaderProgressBlock = ((_ receivedSize: Int64, _ totalSize: Int64) -> ())

let MeshLoaderEmptyOptionsInfo = [MeshLoaderOptionsInfoItem]()

public let MeshDownloaderErrorDomain = "com.liao.meshloader.Error"

public enum MeshDownloaderError: Int {
    /// The URL is invalid.
    case invalidURL = 20000
    
    /// The downloading task is cancelled before started.
    case downloadCancelledBeforeStarting = 30000
}

/// Download task.
public class MeshDownloadTask {
    var internalTask: Request?
    
    /// Downloader by which this task is intialized.
    public fileprivate(set) weak var ownerDownloader: MeshDownloader?
    
    /**
     Cancel this download task. It will trigger the completion handler with an NSURLErrorCancelled error.
     */
    public func cancel() {
        ownerDownloader?.cancelDownloadingTask(self)
    }
    
    /// The original request URL of this download task.
    public var url: URL? {
        return internalTask?.task?.currentRequest?.url
    }
}
/**
Items could be added into MeshLoaderOptionsInfo.
*/
public enum MeshLoaderOptionsInfoItem {
    
    /// The `MeshRequestModifier` contained will be used to change the request before it being sent.
    /// This is the last chance you can modify the request. You can modify the request for some customizing purpose,
    /// such as adding auth token to the header, do basic HTTP auth or something like url mapping. The original request
    /// will be sent without any modification by default.
    case requestModifier(RequestModifier)
    
    /// When down load error from server, It will retry download specific times
    /// Associated `Int` first args present the retry times
    /// Associated `TimeInterval` second args present the retry seconds interval
    case retryTimes(Int)
    
    /// Associated `Float` value will be set as the priority of download task. The value for it should be
    /// between 0.0~1.0. If this option not set, the default value (`NSURLSessionTaskPriorityDefault`) will be used.
    case downloadPriority(Float)
    
    case resumeDownload(Bool)
}

public class MeshDownloader {
    
    typealias CallbackPair = (progressBlock: MeshDownloaderProgressBlock?, completionHandler: MeshDownloaderCompletionHandler?)
    
    // MARK: - Public property
    /// The duration before the download is timeout. Default is 15 seconds.
    public var downloadTimeout: TimeInterval = 15.0
    
    public var requestsUsePipelining: Bool = false
    
    class FetchLoader {
        
        let retryTimes: Int //same url with override previous setting
        let url: URL
        init(url: URL, retryTimes: Int = 0) {
            self.url = url
            self.retryTimes = retryTimes
        }
        
        var tryStep = 0
        
        var contents = [(callback: CallbackPair, destination: URL?, options: MeshLoaderOptionsInfo)]()
        
        var downloadTaskCount = 0
        var downloadTask: MeshDownloadTask?
        var cancelSemaphore: DispatchSemaphore?
        
        func downloadPriority() -> Float {
            return contents.last?.options.downloadPriority ?? URLSessionTask.defaultPriority
        }
        
        func resumeDownload() -> Bool {
            return contents.last?.options.resumeDownload ?? true
        }
        
        func clear() {
            downloadTask = nil
        }
    }
    
    // MARK: - Internal property
    let barrierQueue: DispatchQueue
    let cancelQueue: DispatchQueue
    
    var fetchLoads = [URL: FetchLoader]()
    
    public init(name: String) {
        if name.isEmpty {
            fatalError("[Mesh] You should specify a name for the downloader. A downloader with empty name is not permitted.")
        }
        
        barrierQueue = DispatchQueue(label: "com.liao.MeshDownloader.Barrier.\(name)", attributes: .concurrent)
        cancelQueue = DispatchQueue(label: "com.liao.MeshDownloader.Cancel.\(name)")
    }
    
    @discardableResult
    public func requestUrl(with url: URL,
                           destination: URL? = nil,
                           options: MeshLoaderOptionsInfo? = nil,
                           progressBlock: MeshDownloaderProgressBlock? = nil,
                           completionHandler: MeshDownloaderCompletionHandler? = nil) -> MeshDownloadTask? {
        
        guard let requestInfo = getRequestFromUrl(with: url, tryStep: 0, options: options) else {
            completionHandler?(nil, nil, NSError(domain: MeshDownloaderErrorDomain, code: MeshDownloaderError.downloadCancelledBeforeStarting.rawValue, userInfo: nil))
            meshLogger.log(info: MeshDownloaderErrorDomain + " downloadCancelledBeforeStarting \(url)")
            return nil
        }
        
        // There is a possiblility that request modifier changed the url to `nil` or empty.
        guard let url = requestInfo.0.url, !url.absoluteString.isEmpty else {
            completionHandler?(nil, nil, NSError(domain: MeshDownloaderErrorDomain, code: MeshDownloaderError.invalidURL.rawValue, userInfo: nil))
            meshLogger.log(info: MeshDownloaderErrorDomain + " invalidURL nil or empty")
            return nil
        }
        
        var downloadTask: MeshDownloadTask?
        setup(progressBlock: progressBlock, with: completionHandler, for: url, destination: destination, options: options ?? MeshLoaderEmptyOptionsInfo) {(fetchLoad) -> Void in
            if fetchLoad.downloadTask == nil {
                self.performRequest(url: url, request: requestInfo.0, fetchLoad: fetchLoad, delay: requestInfo.1)
            }
            fetchLoad.downloadTaskCount += 1
            downloadTask = fetchLoad.downloadTask
        }
        return downloadTask
    }
    
    private func getRequestFromUrl(with url: URL, tryStep: Int, options: MeshLoaderOptionsInfo? = nil) -> (URLRequest, TimeInterval)? {
        let timeout = self.downloadTimeout == 0.0 ? 15.0 : self.downloadTimeout
        
        // We need to set the URL as the load key. So before setup progress, we need to ask the `requestModifier` for a final URL.
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeout)
        request.httpShouldUsePipelining = requestsUsePipelining
        
        if let modifier = options?.modifier {
            guard let result = modifier.modified(for: request, tryStep: tryStep) else {
                return nil
            }
            return result
        }
        return (request, 0)
    }
    
    private func doRequest(url: URL, request aRequest: URLRequest, fetchLoad: FetchLoader) -> Request {
        if let destinationURL = fetchLoad.contents.last?.destination {
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                return (destinationURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            let downloadRequest: DownloadRequest
            if fetchLoad.resumeDownload() && FileManager.default.fileExists(atPath: reusmeDataDestination(from: url).path) {
                if let data = try? Data(contentsOf: reusmeDataDestination(from: url)) {
                    downloadRequest = download(resumingWith: data, to: destination)
                } else {
                    downloadRequest = download(aRequest, to: destination)
                }
            } else {
                downloadRequest = download(aRequest, to: destination)
            }
            downloadRequest.downloadProgress(queue: .main, closure: { [weak self] (progress) in
                if let task = fetchLoad.downloadTask?.internalTask?.task {
                    self?.urlSession(url: url, task: task, progress: progress)
                }
            }).response(completionHandler: { [weak self] (response) in
                if let strongSelf = self {
                    if let task = fetchLoad.downloadTask?.internalTask?.task {
                        if let resumeData = response.resumeData {
                            let saveURL = strongSelf.reusmeDataDestination(from: url)
                            try? FileManager.default.removeItem(at: saveURL)
                            try? resumeData.write(to: saveURL)
                        }
                        strongSelf.urlSession(url: url, task: task, data: nil, destination: response.destinationURL, didCompleteWithError: response.error, timeline: response.timeline)
                    }
                }
                
            })
            downloadRequest.task?.priority = fetchLoad.downloadPriority()
            return downloadRequest
        } else {
            let dataRequest = request(aRequest).downloadProgress(queue: .main, closure: { [weak self] progress in
                if let task = fetchLoad.downloadTask?.internalTask?.task {
                    self?.urlSession(url: url, task: task, progress: progress)
                }
            }).responseData(completionHandler: { [weak self] (response: DataResponse<Data>) in
                if let task = fetchLoad.downloadTask?.internalTask?.task {
                    self?.urlSession(url: url, task: task, data: response.result.value, destination: nil, didCompleteWithError: response.error, timeline: response.timeline)
                }
            })
            dataRequest.task?.priority = fetchLoad.downloadPriority()
            return dataRequest
        }
    }
    
    private func reusmeDataDestination(from url: URL) -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(url.absoluteString.kf.md5).tmp")
    }
    
    // A single key may have multiple callbacks. Only download once.
    private func setup(progressBlock: MeshDownloaderProgressBlock?, with completionHandler: MeshDownloaderCompletionHandler?, for url: URL, destination: URL?, options: MeshLoaderOptionsInfo, started: @escaping ((FetchLoader) -> Void)) {
        
        func prepareFetchLoad() {
            var loadObjectForURL: FetchLoader? = nil
            barrierQueue.sync(flags: .barrier) {
                loadObjectForURL = fetchLoads[url] ?? FetchLoader(url: url, retryTimes: options.retryTimes)
                let callbackPair = (progressBlock: progressBlock, completionHandler: completionHandler)
                loadObjectForURL?.contents.append((callbackPair, destination, options))
                fetchLoads[url] = loadObjectForURL
            }
            started(loadObjectForURL!)
        }
        
        if let fetchLoad = fetchLoad(for: url), fetchLoad.downloadTaskCount == 0 {
            if fetchLoad.cancelSemaphore == nil {
                fetchLoad.cancelSemaphore = DispatchSemaphore(value: 0)
            }
            cancelQueue.async {
                _ = fetchLoad.cancelSemaphore?.wait(timeout: .distantFuture)
                fetchLoad.cancelSemaphore = nil
                prepareFetchLoad()
            }
        } else {
            prepareFetchLoad()
        }
    }
    
    func cancelDownloadingTask(_ task: MeshDownloadTask) {
        barrierQueue.sync(flags: .barrier) {
            if let URL = task.url, let FetchLoader = self.fetchLoads[URL] {
                FetchLoader.downloadTaskCount -= 1
                if FetchLoader.downloadTaskCount == 0 {
                    task.internalTask?.cancel()
                }
            }
        }
    }
    
    func fetchLoad(for url: URL) -> FetchLoader? {
        var fetchLoad: FetchLoader?
        barrierQueue.sync(flags: .barrier) { fetchLoad = fetchLoads[url] }
        return fetchLoad
    }
    
    fileprivate func urlSession(url: URL,task: URLSessionTask, progress: Progress) {
        if let fetchLoad = fetchLoad(for: url) {
            for content in fetchLoad.contents {
                content.callback.progressBlock?(progress.completedUnitCount, progress.totalUnitCount)
            }
        }
    }
    
    fileprivate func urlSession(url: URL, task: URLSessionTask, data: Data?, destination: URL?, didCompleteWithError error: Error?, timeline: Timeline) {
        guard error == nil else {
            if let destination = destination {
                try? FileManager.default.removeItem(at: destination)
            }
            if (error! as NSError).code == URLError.cancelled.rawValue {
                callCompletionHandlerFailure(error: error!, url: url)
                return
            }
            if let fetchLoad = fetchLoad(for: url) {
                if fetchLoad.tryStep < fetchLoad.retryTimes {
                    fetchLoad.tryStep += 1
                    retryLoadUrlIfNeed(url, tryStep: fetchLoad.tryStep, previousRequestError: error!)
                } else {
                    callCompletionHandlerFailure(error: error!, url: url)
                }
            } else {
                callCompletionHandlerFailure(error: error!, url: url)
            }
            return
        }
        
        if let fetchLoad = fetchLoad(for: url) {
            cleanFetchLoad(for: url)
            for content in fetchLoad.contents {
                content.callback.completionHandler?(data, destination, nil)
            }
        }
    }
    
    private func retryLoadUrlIfNeed(_ url: URL, tryStep: Int, previousRequestError: Error) {
        if let fetchLoad = fetchLoad(for: url) {
            if let requestInfo = getRequestFromUrl(with: url, tryStep: tryStep, options: fetchLoad.contents.last?.options) {
                meshLogger.log(info: "retry download url \(requestInfo.0.url?.absoluteString ?? "") original url is \(url.absoluteString) \(requestInfo.1) second later")
                performRequest(url: url, request: requestInfo.0, fetchLoad: fetchLoad, delay: requestInfo.1)
            } else {
                callCompletionHandlerFailure(error: previousRequestError, url: url)
            }
        }
    }
    
    private func performRequest(url: URL, request: URLRequest, fetchLoad: FetchLoader, delay: TimeInterval) {
        let task = fetchLoad.downloadTask ?? MeshDownloadTask()
        task.ownerDownloader = self
        fetchLoad.downloadTask = task
        if delay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if let fetchLoad = self.fetchLoad(for: url) { //ensure not cancelled
                    task.internalTask = self.doRequest(url: url, request: request, fetchLoad: fetchLoad)
                }
            }
        } else {
            task.internalTask = doRequest(url: url, request: request, fetchLoad: fetchLoad)
        }
    }
    
    private func cleanFetchLoad(for url: URL) {
        barrierQueue.sync(flags: .barrier) {
            fetchLoads.removeValue(forKey: url)?.clear()
        }
    }
    
    private func callCompletionHandlerFailure(error: Error, url: URL) {
        guard let fetchLoad = fetchLoad(for: url) else {
            return
        }
        // We need to clean the fetch load first, before actually calling completion handler.
        cleanFetchLoad(for: url)
        
        var leftSignal: Int
        repeat {
            leftSignal = fetchLoad.cancelSemaphore?.signal() ?? 0
        } while leftSignal != 0
        
        for content in fetchLoad.contents {
            content.callback.completionHandler?(nil, nil, error as NSError)
        }
    }
}


func <== (lhs: MeshLoaderOptionsInfoItem, rhs: MeshLoaderOptionsInfoItem) -> Bool {
    switch (lhs, rhs) {
    case (.requestModifier(_), .requestModifier(_)): return true
    case (.downloadPriority(_), .downloadPriority(_)): return true
    case (.retryTimes(_), .retryTimes(_)): return true
    case (.resumeDownload(_), .resumeDownload(_)): return true
    default: return false
    }
}

extension Collection where Iterator.Element == MeshLoaderOptionsInfoItem {
    
    /// The `MeshRequestModifier` will be used before sending a download request.
    public var modifier: RequestModifier {
        if let item = lastMatchIgnoringAssociatedValue(.requestModifier(NoModifier.default)),
            case .requestModifier(let modifier) = item
        {
            return modifier
        }
        return meshDownloadModify
    }
    
    public var resumeDownload: Bool {
        if let item = lastMatchIgnoringAssociatedValue(.resumeDownload(true)),
            case .resumeDownload(let value) = item
        {
            return value
        }
        return true
    }
    
    public var retryTimes: Int {
        if let item = lastMatchIgnoringAssociatedValue(.retryTimes(0)),
        case .retryTimes(let times) = item
        {
            return times
        }
        return meshRetryTimes
    }
    
    /// A `Float` value set as the priority of download task. The value for it should be
    /// between 0.0~1.0.
    public var downloadPriority: Float {
        if let item = lastMatchIgnoringAssociatedValue(.downloadPriority(0)),
            case .downloadPriority(let priority) = item
        {
            return priority
        }
        return URLSessionTask.defaultPriority
    }
    
    func lastMatchIgnoringAssociatedValue(_ target: Iterator.Element) -> Iterator.Element? {
        return reversed().first { $0 <== target }
    }
}
