//
//  AlbumPreviewControllerToolbar.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 4/11/17.
//  Copyright © 2017 kingxt. All rights reserved.
//

import Foundation
import SnapKit
import ReactiveSwift
import Result
import Core

class MediaAssetsPickerToolbar: UIView {

    private let selectionContext: MediaSelectionContext
    private let config: AlbumConfig
    private let (lifetime, token) = Lifetime.make()
    private var requestImageSizeDisposable: Disposable?

    init(selectionContext: MediaSelectionContext, config: AlbumConfig) {
        self.selectionContext = selectionContext
        self.config = config
        super.init(frame: CGRect.zero)
        addSubview(gapLineView)
        gapLineView.snp.makeConstraints { make in
            make.left.right.top.equalTo(self)
            make.height.equalTo(0.5)
        }

        addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(10)
        }

        addSubview(sendButton)
        sendButton.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.right.equalTo(self).offset(-10)
        }

        addSubview(badgeView)
        badgeView.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.right.equalTo(self.sendButton.snp.left).offset(-6)
        }

        let count = selectionContext.selectedCount
        sendButton.isEnabled = count > 0
        animationBadgeView(count: count)
        calculateOriginalImageSize()
        selectionContext.dataSourceChangeSignal().take(during: lifetime).observeValues { [weak self] (count: Int) in
            if let strongSelf = self {
                strongSelf.sendButton.isEnabled = count > 0
                strongSelf.animationBadgeView(count: count)
                strongSelf.calculateOriginalImageSize()
            }
        }
        if config.style.contains(.originalImage) {
            addSubview(originalButton)
            originalButton.snp.makeConstraints { make in
                make.center.equalTo(self)
            }
            selectionContext.isSelectOriginalImage.producer.take(during: lifetime).startWithValues { [weak self] (_: Bool) in
                if let strongSelf = self {
                    strongSelf.calculateOriginalImageSize()
                }
            }
        }
    }

    deinit {
        requestImageSizeDisposable?.dispose()
    }

    private func calculateOriginalImageSize() {
        let selected = originalButton.isSelected
        if selected {
            requestCurrentAssetFileSize()
        } else {
            originalButton.setTitle(SLLocalized("MediaAssetsPicker.OriginalPicture"), for: .normal)
        }
    }

    private func requestCurrentAssetFileSize() {
        requestImageSizeDisposable?.dispose()
        if selectionContext.isSelectOriginalImage.value {
            let values: [MediaAsset] = selectionContext.selectedValues()
            var signals: [SignalProducer<UInt64, NoError>] = [SignalProducer<UInt64, NoError>]()
            for item in values {
                signals.append(item.fileSizeSignal())
            }
            requestImageSizeDisposable = SignalProducer(signals).flatten(.merge).collect().observe(on: UIScheduler()).startWithValues({ [weak self] (sizeItems: [UInt64]) in
                guard let `self` = self else {
                    return
                }
                let totoal = sizeItems.reduce(0, { $0 + $1 })
                if totoal == 0 {
                    self.originalButton.setTitle(SLLocalized("MediaAssetsPicker.OriginalPicture"), for: .normal)
                } else if totoal > 1024 * 1024 {
                    self.originalButton.setTitle(String(format: "%.1fM", Double(totoal) / (1024 * 1024)), for: .normal)
                } else {
                    self.originalButton.setTitle(String(format: "%.1fK", Double(totoal) / 1024), for: .normal)
                }
            })
        }
    }

    func animationBadgeView(count: Int) {
        badgeView.text = "\(count)"
        let incremented = Int(badgeView.text ?? "0") ?? 0 < count
        var alpha: CGFloat = 0
        if count != 0 {
            alpha = 1
        }
        if badgeView.alpha < CGFloat(Float.ulpOfOne) && alpha > CGFloat(Float.ulpOfOne) {
            badgeView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: 0.12, delay: 0, options: .curveEaseOut, animations: { () -> Void in
                self.badgeView.alpha = alpha
                self.badgeView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }, completion: { (_ finished: Bool) -> Void in
                if finished {
                    UIView.animate(withDuration: 0.08, delay: 0, options: .curveEaseIn, animations: { () -> Void in
                        self.badgeView.transform = CGAffineTransform.identity
                    }, completion: { _ in })
                }
            })
        } else if badgeView.alpha > CGFloat(Float.ulpOfOne) && alpha < CGFloat(Float.ulpOfOne) {
            UIView.animate(withDuration: 0.16, delay: 0, options: .curveEaseOut, animations: { () -> Void in
                self.badgeView.alpha = alpha
                self.badgeView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }, completion: { (_ finished: Bool) -> Void in
                if finished {
                    self.badgeView.transform = CGAffineTransform.identity
                }
            })
        } else {
            UIView.animate(withDuration: 0.12, delay: 0, options: .curveEaseOut, animations: { () -> Void in
                self.badgeView.transform = incremented ? CGAffineTransform(scaleX: 1.2, y: 1.2) : CGAffineTransform(scaleX: 0.8, y: 0.8)
            }, completion: { (_ finished: Bool) -> Void in
                if finished {
                    UIView.animate(withDuration: 0.08, delay: 0, options: .curveEaseIn, animations: { () -> Void in
                        self.badgeView.transform = CGAffineTransform.identity
                    }, completion: { _ in })
                }
            })
        }
    }

    @objc fileprivate func confirmClick() {
        let result: [MediaAsset] = selectionContext.selectedValues()
        if selectionContext.isSelectOriginalImage.value || !config.compressVideo {
            config.confirmCallback(result, selectionContext.isSelectOriginalImage.value)
        } else {
            compressVideo(assets: result) { (item: [MediaSelectableItem]) in
                self.config.confirmCallback(item, self.selectionContext.isSelectOriginalImage.value)
            }
        }
    }

    @objc fileprivate func cancelClick() {
        config.cancelCallback()
    }

    private lazy var gapLineView: UIView = {
        let gapLineView = UIView()
        gapLineView.backgroundColor = UIColorRGB(0xDCDCDC)
        return gapLineView
    }()

    private lazy var sendButton: UIButton = {
        let sendButton = UIButton()
        sendButton.setTitle(self.config.confirmTitle, for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        sendButton.setTitleColor(defaultAppearance.tintColor, for: .normal)
        sendButton.addTarget(self, action: #selector(confirmClick), for: .touchUpInside)
        sendButton.setTitleColor(.gray, for: .disabled)
        return sendButton
    }()

    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.setTitle(SLLocalized("MediaAssetsPicker.Cancel"), for: .normal)
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cancelButton.setTitleColor(defaultAppearance.tintColor, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelClick), for: .touchUpInside)
        cancelButton.setTitleColor(.gray, for: .disabled)
        return cancelButton
    }()

    private lazy var badgeView: BadgeView = {
        let badgeView = BadgeView()
        badgeView.badgeColor = defaultAppearance.tintColor
        badgeView.font = UIFont.systemFont(ofSize: 14)
        badgeView.minBadgeSize = CGSize(width: 22, height: 22)
        badgeView.textColor = defaultAppearance.badgeViewTextColor
        return badgeView
    }()

    private(set) lazy var originalButton: OriginalChooseButton = {
        let originalButton = OriginalChooseButton(frame: CGRect.zero, borderColor: .gray, fillColor: defaultAppearance.tintColor)
        originalButton.setTitle(SLLocalized("MediaAssetsPicker.OriginalPicture"), for: .normal)
        originalButton.setTitleColor(.gray, for: .normal)
        originalButton.setTitleColor(.black, for: .selected)
        originalButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        originalButton.reactive.isSelected <~ self.selectionContext.isSelectOriginalImage
        originalButton.reactive.controlEvents(UIControl.Event.touchUpInside).observe({ [weak self] (event: Signal.Event) in
            if let strongSelf = self {
                strongSelf.selectionContext.isSelectOriginalImage.value = !(event.value?.isSelected ?? true)
            }
        })
        return originalButton
    }()

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
