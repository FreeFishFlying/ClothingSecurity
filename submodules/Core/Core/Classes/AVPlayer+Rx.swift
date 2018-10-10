//
//  AVPlayer+Rx.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 2017/4/14.
//  Copyright © 2017年 kingxt. All rights reserved.
//

import Foundation
import AVFoundation
import ReactiveSwift
import Result

public extension Reactive where Base: AVPlayer {

    public func periodicTimeObserver(interval: CMTime) -> SignalProducer<CMTime, NoError> {
        return SignalProducer<CMTime, NoError> { observer, lifetime in
            let token = self.base.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (time: CMTime) in
                observer.send(value: time)
            })
            lifetime.observeEnded {
                self.base.removeTimeObserver(token)
            }
        }
    }

    public func playFinishedObserver() -> SignalProducer<Void, NoError> {
        return SignalProducer<Void, NoError> { observer, lifetime in
            if CMTimeGetSeconds(self.base.currentTime()) > 0 {
                let disposable = self.boundaryTimeObserver(times: [self.base.currentItem!.duration]).startWithValues({ _ in
                    observer.send(value: ())
                    observer.sendCompleted()
                })
                lifetime += disposable
            } else {
                let disposable = self.boundaryTimeObserver(times: [CMTimeMake(value: 10, timescale: 100)]).take(first: 1).startWithValues { _ in
                    let disposable2 = self.boundaryTimeObserver(times: [self.base.currentItem!.duration]).startWithValues({ _ in
                        observer.send(value: ())
                        observer.sendCompleted()
                    })
                    lifetime += disposable2
                }
                lifetime += disposable
            }
        }
    }

    public func boundaryTimeObserver(times: [CMTime]) -> SignalProducer<Void, NoError> {
        return SignalProducer<Void, NoError> { observer, lifetime in
            let timeValues = times.map() { NSValue(time: $0) }
            let token = self.base.addBoundaryTimeObserver(forTimes: timeValues, queue: DispatchQueue.main) {
                observer.send(value: ())
            }
            lifetime.observeEnded {
                self.base.removeTimeObserver(token)
            }
        }
    }
}
