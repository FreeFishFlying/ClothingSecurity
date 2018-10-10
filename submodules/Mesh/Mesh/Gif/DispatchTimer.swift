//
//  Timer.swift
//  Components
//
//  Created by kingxt on 7/27/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation

public class DispatchTimer {
    
    private let timeout: DispatchTimeInterval
    private let queue: DispatchQueue
    private let isRepeat: Bool
    
    public init(timeout: DispatchTimeInterval, isRepeat: Bool, queue: DispatchQueue) {
        self.timeout = timeout
        self.queue = queue
        self.isRepeat = isRepeat
    }
    
    private var timer: DispatchSourceTimer?
    
    public func start(handler: @escaping () -> Void) {
        timer = DispatchSource.makeTimerSource(queue: queue)
        if !isRepeat {
            timer?.schedule(deadline: DispatchTime.now() + timeout)
        } else {
            timer?.schedule(deadline: DispatchTime.now() + timeout, repeating: timeout)
        }
        timer?.setEventHandler {
            handler()
        }
        timer?.resume()
    }
    
    public func stop() {
        if let time = self.timer {
            time.cancel()
            timer = nil
        }
    }
}
