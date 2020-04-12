//
//  FileVisitSource.swift
//  Components
//
//  Created by kingxt on 2017/7/22.
//  Copyright © 2017年 liao. All rights reserved.
//

import Foundation
import Mesh

public enum FileVisitSourceType: Int {
    case unknown
    case imageCache
    case fileCache
    case photos
    case filePath
    case remotePath
    
    public func tag() -> String {
        switch self {
        case .unknown:
            return "unknown"
        case .imageCache:
            return "ic_"
        case .fileCache:
            return "fc_"
        case .photos:
            return "ph_"
        case .filePath:
            return "var"
        case .remotePath:
            return "http"
        }
    }
}

public enum FileVisitSource {
    case imageCache(String)
    case fileCache(String)
    case photos(String)
    case filePath(String)
    case remotePath(String)
    case unknown(String)
    
    public static func from(string: String) -> FileVisitSource {
        if string.length > 3 {
            if string.hasPrefix(FileVisitSourceType.imageCache.tag()) {
                return FileVisitSource.imageCache(string)
            } else if string.hasPrefix(FileVisitSourceType.fileCache.tag()) {
                return FileVisitSource.fileCache(string)
            } else if string.hasPrefix(FileVisitSourceType.photos.tag()) {
                return FileVisitSource.photos(string)
            } else if string.hasPrefix(FileVisitSourceType.filePath.tag()) || string.hasPrefix("/" + FileVisitSourceType.filePath.tag()) {
                return FileVisitSource.filePath(string)
            } else if string.hasPrefix(FileVisitSourceType.remotePath.tag()) {
                return FileVisitSource.remotePath(string)
            }
        }
        return FileVisitSource.unknown(string)
    }
    
    public func type() -> FileVisitSourceType {
        let string = value()
        if string.length > 3 {
            if string.hasPrefix(FileVisitSourceType.imageCache.tag()) {
                return .imageCache
            } else if string.hasPrefix(FileVisitSourceType.fileCache.tag()) {
                return .fileCache
            } else if string.hasPrefix(FileVisitSourceType.photos.tag()) {
                return .photos
            } else if string.hasPrefix(FileVisitSourceType.filePath.tag()) {
                return .filePath
            } else if string.hasPrefix(FileVisitSourceType.remotePath.tag()) {
                return .remotePath
            }
        }
        return .unknown
    }
    
    public func tag() -> String {
        switch self {
        case .imageCache(_):
            return FileVisitSourceType.imageCache.tag()
        case .fileCache(_):
            return FileVisitSourceType.fileCache.tag()
        case .photos(_):
            return FileVisitSourceType.photos.tag()
        case .filePath(_):
            return FileVisitSourceType.filePath.tag()
        case .remotePath(_):
            return FileVisitSourceType.remotePath.tag()
        case .unknown(_):
            return FileVisitSourceType.unknown.tag()
        }
    }
    
    public func value() -> String {
        switch self {
        case .imageCache(let key):
            return key
        case .fileCache(let key):
            return key
        case .photos(let key):
            return key
        case .filePath(let key):
            return key
        case .remotePath(let key):
            return key
        case .unknown(let key):
            return key
        }
    }
    
    public func trueValue() -> String {
        switch self {
        case .imageCache(let key), .fileCache(let key), .photos(let key):
            if tag().length <= key.count {
                let index = key.index(key.startIndex, offsetBy: tag().length)
                let subString = key[index...]
                return String(subString)
            }
            return String(key)
        case .filePath(let key), .remotePath(let key), .unknown(let key):
            return key
        }
    }
    
    public static func random(type: FileVisitSourceType, fileType: String? = nil) -> FileVisitSource {
        var key = type.tag() + UUID().uuidString
        if let fileType = fileType {
            key += "." + fileType
        }
        switch type {
        case .imageCache:
            return FileVisitSource.imageCache(key)
        case .fileCache:
            return FileVisitSource.fileCache(key)
        case .photos:
            return FileVisitSource.photos(key)
        case .filePath:
            return FileVisitSource.filePath(randomTemporaryURL(extension: fileType ?? "bin").path)
        case .remotePath, .unknown:
            fatalError("unsupported random remote path")
        }
    }
}

func <== (lhs: FileVisitSource, rhs: FileVisitSource) -> Bool {
    switch (lhs, rhs) {
    case (.imageCache(_), .imageCache(_)): return true
    case (.fileCache(_), .fileCache(_)): return true
    case (.photos(_), .photos(_)): return true
    case (.filePath(_), .filePath(_)): return true
    case (.remotePath, .remotePath): return true
    default: return false
    }
}
