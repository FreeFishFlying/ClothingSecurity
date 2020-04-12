//
//  AlbumPhotoPickerStripCell.swift
//  VideoPlayer-Swift
//
//  Created by Dylan on 14/04/2017.
//  Copyright © 2017 kingxt. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift
import Result
import Core

class AlbumPhotoPickerStripCell: UICollectionViewCell {
    internal static let stripCellIdentifier = "stripCellIdentifier"

    public weak var selectionContext: MediaSelectionContext?
    public var asset: MediaAsset?
    private var disposable: Disposable?

//    private lazy var checkButton: CheckButtonView = {
//        let checkButton = CheckButtonView()
//        checkButton.fillColor = UIColorRGB(0xF8E71C)
//        checkButton.addTarget(self, action: #selector(self.checkButtonClick), for: UIControl.Event.touchUpInside)
//        return checkButton
//    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(imageView)
//        contentView.addSubview(checkButton)

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
//        checkButton.snp.makeConstraints { make in
//            make.right.equalTo(-2)
//            make.top.equalTo(2)
//            make.width.height.equalTo(32)
//        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    @objc private func checkButtonClick() {
//        guard let selectionContext = selectionContext, let asset = asset else {
//            return
//        }
//        selectionContext.setItem(asset, selected: !checkButton.isSelected)
//    }

    func fillData(asset: MediaAsset?) {
        self.asset = asset
        disposable?.dispose()
        guard let asset = asset, let selectionContext = selectionContext else {
            imageView.reset()
            return
        }

        refreshEidtorImage()
        disposable = asset.eidtorChangeSignal.take(during: reactive.lifetime).observeValues { [weak self] _ in
            if let strongSelf = self {
                strongSelf.refreshEidtorImage()
            }
        }

//        checkButton.setChecked(selectionContext.isItemSelected(asset), animated: false)
//        let selectedDisposable = selectionContext.itemInformativeSelectedSignal(item: asset).take(during: reactive.lifetime).startWithValues({ [weak self] (change: SelectionChange) in
//            if let strongSelf = self {
//                strongSelf.checkButton.setChecked(change.selected, animated: change.animated)
//            }
//        })
//        disposable = CompositeDisposable([editorDisposable, selectedDisposable])
    }

    private func refreshEidtorImage() {
        imageView.reset()
        if let asset = asset {
            if let image = asset.editorResult?.editorImage {
                imageView.image = image
            } else {
                let imageSize = CGSize(width: frame.width * 1.6, height: frame.height * 1.6)
                imageView.setSignal(asset.imageSignal(imageType: .thumbnail, size: imageSize, allowNetworkAccess: true, applyEditorPresentation: true))
            }
        }
    }
}
