//
//  SignalImageView.swift
//  Components-Swift
//
//  Created by kingxt on 5/4/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import Result

private var disposableKey: Void?

public extension UIImageView {

    public func setSignal(_ signal: SignalProducer<UIImage?, AnyError>) {
        reset()
        let maybeIndicator = kf.indicator
        maybeIndicator?.startAnimatingView()
        let disposable = signal.observe(on: UIScheduler()).startWithResult { [weak self] result in
            if let strongSelf = self {
                if let value = result.value {
                    strongSelf.image = value
                }
            }
            maybeIndicator?.stopAnimatingView()
        }
        setDisposable(disposable)
    }

    public func setSignal(_ signal: SignalProducer<UIImage?, NoError>) {
        setSignal(signal.mapError { AnyError($0) })
    }

    public func setSignal(_ signal: SignalProducer<UIImage?, NSError>) {
        setSignal(signal.mapError { AnyError($0) })
    }

    public func reset() {
        image = nil
        disposable?.dispose()
        let maybeIndicator = kf.indicator
        maybeIndicator?.stopAnimatingView()
    }

    private var disposable: Disposable? {
        return objc_getAssociatedObject(self, &disposableKey) as? Disposable
    }

    private func setDisposable(_ disposable: Disposable?) {
        objc_setAssociatedObject(self, &disposableKey, disposable, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
