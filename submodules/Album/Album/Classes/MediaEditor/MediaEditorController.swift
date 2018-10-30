//
//  MediaEditorController.swift
//  Components-Swift
//
//  Created by kingxt on 2017/5/20.
//  Copyright © 2017年 liao. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import Result
import pop
import AVFoundation
import Core
import MediaEditorKit

private var imageBundle: Bundle?

public func popWhenAllAnimatedCompleted(animations: [POPAnimation], completed: @escaping (Bool) -> Void) {
    var items = animations
    var allFinished = true
    let onAnimationCompletion = { (animation: POPAnimation?, finished: Bool) in
        if !finished {
            allFinished = false
        }
        if animation != nil {
            items.remove(object: animation!)
        }
        if items.isEmpty {
            completed(allFinished)
        }
    }
    for animation in animations {
        animation.completionBlock = onAnimationCompletion
    }
}

func MediaEditorImageNamed(_ str: String) -> UIImage? {
    if imageBundle == nil {
        let frameworkBundle = Bundle(for: MeidaCropController.self)
        imageBundle = Bundle(path: frameworkBundle.bundlePath.appending("/PhotoEditor.bundle"))
    }
    let str = str.appending(".png")
    return UIImage(named: str, in: imageBundle!, compatibleWith: nil)
}

public protocol MediaEditor: class {
    func tabBarImage() -> UIImage?
    func animationTranslationInView() -> UIView
    func animationTranslationOutView(isCancelled: Bool) -> UIView?
    func fillResult(result: MediaEditorResult)
}

extension UIImage {
    class func imageByCombiningImage(firstImage: UIImage, withImage secondImage: UIImage) -> UIImage {
        UIGraphicsBeginImageContext(firstImage.size);
        firstImage.draw(at: CGPoint(x: 0,  y: 0))
        let displaySize = ImageUtils.scaleToSize(size: secondImage.size, maxSize:firstImage.size)
        let displayFrame = CGRect(origin: CGPoint(x: (firstImage.size.width - displaySize.width) / 2, y: (firstImage.size.height - displaySize.height) / 2), size: displaySize)
        secondImage.draw(in: displayFrame)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

public class MediaEditorResult {
    //oc version
    public var adjustments: AnyObject? = nil
    public var thumbnailImage: UIImage? = nil
    public var hasChanges: Bool = false
    
    //swift version
    public var editorImage: UIImage? //final editor image
    
    public var cropResult: MediaCropResult?

    public var playRate: MediaVideoSettings.PlayRate?
    public var filterResult: MediaFilterResult?
    public var videoTrimResult: CMTimeRange?
    public var caption: String?
    
    var paintHostImage: UIImage? //orignal image for crop and paint for internal usage

    func isValide() -> Bool {
        return cropResult != nil
            || playRate != nil
            || filterResult == nil
            || videoTrimResult != nil
            || editorImage != nil
            || caption != nil
    }
    
    func applyTo(image: UIImage, withCrop: Bool = true) -> UIImage {
        let image = paintHostImage != nil ? paintHostImage! : image
        var newImage = image
        if withCrop {
            newImage = cropResult?.apply(image: image) ?? image
        }
        if let currentFilter = filterResult {
            newImage = applyFilter(image: newImage, filterName: currentFilter.filterName) ?? newImage
        }
        return newImage
    }
}

public class MediaEditorContext {

    public let editorResult: MediaEditorResult

    init(editorResult: MediaEditorResult) {
        self.editorResult = editorResult
    }

    public var thumbnailSignal: SignalProducer<UIImage?, NoError>?
    public let filterSignal: (output: Signal<UIImage?, NoError>, input: Signal<UIImage?, NoError>.Observer) = Signal<UIImage?, NoError>.pipe()
    public var videoPlayItemSignal: SignalProducer<AVAsset?, RequestImageDataError>?
    public var lockedAspectRatio: CGFloat?
}

public class MediaEditorController: UIViewController {
    
    static let bottomBarHeight: CGFloat = 40
    static let operationViewHeight: CGFloat = 120
    
    static let previewImageViewGap: CGFloat = 9

    public struct EditorType: OptionSet {

        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        static let crop = EditorType(rawValue: 1)
        static let videoEditor = EditorType(rawValue: 1 << 1)
        static let imageFilter = EditorType(rawValue: 1 << 2)
        static let imagePaint = EditorType(rawValue: 1 << 3)
    }

    public var didCancel: (() -> Void)?
    public var didConfirm: ((_: MediaEditorResult?) -> Void)?

    private var editors: [MediaEditor] = [MediaEditor]()

    private let editorContext: MediaEditorContext
    private let animationContext: AnimationTranslationContext
    private var previousSelectedIndex: Int = 0
    private var isAnimating = false

    public init(editorType: EditorType, editorContext: MediaEditorContext, animationContext: AnimationTranslationContext) {
        self.editorContext = editorContext
        self.animationContext = animationContext
        super.init(nibName: nil, bundle: nil)
        setupEditors(editorType: editorType)
    }

    private func setupEditors(editorType: EditorType) {
        if editorType.contains(.crop) {
            editors.append(MeidaCropController(editorContext: editorContext, animationContext: animationContext, lockedAspectRatio: editorContext.lockedAspectRatio))
        }
        if editorType.contains(.imagePaint) {
            editors.append(MediaPaintViewController(editorContext: editorContext, animationContext: animationContext))
        }
        if editorType.contains(.videoEditor) {
            editors.append(MediaEditorVideoController(editorContext: editorContext, animationContext: animationContext))
        }
//        if editorType.contains(.imageFilter) && operatingSystem.majorVersion >= 9 {
            //ios8 -[CIContext initWithOptions:]: unrecognized selector sent to instance
//            editors.append(MediaFilterController(editorContext: editorContext, animationContext: animationContext))
//        }
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        super.loadView()
        view.addSubview(editToolbar)
        showCurrentEditorView(selectedIndex: 0)

        let isVerticalLayout = view.bounds.size.width < view.bounds.size.height || isIpad()
        layout(isVerticalLayout: isVerticalLayout)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        editToolbar.selectedIndex.producer.skip(first: 1).startWithValues { [weak self] selectedIndex in
            if let strongSelf = self {
                if strongSelf.previousSelectedIndex != selectedIndex {
                    strongSelf.showCurrentEditorView(selectedIndex: selectedIndex)
                }
            }
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.layoutIfNeeded()
        animationTranslationIn()
    }

    private func showCurrentEditorView(selectedIndex: Int) {
        if isAnimating {
            return
        }
        let previousEditor = editors[previousSelectedIndex] as! UIViewController
        if previousEditor.isViewLoaded {
            editors[previousSelectedIndex].fillResult(result: editorContext.editorResult)
            previousEditor.removeFromParent()
        }

        let currentEditor = editors[selectedIndex] as! UIViewController
        addChild(currentEditor)
        var safeBottomAreaHeight: CGFloat = 0
        if #available(iOS 11.0, *) {
            safeBottomAreaHeight = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        }
        var marginTop: CGFloat = 2 * MediaEditorController.previewImageViewGap
        if #available(iOS 11.0, *) {
            marginTop = UIApplication.shared.keyWindow!.safeAreaInsets.top + MediaEditorController.previewImageViewGap
        }
        view.insertSubview(currentEditor.view, belowSubview: editToolbar)
        currentEditor.view.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(marginTop)
            make.size.equalTo(CGSize(width: view.bounds.size.width, height: view.bounds.size.height - MediaEditorController.bottomBarHeight - safeBottomAreaHeight - marginTop))
        }
        
        if selectedIndex != previousSelectedIndex {
            isAnimating = true
            UIView.transition(from: previousEditor.view, to: currentEditor.view, duration: 0.25, options: .transitionCrossDissolve, completion: { _ in
                self.isAnimating = false
            })
        }
        view.bringSubviewToFront(editToolbar)
        previousSelectedIndex = selectedIndex
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let layoutVertical = size.width < size.height || isIpad()
        layout(isVerticalLayout: layoutVertical)
    }

    func layout(isVerticalLayout: Bool) {
        if isVerticalLayout {
            editToolbar.snp.remakeConstraints { make in
                make.left.right.equalTo(view)
                if #available(iOS 11, *) {
                    make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                } else {
                    make.bottom.equalToSuperview()
                }
                make.height.equalTo(40)
            }
        } else {
            editToolbar.snp.remakeConstraints { make in
                make.top.bottom.right.equalTo(view)
                make.width.equalTo(40)
            }
        }
        editToolbar.layoutIfNeeded()
        editToolbar.layout(isVerticalLayout: isVerticalLayout)
    }

    func currentEditor() -> MediaEditor {
        return editors[editToolbar.selectedIndex.value]
    }

    private func collectResult() {
        for editor in editors {
            let controller = editor as! UIViewController
            if controller.isViewLoaded {
                editor.fillResult(result: editorContext.editorResult)
            }
        }
        if let image = editorContext.editorResult.paintHostImage {
            editorContext.editorResult.editorImage = editorContext.editorResult.applyTo(image: image)
        }
    }

    private func animationTranslationIn() {
        let targetView = currentEditor().animationTranslationInView()
        animationContext.stateChangeSignal().startWithValues { [weak self] state in
            switch state {
            case .willTranslationIn:
                self?.editToolbar.alpha = 0
                UIView.animate(withDuration: 0.3) {
                    self?.editToolbar.alpha = 1
                }
            default: break
            }
        }
        if !animationContext.translationIn(on: view, toRect: targetView.superview!.convert(targetView.frame, to: view)) {
            print("animated in error")
        }
    }

    private func animationTranslationOut(isCancelled: Bool) {
        if let dismissalView = currentEditor().animationTranslationOutView(isCancelled: isCancelled) {
            animationContext.dismissalView = dismissalView
        }
        animationContext.stateChangeSignal().startWithValues { [weak self] state in
            switch state {
            case .willTranslationOut:
                self?.editToolbar.alpha = 1
                UIView.animate(withDuration: 0.3) {
                    self?.editToolbar.alpha = 0
                }
            case .didTranslationOut:
                if let strongSelf = self {
                    if isCancelled {
                        strongSelf.didCancel?()
                    } else {
                        if strongSelf.editorContext.editorResult.isValide() {
                            strongSelf.didConfirm?(strongSelf.editorContext.editorResult)
                        } else {
                            strongSelf.didConfirm?(nil)
                        }
                    }
                }
            default: break
            }
        }
        animationContext.translationOut(on: view, delayHideTime: 0.2)

        let animationBackground = POPBasicAnimation(propertyNamed: kPOPViewBackgroundColor)
        animationBackground?.autoreverses = false
        animationBackground?.removedOnCompletion = true
        animationBackground?.fromValue = UIColor.black
        animationBackground?.toValue = UIColor.clear
        view.pop_add(animationBackground, forKey: "animationBackground")
    }

    private lazy var editToolbar: MediaEditorToolbar = {
        var taps: [UIImage] = [UIImage]()
        for editor in self.editors {
            taps.append(editor.tabBarImage() ?? UIImage())
        }
        let toolbar = MediaEditorToolbar(taps: taps)
        toolbar.didCancel = { [weak self] () in
            self?.animationTranslationOut(isCancelled: true)
        }
        toolbar.didConfirm = { [weak self] () in
            self?.collectResult()
            self?.animationTranslationOut(isCancelled: false)
        }
        return toolbar
    }()
}
