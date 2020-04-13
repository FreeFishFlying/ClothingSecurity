//
//  MediaPickerCell.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 2017/4/5.
//  Copyright © 2017年 kingxt. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import ReactiveSwift
import Core

let MediaPickerPhotoCellKind = "MediaPickerPhotoCellKind"

class MediaPickerCell: UICollectionViewCell {

    public var selectionContext: MediaSelectionContext?
    private var disposable: Disposable?
    private var asset: MediaAsset?

    private lazy var checkButton: CheckBadgeButton = {
        let button = CheckBadgeButton(buttonSize: CGSize(width: 25, height: 25))
        button.addTarget(self, action: #selector(self.checkButtonPressed), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView)
        }
        contentView.addSubview(checkButton)
        checkButton.snp.makeConstraints { make in
            make.right.equalTo(-2)
            make.top.equalTo(2)
            make.width.equalTo(self.checkButton.frame.size.width)
            make.height.equalTo(self.checkButton.frame.size.height)
        }
    }

    func setMultiChoose(enabled: Bool) {
        checkButton.isHidden = !enabled
    }

    deinit {
        self.disposable?.dispose()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func checkButtonPressed() {
        if let asset = self.asset {
            selectionContext?.setItem(asset, selected: !checkButton.isSelected)
        }
    }

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    func fillData(asset: MediaAsset?) {
        self.asset = asset
        if asset == nil {
            imageView.reset()
            return
        }
        disposable?.dispose()
        let length = frame.size.width * 1.6
        if let selectionContext = self.selectionContext, let asset = asset {
            imageView.setSignal(asset.imageSignal(imageType: .thumbnail, size: CGSize(width: length, height: length), allowNetworkAccess: false, applyEditorPresentation: true))
            let editorDisposable = asset.eidtorChangeSignal.take(during: reactive.lifetime).observeValues({ [weak self] (_: MediaEditorResult?) in
                if let strongSelf = self {
                    if let asset = strongSelf.asset {
                        strongSelf.imageView.setSignal(asset.imageSignal(imageType: .thumbnail, size: CGSize(width: length, height: length), allowNetworkAccess: false, applyEditorPresentation: true))
                    }
                }
            })
            checkButton.setChecked(selectionContext.itemIndex(asset), animated: false)
            isSelected = checkButton.isSelected
            let selectedDisposable = selectionContext.itemInformativeSelectedSignal(item: asset).take(during: reactive.lifetime).startWithValues({ [weak self] (change: SelectionChange) in
                if let strongSelf = self {
                    strongSelf.checkButton.setChecked(change.index ?? 0, animated: change.animated)
                    strongSelf.isSelected = change.selected
                }
            })
            disposable = CompositeDisposable([editorDisposable, selectedDisposable])
        }
    }
}
