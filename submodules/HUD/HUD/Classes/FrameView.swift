//
//  HUDView.swift
//  PKHUD
//
//  Created by Philip Kluz on 6/16/14.
//  Copyright (c) 2016 NSExceptional. All rights reserved.
//  Licensed under the MIT license.
//

import UIKit

/// Provides the general look and feel of the PKHUD, into which the eventual content is inserted.
internal class FrameView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    fileprivate func commonInit() {
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        layer.cornerRadius = 4.0
        layer.masksToBounds = true

        addSubview(self.content)

        let offset = 20.0

        let motionEffectsX = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        motionEffectsX.maximumRelativeValue = offset
        motionEffectsX.minimumRelativeValue = -offset

        let motionEffectsY = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        motionEffectsY.maximumRelativeValue = offset
        motionEffectsY.minimumRelativeValue = -offset

        let group = UIMotionEffectGroup()
        group.motionEffects = [motionEffectsX, motionEffectsY]

        addMotionEffect(group)
    }

    fileprivate var _content = UIView()
    internal var content: UIView {
        get {
            return _content
        }
        set {
            _content.removeFromSuperview()
            _content = newValue
            _content.alpha = 0.85
            _content.clipsToBounds = true
            _content.contentMode = .center
            frame.size = _content.bounds.size
            addSubview(_content)
        }
    }
}
