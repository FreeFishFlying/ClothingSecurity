//
//  Mesh.swift
//  Mesh
//
//  Created by kingxt on 2017/6/17.
//  Copyright © 2017年 liao. All rights reserved.
//

import Foundation


@objc public protocol MeshLogger {
    func log(info: String)
}

public var meshLogger: MeshLogger = MeshFileLogger(fileName: "http.traffic.log")
public var meshDownloadModify: RequestModifier = NoModifier.default
public var meshRetryTimes: Int = 3
public var meshImageCacheName: String = "chaoxin.images"
public var meshUploadBaseUrl: String = ""

public let MeshHttpMetricNotificationName = "com.liao.mesh.http.metric"
public let MeshHttpMetric = "com.liao.mesh.http.metric"

public struct HttpMetric {
    public let url: String
    public let statusCode: Int
    public let requestDuration: TimeInterval
    public let bytesExpectedToSend: Int64
    public let bytesExpectedToReceive: Int64
    public let task: URLSessionTask?
    
    public init(url: String, statusCode: Int, requestDuration: TimeInterval, bytesExpectedToSend: Int64, bytesExpectedToReceive: Int64, task: URLSessionTask?) {
        self.url = url
        self.statusCode = statusCode
        self.requestDuration = requestDuration
        self.bytesExpectedToSend = bytesExpectedToSend
        self.bytesExpectedToReceive = bytesExpectedToReceive
        self.task = task
    }
}

func logResponse(url: URL?, timeline: Timeline, metrics: AnyObject?, statusCode: Int?, task: URLSessionTask?, error: Error?) {
    let bytesExpectedToSend = task?.countOfBytesExpectedToSend
    let bytesExpectedToReceive = task?.countOfBytesExpectedToReceive
    DispatchQueue.global(qos: .background).async {
        if let urlString = url?.absoluteString {
            if let error = error {
                if (error as NSError).code == URLError.cancelled.rawValue {
                    return
                }
                if let metrics = metrics {
                    meshLogger.log(info: urlString + " timeline: \(timeline) \n metrics: \(metrics) error: \(error)")
                } else {
                    meshLogger.log(info: urlString + " timeline: \(timeline) \n error: \(error)")
                }
            } else if statusCode != 200 {
                meshLogger.log(info: urlString + " timeline: \(timeline) \n statusCode: \(statusCode ?? 0) \(task?.response?.description ?? "")")
            }
            let metric = HttpMetric(
                url: urlString,
                statusCode: statusCode ?? 0,
                requestDuration: timeline.requestDuration,
                bytesExpectedToSend: bytesExpectedToSend ?? 0,
                bytesExpectedToReceive: bytesExpectedToReceive ?? 0,
                task: task
            )
            NotificationCenter.default.post(
                name: Notification.Name.Mesh.HttpRequestMetric,
                object: nil,
                userInfo: [MeshHttpMetric: metric]
            )
        }
    }
}

// MARK: - Convenience for Objective-c
@objc public class MeshObjcBridge: NSObject {
    @objc public class func downloadImage(url: URL, progress: @escaping DownloadProgressBlock, completionHandler: @escaping CompletionHandler) -> RetrieveImageTask {
        return KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: progress, completionHandler: completionHandler)
    }
}

public extension Notification.Name {
    public struct Mesh {
        public static let HttpRequestMetric = Notification.Name(rawValue: MeshHttpMetricNotificationName)
    }
}

public extension UIImage {
    @objc public class func gifImage(from data: Data) -> UIImage? {
        return Kingfisher<Image>.image(data: data, scale: 1, preloadAllAnimationData: false, onlyFirstFrame: false)
    }
}
