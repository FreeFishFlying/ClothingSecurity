//
//  AlbumPreviewInterfaceView.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 4/12/17.
//  Copyright © 2017 kingxt. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import Result
import PinLayout
import Core

class AlbumPreviewInterfaceView: UIView {

    private let config: AlbumConfig
    private let selectionContext: MediaSelectionContext
    private var disposable: Disposable?
    private(set) var actionAsset: MediaAsset?
    private lazy var selectionStripContext: MediaSelectionStripContext = {
        let selectionStripContext = MediaSelectionStripContext(items: self.selectionContext.selectedValues())
        return selectionStripContext
    }()

    public var isPublishPreview: Bool?
    public var backAction: (() -> Void)?
    public var confirmAction: (() -> Void)?
    public var cropAction: (() -> Void)?
    public var paintAction: (() -> Void)?

    public var stripItemDidSelected: ((MediaAsset) -> Void)? {
        didSet {
            if let stripView = self.selectedPhotoView {
                stripView.stripItemDidSelected = stripItemDidSelected
            }
        }
    }

    init(config: AlbumConfig, selectionContext: MediaSelectionContext, displayCounter: Bool) {
        self.config = config
        self.selectionContext = selectionContext
        super.init(frame: CGRect.zero)

        addSubview(bottomToolbar)

        if canInputCaption {
            addSubview(captionInputView)
        }

        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        bottomToolbar.addSubview(backgroundView)

        bottomToolbar.snp.makeConstraints { make in
            make.left.right.equalTo(self)
            if #available(iOS 11, *) {
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
            make.height.equalTo(46)
        }

        backgroundView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(bottomToolbar)
            make.height.equalTo(200)
        }

        bottomToolbar.addSubview(sendButton)
        sendButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.bottomToolbar)
            make.right.equalTo(self).offset(-10)
        }

        bottomToolbar.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.bottomToolbar)
            make.left.equalTo(self).offset(10)
        }

        bottomToolbar.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.left.equalTo(50)
            make.right.equalTo(-50)
            make.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(1)
        }

        addSubview(checkButton)
        checkButton.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.top.equalTo(10)
            make.width.equalTo(self.checkButton.frame.size.width)
            make.height.equalTo(self.checkButton.frame.size.height)
        }
        checkButton.isHidden = !self.config.style.contains(.multiChoose)

        if displayCounter {
            addSubview(counterButton)
            counterButton.snp.makeConstraints { make in
                make.right.equalToSuperview()
                make.bottom.equalTo(self.bottomToolbar.snp.top).offset(-50)
                make.width.equalTo(91)
                make.height.equalTo(38)
            }
            counterButton.isHidden = selectionContext.selectedCount == 0
            counterButton.selectedCount = selectionContext.selectedCount
            selectionContext.dataSourceChangeSignal().take(during: reactive.lifetime).observeValues { [weak self] count in
                if let strongSelf = self {
                    strongSelf.counterButton.selectedCount = count
                }
            }
        }

        addGestureRecognizer(tapGestureRecognizer)
        addNotification()
    }

    fileprivate lazy var canInputCaption: Bool = {
        self.config.style.contains(.captionEnabled)
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        if canInputCaption {
            captionInputView.pin.bottomLeft(to: bottomToolbar.anchor.topLeft).right(0).height(44)
        }
    }

    func action(asset: MediaAsset) {
        if actionAsset == nil || actionAsset! !== asset {
            checkButton.setChecked(selectionContext.itemIndex(asset), animated: false)
            disposable?.dispose()
            disposable = selectionContext.itemInformativeSelectedSignal(item: asset).startWithValues({ [weak self] (change: SelectionChange) in
                if let strongSelf = self {
                    strongSelf.checkButton.setChecked(change.index ?? 0, animated: change.animated)
                }
            })
            actionAsset = asset

            var marginTop: CGFloat = 10
            if #available(iOS 11.0, *) {
                marginTop = UIApplication.shared.keyWindow!.safeAreaInsets.top
            }
            if asset.isVideo() {
                checkButton.snp.updateConstraints({ make in
                    make.top.equalTo(70 + marginTop)
                })
                if canInputCaption {
                    captionInputView.isHidden = true
                }
            } else {
                checkButton.snp.updateConstraints({ make in
                    make.top.equalTo(marginTop)
                })
                if canInputCaption {
                    captionInputView.isHidden = false
                }
            }

            stackView.arrangedSubviews.forEach({ (view) in
                stackView.removeArrangedSubview(view)
            })
            if config.style.contains(.editEnabled) && !asset.isGif() && !asset.isVideo() {
                stackView.addArrangedSubview(cropButton)
                stackView.addArrangedSubview(paintButton)
            }
            if config.style.contains(.originalImage) && !asset.isGif() {
                let view = UIView(frame: CGRect.zero)
                view.addSubview(originalButton)
                originalButton.snp.makeConstraints({ (make) in
                    make.centerY.equalToSuperview()
                    make.centerX.equalToSuperview().offset(-2)
                })
                stackView.addArrangedSubview(view)
            }
            if canInputCaption {
                captionInputView.text = asset.editorResult?.caption ?? ""
            }
        }
    }

    private let stackView: StackView = {
        let stackView = StackView()
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.isLayoutMarginsRelativeArrangement = false
        return stackView
    }()

    func unSelectCountButtonIfNeed() {
        guard config.style.contains(.multiChoose) else {
            return
        }
        if !counterButton.isHidden && counterButton.isSelected {
            counterButton.isSelected = false
            selectedPhotoView?.setHidden(hidden: true, animation: true)
        }
    }

    deinit {
        self.disposable?.dispose()
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if canInputCaption && captionInputView.isFirstResponder {
            return view
        }
        if let v = view {
            if v is UIButton {
                return v
            } else if selectedPhotoView != nil && v.isDescendant(of: selectedPhotoView!) {
                return v
            } else if canInputCaption && v.isDescendant(of: captionInputView) {
                return v
            }
        }
        return nil
    }

    @objc func checkButtonPressed() {
        guard let asset = self.actionAsset else {
            return
        }
        let selected = !checkButton.isSelected
        selectionContext.setItem(asset, selected: !checkButton.isSelected)
        if selected {
            selectionStripContext.addSelectedItem(item: asset)
        } else {
            selectionStripContext.removeSelectedItem(item: asset)
        }
    }

    @objc fileprivate func confirmClick() {
        if let isPublishPreview = isPublishPreview {
            if !isPublishPreview {
                selectionContextStatus()
            }
        } else {
            selectionContextStatus()
        }
        guard let confirmAction = self.confirmAction else {
            return
        }
        confirmAction()
    }

    func selectionContextStatus() {
        if selectionContext.selectedCount == 0 {
            if let asset = self.actionAsset {
                selectionContext.setItem(asset, selected: true)
            }
        }
    }

    @objc fileprivate func cancelClick() {
        guard let backAction = self.backAction else {
            return
        }
        backAction()
    }

    @objc fileprivate func cropAsset() {
        cropAction?()
    }

    @objc fileprivate func paintAsset() {
        paintAction?()
    }

    private func counterClick() {
        guard config.style.contains(.multiChoose) else {
            return
        }
        counterButton.isSelected = !counterButton.isSelected
        if counterButton.isSelected {
            if selectedPhotoView == nil {
                createSelectedPhotoStripView()
            }
            guard let selectedPhotoView = selectedPhotoView else {
                return
            }
            selectedPhotoView.setHidden(hidden: false, animation: true)
        } else {
            guard let selectedPhotoView = selectedPhotoView else {
                return
            }
            selectedPhotoView.setHidden(hidden: true, animation: true)
        }
    }

    private func createSelectedPhotoStripView() {
        let stripView = AlbumPhotoPickerStripView(stripContext: selectionStripContext, selectionContext: selectionContext)
        let photoViewSize: CGSize = stripView.photoThumbnailSize()
        addSubview(stripView)
        stripView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(photoViewSize.height + 8)
            make.bottom.equalTo(counterButton.snp.top).offset(-14)
        }
        stripView.layoutIfNeeded()
        stripView.stripItemDidSelected = stripItemDidSelected
        selectedPhotoView = stripView
    }

    private func onCaptionChanged(text: String) {
        if actionAsset?.editorResult == nil {
            actionAsset?.editorResult = MediaEditorResult()
        }
        actionAsset?.editorResult?.caption = text
    }

    private lazy var bottomToolbar: UIView = {
        let bottomToolbar = UIView()
        return bottomToolbar
    }()

    private lazy var cropButton: UIButton = {
        let button = UIButton()
        button.hitTestEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        button.addTarget(self, action: #selector(cropAsset), for: .touchUpInside)
        button.setTitle(SLLocalized("剪裁/旋转"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.autoHighlight = true
        return button
    }()

    private lazy var sendButton: UIButton = {
        let sendButton = UIButton()
        sendButton.setTitle(self.config.confirmTitle, for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.addTarget(self, action: #selector(confirmClick), for: .touchUpInside)
        sendButton.setTitleColor(.gray, for: .disabled)
        sendButton.autoHighlight = true
        return sendButton
    }()

    private lazy var paintButton: UIButton = {
        let button = UIButton()
        button.hitTestEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        button.addTarget(self, action: #selector(paintAsset), for: .touchUpInside)
        button.setTitle(SLLocalized("涂鸦"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.autoHighlight = true
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.setTitle(SLLocalized("MediaAssetsPicker.Back"), for: .normal)
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelClick), for: .touchUpInside)
        cancelButton.setTitleColor(.gray, for: .disabled)
        cancelButton.autoHighlight = true
        return cancelButton
    }()

    private lazy var checkButton: UIButton = {
        let checkButton = CheckBadgeButton(buttonSize: CGSize(width: 28, height: 28), fontSize: 17)
        checkButton.addTarget(self, action: #selector(self.checkButtonPressed), for: .touchUpInside)
        return checkButton
    }()

    private(set) lazy var originalButton: OriginalChooseButton = {
        let originalButton = OriginalChooseButton(frame: CGRect.zero)
        originalButton.setTitle(SLLocalized("MediaAssetsPicker.OriginalPicture"), for: .normal)
        originalButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        originalButton.reactive.isSelected <~ self.selectionContext.isSelectOriginalImage
        originalButton.reactive.controlEvents(UIControl.Event.touchUpInside).observe({ [weak self] (event: Signal<OriginalChooseButton, NoError>.Event) in
            if let strongSelf = self {
                strongSelf.selectionContext.isSelectOriginalImage.value = !(event.value?.isSelected ?? true)
            }
        })
        return originalButton
    }()

    fileprivate lazy var captionInputView: CaptionInputView = {
        let input = CaptionInputView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 320, height: 44)))
        input.backgroundColor = UIColorRGBA(0x000000, 0.9)
        input.confirmInputCallback = { [weak self] (text: String) in
            self?.onCaptionChanged(text: text)
        }
        return input
    }()

    private lazy var counterButton: AlbumPhotoPickerCounterButton = {
        let counterButton = AlbumPhotoPickerCounterButton()
        counterButton.reactive.controlEvents(UIControl.Event.touchUpInside).observe({ [weak self] (_: Signal<AlbumPhotoPickerCounterButton, NoError>.Event) in
            if let strongSelf = self {
                strongSelf.counterClick()
            }
        })
        return counterButton
    }()

    fileprivate lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapView))
        recognizer.isEnabled = false
        return recognizer
    }()

    private var selectedPhotoView: AlbumPhotoPickerStripView?

    public func begainInputCaption() {
        for window in UIApplication.shared.windows {
            window.endEditing(true)
        }
        captionInputView.becomeFirstResponder()
    }
}

extension AlbumPreviewInterfaceView {
    fileprivate func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc fileprivate func keyboardWillShow() {
        tapGestureRecognizer.isEnabled = true
    }

    @objc fileprivate func keyboardWillHide() {
        tapGestureRecognizer.isEnabled = false
    }

    @objc fileprivate func tapView() {
        if canInputCaption {
            captionInputView.resignFirstResponder()
        }
    }
}
