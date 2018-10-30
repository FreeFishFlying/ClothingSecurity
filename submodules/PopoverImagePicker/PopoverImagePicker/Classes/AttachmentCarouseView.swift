//
//  AttachmentCarouseView.swift
//  Components-Swift
//
//  Created by Dylan on 16/05/2017.
//  Copyright © 2017 liao. All rights reserved.
//

import UIKit
import SnapKit
import ReactiveSwift
import Result
import Core
import Album
import ActionSheet

public class AttachmentCarouseView: ActionSheetEventThroughView {
    
    fileprivate static let AttachmentCellSize = CGSize(width: 120, height: 120)
    fileprivate static let AttachmentNormalPhotoMaxWidth: CGFloat = 200.0
    fileprivate static let AttachmentZoomedPhotoHeight: CGFloat = 198.0
    fileprivate static let AttachmentZoomedPhotoMaxWidth: CGFloat = 250.0
    fileprivate static let AttachmentEdgeInset: CGFloat = 8.0
    fileprivate static let AttachmentDisplayedAssetLimit = 50
    
    fileprivate let style: MediaAssetsPickerController.Style
    fileprivate let confirmTitle: String
    fileprivate let assetType: MediaAssetType
    fileprivate let lockAspectRatio: CGFloat?
    
    fileprivate var assetGroup: MediaAssetGroup?
    fileprivate var (senderSignal, senderObserver) = Signal<([MediaSelectableItem], Bool), NoError>.pipe()
    fileprivate var previewIndex: Int = 0
    
    private var dragIndexPath: IndexPath?
    private var dragCell: AttachmentAssetCell?
    private var dragImageView: DragSendImageView?
    private var startDragPoint: CGPoint?
    private var dragImageCenter: CGPoint?
    
    public var zoomedIn = false
    public var dragToSend = false {
        didSet {
            addDragToSend(enabled: dragToSend)
        }
    }
    
    fileprivate let os = ProcessInfo().operatingSystemVersion
    
    fileprivate lazy var selectionContext = MediaSelectionContext()
    public var (selectionSignal, selectionObserver) = Signal<(Int, Int, UInt64?), NoError>.pipe()
    
    public var selectedAsset: [MediaAsset] {
        return selectionContext.selectedValues()
    }
    
    public init(frame: CGRect, style: MediaAssetsPickerController.Style, confirmTitle: String, assetType: MediaAssetType = .any, lockAspectRatio: CGFloat? = nil) {
        self.style = style
        self.confirmTitle = confirmTitle
        self.assetType = assetType
        self.lockAspectRatio = lockAspectRatio
        super.init(frame: frame)
        initializeSubviews()
        loadAssetGroupData()
        if !isSingleChoose {
            selectionContext
                .selectionContextChangeSignal()
                .take(during: reactive.lifetime)
                .throttle(0.4, on: QueueScheduler.main)
                .observeValues { [weak self] change in
                    if let strongSelf = self {
                        strongSelf.selectionAssetDidChanged(change)
                    }
            }
        }
    }
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if #available(iOS 9.0, *) {
            self.viewControllerPreviewing = newWindow?.rootViewController?.registerForPreviewing(with: self, sourceView: self.collectionView)
        }
    }

    fileprivate let smallLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = AttachmentEdgeInset
        layout.minimumInteritemSpacing = AttachmentEdgeInset
        layout.estimatedItemSize = CGSize(width: 80, height: AttachmentCarouseView.AttachmentCellSize.height - 2 * AttachmentCarouseView.AttachmentEdgeInset)
        return layout
    }()
    
    fileprivate let largeLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = AttachmentEdgeInset
        layout.minimumInteritemSpacing = AttachmentEdgeInset
        layout.estimatedItemSize = CGSize(width: 120, height: AttachmentCarouseView.AttachmentZoomedPhotoHeight - 2 * AttachmentCarouseView.AttachmentEdgeInset)
        return layout
    }()
    
    fileprivate lazy var collectionView: AttachmentCarouseCollectionView = {
        let collectionView: AttachmentCarouseCollectionView = AttachmentCarouseCollectionView(frame: CGRect.zero, collectionViewLayout: self.smallLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(AttachmentAssetCell.self, forCellWithReuseIdentifier: AttachmentAssetCell.AssetCellIdentifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "defaultCell")
        return collectionView
    }()
    
    private lazy var panGesture: DirectionPanGestureRecognizer = {
        let panGesture = DirectionPanGestureRecognizer(direction: DirectionPanGestureRecognizer.PanDirection.vertical, target: self, action: #selector(attachmentCarouseImagePanGes(gestureRecognizer:)))
        return panGesture
    }()
    
    fileprivate lazy var cameraView: AttachmentCameraView = {
        let height = AttachmentCarouseView.AttachmentCellSize.height
        let y = AttachmentCarouseView.AttachmentZoomedPhotoHeight + AttachmentCarouseView.AttachmentEdgeInset - height
        let cameraView = AttachmentCameraView(frame: CGRect(x: self.enableClickToLargeMode ? AttachmentCarouseView.AttachmentEdgeInset : -AttachmentCarouseView.AttachmentCellSize.width + AttachmentCarouseView.AttachmentEdgeInset, y: y, width: height - 2 * AttachmentCarouseView.AttachmentEdgeInset, height: height - 2 * AttachmentCarouseView.AttachmentEdgeInset), onlyTakeImage: self.assetType == .photo, isOnlyCrop: isOnlyCrop)
        if !self.enableClickToLargeMode {
            cameraView.frame.origin = CGPoint(x: cameraView.frame.origin.x, y: AttachmentCarouseView.AttachmentEdgeInset)
        }
        return cameraView
    }()
    
    public var cameraPickAssetSignal: Signal<MediaSelectableItem, NoError> {
        return cameraView.cameraPickAssetSignal
    }
    
    fileprivate let backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        return backgroundView
    }()
    
    fileprivate lazy var albumConfig: AlbumConfig = {
        let config = AlbumConfig(style: self.style, confirmTitle: self.confirmTitle, assetType: self.assetType, lockAspectRatio: self.lockAspectRatio,
                                      confirmCallback: { [weak self] assets, original in
                                        self?.senderObserver.send(value: (assets, original))
            },
                                      cancelCallback: { [weak self] () in
                                        
        })
        return config
    }()
    
    private var viewControllerPreviewing: UIViewControllerPreviewing?
    
    public var didClickSendSignal: Signal<([MediaSelectableItem], Bool), NoError> {
        return senderSignal
    }
    
    public func showCameraController() {
        cameraView.showPickerController()
    }
    
    fileprivate var isSingleChoose: Bool {
        return style.contains(.single)
    }
    
    fileprivate var isOnlyCrop: Bool {
        return style.contains(.onlyCrop)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeSubviews() {
        addSubview(backgroundView)
        addSubview(collectionView)
        let height = AttachmentCarouseView.AttachmentCellSize.height
        backgroundView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(height)
        }
        
        if !enableClickToLargeMode {
            collectionView.snp.makeConstraints { make in
                make.left.bottom.right.equalToSuperview()
                make.height.equalTo(height)
            }
            collectionView.contentInset = UIEdgeInsets(top: 0, left: AttachmentCarouseView.AttachmentCellSize.width, bottom: 0, right: 0)
        } else {
            collectionView.snp.makeConstraints { make in
                make.left.bottom.right.equalToSuperview()
                make.height.equalTo(AttachmentCarouseView.AttachmentZoomedPhotoHeight)
            }
        }
        collectionView.addSubview(cameraView)
    }
    
    fileprivate var enableClickToLargeMode: Bool {
        return os.majorVersion >= 10 && !isSingleChoose
    }
    
    private func loadAssetGroupData() {
        MediaAssetsLibrary(assetType: assetType).cameraRollGroup().observe(on: UIScheduler()).startWithResult { [weak self] (result: Result<MediaAssetGroup, MediaAssetsLibrary.MediaAssetsLibraryError>) in
            if let strongSelf = self,
                let value = result.value {
                strongSelf.assetGroup = value
                strongSelf.collectionView.collectionViewLayout.invalidateLayout()
                
                strongSelf.collectionView.reloadData()
                strongSelf.collectionView.reloadItems(at: strongSelf.collectionView.indexPathsForSelectedItems ?? [])
            }
        }
    }
    
    private func selectionAssetDidChanged(_ change: SelectionChange) {
        let selecteCount = selectionContext.selectedCount
        if let asset = change.sender as? MediaAsset {
            if let index = assetGroup?.indexFor(asset: asset) {
                updateZoomMode(zoomed: selecteCount > 0, animated: true, index: reverse(index: index))
            }
        }
        
        let values: [MediaAsset] = selectionContext.selectedValues()
        var imageCount = 0
        var videoCount = 0
        for item in values {
            if item.isVideo() {
                videoCount += 1
            } else {
                imageCount += 1
            }
        }
        
        selectionObserver.send(value: (imageCount, videoCount, nil))
        if selecteCount > 0 {
            selectionContext.selectedAssetFileSizeSignal().startWithValues { [weak self] size in
                if let strongSelf = self {
                    strongSelf.selectionObserver.send(value: (imageCount, videoCount, size))
                }
            }
        }
    }
    
    private func updateZoomMode(zoomed: Bool, animated: Bool, index: Int) {
        if !enableClickToLargeMode {
            return
        }
        if zoomedIn == zoomed {
            centerOnItem(index: index, animated: true)
            return
        }
        
        if collectionView.isUserInteractionEnabled == false {
            return
        }
        zoomedIn = zoomed
        collectionView.isUserInteractionEnabled = false
        let toLayout = zoomedIn ? largeLayout : smallLayout
        if toLayout == largeLayout {
            updateVisibleCell()
        }
        let transitionLayout = collectionView.transition(to: toLayout, duration: 0.3) { [weak self] _, _ in
            if let strongSelf = self {
                strongSelf.collectionView.isUserInteractionEnabled = true
                strongSelf.centerOnItem(index: index, animated: false)
            }
        }
        
        if let progressLayout = transitionLayout as? TransitionAnimationLayout {
            progressLayout.progressChanged = { [weak self] progress in
                if let strongSelf = self {
                    strongSelf.updateZoomMode(progress: progress)
                }
            }
            
            let insets = collectionView(collectionView, layout: toLayout, insetForSectionAt: 0)
            var point = collectionView.toContentOffset(layout: progressLayout, at: IndexPath(item: index, section: 0), to: collectionView.bounds.size, to: insets)
            point.y = 0
            progressLayout.toContentOffet = point
        }
    }
    
    private func centerOnItem(index: Int, animated: Bool) {
        let cellFrame = collectionView.collectionViewLayout.layoutAttributesForItem(at: IndexPath(row: index, section: 0))?.frame ?? CGRect.zero
        let x = cellFrame.origin.x - (collectionView.frame.size.width - cellFrame.size.width) / 2.0
        let contentOffset: CGFloat = max(0.0, min(x, collectionView.contentSize.width - collectionView.frame.size.width))
        collectionView.setContentOffset(CGPoint(x: contentOffset, y: 0), animated: animated)
    }
    
    private func updateZoomMode(progress: CGFloat) {
        let p = min(1.0, progress)
        let f = zoomedIn ? 1 - p : p
        let t = zoomedIn ? p : 1 - p
        let height = (AttachmentCarouseView.AttachmentCellSize.height) * f + t * AttachmentCarouseView.AttachmentZoomedPhotoHeight
        backgroundView.snp.updateConstraints({ make in
            make.height.equalTo(height)
        })
        
        var cameraViewFrame = cameraView.frame
        cameraViewFrame.origin.x = AttachmentCarouseView.AttachmentEdgeInset * f + -AttachmentCarouseView.AttachmentCellSize.width * t
        cameraView.frame = cameraViewFrame
        cameraView.alpha = f
    }
    
    private func updateVisibleCell() {
        for cell in collectionView.visibleCells {
            if let cell = cell as? AttachmentAssetCell, let indexPath = collectionView.indexPath(for: cell) {
                cell.refreshAsset(size: collectionView(collectionView, layout: largeLayout, sizeForItemAt: indexPath))
            }
        }
    }
    
    fileprivate func reverse(index: Int) -> Int {
        let count = assetGroup?.assetCount() ?? 0
        let reversedIndex = count - 1 - index
        return reversedIndex
    }
    
    fileprivate func enterEdit(indexPath: IndexPath) {
        guard let assetGroup = assetGroup else {
            return
        } 
        if let asset = assetGroup.objectAt(index: reverse(index: indexPath.item)), let cell = collectionView.cellForItem(at: indexPath) {
            let scale = UIScreen.main.scale
            var size = ImageUtils.fitSize(size: asset.dimensions(), maxSize: UIScreen.main.bounds.size)
            size.width *= scale
            size.height *= scale
            let thumbnailSignal = asset.imageSignal(imageType: .fastScreen, size: size, allowNetworkAccess: true, applyEditorPresentation: false).filter({ (data) -> Bool in
                return data.0 != nil
            }).filterMap({ (data) -> UIImage? in
                return data.0
            }).flatMapError({ (_) -> SignalProducer<UIImage?, NoError> in
                return SignalProducer.empty
            })

            let overlayViewController = OverlayViewController()
            overlayViewController.show()
            let frameView = UIView()
            frameView.frame = cell.frame
            MediaEditorBridge.editor(asset: asset, type: MediaEditorBridge.EditorType.crop, fromView: frameView, onViewController: overlayViewController, context: selectionContext, lockAspectRatio: lockAspectRatio) { [weak self] (assert) in
                self?.senderObserver.send(value: ([assert], false))
                }.startWithValues { (status) in
                    switch status {
                    case .beginTransitionOut:
                        overlayViewController.dismiss()
                    default: break
                    }
            }
        }
    }
    
    public func showCarousePreview(indexPath: IndexPath? = nil, showEditor: Bool = false) {
        if let assetGroup = assetGroup {
            var position: IndexPath
            if indexPath != nil {
                position = indexPath!
            } else {
                position = getMiddleIndexPath()
            }
            let index = reverse(index: position.item)
            let asset = assetGroup.objectAt(index: index)
            let albumPreviewController = AlbumPreviewController(assetGroup: assetGroup, position: index, config: albumConfig, selectionContext: selectionContext)
            albumPreviewController.animationTarget = { (position: Int) in
                guard let cell = self.collectionView.cellForItem(at: IndexPath(item: self.reverse(index: position), section: 0)) else {
                    return nil
                }
                return cell
            }
            albumPreviewController.dismissAnimationInset = { () -> UIEdgeInsets in
                UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
            if !(asset?.isVideo() ?? false) {
                albumPreviewController.enterInputModeAfterAppear = showEditor
            }
            albumPreviewController.show()
        }
    }
    
    private func getMiddleIndexPath() -> IndexPath {
        var visiableSelectedCells: [AttachmentAssetCell] = [AttachmentAssetCell]()
        collectionView.visibleCells.forEach { (cell) in
            if let cell = cell as? AttachmentAssetCell, let asset = cell.asset {
                if selectionContext.isItemSelected(asset) {
                    visiableSelectedCells.append(cell)
                }
            }
        }
        visiableSelectedCells = visiableSelectedCells.sorted(by: { (item1, item2) -> Bool in
            return item1.frame.origin.x < item2.frame.origin.x
        })
        if visiableSelectedCells.count == 0 {
            var visibleIndexPaths = collectionView.indexPathsForVisibleItems
            visibleIndexPaths = visibleIndexPaths.sorted(by: { (indexPath1, indexPath2) -> Bool in
                indexPath1.item > indexPath2.item
            })
            let middleIndex = visibleIndexPaths.count / 2
            if middleIndex < visibleIndexPaths.count {
                return visibleIndexPaths[middleIndex]
            }
        } else if visiableSelectedCells.count == 1 {
            return collectionView.indexPath(for: visiableSelectedCells[0]) ?? IndexPath(item: 0, section: 0)
        } else {
            let middleIndex = visiableSelectedCells.count / 2
            return collectionView.indexPath(for: visiableSelectedCells[middleIndex]) ?? IndexPath(item: 0, section: 0)
        }
        
        return IndexPath(item: 0, section: 0)
    }
    
    private func addDragToSend(enabled: Bool) {
        if enabled {
            if !hasDragToSendGesture() {
                addGestureRecognizer(panGesture)
            }
        } else {
            if hasDragToSendGesture() {
                removeGestureRecognizer(panGesture)
            }
        }
    }
    
    private func hasDragToSendGesture() -> Bool {
        if let recognizers = gestureRecognizers {
            for gesture in recognizers {
                if gesture is UIPanGestureRecognizer {
                    return true
                }
            }
        }
        return false
    }
    
    @objc private func attachmentCarouseImagePanGes(gestureRecognizer: UIPanGestureRecognizer) {
        if let window = window {
            var point = gestureRecognizer.location(in: window)
            switch gestureRecognizer.state {
            case .began:
                let cellPoint = gestureRecognizer.location(in: collectionView)
                if let indexPath = collectionView.indexPathForItem(at: cellPoint), let cell = collectionView.cellForItem(at: indexPath) as? AttachmentAssetCell {
                    dragIndexPath = indexPath
                    dragCell = cell
                    if dragImageView != nil && dragImageView!.superview != nil {
                        dragImageView!.removeFromSuperview()
                    }
                    point = gestureRecognizer.location(in: window)
                    dragCell?.imageView.alpha = 0
                    dragImageView = DragSendImageView()
                    dragImageView?.clipsToBounds = true
                    dragImageView?.image = dragCell?.imageView.image
                    let imageFrame = cell.imageView.frame
                    addSubview(dragImageView!)
                    let imagePoint = cell.imageView.convert(cell.imageView.center, to: self)
                    dragImageView?.frame = imageFrame
                    dragImageView?.contentMode = UIView.ContentMode.scaleAspectFill
                    dragImageView?.center = imagePoint
                    startDragPoint = point
                    dragImageCenter = dragImageView?.center
                } else {
                    dragIndexPath = nil
                }
            case .changed:
                if let startPoint = startDragPoint, let dragCenter = dragImageCenter {
                    if dragIndexPath != nil && point.y - startPoint.y < 0 {
                        dragImageView?.center = CGPoint(x: dragCenter.x + point.x - startPoint.x, y: dragCenter.y + point.y - startPoint.y)
                        dragImageView?.showDragToSend = startPoint.y - point.y > 120
                    }
                }
            case .ended:
                if let dragImageCenter = dragImageCenter, let imageView = dragImageView, let asset = dragCell?.asset {
                    let verlocity = gestureRecognizer.velocity(in: collectionView)
                    let shouldSendImage = imageView.showDragToSend || verlocity.y < -1000
                    if shouldSendImage && dragIndexPath != nil {
                        UIView.animate(withDuration: 0.2, animations: {
                            self.dragCell?.imageView.alpha = 1
                        })
                        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                            self.dragImageView?.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 5)
                        }, completion: { _ in
                            self.dragImageView?.removeFromSuperview()
                            compressVideo(assets: [asset], completedHandler: { [weak self] assets in
                                self?.senderObserver.send(value: (assets, false))
                            })

                        })
                    } else {
                        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                            self.dragImageView?.center = CGPoint(x: dragImageCenter.x, y: dragImageCenter.y)
                        }, completion: { _ in
                            self.dragImageView?.removeFromSuperview()
                            self.dragCell?.imageView.alpha = 1
                        })
                    }
                }
            case .failed, .cancelled:
                dragImageView?.removeFromSuperview()
                if dragIndexPath != nil {
                    dragCell?.imageView.alpha = 1
                }
            default:
                break
            }
        }
    }
    
    @available(iOS 9.0, *)
    public func forceTouchPreviewActionItems(asset: MediaAsset) -> [UIPreviewActionItem] {
        let previewSendAction = UIPreviewAction(title: SLLocalized("MediaAssetsPicker.Send"), style: .default) { [weak self] (_, _) in
            DispatchQueue.main.async {
                compressVideo(assets: [asset], completedHandler: { result in
                    self?.senderObserver.send(value: (result, false))
                })
            }
        }
        let previewSendOriginalAction = UIPreviewAction(title: SLLocalized("CarouseAttachment.SendOriginal"), style: .default) { [weak self] (_, _) in
            self?.senderObserver.send(value: ([asset], true))
        }
        return [previewSendAction, previewSendOriginalAction]
    }
    
    deinit {
        if #available(iOS 9.0, *) {
            if let viewControllerPreviewing = viewControllerPreviewing {
                window?.rootViewController?.unregisterForPreviewing(withContext: viewControllerPreviewing)
            }
        }
    }
}

extension AttachmentCarouseView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = assetGroup?.assetCount() ?? 0
        return min(count, AttachmentCarouseView.AttachmentDisplayedAssetLimit)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AttachmentAssetCell.AssetCellIdentifier, for: indexPath) as? AttachmentAssetCell {
            cell.selectionContext = selectionContext
            let asset = assetGroup?.objectAt(index: reverse(index: indexPath.item))
            cell.fillData(asset: asset, isSingleChoose: isSingleChoose)
            return cell
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: "defaultCell", for: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var dimensions = assetGroup?.objectAt(index: reverse(index: indexPath.item))?.dimensions() ?? CGSize.zero
        dimensions.width = dimensions.width < 1 ? 1 : dimensions.width
        dimensions.height = dimensions.height < 1 ? 1 : dimensions.height
        let height = AttachmentCarouseView.AttachmentCellSize.height
        if collectionViewLayout == largeLayout {
            dimensions.width = min(AttachmentCarouseView.AttachmentZoomedPhotoMaxWidth, floor(dimensions.width * AttachmentCarouseView.AttachmentZoomedPhotoHeight / dimensions.height))
            dimensions.height = floor(AttachmentCarouseView.AttachmentZoomedPhotoHeight - 2 * AttachmentCarouseView.AttachmentEdgeInset)
        } else {
            dimensions.width = min(AttachmentCarouseView.AttachmentNormalPhotoMaxWidth, floor(dimensions.width * height / dimensions.height))
            dimensions.height = floor(height - 2 * AttachmentCarouseView.AttachmentEdgeInset)
        }
        return dimensions
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return smallLayout.minimumLineSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
        return TransitionAnimationLayout(currentLayout: fromLayout, nextLayout: toLayout)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let edgeInset = AttachmentCarouseView.AttachmentEdgeInset
        if !enableClickToLargeMode {
            return UIEdgeInsets(top: edgeInset, left: edgeInset, bottom: edgeInset - 0.1, right: edgeInset)
        }
        if collectionViewLayout == largeLayout {
            return UIEdgeInsets(top: edgeInset, left: edgeInset, bottom: edgeInset - 0.1, right: edgeInset)
        } else {
            let leftInset = AttachmentCarouseView.AttachmentCellSize.width
            let height = AttachmentCarouseView.AttachmentCellSize.height
            let topInset = floor(AttachmentCarouseView.AttachmentZoomedPhotoHeight + edgeInset - height - 0.1)
            return UIEdgeInsets(top: topInset, left: leftInset, bottom: edgeInset, right: edgeInset)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.lockAspectRatio != nil || isOnlyCrop {
            enterEdit(indexPath: indexPath)
        } else {
            showCarousePreview(indexPath: indexPath, showEditor: false)
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for cell in collectionView.visibleCells {
            cell.setNeedsLayout()
        }
    }
}

extension AttachmentCarouseView: UIViewControllerPreviewingDelegate {
    
    @available(iOS 9.0, *)
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.collectionView.indexPathForItem(at: location) else {
            return nil
        }
        guard let cell = self.collectionView.cellForItem(at: indexPath) else {
            return nil
        }
        guard let asset: MediaAsset = self.assetGroup?.objectAt(index: reverse(index: indexPath.item)) else {
            return nil
        }
        UIApplication.shared.windows.forEach { (window) in
            window.endEditing(true)
        }
        previewIndex = reverse(index: indexPath.item)
        let forceTouchController = ForceTouchPreviewController(asset: asset, previewActionItems: forceTouchPreviewActionItems(asset: asset))
        previewingContext.sourceRect = cell.frame
        let size = ImageUtils.fitSize(size: asset.dimensions(), maxSize: UIScreen.main.bounds.size)
        forceTouchController.preferredContentSize = size
        return forceTouchController
    }
    
    @available(iOS 9.0, *)
    public func previewingContext(_: UIViewControllerPreviewing, commit _: UIViewController) {
        guard let assetGroup = assetGroup else {
            return
        }
        let albumPreviewController = AlbumPreviewController(assetGroup: assetGroup, position: previewIndex, config: albumConfig, selectionContext: selectionContext)
        albumPreviewController.animationTarget = { (position: Int) in
            guard let cell = self.collectionView.cellForItem(at: IndexPath(item: self.reverse(index: position), section: 0)) else {
                return nil
            }
            return cell
        }
        albumPreviewController.dismissAnimationInset = { () -> UIEdgeInsets in
            UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        albumPreviewController.show()
    }
}
