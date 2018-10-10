//
//  FileCache.swift
//  Components
//
//  Created by 徐涛 on 09/07/2017.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import Result
import ReactiveSwift
import Mesh
import enum Result.Result

public func randomTemporaryURL(extension: String = "tmp") -> URL {
    return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(UUID().uuidString).\(`extension`)")
}

public class FileCache: NSObject {

    public enum FileType: String {
        case audio = "ogg"
        case video = "mp4"
        case gif = "gif"
        case all = "*"
    }

    private class func md5(_ string: String) -> String {
        return string.kf.md5
    }

    private class func cacheDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let path = paths[0].appending("/").appending("ck.files")
        if !FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        return path
    }
    
    public class func randomKey(type: FileType? = nil) -> FileVisitSource {
        if type == nil || type!.rawValue == "*" {
            return FileVisitSource.random(type: .fileCache)
        } else {
            return FileVisitSource.random(type: .fileCache, fileType: type!.rawValue)
        }
    }

    @objc public class func fileLocalURL(remoteURL: URL) -> URL {
        let pathExtension: String = ".\(remoteURL.pathExtension)"
        let fileURLString: String = cacheDirectory().appending("/").appending(md5(remoteURL.absoluteString)).appending(pathExtension)
        return URL(fileURLWithPath: fileURLString)
    }

    @objc public class func fileHasLoaded(url: URL) -> URL? {
        if url.isFileURL {
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
        }
        if FileManager.default.fileExists(atPath: url.path) {
            return url
        }
        let cacheURL: URL = fileLocalURL(remoteURL: url)
        if FileManager.default.fileExists(atPath: cacheURL.path) {
            return cacheURL
        }
        return nil
    }

    @objc public class func clearFileOnDisk() {
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: cacheDirectory(), isDirectory: true))
        _ = cacheDirectory()
    }

    public class func removeCached(type: FileType) {
        let diskCacheURL = URL(fileURLWithPath: cacheDirectory())
        let resourceKeys: Set<URLResourceKey> = [.isDirectoryKey, .contentAccessDateKey, .totalFileAllocatedSizeKey]
        for fileUrl in (try? FileManager.default.contentsOfDirectory(at: diskCacheURL, includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles)) ?? [] {
            do {
                if fileUrl.pathExtension != type.rawValue && type != .all {
                    continue
                }
                let resourceValues = try fileUrl.resourceValues(forKeys: resourceKeys)
                // If it is a Directory. Continue to next file URL.
                if resourceValues.isDirectory == true {
                    continue
                }

                try FileManager.default.removeItem(at: fileUrl)
            } catch _ {}
        }
    }

    public class func travelCachedSize(type: FileType) -> UInt {
        let diskCacheURL = URL(fileURLWithPath: cacheDirectory())
        let resourceKeys: Set<URLResourceKey> = [.isDirectoryKey, .contentAccessDateKey, .totalFileAllocatedSizeKey]
        var diskCacheSize: UInt = 0

        for fileUrl in (try? FileManager.default.contentsOfDirectory(at: diskCacheURL, includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles)) ?? [] {
            do {
                if fileUrl.pathExtension != type.rawValue && type != .all {
                    continue
                }
                let resourceValues = try fileUrl.resourceValues(forKeys: resourceKeys)
                // If it is a Directory. Continue to next file URL.
                if resourceValues.isDirectory == true {
                    continue
                }

                if let fileSize = resourceValues.totalFileAllocatedSize {
                    diskCacheSize += UInt(fileSize)
                }
            } catch _ {}
        }

        return diskCacheSize
    }
}
