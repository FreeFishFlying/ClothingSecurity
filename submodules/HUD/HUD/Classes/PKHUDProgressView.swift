//
//  PKHUDProgressVIew.swift
//  PKHUD
//
//  Created by Philip Kluz on 6/12/15.
//  Copyright (c) 2016 NSExceptional. All rights reserved.
//  Licensed under the MIT license.
//

import UIKit
import QuartzCore

/// PKHUDProgressView provides an indeterminate progress view.
open class PKHUDProgressView: PKHUDSquareBaseView, PKHUDAnimating {

    public init(title: String? = nil, subtitle: String? = nil) {
        super.init(title: title, subtitle: subtitle)
        layer.addSublayer(shapeLayer)
        frame = CGRect(origin: CGPoint.zero, size: CGSize(width: max(frame.size.width, 150), height: frame.size.height + 114))
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.position = CGPoint(x: frame.size.width / 2, y: ((titleLabel.text ?? "").count > 0 ? titleLabel.frame.maxY : 0) + shapeLayer.frame.size.height / 2 + padding)
        maskCircleLayer.frame = shapeLayer.bounds
    }

    public let maskCircleLayer: CALayer = {
        let maskLayer = CALayer()
        maskLayer.contents = ImageNamed("AngleMask")?.cgImage
        return maskLayer
    }()

    public lazy var shapeLayer: CAShapeLayer = {
        let strokeThickness: CGFloat = 4
        let radius: CGFloat = 30
        let strokeColor: UIColor = UIColor.white

        var arcCenter = CGPoint(x: radius + strokeThickness / 2 + 5, y: radius + strokeThickness / 2 + 5)
        var smoothedPath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: CGFloat(CGFloat.pi * 3 / 2), endAngle: CGFloat(CGFloat.pi / 2 + CGFloat.pi * 5), clockwise: true)

        let indefiniteAnimatedLayer = CAShapeLayer()
        indefiniteAnimatedLayer.contentsScale = UIScreen.main.scale
        indefiniteAnimatedLayer.frame = CGRect(x: 0.0, y: 0.0, width: arcCenter.x * 2, height: arcCenter.y * 2)
        indefiniteAnimatedLayer.fillColor = UIColor.clear.cgColor
        indefiniteAnimatedLayer.strokeColor = strokeColor.cgColor
        indefiniteAnimatedLayer.lineWidth = strokeThickness
        indefiniteAnimatedLayer.lineCap = CAShapeLayerLineCap.round
        indefiniteAnimatedLayer.lineJoin = CAShapeLayerLineJoin.bevel
        indefiniteAnimatedLayer.path = smoothedPath.cgPath
        indefiniteAnimatedLayer.mask = self.maskCircleLayer

        return indefiniteAnimatedLayer
    }()

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public func startAnimation() {
        let animationDuration: TimeInterval = 1
        let linearCurve = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)

        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = (CGFloat.pi * 2)
        animation.duration = animationDuration
        animation.timingFunction = linearCurve
        animation.isRemovedOnCompletion = false
        animation.repeatCount = .infinity
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.autoreverses = false
        shapeLayer.mask?.add(animation, forKey: "rotate")

        let animationGroup = CAAnimationGroup()
        animationGroup.duration = animationDuration
        animationGroup.repeatCount = .infinity
        animationGroup.isRemovedOnCompletion = false
        animationGroup.timingFunction = linearCurve
        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.fromValue = 0.015
        strokeStartAnimation.toValue = 0.515
        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.fromValue = 0.485
        strokeEndAnimation.toValue = 0.985
        animationGroup.animations = [strokeStartAnimation, strokeEndAnimation]
        shapeLayer.add(animationGroup, forKey: "progress")
    }

    public func stopAnimation() {
        shapeLayer.removeAllAnimations()
    }
}
