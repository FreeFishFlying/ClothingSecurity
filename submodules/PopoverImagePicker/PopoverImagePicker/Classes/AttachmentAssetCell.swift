//
//  AttachmentAssetCell.swift
//  Components-Swift
//
//  Created by Dylan on 16/05/2017.
//  Copyright © 2017 liao. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import CoreGraphics
import PinLayout
import Core
import Album

class AttachmentAssetCell: UICollectionViewCell {
    
    static let AssetCellIdentifier = "AssetCellIdentifier"
    
    private static let AttachmetAssetCornerRadius: CGFloat = 6
    public static let CornersImage: UIImage = {
        let rect = CGRect(x: 0, y: 0, width: AttachmetAssetCornerRadius * 2 + 1.0, height: AttachmetAssetCornerRadius * 2 + 1.0)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        if let context: CGContext = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.white.cgColor)
            context.fill(rect)
            context.setBlendMode(CGBlendMode.clear)
            
            context.setFillColor(UIColor.clear.cgColor)
            context.fillEllipse(in: rect)
            let insets = UIEdgeInsets(top: AttachmetAssetCornerRadius, left: AttachmetAssetCornerRadius, bottom: AttachmetAssetCornerRadius, right: AttachmetAssetCornerRadius)
            if let cornersImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: insets) {
                return cornersImage
            }
        }
        return UIImage()
    }()
    
    weak var selectionContext: MediaSelectionContext?
    var asset: MediaAsset?
    private var disposable: Disposable?
    
    lazy var checkButton: CheckButtonView = {
        let checkButton = CheckButtonView()
        checkButton.addTarget(self, action: #selector(checkButtonClick), for: .touchUpInside)
        return checkButton
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    public lazy var cornersView: UIImageView = UIImageView(image: AttachmentAssetCell.CornersImage)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(checkButton)
        contentView.addSubview(shadowView)
        shadowView.addSubview(typeLabel)
        shadowView.addSubview(videoTypeImageView)
        shadowView.addSubview(videoDurationLabel)
        contentView.addSubview(cornersView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fillData(asset: MediaAsset?, isSingleChoose: Bool) {
        if asset != nil && self.asset != nil {
            if asset?.uniqueIdentifier() == self.asset?.uniqueIdentifier() {
                return
            }
        }
        checkButton.isHidden = isSingleChoose
        self.asset = asset
        refreshAsset()
    }

    func refreshAsset(size: CGSize? = nil) {
        disposable?.dispose()
        disposable = nil
        guard let asset = asset, let selectionContext = selectionContext else {
            imageView.reset()
            return
        }

        refreshEidtorImage(size: size)
        let editorDisposable = asset.eidtorChangeSignal.take(during: reactive.lifetime).observeValues {[weak self] (_) in
            if let strongSelf = self {
                strongSelf.refreshEidtorImage()
            }
        }
        checkButton.setChecked(selectionContext.isItemSelected(asset), animated: false)
        let selectDisposable = selectionContext.itemInformativeSelectedSignal(item: asset).take(during: reactive.lifetime).startWithValues({ [weak self] (change: SelectionChange) in
            if let strongSelf = self {
                strongSelf.checkButton.setChecked(change.selected, animated: change.animated)
            }
        })
        disposable = CompositeDisposable([editorDisposable, selectDisposable])
        
        shadowView.isHidden = true
        typeLabel.isHidden = true
        videoTypeImageView.isHidden = true
        videoDurationLabel.isHidden = true
        if asset.isGif() {
            shadowView.isHidden = false
            typeLabel.isHidden = false
        } else if asset.isVideo() {
            shadowView.isHidden = false
            videoTypeImageView.isHidden = false
            videoDurationLabel.isHidden = false
            videoDurationLabel.text = formatTimeInterval(asset.videoDuration())
        }
    }
    
    private func refreshEidtorImage(size: CGSize? = nil) {
        imageView.reset()
        if let image = self.asset?.editorResult?.editorImage {
            imageView.image = image
        } else if let asset = asset {
            let imageSize: CGSize
            if let size = size {
                imageSize = CGSize(width: size.width * 2, height: size.height * 2)
            } else {
                imageSize = CGSize(width: bounds.width * 2, height: bounds.height * 2)
            }
            imageView.setSignal(asset.imageSignal(imageType: .thumbnail, size: imageSize, allowNetworkAccess: false, applyEditorPresentation: true))
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var offset: CGFloat = 0.0
        if let superview = superview {
            let rect = superview.convert(frame, to: superview.superview)
            if rect.origin.x < 0 {
                offset = rect.origin.x * -1
            } else if rect.maxX > superview.frame.size.width {
                offset = superview.frame.size.width - rect.maxX
            }
        }
        let x: CGFloat = max(0, min(bounds.size.width - checkButton.frame.size.width, bounds.size.width - checkButton.frame.size.width + offset))
        let y: CGFloat = bounds.size.height - checkButton.frame.size.height
        checkButton.frame = CGRect(x: x, y: y, width: CGFloat(checkButton.frame.size.width), height: CGFloat(checkButton.frame.size.height))
        
        imageView.pin.topLeft().bottomRight()
        cornersView.pin.topLeft().bottomRight()
        shadowView.pin.topLeft().right().height(20)
        typeLabel.pin.left(5).width(30).vCenter().height(of: shadowView)
        videoTypeImageView.pin.left(5).size(CGSize(width: 18, height: 12)).vCenter()
        videoDurationLabel.pin.right(5).vCenter().size(of: shadowView)
    }
    
    @objc private func checkButtonClick() {
        guard let selectionContext = selectionContext, let asset = asset else {
            return
        }
        selectionContext.setItem(asset, selected: !checkButton.isSelected)
    }
    
    private static var shadowImage: UIImage? = {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: CGFloat(1.0), height: CGFloat(20.0)), false, 0.0)
        var context: CGContext? = UIGraphicsGetCurrentContext()
        var colors = [UIColorRGBA(0x000000, 0.8).cgColor, UIColorRGBA(0x000000, 0.0).cgColor] as CFArray
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
        shadowView.image = AttachmentAssetCell.shadowImage
        shadowView.isHidden = true
        return shadowView
    }()
    
    private lazy var videoTypeImageView: UIImageView = {
        let imageView = UIImageView(image: ImageNamed("VideoTagIcon"))
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var videoDurationLabel: UILabel = {
        let typeLabel = UILabel()
        typeLabel.isHidden = true
        typeLabel.textColor = UIColor.white
        typeLabel.backgroundColor = UIColor.clear
        typeLabel.textAlignment = .right
        typeLabel.font = UIFont.systemFont(ofSize: 12)
        return typeLabel
    }()
    
    private lazy var typeLabel: UILabel = {
        let typeLabel = UILabel()
        typeLabel.isHidden = true
        typeLabel.textColor = UIColor.white
        typeLabel.backgroundColor = UIColor.clear
        typeLabel.textAlignment = .left
        typeLabel.font = UIFont.systemFont(ofSize: 12)
        typeLabel.text = "GIF"
        return typeLabel
    }()
}

class DragSendImageView: UIImageView {
    
    private var tipLabel: UILabel = {
        let tipLabel = UILabel()
        tipLabel.font = UIFont.systemFont(ofSize: 12)
        tipLabel.backgroundColor = UIColorRGBA(0x000000, 0.8)
        tipLabel.textColor = UIColor.white
        tipLabel.layer.cornerRadius = 2;
        tipLabel.layer.masksToBounds = true;
        tipLabel.text = SLLocalized("CarouseAttachment.TipSend");
        return tipLabel
    }()
    
    public var showDragToSend: Bool = false {
        didSet {
            showDragTipLabel(enabled: showDragToSend)
        }
    }
    
    private func showDragTipLabel(enabled: Bool) {
        if enabled {
            tipLabel.isHidden = false
            if tipLabel.superview == nil {
                addSubview(tipLabel)
                tipLabel.snp.makeConstraints { make in
                    make.centerX.equalToSuperview()
                    make.height.equalTo(15)
                    make.top.equalTo(5)
                }
            }
        } else {
            tipLabel.isHidden = true
        }
    }
}
