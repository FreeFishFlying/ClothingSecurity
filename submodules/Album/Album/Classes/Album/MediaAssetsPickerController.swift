//
//  MediaAssetsPickerController.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 2017/4/5.
//  Copyright © 2017年 kingxt. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Photos
import ReactiveSwift
import Core
import Result
import HUD

public struct AlbumAppearance {
    public let tintColor: UIColor
    public let checkBoxColor: UIColor
    public let checkBoxCheckColor: UIColor
    public let badgeViewTextColor: UIColor
    
    public init(tintColor: UIColor, checkBoxColor: UIColor, checkBoxCheckColor: UIColor, badgeViewTextColor: UIColor) {
        self.tintColor = tintColor
        self.checkBoxColor = checkBoxColor
        self.checkBoxCheckColor = checkBoxCheckColor
        self.badgeViewTextColor = badgeViewTextColor
    }
}

public var defaultAppearance = AlbumAppearance(tintColor: UIColorRGB(0x007AFF), checkBoxColor: UIColorRGB(0x29C519), checkBoxCheckColor: UIColor.white, badgeViewTextColor: UIColor.white)

public struct AlbumConfig {
    let style: MediaAssetsPickerController.Style
    let confirmTitle: String
    let confirmCallback: ([MediaSelectableItem], Bool) -> Void
    let cancelCallback: () -> Void
    let defautEnterCameraAlbum: Bool
    let assetType: MediaAssetType
    let selectItemOnConfirm: Bool
    let selectionContext: MediaSelectionContext?
    let lockAspectRatio: CGFloat?
    let compressVideo: Bool
    let maxVideoSize: UInt64?
    let maxDuration: TimeInterval

    public init(style: MediaAssetsPickerController.Style, confirmTitle: String, defautEnterCameraAlbum: Bool = true, assetType: MediaAssetType = .any, selectionContext: MediaSelectionContext? = nil, selectItemOnConfirm: Bool = true, lockAspectRatio: CGFloat? = nil, compressVideo: Bool = true, maxVideoSize: UInt64? = nil, maxDuration: TimeInterval = 300, confirmCallback: @escaping ([MediaSelectableItem], Bool) -> Void, cancelCallback: @escaping () -> Void) {
        self.style = style
        self.confirmCallback = confirmCallback
        self.cancelCallback = cancelCallback
        self.confirmTitle = confirmTitle
        self.defautEnterCameraAlbum = defautEnterCameraAlbum
        self.assetType = assetType
        self.selectionContext = selectionContext
        self.selectItemOnConfirm = selectItemOnConfirm
        self.lockAspectRatio = lockAspectRatio
        self.compressVideo = compressVideo
        self.maxVideoSize = maxVideoSize
        self.maxDuration = maxDuration
    }
}

public class MediaAssetsPickerController: UIViewController {

    public struct Style: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let multiChoose = Style(rawValue: 1)
        public static let single = Style(rawValue: 1 << 1)
        public static let originalImage = Style(rawValue: 1 << 2)
        public static let editEnabled = Style(rawValue: 1 << 3)
        public static let captionEnabled = Style(rawValue: 1 << 4)
        public static let captureImageOnCameraRoll = Style(rawValue: 1 << 5)
        public static let onlyCrop = Style(rawValue: 1 << 6)
    }

    internal var assetGroup: MediaAssetGroup
    internal let config: AlbumConfig
    internal let selectionContext: MediaSelectionContext
    internal var previewIndex: Int = 0

    private var enableCaptureImage: Bool = false
    private var hasEverLayoutSubviews = false
    private var setImageSelectedAfterCreationDate: Date? = nil

    public init(assetGroup: MediaAssetGroup, config: AlbumConfig, selectionContext: MediaSelectionContext) {
        self.assetGroup = assetGroup
        self.config = config
        self.selectionContext = selectionContext
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        backupSource.removeAll()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .available {
                registerForPreviewing(with: self, sourceView: self.collectionView)
            }
        }
        view.backgroundColor = .white
    }
    
    func refresh(group: MediaAssetGroup) {
        self.assetGroup = group
        if let date = setImageSelectedAfterCreationDate {
            if let asset = assetGroup.objectAt(index: assetGroup.assetCount() - 1) {
                if let creationDate = asset.creationDate {
                    if creationDate > date {
                        selectionContext.setItem(asset, selected: true)
                    }
                }
            }
        } else {
            collectionView.reloadData()
            return
        }
        setImageSelectedAfterCreationDate = nil
        collectionView.reloadData()
        collectionView.invalidateIntrinsicContentSize()
        DispatchQueue.main.async {
            if self.collectionView.contentSize.height > self.collectionView.frame.size.height {
                self.collectionView.setContentOffset(CGPoint(x: 0, y: self.collectionView.contentSize.height - self.collectionView.frame.size.height), animated: true)
            }
        }
    }

    public override func loadView() {
        super.loadView()
        title = assetGroup.title()

        if (config.style.contains(.originalImage) || config.style.contains(.editEnabled) || config.style.contains(.multiChoose)) && !config.style.contains(.single) {
            view.addSubview(collectionView)
            view.addSubview(toolbar)
            toolbar.snp.makeConstraints { make in
                make.left.right.equalTo(self.view)
                if #available(iOS 11, *) {
                    make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                } else {
                    make.bottom.equalToSuperview()
                }
                make.height.equalTo(45)
            }
            collectionView.snp.makeConstraints { make in
                make.left.right.top.equalTo(self.view)
                make.bottom.equalTo(self.toolbar.snp.top)
            }
            collectionView.layoutIfNeeded()
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: SLLocalized("MediaAssetsPicker.Cancel"), style: .plain, target: self, action: #selector(cancel))
            view.addSubview(collectionView)
            collectionView.snp.makeConstraints { make in
                make.edges.equalTo(self.view)
            }
            collectionView.layoutIfNeeded()
        }
    }

    @objc func cancel() {
        config.cancelCallback()
    }
    
    public var captureImageOnCameraRoll: Bool {
        return assetGroup.isCameraRoll() && config.style.contains(.captureImageOnCameraRoll)
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !hasEverLayoutSubviews {
            hasEverLayoutSubviews = true
            if collectionView.contentSize.height > collectionView.frame.size.height {
                collectionView.setContentOffset(CGPoint(x: 0, y: collectionView.contentSize.height - collectionView.frame.size.height), animated: false)
            }
        }
    }

    private lazy var collectionLayout: PanToSelectCollectionFlowLayout = {
        let collectionLayout = PanToSelectCollectionFlowLayout()
        if self.config.style.contains(.multiChoose) {
            collectionLayout.handleCellSelection = { [weak self] (indexPath: IndexPath, selected: Bool) in
                if let strongSelf = self, let asset = strongSelf.assetGroup.objectAt(index: indexPath.item) {
                    strongSelf.selectionContext.setItem(asset, selected: selected, animated: true)
                }
            }
        }
        collectionLayout.minimumLineSpacing = 1
        collectionLayout.minimumInteritemSpacing = 1
        return collectionLayout
    }()

    internal lazy var collectionView: UICollectionView = {
        let collectionView: UICollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: self.collectionLayout)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.white
        collectionView.delaysContentTouches = true
        collectionView.canCancelContentTouches = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MediaPickerCell.self, forCellWithReuseIdentifier: MediaPickerPhotoCellKind)
        collectionView.register(MediaPickerVideoCell.self, forCellWithReuseIdentifier: MediaPickerVideoCellKind)
        collectionView.register(MediaPickerGifCell.self, forCellWithReuseIdentifier: MediaPickerGifCellKind)
        collectionView.register(CapturePreivewCell.self, forCellWithReuseIdentifier: MediaPickerCapturePreivewCellKind)
        return collectionView
    }()

    private lazy var toolbar: MediaAssetsPickerToolbar = {
        let toolbar = MediaAssetsPickerToolbar(selectionContext: self.selectionContext, config: self.config)
        toolbar.backgroundColor = .white
        return toolbar
    }()

    fileprivate func enterEdit(indexPath: IndexPath) {
        if let asset = assetGroup.objectAt(index: indexPath.item), let cell = collectionView.cellForItem(at: indexPath) {
            let overlayViewController = OverlayViewController()
            overlayViewController.show()
            let frameView = UIView()
            frameView.frame = cell.frame
            MediaEditorBridge.editor(asset: asset, type: MediaEditorBridge.EditorType.crop, fromView: frameView, onViewController: overlayViewController, context: selectionContext) { [weak self] (assert) in
                self?.config.confirmCallback([assert], false)
                }.startWithValues { (status) in
                    switch status {
                    case .beginTransitionOut:
                        overlayViewController.dismiss()
                    default: break
                    }
            }
        }
    }
}

extension MediaAssetsPickerController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private var itemsPerRow: Int {
        return Int(view.frame.size.width / 100)
    }

    private var interitemSpace: CGFloat {
        return 1.0
    }

    public func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return assetGroup.assetCount() + (captureImageOnCameraRoll ? 1 : 0)
    }
    
    public func captureImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.presentingViewController?.dismiss(animated: false, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if config.style.contains(.multiChoose) {
                setImageSelectedAfterCreationDate = Date()
                MediaAssetsLibrary.default.saveImage(image: image)
            } else {
                config.confirmCallback([ImageAsset(image: image)], false)
            }
        }
    }

    public func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let asset = assetGroup.objectAt(index: indexPath.item) else {
            if captureImageOnCameraRoll {
                captureImage()
            }
            return
        }
        func enterDetail() {
            if config.lockAspectRatio != nil || config.style.contains(.onlyCrop) {
                enterEdit(indexPath: indexPath)
            } else if config.style.contains(.editEnabled) {
                let albumPreviewController = AlbumPreviewController(assetGroup: assetGroup, position: indexPath.item, config: config, selectionContext: selectionContext)
                albumPreviewController.animationTarget = { [weak self] (position: Int) in
                    guard let `self` = self else {
                        return nil
                    }
                    guard let cell = self.collectionView.cellForItem(at: IndexPath(item: position, section: 0)) else {
                        return nil
                    }
                    return cell
                }
                albumPreviewController.dismissAnimationInset = { [weak self] () -> UIEdgeInsets in
                    guard let `self` = self else {
                        return UIEdgeInsets.zero
                    }
                    return UIEdgeInsets(top: 64, left: 0, bottom: self.view.frame.size.height - self.collectionView.frame.maxY, right: 0)
                }
                albumPreviewController.show()
            } else if config.style.contains(.multiChoose) {
                selectionContext.setItem(asset, selected: true)
            } else {
                config.confirmCallback([asset], false)
            }
        }
        if let maxSize = config.maxVideoSize, asset.type() == .video {
            asset.fileSizeSignal().observe(on: UIScheduler()).startWithResult { [weak self] (result) in
                guard let `self` = self else { return }
                if let size = result.value {
                    if size <= maxSize || asset.videoDuration() <= self.config.maxDuration {
                        enterDetail()
                    } else {
                        HUD.tip(text: "该视频超出最大限制", onView: self.view)
                    }
                }
            }
        } else {
            enterDetail()
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let asset = assetGroup.objectAt(index: indexPath.item) else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaPickerCapturePreivewCellKind, for: indexPath) as!
             CapturePreivewCell
            return cell
        }
        let cell: MediaPickerCell
        if asset.isVideo() {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaPickerVideoCellKind, for: indexPath) as! MediaPickerVideoCell
        } else if asset.isGif() {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaPickerGifCellKind, for: indexPath) as! MediaPickerGifCell
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaPickerPhotoCellKind, for: indexPath) as! MediaPickerCell
        }
        cell.selectionContext = selectionContext
        cell.fillData(asset: assetGroup.objectAt(index: indexPath.item))
        cell.setMultiChoose(enabled: config.style.contains(.multiChoose))
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let interitemPadding = CGFloat(max(0, itemsPerRow - 1)) * interitemSpace
        let availableWidth = collectionView.bounds.width - interitemPadding
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)
        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    public func collectionView(_: UICollectionView,
                               layout _: UICollectionViewLayout,
                               insetForSectionAt _: Int) -> UIEdgeInsets {
        return .zero
    }

    public func collectionView(_: UICollectionView,
                               layout _: UICollectionViewLayout,
                               minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return interitemSpace
    }

    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return interitemSpace
    }
}

extension MediaAssetsPickerController: UIViewControllerPreviewingDelegate {

    @available(iOS 9.0, *)
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.collectionView.indexPathForItem(at: location) else {
            return nil
        }
        guard let cell = self.collectionView.cellForItem(at: indexPath) else {
            return nil
        }
        guard let asset: MediaAsset = self.assetGroup.objectAt(index: indexPath.item) else {
            return nil
        }

        previewIndex = indexPath.item
        let forceTouchController = ForceTouchPreviewController(asset: asset)
        previewingContext.sourceRect = cell.frame
        let size = ImageUtils.fitSize(size: asset.dimensions(), maxSize: UIScreen.main.bounds.size)
        forceTouchController.preferredContentSize = size
        return forceTouchController
    }

    @available(iOS 9.0, *)
    public func previewingContext(_: UIViewControllerPreviewing, commit _: UIViewController) {
        if config.style.contains(.editEnabled) {
            let albumPreviewController = AlbumPreviewController(assetGroup: assetGroup, position: previewIndex, config: config, selectionContext: selectionContext)
            albumPreviewController.animationTarget = { [weak self] (position: Int) in
                guard let `self` = self else {
                    return nil
                }
                guard let cell = self.collectionView.cellForItem(at: IndexPath(item: position, section: 0)) else {
                    return nil
                }
                return cell
            }
            albumPreviewController.show()
        }
    }
}
