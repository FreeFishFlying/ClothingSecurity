//
//  MediaPickerGifCell.swift
//  Components-Swift
//
//  Created by kingxt on 6/6/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import UIKit
import Core

let MediaPickerGifCellKind = "MediaPickerGifCellKind"

class MediaPickerGifCell: MediaPickerCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(shadowView)
        shadowView.addSubview(typeLabel)

        shadowView.snp.makeConstraints { make in
            make.bottom.left.right.equalTo(self.contentView)
            make.height.equalTo(20)
        }
        typeLabel.snp.makeConstraints { make in
            make.left.equalTo(self).offset(5)
            make.centerY.equalTo(shadowView)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static var shadowImage: UIImage? = {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: CGFloat(1.0), height: CGFloat(20.0)), false, 0.0)
        var context: CGContext? = UIGraphicsGetCurrentContext()
        var colors = [UIColorRGBA(0x000000, 0.0).cgColor, UIColorRGBA(0x000000, 0.8).cgColor] as CFArray
        var locations: [CGFloat] = [0.0, 1.0]
        var colorSpace: CGColorSpace? = CGColorSpaceCreateDeviceRGB()
        var gradient: CGGradient? = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations)
        if let gradient = gradient {
            context?.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: 20), options: [])
        } else {
            return nil
        }
        let shadowImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return shadowImage
    }()

    private lazy var shadowView: UIImageView = {
        let shadowView = UIImageView()
        shadowView.image = MediaPickerGifCell.shadowImage
        return shadowView
    }()

    private lazy var typeLabel: UILabel = {
        let typeLabel = UILabel()
        typeLabel.textColor = UIColor.white
        typeLabel.backgroundColor = UIColor.clear
        typeLabel.textAlignment = .left
        typeLabel.font = UIFont.systemFont(ofSize: 12)
        typeLabel.text = "GIF"
        return typeLabel
    }()
}
