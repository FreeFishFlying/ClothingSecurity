//
//  PKHUDCheckmarkView.swift
//  PKHUD
//
//  Created by Philip Kluz on 9/27/15.
//  Copyright (c) 2016 NSExceptional. All rights reserved.
//  Licensed under the MIT license.
//

import UIKit

/// PKHUDCheckmarkView provides an animated success (checkmark) view.
open class PKHUDSuccessView: PKHUDSquareBaseView, PKHUDAnimating {

    var checkmarkShapeLayer: CAShapeLayer = {
        let checkmarkPath = UIBezierPath()
        checkmarkPath.move(to: CGPoint(x: 7.0, y: 35.0))
        checkmarkPath.addLine(to: CGPoint(x: 34.0, y: 58.0))
        checkmarkPath.addLine(to: CGPoint(x: 79.0, y: 8.0))

        let layer = CAShapeLayer()
        layer.frame = CGRect(x: 3.0, y: 3.0, width: 88.0, height: 56.0)
        layer.path = checkmarkPath.cgPath
        layer.fillMode = CAMediaTimingFillMode.forwards
        layer.lineCap = CAShapeLayerLineCap.round
        layer.lineJoin = CAShapeLayerLineJoin.round
        layer.fillColor = nil
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 6.0
        return layer
    }()

    public init(title: String? = nil, subtitle: String? = nil) {
        super.init(title: title, subtitle: subtitle)
        layer.addSublayer(checkmarkShapeLayer)
        frame = CGRect(origin: CGPoint.zero, size: CGSize(width: frame.size.width, height: frame.size.height + 90))
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        checkmarkShapeLayer.position = CGPoint(x: frame.size.width / 2, y: ((titleLabel.text ?? "").count > 0 ? titleLabel.frame.maxY : 0) + checkmarkShapeLayer.frame.size.height / 2 + padding / 2)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.addSublayer(checkmarkShapeLayer)
        checkmarkShapeLayer.position = layer.position
    }

    open func startAnimation() {
        let checkmarkStrokeAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
        checkmarkStrokeAnimation.values = [0, 1]
        checkmarkStrokeAnimation.keyTimes = [0, 1]
        checkmarkStrokeAnimation.duration = 0.35

        checkmarkShapeLayer.add(checkmarkStrokeAnimation, forKey: "checkmarkStrokeAnim")
    }

    open func stopAnimation() {
        checkmarkShapeLayer.removeAnimation(forKey: "checkmarkStrokeAnimation")
    }
}
