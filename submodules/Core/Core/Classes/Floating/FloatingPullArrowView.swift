//
//  FloatingPullArrowView.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 2017/2/27.
//  Copyright © 2017 kingxt. All rights reserved.
//

import UIKit

class FloatingPullArrowView: UIView {

    private lazy var image: UIImage? = {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 8, height: 23), false, 0.0)
        var context: CGContext? = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.black.cgColor)
        UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 8, height: 23), cornerRadius: 4.5).fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }()

    private lazy var topPart: UIImageView = {
        let topPart = UIImageView(frame: CGRect(x: 0, y: 0, width: 8, height: 38))
        topPart.contentMode = .bottom
        topPart.image = self.image
        return topPart
    }()

    private lazy var bottomPart: UIImageView = {
        let bottomPart = UIImageView(frame: CGRect(x: 0, y: 0, width: 8, height: 38))
        bottomPart.contentMode = .top
        bottomPart.image = self.image
        bottomPart.transform = CGAffineTransform(scaleX: 1, y: -1)
        return bottomPart
    }()

    func setAngled(_ angled: Bool, animated: Bool) {
        let changeBlock: () -> Void = { () -> Void in
            let angle: CGFloat = angled ? 0.20944 : 0.0
            self.topPart.transform = CGAffineTransform(rotationAngle: angle)
            self.bottomPart.transform = CGAffineTransform(rotationAngle: -angle)
        }
        if animated {
            UIView.animate(withDuration: 0.25, animations: changeBlock)
        } else {
            changeBlock()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.rasterizationScale = 2
        layer.shouldRasterize = true
        layer.allowsEdgeAntialiasing = true
        addSubview(topPart)
        addSubview(bottomPart)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
