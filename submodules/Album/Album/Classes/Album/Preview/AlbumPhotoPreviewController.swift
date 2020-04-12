//
//  AlbumPhotoPreviewController.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 4/10/17.
//  Copyright © 2017 kingxt. All rights reserved.
//

import Foundation
import SnapKit
import PhotosUI
import ReactiveSwift
import Result
import Mesh
import Core

extension UIImage {

    public func isLongImage(targetFrame: CGRect) -> Bool {
        let scale = targetFrame.size.width / (targetFrame.size.height + 10)
        if size.width / size.height < scale {
            return true
        }
        return false
    }
}

class AlbumPhotoPreviewController: UIViewController, AlbumPreviewItem {

    private let asset: MediaAsset
    private let index: Int
    private let (lifetime, token) = Lifetime.make()

    private let zoomableItemView: ZoomableItemView = {
        let zoomableItemView = ZoomableItemView()
        zoomableItemView.maximumZoomScale = 2.5
        return zoomableItemView
    }()

    private lazy var imageView: AnimatedImageView = {
        let imageView = AnimatedImageView(frame: self.view.bounds)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.text = SLLocalized("Image.LoadFailure")
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        label.textAlignment = .center
        self.view.addSubview(label)
        label.snp.makeConstraints({ make in
            make.edges.equalTo(self.view)
        })
        return label
    }()

    private let overlayView: LoadingOverlayView = {
        var overlayView = LoadingOverlayView(frame: CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0))
        overlayView.setRadius(44)
        return overlayView
    }()

    override func loadView() {
        super.loadView()
        view.addSubview(zoomableItemView)
        zoomableItemView.setZoomableView(imageView)
        zoomableItemView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        view.addSubview(overlayView)
        overlayView.center = view.center
    }

    func canPanToDismiss() -> Bool {
        return true
    }

    func animationOutView() -> UIView? {
        return imageView
    }

    func editorAnimationTargetView() -> UIImageView? {
        return imageView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let size = ImageUtils.fitSize(size: asset.dimensions(), maxSize: UIScreen.main.bounds.size)
        let scale: CGFloat = 2
        let action: () -> Void = { [weak self] in
            if let strongSelf = self {
                strongSelf.asset.imageSignal(imageType: .fastScreen, size: CGSize(width: size.width * scale, height: size.height * scale), allowNetworkAccess: true, applyEditorPresentation: true).observe(on: UIScheduler()).on(completed: {
                    if strongSelf.asset.isGif() {
                        if let data = strongSelf.imageView.image?.kf.gifRepresentation() {
                            strongSelf.overlayView.setNone()
                            strongSelf.imageView.image = Kingfisher<Image>.animated(with: data, preloadAll: false)
                        } else {
                            strongSelf.asset.mediaAssetImageDataSignal(allowNetworkAccess: true).startWithResult({ result in
                                if let value = result.value {
                                    if let gifData = value.0?.imageData {
                                        strongSelf.overlayView.setNone()
                                        strongSelf.imageView.image = Kingfisher<Image>.animated(with: gifData, preloadAll: false)
                                    }
                                }
                            })
                        }
                    } else {
                        strongSelf.loadFullImageIfNeed()
                    }
                }, value: { image, progress in
                    if image != nil {
                        strongSelf.imageView.image = image
                        strongSelf.overlayView.setNone()
                    } else if let progress = progress {
                        strongSelf.overlayView.setProgress(CGFloat(max(progress, 0.03)), cancelEnabled: false, animated: true)
                    } else {
                        strongSelf.overlayView.setNone()
                        strongSelf.tipLabel.isHidden = false
                    }
                }).start()
            }
        }
        action()
        asset.eidtorChangeSignal.take(during: reactive.lifetime).observeValues { _ in
            action()
        }
    }

    func loadFullImageIfNeed() {
        if imageView.image?.isLongImage(targetFrame: view.frame) ?? false {
            asset.imageSignal(imageType: .largeThumbnail, size: view.frame.size, allowNetworkAccess: true, applyEditorPresentation: true).observe(on: UIScheduler()).startWithResult { [weak self] result in
                if let strongSelf = self {
                    if let data = result.value, let image = data.0 {
                        strongSelf.imageView.image = image
                        strongSelf.setUpImageViewSize(image: image)
                        strongSelf.zoomableItemView.setZoomableView(strongSelf.imageView)
                    }
                }
            }
        }
    }

    private func setUpImageViewSize(image: UIImage) {
        if image.isLongImage(targetFrame: view.bounds) {
            let imageHeight = image.size.height / image.size.width * view.frame.size.width
            imageView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: imageHeight)
        } else {
            imageView.frame = view.bounds
        }
    }

    func location() -> Int {
        return index
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        zoomableItemView.reset()
        imageView.frame = CGRect(origin: CGPoint.zero, size: size)
        overlayView.center = view.center
    }

    func displayAsset() -> MediaAsset {
        return asset
    }

    func willTranslatedOut() {
    }

    init(asset: MediaAsset, location: Int) {
        self.asset = asset
        index = location
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func willTranslatedIn() {
        imageView.alpha = 0
        zoomableItemView.alpha = 0
    }

    func didTranslatedIn() {
        imageView.alpha = 1
        zoomableItemView.alpha = 1
    }
}
