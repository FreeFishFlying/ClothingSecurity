//
//  FloatingWindow.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 2017/3/1.
//  Copyright © 2017 kingxt. All rights reserved.
//

import UIKit

class FloatingWindow: OverlayControllerWindow {

    override init(contentController: OverlayViewController) {
        super.init(contentController: contentController)
        backgroundColor = UIColor.clear
        windowLevel = UIWindow.Level(rawValue: 100_000_000.0 + 0.001)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let localPoint: CGPoint? = rootViewController?.view?.convert(point, from: self)
        if let localPoint = localPoint {
            let result: UIView? = rootViewController?.view?.hitTest(localPoint, with: event)
            if result == rootViewController?.view {
                return nil
            }
            return result
        }
        return nil
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
