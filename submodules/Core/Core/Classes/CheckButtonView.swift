//
//  CheckButtonView.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 2017/4/8.
//  Copyright © 2017年 kingxt. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift

public class CheckButtonView: UIButton {

    private let buttonSize: CGSize
    private let insideInset: CGFloat = 4
    private var hasCreateCheckMark = false
    
    public var fillColor: UIColor = UIColorRGB(0x29C519)
    public var onCheckColor: UIColor = UIColor.white

    public init(buttonSize: CGSize = CGSize(width: 32.0, height: 32.0)) {
        self.buttonSize = buttonSize
        super.init(frame: CGRect(x: 0, y: 0, width: self.buttonSize.width, height: self.buttonSize.height))
        addSubview(wrapperView)
        wrapperView.layer.addSublayer(checkBackground)
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var wrapperView: UIView = {
        let view: UIView = UIView(frame: self.bounds)
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var checkBackground: CALayer = {
        let checkBackground = CALayer()
        checkBackground.contents = self.backgroundImage?.cgImage
        checkBackground.frame = CGRect(x: 0, y: 0, width: self.buttonSize.width, height: self.buttonSize.height)
        return checkBackground
    }()

    private lazy var checkFillView: UIImageView = {
        let fillView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.buttonSize.width, height: self.buttonSize.height))
        fillView.alpha = 0.0
        fillView.image = self.fillImage
        fillView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        return fillView
    }()

    private lazy var checkView: UIView = {
        let checkView = UIView(frame: self.bounds.insetBy(dx: 4, dy: 4))
        checkView.alpha = 0.0
        checkView.isUserInteractionEnabled = false
        return checkView
    }()

    private lazy var backgroundImage: UIImage? = {
        var rect = CGRect(x: 0, y: 0, width: self.buttonSize.width, height: self.buttonSize.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        var context: CGContext? = UIGraphicsGetCurrentContext()
        context?.setShadow(offset: CGSize.zero, blur: 2.5, color: UIColor(white: CGFloat(0.0), alpha: CGFloat(0.22)).cgColor)
        context?.setLineWidth(CGFloat(1.5))
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.strokeEllipse(in: rect.insetBy(dx: CGFloat(self.insideInset + 0.5), dy: CGFloat(self.insideInset + 0.5)))
        let backgroundImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return backgroundImage
    }()

    private lazy var fillImage: UIImage? = {
        var rect = CGRect(x: 0, y: 0, width: self.buttonSize.width, height: self.buttonSize.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        var context: CGContext? = UIGraphicsGetCurrentContext()
        context?.setFillColor(self.fillColor.cgColor)
        context?.fillEllipse(in: rect.insetBy(dx: CGFloat(self.insideInset), dy: CGFloat(self.insideInset)))
        let fillImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return fillImage
    }()

    private func pathForCheckMark() -> UIBezierPath {
        let checkMarkPath = UIBezierPath()
        let size = buttonSize.width
        checkMarkPath.move(to: CGPoint(x: CGFloat(size / 3.16), y: CGFloat(size / 1.9)))
        checkMarkPath.addLine(to: CGPoint(x: CGFloat(size / 2.3), y: CGFloat(size / 1.55)))
        checkMarkPath.addLine(to: CGPoint(x: CGFloat(size / 1.46), y: CGFloat(size / 2.7)))
        return checkMarkPath
    }

    private lazy var checkMarkLayer: CAShapeLayer = {
        let checkMarkLayer = CAShapeLayer()
        checkMarkLayer.frame = CGRect(x: -4, y: -4, width: self.bounds.size.width, height: self.bounds.size.height)
        checkMarkLayer.path = self.pathForCheckMark().cgPath
        checkMarkLayer.strokeColor = self.onCheckColor.cgColor
        checkMarkLayer.lineWidth = 1.5
        checkMarkLayer.fillColor = UIColor.clear.cgColor
        checkMarkLayer.lineCap = CAShapeLayerLineCap.round
        checkMarkLayer.lineJoin = CAShapeLayerLineJoin.round
        checkMarkLayer.rasterizationScale = CGFloat(2.0 * UIScreen.main.scale)
        checkMarkLayer.shouldRasterize = true
        return checkMarkLayer
    }()

    private func createCheckButtonDetailsIfNeeded() {
        if !hasCreateCheckMark {
            hasCreateCheckMark = true
            checkBackground.removeFromSuperlayer()
            wrapperView.addSubview(checkFillView)
            wrapperView.addSubview(checkView)
            checkView.layer.addSublayer(checkMarkLayer)
            wrapperView.layer.addSublayer(checkBackground)
        }
    }

    public func setChecked(_ checked: Bool, animated: Bool) {
        if checked {
            createCheckButtonDetailsIfNeeded()
        }

        if animated {
            if isSelected == checked {
                return
            }
            if checked {
                checkFillView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            } else {
                checkFillView.transform = .identity
            }
            UIView.animate(withDuration: 0.19, animations: { () -> Void in
                self.checkFillView.alpha = checked ? 1.0 : 0.0
                self.checkFillView.transform = checked ? CGAffineTransform.identity : CGAffineTransform(scaleX: 0.01, y: 0.01)
            })
            if checked {
                let duration: TimeInterval = 0.4
                let damping: CGFloat = 0.35
                let initialVelocity: CGFloat = 0.8
                UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: damping, initialSpringVelocity: initialVelocity, options: .beginFromCurrentState, animations: { () -> Void in
                    self.wrapperView.transform = CGAffineTransform.identity
                    self.checkView.alpha = 1.0
                }, completion: { _ in })
            } else {
                let duration: TimeInterval = 0.17
                UIView.animate(withDuration: duration, animations: { () -> Void in
                    self.checkView.alpha = 0.0
                }, completion: { (_: Bool) -> Void in
                })
            }
        } else {
            checkFillView.alpha = checked ? 1 : 0
            checkFillView.transform = checked ? .identity : CGAffineTransform(scaleX: 0.1, y: 0.1)
            checkView.alpha = checked ? 1 : 0
        }
        super.isSelected = checked
    }
}
