//
//  ImagePreviewController.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 4/10/17.
//  Copyright © 2017 kingxt. All rights reserved.
//

import Foundation
import UIKit
import pop
import SnapKit
import ReactiveSwift
import Result
import AVFoundation
import Core
import AlertController

protocol AlbumPreviewItem: class {
    func canPanToDismiss() -> Bool
    func location() -> Int
    func displayAsset() -> MediaAsset

    func animationOutView() -> UIView?
    func editorAnimationTargetView() -> UIImageView?

    func willTranslatedOut()
    func willTranslatedIn()
    func didTranslatedIn()
}

public enum MediaAssetOrder: Int {
    case ascending = 0
    case same
    case descending
    case unknown
}

public protocol MediaGroup {
    func objectAt(index: Int) -> MediaAsset?
    func assetCount() -> Int
    func getAssetDirection(from: MediaAsset, to: MediaAsset) -> (orderd: MediaAssetOrder, toIndex: Int)
}

public struct MediaGroupDefault: MediaGroup {

    public init(data: [MediaAsset]) {
        self.data = data
    }

    let data: [MediaAsset]

    public func objectAt(index: Int) -> MediaAsset? {
        return data[safe: index]
    }

    public func assetCount() -> Int {
        return data.count
    }

    public func getAssetDirection(from: MediaAsset, to: MediaAsset) -> (orderd: MediaAssetOrder, toIndex: Int) {
        var order: MediaAssetOrder
        let fromIndex = data.index(of: from) ?? 0
        let toIndex = data.index(of: to) ?? 0
        if fromIndex > toIndex {
            order = .descending
        } else if fromIndex < toIndex {
            order = .ascending
        } else {
            order = .same
        }
        return (order, toIndex)
    }
}

public class AlbumPreviewController: OverlayViewController, UIScrollViewDelegate {

    fileprivate let assetGroup: MediaGroup
    private var position: Int = 0
    private var scrollOffset: CGPoint = CGPoint.zero
    private let config: AlbumConfig
    private let selectionContext: MediaSelectionContext
    private var requestImageSizeDisposable: Disposable?
    private let (lifetime, token) = Lifetime.make()

    public var animationTarget: ((_ position: Int) -> UIView?)?
    public var dismissAnimationInset: (() -> UIEdgeInsets)?
    public var enterInputModeAfterAppear: Bool?
    public var isPublishPreview: Bool? {
        didSet {
            interfaceView.isPublishPreview = isPublishPreview
        }
    }

    public init(assetGroup: MediaGroup, position: Int, config: AlbumConfig, selectionContext: MediaSelectionContext) {
        self.assetGroup = assetGroup
        self.position = position
        self.config = config
        self.selectionContext = selectionContext
        
        super.init(nibName: nil, bundle: nil)

        guard let viewController = self.viewControllerAtIndex(position) else {
            return
        }
        pageViewController.setViewControllers([viewController], direction: .forward, animated: false, completion: nil)

        selectionContext.isSelectOriginalImage.producer.take(during: lifetime).startWithValues { [weak self] (selected: Bool) in
            if let strongSelf = self {
                if selected {
                    if strongSelf.interfaceView.actionAsset != nil {
                        strongSelf.selectionContext.setItem(strongSelf.interfaceView.actionAsset!, selected: true)
                    }
                    strongSelf.requestCurrentAssetFileSize()
                } else {
                    strongSelf.interfaceView.originalButton.setTitle(SLLocalized("MediaAssetsPicker.OriginalPicture"), for: .normal)
                }
            }
        }
    }
    
    public override func show() {
        super.show()
        if !isIpad() {
            overlayWindow?.resetPortraitAfterDismiss = true
        }
    }

    deinit {
        requestImageSizeDisposable?.dispose()
    }

    public override func loadView() {
        super.loadView()
        backView.isHidden = false
        view.addSubview(pageViewController.view)
        addChild(pageViewController)

        view.addSubview(interfaceView)
        interfaceView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        animationTranslationIn()
        if let scrollView = self.pageViewController.view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            scrollView.delegate = self
        }
        enablePanToDismiss(target: pageViewController.view, animationTargetView: pageViewController.view)
        setStatusBarStatusAlpha(0)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let currentItem = self.currentVisiableItem() else {
            return
        }
        interfaceView.action(asset: currentItem.displayAsset())
        if let enterInput = enterInputModeAfterAppear {
            if enterInput {
                overlayWindow?.makeKey()
                interfaceView.begainInputCaption()
            }
            enterInputModeAfterAppear = nil
        }
    }

    private func setStatusBarStatusAlpha(_ alpha: CGFloat) {
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.isHidden {
            return
        }
        UIView.animate(withDuration: 0.2) {
            statusBar.alpha = alpha
        }
    }

    private func animationTranslationIn() {
        guard let animationBeginView = self.animationTarget?(self.position) else {
            return
        }
        guard let animationBeginViewParent = animationBeginView.superview else {
            return
        }
        guard let mediaAsset = assetGroup.objectAt(index: position) else {
            return
        }
        currentVisiableItem()?.willTranslatedIn()

        let startAnimationFrame = animationBeginViewParent.convert(animationBeginView.frame, to: view)
        let animationView: AspectModeScaleImageView = AspectModeScaleImageView(frame: startAnimationFrame)
        view.addSubview(animationView)
        animationView.contentMode = .scaleAspectFill

        backView.backgroundColor = .clear
        interfaceView.alpha = 0
        let size = ImageUtils.fitSize(size: mediaAsset.dimensions(), maxSize: UIScreen.main.bounds.size)

        func resetState() {
            backView.backgroundColor = .black
            interfaceView.alpha = 1
            currentVisiableItem()?.didTranslatedIn()
            animationView.removeFromSuperview()
            if config.style.contains(.captionEnabled) {
                UIApplication.shared.windows.forEach { window in
                    if window != self.view.window {
                        window.endEditing(true)
                    }
                }
            }
        }

        mediaAsset.imageSignal(imageType: .fastLargeThumbnail, size: size, allowNetworkAccess: false, applyEditorPresentation: true).observe(on: UIScheduler()).startWithResult { (result: Result<(UIImage?, Double?), RequestImageDataError>) in
            if let image = result.value?.0 {
                if animationView.image == nil {
                    animationView.image = image
                    if image.isLongImage(targetFrame: self.view.frame) {
                        animationView.initialeState(.fill, newFrame: self.longImageViewFrame(from: image))
                    } else {
                        animationView.initialeState(.fit, newFrame: self.view.frame)
                    }
                    UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: [.allowAnimatedContent, .curveEaseIn], animations: {
                        animationView.transitionState(.fit)
                    }) { _ in
                        animationView.endState(.fit)
                        resetState()
                    }

                    let animationBackground = POPBasicAnimation(propertyNamed: kPOPViewBackgroundColor)
                    animationBackground?.autoreverses = false
                    animationBackground?.removedOnCompletion = true
                    animationBackground?.fromValue = UIColor.clear
                    animationBackground?.toValue = UIColor.black
                    self.backView.pop_add(animationBackground, forKey: "animationBackground")

                    self.view.bringSubviewToFront(self.pageViewController.view)
                    self.view.bringSubviewToFront(self.interfaceView)

                    UIView.animate(withDuration: 0.35) {
                        self.interfaceView.alpha = 1
                    }
                } else {
                    animationView.image = image
                }
            } else if animationView.image == nil {
                resetState()
            }
        }
    }
    
    private func longImageViewFrame(from image: UIImage) -> CGRect {
        let imageHeight = image.size.height / image.size.width * view.frame.size.width
        return CGRect(x: 0, y: 0, width: view.frame.size.width, height: imageHeight)
    }

    public override func updateDismissTransition(withProgress progress: CGFloat, animated: Bool) {
        super.updateDismissTransition(withProgress: progress, animated: animated)
        let alpha: CGFloat = 1.0 - max(0.0, min(1.0, progress))
        if animated {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.interfaceView.alpha = alpha
            })
        } else {
            interfaceView.alpha = alpha
        }
    }

    public override func beginTransitionOut(withVelocity velocity: CGFloat) {
        setStatusBarStatusAlpha(1)
        view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2) {
            self.interfaceView.alpha = 0
        }
        guard let item = self.currentVisiableItem() else {
            return super.beginTransitionOut(withVelocity: velocity)
        }
        guard let animationEndView = self.animationTarget?(item.location()) else {
            return super.beginTransitionOut(withVelocity: velocity)
        }
        guard let animationEndViewParent = animationEndView.superview else {
            return super.beginTransitionOut(withVelocity: velocity)
        }

        let endAnimationFrame = animationEndViewParent.convert(animationEndView.frame, to: view)
        let animationView: UIView = item.animationOutView() ?? pageViewController.view

        var displaySize = ImageUtils.scaleToSize(size: item.displayAsset().dimensions(), maxSize: animationView.frame.size)
        if let cropResult = item.displayAsset().editorResult?.cropResult {
            displaySize = ImageUtils.scaleToSize(size: cropResult.cropRect.size, maxSize: animationView.frame.size)
        }
        let displayFrame = CGRect(origin: CGPoint(x: (animationView.frame.size.width - displaySize.width) / 2, y: (animationView.frame.size.height - displaySize.height) / 2), size: displaySize)

        let animationEdge = dismissAnimationInset?() ?? UIEdgeInsets.zero
        super.dismiss(animationView: animationView, displayFrame: displayFrame, animationContainerEdge: animationEdge, toFrame: endAnimationFrame, fromContentMode: .scaleAspectFit, toContentMode: .scaleAspectFill)
        item.willTranslatedOut()
    }

    public override func dismissTransitionWillBegin() {
        super.dismissTransitionWillBegin()
        interfaceView.unSelectCountButtonIfNeed()
        if let item = self.currentVisiableItem() {
            if let animationEndView = self.animationTarget?(item.location()) {
                animationEndView.isHidden = true
            }
        }
    }

    public override func dismissTransitionDidFinish() {
        super.dismissTransitionDidFinish()
        if let item = self.currentVisiableItem() {
            if let animationEndView = self.animationTarget?(item.location()) {
                animationEndView.isHidden = false
            }
        }
    }

    public override func dismissTransitionDidCancel() {
        super.dismissTransitionDidCancel()
        if let item = self.currentVisiableItem() {
            if let animationEndView = self.animationTarget?(item.location()) {
                animationEndView.isHidden = false
            }
        }
    }

    fileprivate func currentVisiableItem() -> AlbumPreviewItem? {
        guard let viewControllers: [UIViewController] = self.pageViewController.viewControllers else {
            return nil
        }
        return viewControllers.first as? AlbumPreviewItem
    }

    fileprivate func requestCurrentAssetFileSize() {
        requestImageSizeDisposable?.dispose()
        if selectionContext.isSelectOriginalImage.value == true {
            requestImageSizeDisposable = currentVisiableItem()?.displayAsset().fileSizeSignal().observe(on: UIScheduler()).startWithValues({ [weak self] (size: UInt64) in
                if let strongSelf = self {
                    if size > 1024 * 1024 {
                        strongSelf.interfaceView.originalButton.setTitle(String(format: "%.1fM", Double(size) / (1024 * 1024)), for: .normal)
                    } else {
                        strongSelf.interfaceView.originalButton.setTitle(String(format: "%.1fK", Double(size) / 1024), for: .normal)
                    }
                }
            })
        }
    }

    public func scrollViewDidScroll(_: UIScrollView) {
        guard let currentItem = self.currentVisiableItem() else {
            return
        }
        interfaceView.action(asset: currentItem.displayAsset())
    }

    public override func canPanToDismiss() -> Bool {
        guard let currentItem = self.currentVisiableItem() else {
            return false
        }
        return currentItem.canPanToDismiss()
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate lazy var pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewController.OptionsKey.interPageSpacing: 10])
        pageViewController.delegate = self
        pageViewController.dataSource = self
        return pageViewController
    }()

    private func editorAnimationTranslationView() -> UIView? {
        guard let item = self.currentVisiableItem() else {
            return nil
        }
        if let animationView = item.editorAnimationTargetView() {
            let imageView = UIImageView(frame: view.bounds)
            imageView.contentMode = .scaleAspectFit
            if let image = item.displayAsset().editorResult?.editorImage {
                imageView.image = image
            } else {
                imageView.image = animationView.image
            }
            return imageView
        }
        return nil
    }
    
    func editAsset2(type: MediaEditorBridge.EditorType) {
        guard let mediaAsset = currentVisiableItem()?.displayAsset() else {
            return
        }
        MediaEditorBridge.editor(asset: mediaAsset, type: type, fromView: self.currentVisiableItem()?.editorAnimationTargetView() ?? self.view, onViewController: self,
                                 context: selectionContext).startWithValues { [weak self] (status) in
                                    switch status {
                                    case .beginTransitionIn:
                                        self?.interfaceView.isHidden = true
                                    case .beginTransitionOut:
                                        self?.interfaceView.isHidden = false
                                    default: break
                                    }
        }
    }

    func editAsset() {
        let animationContext = AnimationTranslationContext()
        animationContext.fromView = editorAnimationTranslationView()
        animationContext.dismissTargetRect = { [weak self] (_: Int?) -> (CGRect, UIView.ContentMode?) in
            if let strongSelf = self {
                return (strongSelf.view.bounds, .scaleAspectFit)
            }
            return (CGRect.zero, nil)
        }
        let editorResult = currentVisiableItem()?.displayAsset().editorResult ?? MediaEditorResult()
        let editorContext = MediaEditorContext(editorResult: editorResult)
        let thumbnailSignal = SignalProducer<UIImage?, NoError>({ [weak self] (observer: Signal<UIImage?, NoError>.Observer, _) in
            guard let mediaAsset = self?.currentVisiableItem()?.displayAsset() else {
                return observer.sendInterrupted()
            }
            if let paintHostImage = editorResult.paintHostImage {
                observer.send(value: paintHostImage)
                observer.sendCompleted()
                return
            }
            let scale: CGFloat = 2
            var size = ImageUtils.fitSize(size: mediaAsset.dimensions(), maxSize: UIScreen.main.bounds.size)
            size.width *= scale
            size.height *= scale
            let signal = mediaAsset.imageSignal(imageType: .fastScreen, size: size, allowNetworkAccess: true, applyEditorPresentation: false).filter({ (data) -> Bool in
                data.0 != nil
            }).filterMap({ (data) -> UIImage? in
                data.0
            })
            signal.start({ event in
                switch event {
                case .completed:
                    observer.sendCompleted()
                case let .value(value):
                    observer.send(value: value)
                case .failed:
                    observer.sendCompleted()
                case .interrupted:
                    observer.sendInterrupted()
                }
            })
        })

        editorContext.thumbnailSignal = thumbnailSignal

        var editorType: MediaEditorController.EditorType = [.crop, .imagePaint, .imageFilter]
        currentVisiableItem()?.willTranslatedOut()
        if let currentAsset = self.currentVisiableItem()?.displayAsset() {
            if currentAsset.isVideo() {
                editorType = [.crop, .videoEditor]
                editorContext.videoPlayItemSignal = currentAsset.avAssetSignal(allowNetworkAccess: false).map({ (asset, _) -> AVAsset? in
                    asset
                })
            }
        }

        let editorController = MediaEditorController(editorType: editorType, editorContext: editorContext, animationContext: animationContext)

        animationContext.stateChangeSignal().startWithValues { [weak self] state in
            switch state {
            case .willTranslationOut:
                if let strongSelf = self {
                    strongSelf.interfaceView.isHidden = false
                    strongSelf.interfaceView.alpha = 0
                    strongSelf.view.bringSubviewToFront(strongSelf.interfaceView)
                    UIView.animate(withDuration: 0.25, animations: {
                        strongSelf.interfaceView.alpha = 1
                    })
                }
            case .didTranslationOut:
                delay(0.2, closure: {
                    self?.removeMediaEditor()
                })
            case .willTranslationIn:
                UIView.animate(withDuration: 0.25, animations: {
                    self?.interfaceView.alpha = 0
                }, completion: { _ in
                    self?.interfaceView.isHidden = true
                })
            default: break
            }
        }

        editorController.didCancel = { [weak self] in
            self?.removeMediaEditor()
        }
        editorController.didConfirm = { [weak self] (editorResult: MediaEditorResult?) in
            if let strongSelf = self {
                if let asset = strongSelf.currentVisiableItem()?.displayAsset() {
                    if let result = editorResult {
                        asset.editorResult = result
                        asset.eidtorChangeObserver.send(value: result)
                    } else {
                        asset.editorResult = nil
                        asset.eidtorChangeObserver.send(value: nil)
                    }
                }
            }
        }
        addChild(editorController)
        view.addSubview(editorController.view)
        view.bringSubviewToFront(interfaceView)
    }

    func removeMediaEditor() {
        for viewController in children {
            if viewController is MediaEditorController {
                viewController.removeFromParent()
                viewController.view.removeFromSuperview()
            }
        }
    }

    lazy var interfaceView: AlbumPreviewInterfaceView = {
        let interfaceView = AlbumPreviewInterfaceView(config: self.config, selectionContext: self.selectionContext,
                                                      displayCounter: self.assetGroup.assetCount() > 1 && config.style.contains(.multiChoose))
        interfaceView.backAction = { [weak self] in
            if let strongSelf = self {
                strongSelf.beginTransitionOut(withVelocity: 10)
                strongSelf.interfaceView.unSelectCountButtonIfNeed()
            }
        }
        interfaceView.confirmAction = { [weak self] in
            if let strongSelf = self {
                if let item = strongSelf.currentVisiableItem()?.displayAsset() {
                    if strongSelf.config.selectItemOnConfirm {
                        strongSelf.selectionContext.setItem(item, selected: true)
                    }
                }
                strongSelf.currentVisiableItem()?.willTranslatedOut()
                strongSelf.setStatusBarStatusAlpha(1)
                let result: [MediaAsset] = strongSelf.selectionContext.selectedValues()

                func action(output: [MediaSelectableItem]) {
                    strongSelf.config.confirmCallback(output, strongSelf.selectionContext.isSelectOriginalImage.value)
                    let frame = strongSelf.view.frame
                    let finalRect = CGRect(x: frame.origin.x, y: 2 * frame.size.height, width: frame.size.width, height: frame.size.height)
                    UIView.animate(withDuration: 0.25, animations: {
                        strongSelf.view?.frame = finalRect
                    }) { _ in
                        strongSelf.dismiss()
                    }
                }
                if strongSelf.selectionContext.isSelectOriginalImage.value || !strongSelf.config.compressVideo {
                    action(output: result)
                } else {
                    compressVideo(assets: result, cancelHandler: { () in
                        if self?.config.style.contains(.single) ?? false {
                            self?.selectionContext.clear()
                        }
                    }, completedHandler: { selectItems in
                        action(output: selectItems)
                    })
                }
            }
        }
        interfaceView.stripItemDidSelected = { [weak self] (asset: MediaAsset) in
            if let strongSelf = self {
                strongSelf.scrollToItem(assetItem: asset)
            }
        }
        interfaceView.cropAction = { [weak self] in
            if let strongSelf = self {
                strongSelf.editAsset2(type: .crop)
            }
        }
        interfaceView.paintAction = { [weak self] in
            if let strongSelf = self {
                strongSelf.editAsset2(type: .paint)
            }
        }
        return interfaceView
    }()
}

extension AlbumPreviewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    fileprivate func viewControllerAtIndex(_ index: Int) -> UIViewController? {
        if index < 0 || index >= assetGroup.assetCount() {
            return nil
        }
        guard let currentAsset = assetGroup.objectAt(index: index) else {
            return nil
        }
        if currentAsset.isVideo() {
            let viewController = AlbumVideoPreviewController(asset: currentAsset, location: index)
            return viewController
        } else {
            let viewController = AlbumPhotoPreviewController(asset: currentAsset, location: index)
            return viewController
        }
    }

    public func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return viewControllerAtIndex((viewController as! AlbumPreviewItem).location() - 1)
    }

    public func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return viewControllerAtIndex((viewController as! AlbumPreviewItem).location() + 1)
    }

    public func pageViewController(_: UIPageViewController, didFinishAnimating _: Bool, previousViewControllers _: [UIViewController], transitionCompleted _: Bool) {
        requestCurrentAssetFileSize()
    }
}

extension AlbumPreviewController {

    func scrollToItem(assetItem: MediaAsset) {
        guard let currentAsset = currentVisiableItem() else {
            return
        }
        let (orderd, toIndex) = assetGroup.getAssetDirection(from: currentAsset.displayAsset(), to: assetItem)

        if orderd == .same {
            return
        }

        let direction = orderd == .descending ? UIPageViewController.NavigationDirection.reverse : UIPageViewController.NavigationDirection.forward

        let viewController: UIViewController
        if assetItem.isVideo() {
            viewController = AlbumVideoPreviewController(asset: assetItem, location: toIndex)
        } else {
            viewController = AlbumPhotoPreviewController(asset: assetItem, location: toIndex)
        }
        pageViewController.setViewControllers([viewController], direction: direction, animated: true, completion: { [weak self] _ in
            if let strongSelf = self {
                strongSelf.requestCurrentAssetFileSize()
            }
        })
    }
}
