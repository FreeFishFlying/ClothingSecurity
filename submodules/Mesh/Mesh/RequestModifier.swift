//
//  RequestModifier.swift
//  Mesh
//
//  Created by kingxt on 6/16/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation

/// Request modifier of image downloader.
public protocol RequestModifier {
    
    /// Modify the request and perform change 
    ///
    /// - Parameters:
    ///   - request: request
    ///   - tryStep: tryStep try request step
    /// - Returns: return next fire request time interval from now
    func modified(for request: URLRequest, tryStep: Int) -> (URLRequest, TimeInterval)?
}

struct NoModifier: RequestModifier {
    static let `default` = NoModifier()
    private init() {}
    func modified(for request: URLRequest, tryStep: Int) -> (URLRequest, TimeInterval)? {
        return (request, 0)
    }
}

public struct RequestIntervalModifier: RequestModifier {
    static let `default` = RequestIntervalModifier(interval: 3)
    private let interval: TimeInterval
    public func modified(for request: URLRequest, tryStep: Int) -> (URLRequest, TimeInterval)? {
        return (request, interval)
    }
    
    public init(interval: TimeInterval) {
        self.interval = interval
    }
}

public struct AnyModifier: RequestModifier {
    
    let block: (URLRequest) -> (URLRequest, TimeInterval)?
    
    public func modified(for request: URLRequest, tryStep: Int) -> (URLRequest, TimeInterval)? {
        return block(request)
    }
    
    public init(modify: @escaping (URLRequest) -> (URLRequest, TimeInterval)? ) {
        block = modify
    }
}
