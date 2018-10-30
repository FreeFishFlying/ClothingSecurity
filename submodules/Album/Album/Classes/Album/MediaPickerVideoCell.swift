//
//  MediaPickerVideoCell.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 2017/4/8.
//  Copyright © 2017年 kingxt. All rights reserved.
//

import Foundation
import Darwin
import UIKit
import Core

let MediaPickerVideoCellKind = "MediaPickerVideoCellKind"

class MediaPickerVideoCell: MediaPickerCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(shadowView)
        contentView.addSubview(iconView)
        contentView.addSubview(durationLabel)
        shadowView.snp.makeConstraints { make in
            make.bottom.left.right.equalTo(self.contentView)
            make.height.equalTo(20)
        }
        iconView.snp.makeConstraints { make in
            make.left.bottom.equalTo(self)
            make.width.height.equalTo(19)
        }
        durationLabel.snp.makeConstraints { make in
            make.top.bottom.equalTo(self.shadowView)
            make.right.equalTo(self.shadowView).offset(-5)
            make.left.equalTo(self.iconView)
        }
    }

    override func fillData(asset: MediaAsset?) {
        super.fillData(asset: asset)
        if let asset = asset {
            durationLabel.text = formatTimeInterval(asset.videoDuration())

            if asset.subtypes() == .videoTimelapse {
                iconView.image = ImageNamed("ModernMediaItemTimelapseIcon")
            } else if asset.subtypes() == .videoHighFrameRate {
                iconView.image = ImageNamed("ModernMediaItemSloMoIcon")
            } else {
                iconView.image = ImageNamed("ModernMediaItemVideoIcon")
            }
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
        shadowView.image = MediaPickerVideoCell.shadowImage
        return shadowView
    }()

    private lazy var iconView: UIImageView = {
        let iconView = UIImageView()
        iconView.contentMode = .center
        return iconView
    }()

    private lazy var durationLabel: UILabel = {
        let durationLabel = UILabel()
        durationLabel.textColor = UIColor.white
        durationLabel.backgroundColor = UIColor.clear
        durationLabel.textAlignment = .right
        durationLabel.font = UIFont.systemFont(ofSize: 12)
        return durationLabel
    }()
}
