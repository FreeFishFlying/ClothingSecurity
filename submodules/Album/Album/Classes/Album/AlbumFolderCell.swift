//
//  AlbumFolderCel.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 2017/4/4.
//  Copyright © 2017年 kingxt. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Photos
import Core

class AlbumFolderCell: UITableViewCell {

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(96)
            make.top.equalTo(24)
            make.right.equalTo(-10)
        }

        for imageView in imageViews {
            contentView.addSubview(imageView)
        }
        imageViews[0].snp.makeConstraints { make in
            make.left.equalTo(12)
            make.top.equalTo(7)
            make.width.height.equalTo(61)
        }
        imageViews[1].snp.makeConstraints { make in
            make.left.equalTo(10)
            make.top.equalTo(9)
            make.width.height.equalTo(65)
        }
        imageViews[2].snp.makeConstraints { make in
            make.left.equalTo(8)
            make.top.equalTo(11)
            make.width.height.equalTo(69)
        }

        contentView.addSubview(shadowView)
        shadowView.snp.makeConstraints { make in
            make.left.equalTo(self.imageViews[2])
            make.bottom.equalTo(self.imageViews[2])
            make.right.equalTo(self.imageViews[2])
            make.height.equalTo(20)
        }

        contentView.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.top.equalTo(59)
            make.width.height.equalTo(19)
        }

        contentView.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.left.equalTo(96)
            make.top.equalTo(49)
        }
    }

    private lazy var imageViews: [UIImageView] = {
        var imageViews: [UIImageView] = []

        let imageView2: UIImageView = UIImageView()
        imageView2.backgroundColor = UIColorRGB(0xEFEFF4)
        imageView2.clipsToBounds = true
        imageView2.contentMode = .scaleAspectFill
        imageView2.tag = 102
        imageViews.append(imageView2)

        let imageView1: UIImageView = UIImageView()
        imageView1.backgroundColor = UIColorRGB(0xEFEFF4)
        imageView1.clipsToBounds = true
        imageView1.contentMode = .scaleAspectFill
        imageView1.tag = 101
        imageViews.append(imageView1)

        let imageView0: UIImageView = UIImageView()
        imageView0.backgroundColor = UIColorRGB(0xEFEFF4)
        imageView0.clipsToBounds = true
        imageView0.contentMode = .scaleAspectFill
        imageView0.tag = 101
        imageViews.append(imageView0)

        return imageViews
    }()

    private lazy var shadowView: UIImageView = {
        let imageView: UIImageView = UIImageView(image: self.shadowImage)
        return imageView
    }()

    private lazy var iconView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()

    private lazy var countLabel: UILabel = {
        let countLabel = UILabel()
        countLabel.backgroundColor = UIColor.white
        countLabel.contentMode = .left
        countLabel.font = UIFont.systemFont(ofSize: 13)
        countLabel.textColor = UIColor.black
        return countLabel
    }()

    private lazy var shadowImage: UIImage? = {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: CGFloat(1.0), height: CGFloat(20.0)), false, 0.0)
        var context: CGContext? = UIGraphicsGetCurrentContext()
        var colors = [UIColorRGBA(0x000000, 0.0).cgColor, UIColorRGBA(0x000000, 0.8).cgColor] as CFArray
        var locations: [CGFloat] = [0.0, 1.0]
        var colorSpace: CGColorSpace? = CGColorSpaceCreateDeviceRGB()
        var gradient: CGGradient? = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations)
        if let gradient = gradient {
            context?.drawLinearGradient(gradient, start: CGPoint(x: CGFloat(0.0), y: CGFloat(0.0)), end: CGPoint(x: CGFloat(0.0), y: CGFloat(20.0)), options: [])
        } else {
            return nil
        }
        let shadowImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return shadowImage
    }()

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var nameLabel: UILabel = {
        let label: UILabel = UILabel()
        label.backgroundColor = .white
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .black
        return label
    }()

    public func configure(for assetGroup: MediaAssetGroup) {
        nameLabel.text = assetGroup.title()
        countLabel.text = "\(assetGroup.assetCount())"
        let latestAssets = assetGroup.fetchLatestAssets()
        for (i, imageView) in imageViews.enumerated() {
            if i < latestAssets.count {
                imageView.isHidden = false
                imageView.setSignal(latestAssets[latestAssets.count - i - 1].imageSignal(imageType: .thumbnail, size: CGSize(width: 138, height: 138), allowNetworkAccess: false))
            } else {
                imageView.isHidden = true
                imageView.reset()
            }
        }
        setIcon(assetGroup.subtype())
    }

    private func setIcon(_ type: PHAssetCollectionSubtype) {
        var iconImage: UIImage?
        switch type {
        case .smartAlbumFavorites:
            iconImage = ImageNamed("MediaGroupFavorites")
        case .smartAlbumPanoramas:
            iconImage = ImageNamed("MediaGroupPanoramas")
        case .smartAlbumVideos:
            iconImage = ImageNamed("MediaGroupVideo")
        case .smartAlbumBursts:
            iconImage = ImageNamed("MediaGroupBurst")
        case .smartAlbumSlomoVideos:
            iconImage = ImageNamed("MediaGroupSlomo")
        case .smartAlbumTimelapses:
            iconImage = ImageNamed("MediaGroupTimelapse")
        case .smartAlbumScreenshots:
            iconImage = ImageNamed("MediaGroupScreenshots")
        case .smartAlbumSelfPortraits:
            iconImage = ImageNamed("MediaGroupSelfPortraits")
        default:
            break
        }
        iconView.image = iconImage
        iconView.isHidden = iconImage == nil
        shadowView.isHidden = iconView.isHidden
    }
}
