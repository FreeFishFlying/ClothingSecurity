//
//  MeshUploaderResponseCache.swift
//  Mesh
//
//  Created by kingxt on 8/16/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation

class MeshUploaderResponseCache {

    public static let shared = MeshUploaderResponseCache()

    let barrierQueue = DispatchQueue(label: "com.xhb.MeshUploaderResponseCache.Barrier", attributes: .concurrent)

    private let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.path + "/meshcache/"

    init() {
        if !FileManager.default.fileExists(atPath: cacheDirectory) {
            try? FileManager.default.createDirectory(atPath: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }

    private var responseCache: [String: Data] = [:]

    func clear() {
        barrierQueue.sync(flags: .barrier) {
            responseCache.removeAll()
        }
        try? FileManager.default.removeItem(atPath: cacheDirectory)
        try? FileManager.default.createDirectory(atPath: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
    }

    func cacheResponse(id: String, responseData: Data) {
        barrierQueue.sync(flags: .barrier) {
            responseCache[id] = responseData
        }
        try? responseData.write(to: URL(fileURLWithPath: cacheDirectory + id))
    }

    func cachedResponse(id: String) -> Data? {
        var result: Data?
        barrierQueue.sync(flags: .barrier) {
            result = responseCache[id]
        }
        if result == nil {
            if FileManager.default.fileExists(atPath: cacheDirectory + id) {
                if let data = try? Data(contentsOf: URL(fileURLWithPath: cacheDirectory + id)) {
                    barrierQueue.sync(flags: .barrier) {
                        responseCache[id] = data
                    }
                    result = data
                }
            }
        }
        return result
    }

    func feedbackInvalid(id: String) {
        _ = barrierQueue.sync(flags: .barrier) {
            responseCache.removeValue(forKey: id)
        }
        try? FileManager.default.removeItem(atPath: cacheDirectory + id)
    }
}
