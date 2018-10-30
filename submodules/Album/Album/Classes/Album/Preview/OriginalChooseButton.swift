//
//  OriginalChooseButton.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 4/12/17.
//  Copyright © 2017 kingxt. All rights reserved.
//

import Foundation
import UIKit
import Core

class OriginalChooseButton: UIButton {

    private let insideInset: CGFloat = 4
    private let fillColor: UIColor
    private let borderColor: UIColor
    private let circleSize: CGSize = CGSize(width: 16, height: 16)

    init(frame: CGRect, borderColor: UIColor = .white, fillColor: UIColor = UIColorRGB(0x29C519)) {
        self.fillColor = fillColor
        self.borderColor = borderColor
        super.init(frame: frame)
        addSubview(checkBackground)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var checkBackground: UIView = {
        let checkBackground = UIView()
        checkBackground.layer.borderWidth = 1.5
        checkBackground.layer.borderColor = self.borderColor.cgColor
        checkBackground.layer.masksToBounds = true
        checkBackground.layer.cornerRadius = 8
        checkBackground.isUserInteractionEnabled = false
        return checkBackground
    }()

    private lazy var checkFillView: UIImageView = {
        let fillView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: self.circleSize))
        fillView.alpha = 0.0
        fillView.isUserInteractionEnabled = false
        fillView.image = self.fillImage
        fillView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        return fillView
    }()

    private lazy var fillImage: UIImage? = {
        var rect = CGRect(origin: CGPoint.zero, size: self.circleSize)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        var context: CGContext? = UIGraphicsGetCurrentContext()
        context?.setFillColor(self.fillColor.cgColor)
        context?.fillEllipse(in: rect.insetBy(dx: CGFloat(self.insideInset), dy: CGFloat(self.insideInset)))
        let fillImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return fillImage
    }()

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + 20, height: size.height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        checkBackground.frame = CGRect(origin: CGPoint(x: 0, y: (frame.size.height - circleSize.height) / 2), size: circleSize)
        checkFillView.center = checkBackground.center
    }

    override var isSelected: Bool {
        willSet {
            super.isSelected = newValue
        }

        didSet {
            if isSelected && checkFillView.superview == nil {
                addSubview(checkFillView)
                checkFillView.center = checkBackground.center
            }
            UIView.animate(withDuration: 0.19, animations: { () -> Void in
                self.checkFillView.alpha = self.isSelected ? 1.0 : 0.0
                self.checkFillView.transform = self.isSelected ? CGAffineTransform.identity : CGAffineTransform(scaleX: 0.01, y: 0.01)
            })
        }
    }
}
