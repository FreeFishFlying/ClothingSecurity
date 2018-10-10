//
//  MeshUploader.swift
//  Mesh
//
//  Created by kingxt on 6/22/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import Photos
import ReactiveSwift
import Result
import enum Result.Result

public enum MeshUploadType : Int {
    case image
    case audio
    case video
    case file
    case gif
}

public protocol Uploader {
    func upload(fileUrl: URL, options: MeshUploaderOptionsInfo, mediaType: MeshUploadType, sessionId: String, queue: DispatchQueue) -> Signal<FileUploadChange, UploadError>
}

public protocol UploadDataCompressor {
    func compress(image: UIImage) -> Data?
    func compress(data: Data, type: MeshUploadType) -> Data?
    func compress(url: URL) -> URL?
    func toString() -> String
}

public protocol CachedResponseValidator {
    func validate(data: Data) -> Bool
}

struct UploadDataDefaultCompressor: UploadDataCompressor {
    static let `default` = UploadDataDefaultCompressor()
    private init() {}
    
    func compress(data: Data, type: MeshUploadType) -> Data? {
        return data
    }
    
    func compress(image: UIImage) -> Data? {
        return image.jpegData(compressionQuality: 0.8)
    }
    
    func compress(url: URL) -> URL? {
        return url
    }
    
    func toString() -> String {
        return "UploadDataDefaultCompressor"
    }
}

private var latestPHAuthorizationStatus: PHAuthorizationStatus?

public typealias MeshUploaderOptionsInfo = [MeshUploaderOptionsInfoItem]

public let MeshUpLoaderEmptyOptionsInfo = [MeshUploaderOptionsInfoItem]()

public enum MeshUploaderOptionsInfoItem {
    
    case requestModifier(RequestModifier)
    
    /// Compress the system library data if need
    case compressor(UploadDataCompressor)
    
    /// When down load error from server, It will retry download specific times
    /// Associated `Int` first args present the retry times
    /// Associated `TimeInterval` second args present the retry seconds interval
    case retryTimes(Int)
    
    /// The image size retrieve from system photo library
    case imageSize(CGSize)
    
    /// Wherer upload system photo library original data
    case uploadOriginalData
    
    /// value between 0.0 and 1.0 (inclusive), where 0.0 is considered the lowest
    /// priority and 1.0 is considered the highest.
    case uploadPriority(Float)
    
    case cachedResponseValidator(CachedResponseValidator)
    
    case uploader(Uploader)
}

func <== (lhs: MeshUploaderOptionsInfoItem, rhs: MeshUploaderOptionsInfoItem) -> Bool {
    switch (lhs, rhs) {
    case (.requestModifier(_), .requestModifier(_)): return true
    case (.compressor(_), .compressor(_)): return true
    case (.retryTimes(_), .retryTimes(_)): return true
    case (.imageSize(_), .imageSize(_)): return true
    case (.uploadOriginalData, .uploadOriginalData): return true
    case (.uploadPriority(_), .uploadPriority(_)): return true
    case (.cachedResponseValidator(_), .cachedResponseValidator(_)): return true
    default: return false
    }
}

extension Collection where Iterator.Element == MeshUploaderOptionsInfoItem {
    public var uploader: Uploader {
        for item in self.reversed() {
            switch item {
            case .uploader(let uploader):
                return uploader
            default: break
            }
        }
        return DefaultUploader()
    }
    
    /// The `MeshRequestModifier` will be used before sending a download request.
    public var modifier: RequestModifier {
        if let item = lastMatchIgnoringAssociatedValue(.requestModifier(NoModifier.default)),
            case .requestModifier(let modifier) = item
        {
            return modifier
        }
        return meshDownloadModify
    }
    
    public var compressor: UploadDataCompressor {
        if let item = lastMatchIgnoringAssociatedValue(.compressor(UploadDataDefaultCompressor.default)),
            case .compressor(let value) = item
        {
            return value
        }
        return UploadDataDefaultCompressor.default
    }
    
    public var cachedResponseValidator: CachedResponseValidator? {
        var validator: CachedResponseValidator? = nil
        self.forEach { (item) in
            switch item {
            case .cachedResponseValidator(let value):
                validator = value
            default: break
            }
        }
        return validator
    }
    
    public var retryTimes: Int {
        if let item = lastMatchIgnoringAssociatedValue(.retryTimes(0)),
            case .retryTimes(let times) = item
        {
            return times
        }
        return meshRetryTimes
    }
    
    public var uploadPriority: Float {
        if let item = lastMatchIgnoringAssociatedValue(.uploadPriority(0)),
            case .uploadPriority(let value) = item
        {
            return value
        }
        return 0.5
    }
    
    public var imageSize: CGSize {
        if let item = lastMatchIgnoringAssociatedValue(.imageSize(CGSize.zero)),
            case .imageSize(let size) = item
        {
            return size
        }
        return CGSize(width: 960, height: 1920)
    }
    
    public var uploadOriginalData: Bool {
        return contains{ $0 <== .uploadOriginalData }
    }
    
    func lastMatchIgnoringAssociatedValue(_ target: Iterator.Element) -> Iterator.Element? {
        return reversed().first { $0 <== target }
    }
}

public enum UploadError: Error {
    case retrieveUploadDataError(message: String?)
    case uploadDataToServerError(message: String?)
}

public enum MeshUploadErrorCode: Int {
    
    /// badData: The update data is not an exist
    case badData = 10000
    case uploadTrunkError = 100001
}


public struct FileUploadChange {
    public let sessionId: String
    public let status: MeshUploader.Status
    
    public init(sessionId: String, status: MeshUploader.Status) {
        self.sessionId = sessionId
        self.status = status
    }
}

public let MeshUploaderErrorDomain = "com.liao.upload.error"

extension URL {
    func sliceData(fileOffset: UInt64, count: Int) -> SignalProducer<(Data, UInt64), UploadError> {
        return SignalProducer<(Data, UInt64), UploadError>{ (observer, disposable) in
            var count: UInt64 = UInt64(count)
            do {
                let fileAttr = try FileManager.default.attributesOfItem(atPath: self.path)
                let fileSize = fileAttr[FileAttributeKey.size] as! UInt64
                if fileOffset >= fileSize {
                    observer.send(error: .retrieveUploadDataError(message: "file handle read file error"))
                    return
                }
                guard let fileHandle = FileHandle(forReadingAtPath: self.path) else {
                    observer.send(error: .retrieveUploadDataError(message: "file handle read file error"))
                    return
                }
                count = min(fileSize - fileOffset, count)
                fileHandle.seek(toFileOffset: fileOffset)
                if fileOffset + count + 1 == fileSize {
                    count += 1
                }
                let data = fileHandle.readData(ofLength: Int(count))
                fileHandle.closeFile()
                observer.send(value: (data, fileSize))
                observer.sendCompleted()
            } catch {
                observer.send(error: .retrieveUploadDataError(message: "file handle read file error"))
            }
        }
    }
}

public class MeshUploader {
    
    public enum Status: Equatable {
        case pending
        case uploading(fractionCompleted: Double)
        case failed
        case succeeded(responseData: Data, uploadLocalUrl: URL)
        
        public static func ==(lhs: Status, rhs: Status) -> Bool {
            switch (lhs, rhs) {
            case (.pending, .pending): return true
            case (.uploading(_), .uploading(_)): return true
            case (.failed, .failed): return true
            case (.succeeded(_, _), .succeeded(_, _)): return true
            default: return false
            }
        }
    }
    
    public let mediaType: MeshUploadType
    public let sessionId: String
    public private(set) var fileURL: URL?
    public private(set) var phAssetLocalIdentifier: String?
    public private(set) var status: Status = .pending
    public private(set) var tempUploadFileURL: URL?
    public let options: MeshUploaderOptionsInfo
    
    private var uploaderDisposable: Disposable?
    private var uploadFileMD5: String?
    
    private let (uploadSignal, uploadObserver) = Signal<FileUploadChange, UploadError>.pipe()
    
    fileprivate let queue: DispatchQueue
    
    /// Upload a local file to
    ///
    /// - Parameters:
    ///   - fileURL: file url represent the file bundle absolute path
    ///   - mediaType: mediaType file type
    public init(fileURL: URL, sessionId: String, mediaType: MeshUploadType, options: MeshUploaderOptionsInfo = MeshUpLoaderEmptyOptionsInfo) {
        self.fileURL = fileURL
        self.sessionId = sessionId
        self.mediaType = mediaType
        self.options = options
        self.queue = DispatchQueue(label: "com.liao.meshupload." + sessionId)
    }
    
    
    /// Upload a system PHAsset with its identifer
    ///
    /// - Parameters:
    ///   - phAssetLocalIdentifier: the PHAsset identifer
    ///   - mediaType: media type present
    public init(phAssetLocalIdentifier: String, sessionId: String, mediaType: MeshUploadType, options: MeshUploaderOptionsInfo = MeshUpLoaderEmptyOptionsInfo) {
        self.phAssetLocalIdentifier = phAssetLocalIdentifier
        self.sessionId = sessionId
        self.mediaType = mediaType
        self.options = options
        self.queue = DispatchQueue(label: "com.liao.meshupload." + sessionId)
    }
    
    public func resume() {
        if status == .pending || status == .failed {
            self.status = .uploading(fractionCompleted: 0)
            self.queue.async {
                self.tryToRetrieveUploadFileURLSignal().startWithResult { (result) in
                    if let url = result.value {
                        self.tempUploadFileURL = url
                        self.queue.async {
                            let validator = self.options.cachedResponseValidator
                            if validator == nil {
                                self.upload(url: url)
                            } else if let updloadData = try? Data(contentsOf: URL(fileURLWithPath: url.path)) {
                                self.uploadFileMD5 = updloadData.md5
                                if let cachedResponse = MeshUploaderResponseCache.shared.cachedResponse(id: self.uploadFileMD5!) {
                                    if validator!.validate(data: cachedResponse) {
                                        self.status = .succeeded(responseData: cachedResponse, uploadLocalUrl: url)
                                        self.uploadObserver.send(value: FileUploadChange(sessionId: self.sessionId, status: self.status))
                                        self.uploadObserver.sendCompleted()
                                    } else {
                                        MeshUploaderResponseCache.shared.feedbackInvalid(id: self.uploadFileMD5!)
                                        self.upload(url: url)
                                    }
                                } else {
                                    self.upload(url: url)
                                }
                            } else {
                                self.status = .failed
                                self.uploadObserver.send(error: result.error ?? .uploadDataToServerError(message: "no data to upload"))
                            }
                        }
                    } else {
                        self.status = .failed
                        self.uploadObserver.send(error: result.error ?? .uploadDataToServerError(message: "no data to upload"))
                    }
                }
            }
        }
    }
    
    public func cancel() {
        uploaderDisposable?.dispose()
    }
    
    public var currentUploadChange: FileUploadChange {
        return FileUploadChange(sessionId: self.sessionId, status: status)
    }
    
    public func watchDog() -> Signal<FileUploadChange, UploadError> {
        return uploadSignal.observe(on: UIScheduler())
    }
    
    private func upload(url: URL) {
        uploaderDisposable = options.uploader.upload(fileUrl: url, options: options, mediaType: mediaType, sessionId: sessionId, queue: queue).on(value: { [weak self] (change) in
            guard let `self` = self else {
                return
            }
            self.status = change.status
            let validator = self.options.cachedResponseValidator
            if validator != nil && self.uploadFileMD5 != nil {
                switch change.status {
                case let .succeeded(responseData, _):
                    if responseData.count > 0 {
                        MeshUploaderResponseCache.shared.cacheResponse(id: self.uploadFileMD5!, responseData: responseData)
                    }
                default: break
                }
            }
            
        }).observe(uploadObserver)
    }
}

// MARK: Get upload file url
extension MeshUploader {
    fileprivate func tryToRetrieveUploadFileURLSignal() -> SignalProducer<URL, UploadError> {
        return SignalProducer<URL, UploadError> { (observer, lifetime) in
            if self.fileURL != nil {
                if self.options.uploadOriginalData {
                    observer.send(value: self.fileURL!)
                    observer.sendCompleted()
                } else if let url = self.options.compressor.compress(url: self.fileURL!) {
                    observer.send(value: url)
                    observer.sendCompleted()
                } else {
                    observer.send(error: .retrieveUploadDataError(message: "compress \(self.fileURL!) error and cance upload"))
                }
            } else {
                guard let tempUploadFileURL = self.tempUploadFileURL else {
                    guard let phAssetLocalIdentifier = self.phAssetLocalIdentifier else {
                        return observer.send(error: .retrieveUploadDataError(message: "phAssetLocalIdentifier should not nil"))
                    }
                    let task = self.retrievePHAssetUploadFileURL(phAssetLocalIdentifier: phAssetLocalIdentifier).start(observer)
                    lifetime += task
                    return
                }
                observer.send(value: tempUploadFileURL)
                observer.sendCompleted()
            }
        }
    }
    
    private func retrievePHAssetUploadFileURL(phAssetLocalIdentifier: String) -> SignalProducer<URL, UploadError> {
        return SignalProducer<URL, UploadError> { (observer, disposable) in
            self.fetchAsset(phAssetLocalIdentifier: phAssetLocalIdentifier).startWithResult { (result) in
                if let value = result.value, let asset = value {
                    switch asset.mediaType {
                    case .image:
                        let task = self.retrieveImageUploadFileURL(asset: asset).start(observer)
                        disposable += task
                    case .video:
                        let task = self.retrieveVideoUploadFileURL(asset: asset).start(observer)
                        disposable += task
                    default:
                        observer.send(error: .retrieveUploadDataError(message: "PHAsset asset type \(asset.mediaType.rawValue) not support upload"))
                    }
                } else {
                    observer.send(error: .retrieveUploadDataError(message: "load PHAsset error"))
                }
            }
        }
    }
    
    private func degratedOrCancelled(info: [AnyHashable : Any]?) -> Bool {
        if let cancelled = info?[PHImageCancelledKey] as? NSNumber {
            if cancelled.boolValue {
                return true
            }
        }
        if let degradedItem = info?[PHImageResultIsDegradedKey] as? NSNumber {
            return degradedItem.boolValue
        }
        return false
    }
    
    private func retrieveImageUploadFileURL(asset: PHAsset) -> SignalProducer<URL, UploadError> {
        return SignalProducer<URL, UploadError> { (observer, lifetime) in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .exact
            options.isNetworkAccessAllowed = true
            if self.options.uploadOriginalData {
                let token = PHImageManager.default().requestImageData(for: asset, options: options, resultHandler: { (data, dataUTI, orientation, info: [AnyHashable: Any]?) in
                    if self.degratedOrCancelled(info: info) {
                        return
                    }
                    if var data = data {
                        var url = self.randomTemporaryURL()
                        let fileUrl: URL? = info?["PHImageFileURLKey"] as? URL
                        var pathExtension: String = fileUrl?.pathExtension ?? "tmp"
                        if fileUrl?.pathExtension == "HEIC" {
                            if let image = UIImage(data: data) {
                                pathExtension = "jpg"
                                data = image.jpegData(compressionQuality: 1) ?? data
                            }
                        }
                        url = url.deletingPathExtension().appendingPathExtension(pathExtension)
                        do {
                            try data.write(to: url)
                            observer.send(value: url)
                            observer.sendCompleted()
                        } catch {
                            observer.send(error: .retrieveUploadDataError(message: error.localizedDescription))
                        }
                    } else {
                        observer.send(error: .retrieveUploadDataError(message: "retrieveImageUploadFileURL error"))
                    }
                })
                lifetime.observeEnded {
                    PHImageManager.default().cancelImageRequest(token)
                }
            } else {
                let token = PHImageManager.default().requestImage(for: asset, targetSize: self.options.imageSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                    if self.degratedOrCancelled(info: info) {
                        return
                    }
                    self.queue.async {
                        if let image = image, let data = self.options.compressor.compress(image: image) {
                            let url = self.randomTemporaryURL()
                            do {
                                try data.write(to: url)
                                observer.send(value: url)
                                observer.sendCompleted()
                            } catch {
                                observer.send(error: .retrieveUploadDataError(message: error.localizedDescription))
                            }
                        } else {
                            observer.send(error: .retrieveUploadDataError(message: "retrieveImageUploadFileURL error"))
                        }
                    }
                })
                
                lifetime.observeEnded {
                    PHImageManager.default().cancelImageRequest(token)
                }
            }
        }
    }
    
    private func retrieveVideoUploadFileURL(asset: PHAsset) -> SignalProducer<URL, UploadError> {
        return SignalProducer<URL, UploadError> { (observer, lifetime) in
            let task = self.avAssetSignal(asset: asset).startWithResult({ (result) in
                if let value = result.value {
                    if value is AVURLAsset {
                        let urlAsset = value as! AVURLAsset
                        var url: URL = self.randomTemporaryURL()
                        url = url.deletingPathExtension().appendingPathExtension(urlAsset.url.pathExtension)
                        do {
                            try FileManager.default.copyItem(at: urlAsset.url, to: url)
                            if !self.options.uploadOriginalData {
                                self.queue.async {
                                    if let compressUrl = self.options.compressor.compress(url: url) {
                                        observer.send(value: compressUrl)
                                        observer.sendCompleted()
                                    } else {
                                        observer.send(error: .retrieveUploadDataError(message: "cancel upload video for data compressor return nil"))
                                    }
                                }
                            } else {
                                observer.send(value: url)
                                observer.sendCompleted()
                            }
                        } catch {
                            observer.send(error: .retrieveUploadDataError(message: error.localizedDescription))
                        }
                    } else {
                        observer.send(error: .retrieveUploadDataError(message: "retrieveVideoUploadFileURL error"))
                    }
                } else {
                    observer.send(error: .retrieveUploadDataError(message: "retrieveVideoUploadFileURL error"))
                }
            })
            lifetime += task
        }
    }
    
    public func avAssetSignal(asset: PHAsset) -> SignalProducer<AVAsset, UploadError> {
        return SignalProducer<AVAsset, UploadError> { (observer, lifetime) in
            let requestOptions = PHVideoRequestOptions()
            requestOptions.isNetworkAccessAllowed = true
            let token = PHImageManager.default().requestAVAsset(forVideo: asset, options: requestOptions, resultHandler: { (avAsset: AVAsset?, _, info: [AnyHashable: Any]?) in
                if self.degratedOrCancelled(info: info) {
                    return
                }
                if let avAsset = avAsset {
                    observer.send(value: avAsset)
                    observer.sendCompleted()
                } else {
                    observer.send(error: .retrieveUploadDataError(message: "retrieve AVAsset error"))
                }
            })
            
            lifetime.observeEnded {
                PHImageManager.default().cancelImageRequest(token)
            }
        }
    }
    
    private func fetchAsset(phAssetLocalIdentifier: String) -> SignalProducer<PHAsset?, UploadError> {
        return SignalProducer<PHAsset?, UploadError> { (observer, disposable) in
            self.requestAuthorization().startWithValues { (statues) in
                if statues != PHAuthorizationStatus.authorized {
                    observer.send(error: .retrieveUploadDataError(message: "no priority to access system"))
                } else {
                    let assetItem = PHAsset.fetchAssets(withLocalIdentifiers: [phAssetLocalIdentifier], options: nil).firstObject
                    observer.send(value: assetItem)
                    observer.sendCompleted()
                }
            }
        }
    }
    
    public func requestAuthorization() -> SignalProducer<PHAuthorizationStatus, NoError> {
        return SignalProducer<PHAuthorizationStatus, NoError>{ (observer, _) in
            if let latestPHAuthorizationStatus = latestPHAuthorizationStatus {
                observer.send(value: latestPHAuthorizationStatus)
                observer.sendCompleted()
            }
            PHPhotoLibrary.requestAuthorization({ status in
                latestPHAuthorizationStatus = status
                observer.send(value: status)
                observer.sendCompleted()
            })
        }
    }
    
    private func randomTemporaryURL() -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(UUID().uuidString).tmp")
    }
}


// MARK: Upload one trunk

fileprivate class DefaultUploader: Uploader {
    
    private var url: URL!
    private var options: MeshUploaderOptionsInfo!
    private let originalRequest: URLRequest = URLRequest(url: URL(string: meshUploadBaseUrl)!)
    private var tryStep = 0
    private var data: Data?
    private var mediaType: MeshUploadType = .file
    private var sessionId: String!
    private var totalRetryTimes: Int = 0
    private let disposible: CompositeDisposable = CompositeDisposable()
    private var queue: DispatchQueue = DispatchQueue.main
    private var fileOffset: UInt64 = 0
    private var fileSize: UInt64 = 0
    public let bytesPerTrunkUpload: Int = 256 * 1024
    private let (uploadSignal, uploadObserver) = Signal<FileUploadChange, UploadError>.pipe()
    
    func upload(fileUrl: URL, options: MeshUploaderOptionsInfo, mediaType: MeshUploadType, sessionId: String, queue: DispatchQueue) -> Signal<FileUploadChange, UploadError> {
        self.url = fileUrl
        self.options = options
        self.mediaType = mediaType
        self.sessionId = sessionId
        self.queue = queue
        self.totalRetryTimes = options.retryTimes
        
        let signal = Signal<FileUploadChange, UploadError>({ (observer, lifetime) in
            uploadSignal.observeResult({ [weak self] (result) in
                guard let `self` = self else {
                    return
                }
                if let value = result.value {
                    guard let data = self.data else {
                        observer.send(error: .retrieveUploadDataError(message: "upload to server error"))
                        return
                    }
                    switch value.status {
                    case let .uploading(fractionCompleted):
                        let dataLength = self.data?.count ?? 0
                        let percent = Double(fractionCompleted * Double(dataLength) + Double(self.fileOffset))/Double(self.fileSize)
                        observer.send(value: FileUploadChange(sessionId: self.sessionId, status: .uploading(fractionCompleted: percent)))
                    case let .succeeded(responseData, _):
                        if self.fileOffset + UInt64(data.count) == self.fileSize {
                            observer.send(value: FileUploadChange(sessionId: self.sessionId, status: .succeeded(responseData: responseData, uploadLocalUrl: fileUrl)))
                            observer.sendCompleted()
                        } else {
                            self.tryStep = 0
                            self.fileOffset = self.fileOffset + UInt64(data.count)
                            self.uploadTrunk()
                        }
                    default: break
                    }
                } else {
                    observer.send(error: result.error ?? .uploadDataToServerError(message: "upload to server error"))
                }
            })
            lifetime.observeEnded {
                self.disposible.dispose()
            }
        })
        uploadTrunk()
        return signal
    }
    
    func uploadTrunk() {
        url.sliceData(fileOffset: fileOffset, count: bytesPerTrunkUpload).startWithResult { (result) in
            if let (data, fileSize) = result.value {
                if fileSize == 0 {
                    self.uploadObserver.send(error: result.error ?? .uploadDataToServerError(message: "no data to upload"))
                    return
                }
                self.fileSize = fileSize
                self.data = data
                self.tryRequest()
            } else {
                self.uploadObserver.send(error: result.error ?? .uploadDataToServerError(message: "no data to upload"))
            }
        }
    }
    
    private func modifyRequest() -> (URLRequest, TimeInterval)? {
        guard let data = self.data else {
            self.uploadObserver.send(error: .retrieveUploadDataError(message: "no data to update"))
            return nil
        }
        if let (request, interval) = options.modifier.modified(for: originalRequest, tryStep: tryStep) {
            var request = request
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = originalRequest.allHTTPHeaderFields
            
            let lastIndex = fileSize - 1
            let endIndex: UInt64 = min(fileOffset + UInt64(data.count - 1), lastIndex)
            request.setValue("UTF-8", forHTTPHeaderField: "Charset")
            request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            request.setValue(sessionId, forHTTPHeaderField: "X-Session-ID")
            request.setValue("bytes \(fileOffset)-\(endIndex)/\(fileSize)", forHTTPHeaderField: "X-Content-Range")
            
            switch mediaType {
            case .audio:
                request.setValue("attachment; name=\"payload\" filename=\"sound\"", forHTTPHeaderField: "Content-Disposition")
            case .video:
                request.setValue("attachment; name=\"payload\" filename=\"video\"", forHTTPHeaderField: "Content-Disposition")
            case .file:
                request.setValue("attachment; name=\"payload\" filename=\"normal\"", forHTTPHeaderField: "Content-Disposition")
            case .image, .gif:
                request.setValue("attachment; name=\"payload\" filename=\"photo\"", forHTTPHeaderField: "Content-Disposition")
            }
            return (request, interval)
        }
        return nil
    }
    
    private func performUpload(reqeust: URLRequest) {
        guard let data = self.data else {
            self.uploadObserver.send(error: .retrieveUploadDataError(message: "no data to update"))
            return
        }
        let task = Mesh.upload(data, with: reqeust).uploadProgress(queue: .main, closure: { (progress) in
            self.uploadObserver.send(value: FileUploadChange(sessionId: self.sessionId, status: .uploading(fractionCompleted: progress.fractionCompleted)))
        }).responseData(queue: queue, completionHandler: { (response) in
            func callbackError() {
                meshLogger.log(info: self.sessionId + " " + response.description)
                if self.tryStep < self.totalRetryTimes {
                    self.tryStep += 1
                    self.tryRequest()
                } else {
                    self.uploadObserver.send(error: .uploadDataToServerError(message: "http response header not set range"))
                }
            }
            if let value = response.response {
                var responseHeader: [AnyHashable: Any] = value.allHeaderFields
                if let rangeString = responseHeader["Range"] as? String {
                    let comp1 = rangeString.components(separatedBy: "/")
                    if comp1.count == 2 {
                        if let data = response.data {
                            self.uploadObserver.send(value: FileUploadChange(sessionId: self.sessionId, status: .succeeded(responseData: data, uploadLocalUrl: self.url)))
                        } else {
                            self.uploadObserver.send(value: FileUploadChange(sessionId: self.sessionId, status: .succeeded(responseData: Data(), uploadLocalUrl: self.url)))
                        }
                    } else {
                        callbackError()
                    }
                } else {
                    callbackError()
                }
            } else {
                callbackError()
            }
        })
        task.task?.priority = options.uploadPriority
        disposible.add {
            task.cancel()
        }
    }
    
    private func tryRequest() {
        if let (request, interval) = modifyRequest() {
            meshLogger.log(info: "try to upload \(request.url?.absoluteString ?? ""), \(interval) later")
            if interval > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                    self.queue.async {
                        if !self.disposible.isDisposed {
                            self.performUpload(reqeust: request)
                        }
                    }
                }
            } else {
                performUpload(reqeust: request)
            }
        } else {
            uploadObserver.send(error: .uploadDataToServerError(message: "modify request return nil and cancelled"))
        }
    }
}
