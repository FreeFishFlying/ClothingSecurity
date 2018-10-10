//
//  PKHUDErrorAnimation.swift
//  PKHUD
//
//  Created by Philip Kluz on 9/27/15.
//  Copyright (c) 2016 NSExceptional. All rights reserved.
//  Licensed under the MIT license.
//

import UIKit

/// PKHUDErrorView provides an animated error (cross) view.
open class PKHUDErrorView: PKHUDSquareBaseView, PKHUDAnimating {

    var dashOneLayer = PKHUDErrorView.generateDashLayer()
    var dashTwoLayer = PKHUDErrorView.generateDashLayer()

    class func generateDashLayer() -> CAShapeLayer {
        let dash = CAShapeLayer()
        dash.frame = CGRect(x: 0.0, y: 0.0, width: 70.0, height: 70.0)
        dash.path = {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0.0, y: 35.0))
            path.addLine(to: CGPoint(x: 70.0, y: 35.0))
            return path.cgPath
        }()
        dash.lineCap = CAShapeLayerLineCap.round
        dash.lineJoin = CAShapeLayerLineJoin.round
        dash.fillColor = nil
        dash.strokeColor = UIColor.white.cgColor
        dash.lineWidth = 6
        dash.fillMode = CAMediaTimingFillMode.forwards
        return dash
    }

    public init(title: String? = nil, subtitle: String? = nil) {
        super.init(title: title, subtitle: subtitle)
        layer.addSublayer(dashOneLayer)
        layer.addSublayer(dashTwoLayer)
        dashOneLayer.position = layer.position
        dashTwoLayer.position = layer.position

        frame = CGRect(origin: CGPoint.zero, size: CGSize(width: frame.size.width, height: frame.size.height + 120))
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        dashOneLayer.position = CGPoint(x: frame.size.width / 2, y: ((titleLabel.text ?? "").count > 0 ? titleLabel.frame.maxY : 0) + dashOneLayer.frame.size.height / 2 + padding / 2)
        dashTwoLayer.position = dashOneLayer.position
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.addSublayer(dashOneLayer)
        layer.addSublayer(dashTwoLayer)
        dashOneLayer.position = layer.position
        dashTwoLayer.position = layer.position
    }

    func rotationAnimation(_ angle: CGFloat) -> CABasicAnimation {
        var animation: CABasicAnimation
        if #available(iOS 9.0, *) {
            let springAnimation = CASpringAnimation(keyPath: "transform.rotation.z")
            springAnimation.damping = 1.5
            springAnimation.mass = 0.22
            springAnimation.initialVelocity = 0.5
            animation = springAnimation
        } else {
            animation = CABasicAnimation(keyPath: "transform.rotation.z")
        }

        animation.fromValue = 0.0
        animation.toValue = angle * CGFloat(.pi / 180.0)
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        return animation
    }

    public func startAnimation() {
        let dashOneAnimation = rotationAnimation(-45.0)
        let dashTwoAnimation = rotationAnimation(45.0)

        dashOneLayer.transform = CATransform3DMakeRotation(-45 * CGFloat(.pi / 180.0), 0.0, 0.0, 1.0)
        dashTwoLayer.transform = CATransform3DMakeRotation(45 * CGFloat(.pi / 180.0), 0.0, 0.0, 1.0)

        dashOneLayer.add(dashOneAnimation, forKey: "dashOneAnimation")
        dashTwoLayer.add(dashTwoAnimation, forKey: "dashTwoAnimation")
    }

    public func stopAnimation() {
        dashOneLayer.removeAnimation(forKey: "dashOneAnimation")
        dashTwoLayer.removeAnimation(forKey: "dashTwoAnimation")
    }
}
