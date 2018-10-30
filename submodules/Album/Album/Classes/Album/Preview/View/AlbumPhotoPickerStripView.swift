//
//  AlbumPhotoPickerStripView.swift
//  VideoPlayer-Swift
//
//  Created by Dylan on 13/04/2017.
//  Copyright © 2017 kingxt. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import SnapKit
import pop
import Core

private let containerMargin: CGFloat = 4

class AlbumPhotoPickerStripView: UIView {

    internal var dataSource: [MediaAsset]?
    public weak var selectionContext: MediaSelectionContext?
    public var stripItemDidSelected: ((MediaAsset) -> Void)?
    fileprivate var wrapperCenterConstraint: Constraint?
    private var lastRefreshFrame: CGRect?

    private static let backgroundImage: UIImage = {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 6, height: 6), false, 0.0)
        let context: CGContext? = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColorRGBA(0, 0.9).cgColor)
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: CGFloat(6), height: CGFloat(6)), cornerRadius: 2)
        path.fill()
        let background = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))
        UIGraphicsEndImageContext()
        return background!
    }()

    fileprivate lazy var wrapperView: UIView = {
        let wrapperView = UIView()
        wrapperView.alpha = 0
        return wrapperView
    }()

    fileprivate lazy var backgroundView: UIImageView = {
        let backgroundView = UIImageView()
        backgroundView.image = AlbumPhotoPickerStripView.backgroundImage
        return backgroundView
    }()

    fileprivate lazy var collectionView: AlbumStripCollectionView = {
        let collectionView = AlbumStripCollectionView(frame: CGRect.zero, collectionViewLayout: self.collectionViewLayout)
        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceVertical = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(AlbumPhotoPickerStripCell.self, forCellWithReuseIdentifier: AlbumPhotoPickerStripCell.stripCellIdentifier)
        return collectionView
    }()

    fileprivate lazy var collectionViewLayout: AlbumStripCollectionViewLayout = {
        let collectionViewLayout = AlbumStripCollectionViewLayout()
        collectionViewLayout.scrollDirection = .horizontal
        let height = self.photoThumbnailSize().height - 0.5
        collectionViewLayout.itemSize = CGSize(width: height, height: height)
        collectionViewLayout.minimumLineSpacing = 2
        collectionViewLayout.sectionInset = UIEdgeInsets.zero
        collectionViewLayout.minimumInteritemSpacing = 2
        return collectionViewLayout
    }()

    fileprivate lazy var maskCollectionView: UIView = {
        let maskView = UIView()
        maskView.clipsToBounds = true
        return maskView
    }()

    init(stripContext: MediaSelectionStripContext, selectionContext: MediaSelectionContext) {
        super.init(frame: CGRect.zero)
        self.selectionContext = selectionContext
        dataSource = stripContext.assetItems
        stripContext.dataSourceChangeSignal().observeValues { [weak self] (change: MediaSelectionStripContext.StripContextChange) in
            if let strongSelf = self {
                strongSelf.stripContextDidChange(change: change)
            }
        }
        initializeSubview()
    }

    private override init(frame: CGRect) {
        super.init(frame: frame)
    }

    private func initializeSubview() {
        addSubview(wrapperView)
        wrapperView.addSubview(backgroundView)
        wrapperView.addSubview(maskCollectionView)
        maskCollectionView.addSubview(collectionView)

        let photoSize = photoThumbnailSize()
        wrapperView.snp.makeConstraints { make in
            make.left.right.height.equalToSuperview()
            self.wrapperCenterConstraint = make.centerY.equalToSuperview().offset(photoSize.height).constraint
        }
        backgroundView.snp.makeConstraints { make in
            make.height.centerY.equalToSuperview()
            make.right.equalTo(-4)
            make.width.equalTo(photoSize.width + 8)
        }
        maskCollectionView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().offset(-8)
            make.right.equalTo(-8)
            make.width.equalTo(photoSize.width)
        }
        collectionView.snp.makeConstraints { make in
            make.top.bottom.equalTo(maskCollectionView)
            make.left.equalToSuperview().offset(-40)
            make.right.equalToSuperview().offset(40)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if let v = view {
            if v is UICollectionView {
                return v
            } else if v.isDescendant(of: collectionView) {
                return v
            }
        }
        return nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if lastRefreshFrame == nil {
            layoutCollectionView()
        } else if !frame.equalTo(lastRefreshFrame!) {
            layoutCollectionView()
        }
        lastRefreshFrame = frame
    }
}

extension AlbumPhotoPickerStripView {
    func stripContextDidChange(change: MediaSelectionStripContext.StripContextChange) {
        let indexPath = IndexPath(row: change.index, section: 0)

        if change.add {
            dataSource = change.assetItems
            insertItem(at: indexPath)
        } else if change.assetItems.count == 0 {
            setHidden(hidden: true, animation: true) { [weak self] _ in
                if let strongSelf = self {
                    strongSelf.dataSource = change.assetItems
                    strongSelf.collectionView.reloadData()
                }
            }
        } else {
            dataSource = change.assetItems
            deleteItem(indexPath: indexPath)
        }
    }

    private func insertItem(at indexPath: IndexPath) {
        UIView.performWithoutAnimation {
            self.collectionView.performBatchUpdates({
                self.collectionView.insertItems(at: [indexPath])
            }, completion: { _ in
                UIView.animate(withDuration: 0.3, animations: {
                    self.layoutCollectionView()
                }, completion: { _ in

                })
                var contentOffset = self.collectionView.contentOffset
                contentOffset.x = self.collectionView.contentSize.width - self.collectionView.frame.size.width + self.collectionView.contentInset.left
                self.collectionView.setContentOffset(contentOffset, animated: true)
            })
        }
    }

    private func deleteItem(indexPath: IndexPath) {
        collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at: [indexPath])
        }, completion: { _ in

        })
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutCollectionView()
        }, completion: { _ in

        })
        let itemsCount = dataSource?.count ?? 0
        if itemsCount > 0 && itemsCount < 4 {
            let scrollToIndexPath = IndexPath(row: itemsCount - 1, section: 0)
            collectionView.scrollToItem(at: scrollToIndexPath, at: .right, animated: true)
        }
    }

    public func setHidden(hidden: Bool, animation: Bool, completion: ((Bool) -> Swift.Void)? = nil) {
        if animation {
            isHidden = false
            let photoSize = photoThumbnailSize()
            if hidden {
                if let _ = self.wrapperView.pop_animation(forKey: "hide_opacity") {
                    return
                }
                wrapperView.pop_removeAllAnimations()
                wrapperCenterConstraint?.layoutConstraint?.pop_removeAllAnimations()

                let centerAnimation = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
                if let centerAnimation = centerAnimation {
                    centerAnimation.springSpeed = 12
                    centerAnimation.springBounciness = 7
                    centerAnimation.fromValue = wrapperView.center.y - wrapperView.frame.size.height / 2
                    centerAnimation.toValue = photoSize.height / 3
                    centerAnimation.completionBlock = { (_: POPAnimation?, finished: Bool) -> Void in
                        if finished {
                            self.isHidden = true
                            self.alpha = 1
                        }
                        if let completion = completion {
                            completion(finished)
                        }
                    }
                    wrapperCenterConstraint?.layoutConstraint?.pop_add(centerAnimation, forKey: "hide_center")
                }

                let opacityAnimation = POPSpringAnimation(propertyNamed: kPOPViewAlpha)
                if let opacityAnimation = opacityAnimation {
                    opacityAnimation.springSpeed = 12
                    opacityAnimation.springBounciness = 7
                    opacityAnimation.fromValue = wrapperView.alpha
                    opacityAnimation.toValue = 0
                    wrapperView.pop_add(opacityAnimation, forKey: "hide_opacity")
                }
            } else {
                if let _ = self.wrapperView.pop_animation(forKey: "show_opacity") {
                    return
                }
                wrapperView.pop_removeAllAnimations()
                wrapperCenterConstraint?.layoutConstraint?.pop_removeAllAnimations()

                let centerAnimation = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
                if let centerAnimation = centerAnimation {
                    wrapperCenterConstraint?.update(inset: photoSize.height)
                    centerAnimation.springSpeed = 12
                    centerAnimation.springBounciness = 7
                    let currentCenterY = wrapperView.center.y - wrapperView.frame.size.height / 2
                    centerAnimation.fromValue = currentCenterY <= 0 ? photoSize.height / 3 : currentCenterY
                    centerAnimation.toValue = 0
                    centerAnimation.completionBlock = { (_: POPAnimation?, finished: Bool) -> Void in
                        if finished {
                            self.isHidden = false
                            self.alpha = 1
                        }
                        if let completion = completion {
                            completion(finished)
                        }
                    }
                    wrapperCenterConstraint?.layoutConstraint?.pop_add(centerAnimation, forKey: "show_center")
                }

                let opacityAnimation = POPSpringAnimation(propertyNamed: kPOPViewAlpha)
                if let opacityAnimation = opacityAnimation {
                    opacityAnimation.springSpeed = 12
                    opacityAnimation.springBounciness = 7
                    opacityAnimation.fromValue = wrapperView.alpha
                    opacityAnimation.toValue = 1
                    wrapperView.pop_add(opacityAnimation, forKey: "show_opacity")
                }
            }
        } else {
            isHidden = hidden
            wrapperView.pop_removeAllAnimations()
            wrapperCenterConstraint?.update(offset: 0)
            if let completion = completion {
                completion(true)
            }
        }
    }

    func layoutCollectionView() {
        guard let dataSource = dataSource else {
            return
        }
        let numberOfItems = CGFloat(dataSource.count)

        var contentWidth = numberOfItems * (collectionViewLayout.itemSize.width + collectionViewLayout.minimumInteritemSpacing) - collectionViewLayout.minimumInteritemSpacing
        if frame.size.width < contentWidth + 16 {
            collectionView.snp.remakeConstraints { make in
                make.center.equalTo(wrapperView)
                make.top.bottom.equalTo(maskCollectionView)
                make.width.equalTo(64 + self.frame.size.width)
            }
        } else {
            collectionView.snp.remakeConstraints { make in
                make.top.bottom.equalTo(maskCollectionView)
                make.centerX.equalTo(maskCollectionView)
                make.width.equalTo(contentWidth + 80)
            }
        }
        contentWidth = min(frame.size.width - 8, contentWidth + 8)
        backgroundView.snp.updateConstraints { make in
            make.width.equalTo(contentWidth)
        }
        maskCollectionView.snp.updateConstraints { make in
            make.width.equalTo(contentWidth - 8)
        }
        wrapperView.layoutIfNeeded()
    }
}

extension AlbumPhotoPickerStripView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    public func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        guard let dataSource = dataSource else {
            return 0
        }
        return dataSource.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dataSource = dataSource else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: AlbumPhotoPickerStripCell.stripCellIdentifier, for: indexPath)
        }
        let asset = dataSource[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumPhotoPickerStripCell.stripCellIdentifier, for: indexPath) as! AlbumPhotoPickerStripCell
        cell.selectionContext = selectionContext
        cell.fillData(asset: asset)
        return cell
    }

    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath), let block = stripItemDidSelected {
            let assetCell = cell as! AlbumPhotoPickerStripCell
            if let asset = assetCell.asset {
                block(asset)
            }
        }
    }

    public func scrollViewDidScroll(_: UIScrollView) {
        if collectionView.contentSize.width > collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right {
            if collectionView.contentOffset.x < -collectionView.contentInset.left {
                let offset = -collectionView.contentOffset.x - collectionView.contentInset.left
                backgroundView.snp.updateConstraints({ make in
                    make.right.equalTo(-4 + offset)
                })
                let maskOffset = min(0, -8 + offset)
                maskCollectionView.snp.updateConstraints { make in
                    make.right.equalTo(maskOffset)
                    make.width.equalTo(self.frame.size.width - 8 + maskOffset)
                }
                return
            } else if collectionView.contentOffset.x + collectionView.frame.size.width > collectionView.contentSize.width + collectionView.contentInset.right {
                let offset = -collectionView.contentOffset.x - collectionView.frame.size.width + collectionView.contentSize.width + collectionView.contentInset.right
                backgroundView.snp.updateConstraints({ make in
                    make.right.equalTo(-4 + offset)
                })
                let maskOffset = min(0, -8 - offset)
                maskCollectionView.snp.updateConstraints { make in
                    make.right.equalTo(-8)
                    make.width.equalTo(self.frame.size.width - 8 + maskOffset)
                }
                return
            }
        }
        backgroundView.snp.updateConstraints({ make in
            make.right.equalToSuperview().offset(-4)
        })
        maskCollectionView.snp.updateConstraints { make in
            make.right.equalTo(-8)
            make.width.equalTo(backgroundView.frame.size.width - 8)
        }
    }
}

extension AlbumPhotoPickerStripView {

    public func photoThumbnailSize() -> CGSize {
        let screenSize = UIScreen.main.bounds.size
        let wideScreenWidth = max(screenSize.width, screenSize.height)
        if wideScreenWidth >= 736 {
            return CGSize(width: 103.0, height: 103.0)
        } else if wideScreenWidth >= 667 {
            return CGSize(width: 93.0, height: 93.0)
        } else {
            return CGSize(width: 78, height: 78)
        }
    }
}
