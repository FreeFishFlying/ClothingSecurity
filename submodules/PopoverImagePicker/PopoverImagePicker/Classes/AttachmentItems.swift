//
//  AttachmentItems.swift
//  Components-Swift
//
//  Created by Dylan on 18/05/2017.
//  Copyright © 2017 liao. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import ActionSheet
import Album

public class AttachmentCarouseItemView: ActionSheetItemView {
    
    private lazy var carouseView: AttachmentCarouseView = {
        let carouseView = AttachmentCarouseView(frame: .zero, style: [.multiChoose, .originalImage, .editEnabled, .captionEnabled], confirmTitle: SLLocalized("MediaAssetsPicker.Send"))
        carouseView.dragToSend = true
        return carouseView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(carouseView)
        carouseView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(198.0)
        }
    }
    
    override public var preferredHeight: CGFloat {
        get {
            return 198.0
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var selectionChangeSignal: Signal<(Int, Int, UInt64?), NoError> {
        return carouseView.selectionSignal.take(during: reactive.lifetime)
    }
    
    public var selectedAsset: [MediaAsset] {
        return carouseView.selectedAsset
    }
    
    public var cameraPickAssetSignal: Signal<MediaSelectableItem, NoError> {
        return carouseView.cameraPickAssetSignal
    }
    
    public var didClickSendSignal: Signal<([MediaSelectableItem], Bool), NoError> {
        return carouseView.didClickSendSignal
    }
    
    public func showCarousePreview() {
        carouseView.showCarousePreview(indexPath: nil, showEditor: true)
    }
    
    public func showCameraController() {
        carouseView.showCameraController()
    }
}

public class AttachmentSendItemView: ActionSheetItemView {
    
    private lazy var sendButton: ActionSheetButtonItemView = {
        let sendButton = ActionSheetButtonItemView(frame: CGRect.zero)
        sendButton.title = SLLocalized("CarouseAttachment.Send")
        return sendButton
    }()
    
    private lazy var originalButton: ActionSheetButtonItemView = {
        let originalButton = ActionSheetButtonItemView(frame: CGRect.zero)
        originalButton.title = SLLocalized("CarouseAttachment.SendOriginal")
        return originalButton
    }()
    
    private lazy var captionButton: ActionSheetButtonItemView = {
        let captionButton = ActionSheetButtonItemView(frame: CGRect.zero)
        captionButton.title = SLLocalized("CarouseAttachment.EditorCaption")
        return captionButton
    }()
    
    private lazy var cancelButton: ActionSheetButtonItemView = {
        let cancelButton = ActionSheetButtonItemView(frame: CGRect.zero)
        cancelButton.title = SLLocalized("CarouseAttachment.Cancel")
        return cancelButton
    }()
    
    public var sendSignal: Signal<UIButton, NoError> {
        return sendButton.clickSignal.take(during: reactive.lifetime)
    }
    
    public var originalSendSignal: Signal<UIButton, NoError> {
        return originalButton.clickSignal.take(during: reactive.lifetime)
    }
    
    public var captionSignal: Signal<UIButton, NoError> {
        return captionButton.clickSignal.take(during: reactive.lifetime)
    }
    
    public var cancelSignal: Signal<UIButton, NoError> {
        return cancelButton.clickSignal.take(during: reactive.lifetime)
    }
    
    private var originalSize: UInt64?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        initializeSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var preferredHeight: CGFloat {
        get {
            return 200.0
        }
    }
    
    private func initializeSubviews() {
        addSubview(sendButton)
        addSubview(originalButton)
        addSubview(captionButton)
        addSubview(cancelButton)
        
        sendButton.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(50)
        }
        originalButton.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(sendButton.snp.bottom)
            make.height.equalTo(50)
        }
        captionButton.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(originalButton.snp.bottom)
            make.height.equalTo(50)
        }
        cancelButton.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(captionButton.snp.bottom)
            make.height.equalTo(50)
        }
    }
    
    public func update(imageCount: Int, videoCount: Int, size: UInt64?) {
        var title: String?
        var originalTitle: String = SLLocalized("CarouseAttachment.SendOriginal")
        if imageCount > 0 && videoCount > 0 {
            title = String(format: SLLocalized("CarouseAttachment.SendImageVideo"), imageCount, videoCount)
            originalTitle = String(format: SLLocalized("CarouseAttachment.SendOriImageVideo"), imageCount, videoCount)
        } else if imageCount > 0  {
            title = String(format: SLLocalized("CarouseAttachment.SendImage"), imageCount)
            originalTitle = String(format: SLLocalized("CarouseAttachment.SendOriImage"), imageCount)
        } else if videoCount > 0 {
            title = String(format: SLLocalized("CarouseAttachment.SendVideo"), videoCount)
            originalTitle = String(format: SLLocalized("CarouseAttachment.SendOriVideo"), videoCount)
        }
        if let size = size {
            self.originalSize = size
        }
        if let total = self.originalSize {
            let str: String
            if total > 1024 * 1024 {
                str = String(format: SLLocalized("CarouseAttachment.FileSizeMB"), Double(total) / (1024 * 1024))
            } else {
                str = String(format: SLLocalized("CarouseAttachment.FileSizeKB"), Double(total) / 1024)
            }
            originalTitle = originalTitle + str
        }
        sendButton.title = title
        originalButton.title = originalTitle
    }
}
