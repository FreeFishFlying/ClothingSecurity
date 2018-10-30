//
//  ForceTouchPreviewController.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 2017/4/9.
//  Copyright © 2017年 kingxt. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import PhotosUI
import Mesh
import Result
import Core

@available(iOS 9.0, *)
public class ForceTouchPreviewController: UIViewController {

    private(set) var asset: MediaAsset
    private let previewItems: [UIPreviewActionItem]?

    @available(iOS 9.1, *)
    private lazy var livePhotoView: PHLivePhotoView = {
        let livePhotoView = PHLivePhotoView()
        return livePhotoView
    }()

    private lazy var imageView: AcceleratedAnimationImageView = {
        let imageView = AcceleratedAnimationImageView(frame: self.view.bounds)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    public override var previewActionItems: [UIPreviewActionItem] {
        return previewItems ?? []
    }

    public override func loadView() {
        super.loadView()
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        let size = ImageUtils.fitSize(size: asset.dimensions(), maxSize: UIScreen.main.bounds.size)
        let scale = UIScreen.main.scale
        let fallbackAction = { () -> Void in
            self.imageView.setSignal(self.asset.imageSignal(imageType: .fastScreen, size: CGSize(width: size.width * scale, height: size.height * scale), allowNetworkAccess: true))
            if self.asset.isGif() {
                self.asset.mediaAssetImageDataSignal(allowNetworkAccess: false).take(first: 1).startWithResult({ result in
                    if let value = result.value, let gifData = value.0?.imageData {
                        let path = ImageCache.default.cachePath(forKey: self.asset.uniqueIdentifier()) + ".mp4"
                        self.imageView.play(path: path, data: gifData)
                    }
                })
            }
        }
        if #available(iOS 9.1, *) {
            if asset.isLivePhoto() {
                self.view.addSubview(self.livePhotoView)
                self.livePhotoView.snp.makeConstraints { make in
                    make.edges.equalTo(self.view)
                }
                self.asset.livePhoto(targetSize: CGSize(width: size.width * scale, height: size.height * scale)).startWithValues({ [weak self] (livePhoto: PHLivePhoto?) in
                    if let strongSelf = self {
                        strongSelf.livePhotoView.livePhoto = livePhoto
                        strongSelf.livePhotoView.startPlayback(with: .hint)
                    }
                })
            } else {
                fallbackAction()
            }
        } else {
            fallbackAction()
        }
    }

    public init(asset: MediaAsset, previewActionItems: [UIPreviewActionItem]? = nil) {
        self.asset = asset
        previewItems = previewActionItems
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
