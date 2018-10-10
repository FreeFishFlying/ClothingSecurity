//
//  ImageDownloader.swift
//  Kingfisher
//
//  Created by Wei Wang on 15/4/6.
//
//  Copyright (c) 2017 Wei Wang <onevcat@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Progress update block of downloader.
public typealias ImageDownloaderProgressBlock = DownloadProgressBlock

/// Completion block of downloader.
public typealias ImageDownloaderCompletionHandler = ((_ image: Image?, _ error: NSError?, _ url: URL?, _ originalData: Data?) -> ())



///The code of errors which `ImageDownloader` might encountered.
public enum KingfisherError: Int {
    
    /// badData: The downloaded data is not an image or the data is corrupted.
    case badData = 10000
    
    /// notModified: The remote server responsed a 304 code. No image data downloaded.
    case notModified = 10001
    
    /// The HTTP status code in response is not valid. If an invalid
    /// code error received, you could check the value under `KingfisherErrorStatusCodeKey` 
    /// in `userInfo` to see the code.
    case invalidStatusCode = 10002
    
    /// notCached: The image rquested is not in cache but .onlyFromCache is activated.
    case notCached = 10003
    
    /// The URL is invalid.
    case invalidURL = 20000
    
    /// The downloading task is cancelled before started.
    case downloadCancelledBeforeStarting = 30000
}

/// Key will be used in the `userInfo` of `.invalidStatusCode`
public let KingfisherErrorStatusCodeKey = "statusCode"

/// `ImageDownloader` represents a downloading manager for requesting the image with a URL from server.
open class ImageDownloader {
    
    private let downloader = MeshDownloader(name: "ImageDownloader")
    private let processQueue: DispatchQueue
    /**
     Download an image with a URL and option.
     
     - parameter url:               Target URL.
     - parameter retrieveImageTask: The task to cooporate with cache. Pass `nil` if you are not trying to use downloader and cache.
     - parameter options:           The options could control download behavior. See `KingfisherOptionsInfo`.
     - parameter progressBlock:     Called when the download progress updated.
     - parameter completionHandler: Called when the download progress finishes.
     
     - returns: A downloading task. You could call `cancel` on it to stop the downloading process.
     */
    @discardableResult
    open func downloadImage(with url: URL,
                            retrieveImageTask: RetrieveImageTask? = nil,
                            options: KingfisherOptionsInfo,
                            progressBlock: ImageDownloaderProgressBlock? = nil,
                            completionHandler: ImageDownloaderCompletionHandler? = nil) -> MeshDownloadTask?
    {
        var meshOptions = [MeshLoaderOptionsInfoItem]()
        
        
        if let item = options.lastMatchIgnoringAssociatedValue(.downloadPriority(0)),
            case .downloadPriority(let priority) = item {
            meshOptions.append(.downloadPriority(priority))
        }
        if let item = options.lastMatchIgnoringAssociatedValue(.requestModifier(NoModifier.default)),
            case .requestModifier(let modifier) = item {
            meshOptions.append(.requestModifier(modifier))
        }
        if let item = options.lastMatchIgnoringAssociatedValue(.retryTimes(0)),
            case .retryTimes(let times) = item {
            meshOptions.append(.retryTimes(times))
        }
        
        let task = downloader.requestUrl(with: url, options: meshOptions, progressBlock: { (receivedSize: Int64,  totalSize: Int64) in
            progressBlock?(receivedSize, totalSize)
        }) { (data: Data?, destUrl: URL?, error: NSError?) in
            if let data = data {
                self.processImage(data: data, url: url, imageOptions: options, completionHandler: { (image) in
                    completionHandler?(image, nil, url, data)
                })
            } else {
                completionHandler?(nil, error, url, nil)
            }
        }
        retrieveImageTask?.downloadTask = task
        return task
    }
    
    // MARK: - Public method
    /// The default downloader.
    public static let `default` = ImageDownloader(name: "default")
    
    /**
    Init a downloader with name.
    
    - parameter name: The name for the downloader. It should not be empty.
    
    - returns: The downloader object.
    */
    public init(name: String) {
        if name.isEmpty {
            fatalError("[Kingfisher] You should specify a name for the downloader. A downloader with empty name is not permitted.")
        }
        processQueue = DispatchQueue(label: "com.onevcat.Kingfisher.ImageDownloader.Process.\(name)", attributes: .concurrent)
    }
    
    private func processImage(data: Data, url: URL, imageOptions: KingfisherOptionsInfo, completionHandler: @escaping (UIImage?) -> Void) {
        // We are on main queue when receiving this.
        processQueue.async {
            func callback(acceleratedGifPlayPath: String? = nil) {
                let callbackQueue = imageOptions.callbackDispatchQueue
                let processor = imageOptions.processor
                let image = processor.process(item: .data(data), options: imageOptions)
                if let image = image {
                    if imageOptions.backgroundDecode {
                        let decodedImage = image.kf.decoded(scale: imageOptions.scaleFactor)
                        callbackQueue.safeAsync { completionHandler(decodedImage) }
                    } else {
                        callbackQueue.safeAsync { completionHandler(image) }
                    }
                } else {
                    callbackQueue.safeAsync { completionHandler(nil) }
                }
            }
            callback()
        }
    }
}
