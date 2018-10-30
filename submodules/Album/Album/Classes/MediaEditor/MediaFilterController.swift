//
//  MeidaFilterController.swift
//  Components-Swift
//
//  Created by kingxt on 5/31/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import Core

private let MediaFilterCellKind = "MediaFilterCellKind"

fileprivate class MediaFilterCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
    }

    override var isSelected: Bool {
        didSet {
            super.isSelected = isSelected
            imageView.layer.borderColor = isSelected ? tintColor.cgColor : UIColor.clear.cgColor
            imageView.layer.borderWidth = isSelected ? 1 : 0
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(x: 2, y: 2, width: frame.size.width - 4, height: frame.size.width - 4)
        titleLabel.frame = CGRect(x: 0, y: imageView.frame.maxY + 4, width: frame.size.width, height: 18)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()

    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
}

private let filterPreviewHeight: CGFloat = 100

public func applyFilter(image: UIImage, filterName: String) -> UIImage? {
    let sourceImage = CIImage(image: image)
    if let myFilter = CIFilter(name: filterName) {
        myFilter.setDefaults()
        myFilter.setValue(sourceImage, forKey: kCIInputImageKey)
        let context = CIContext(options: nil)
        if let outputImage = myFilter.outputImage {
            if let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: outputCGImage, scale: image.scale, orientation: .up)
            }
        }
    }
    return nil
}

public class MediaFilterResult {

    public let filterName: String

    init(name: String) {
        filterName = name
    }

    public func apply(image: UIImage?) -> UIImage? {
        if image == nil {
            return image
        }
        return applyFilter(image: image!, filterName: filterName)
    }
}

public class MediaFilterController: UIViewController, MediaEditor {

    fileprivate let editorContext: MediaEditorContext
    private let animationContext: AnimationTranslationContext
    fileprivate var noneProcessedImage: UIImage?
    fileprivate var originalImage: UIImage?

    fileprivate let filterTitleList = [SLLocalized("MediaFilter.Original"), SLLocalized("MediaFilter.Chrome"), SLLocalized("MediaFilter.Fade"), SLLocalized("MediaFilter.Instant"), SLLocalized("MediaFilter.Noir"), SLLocalized("MediaFilter.Process"), SLLocalized("MediaFilter.Transfer")]
    fileprivate let filterNameList = ["No Filter", "CIPhotoEffectChrome", "CIPhotoEffectFade", "CIPhotoEffectInstant", "CIPhotoEffectNoir", "CIPhotoEffectProcess", "CIPhotoEffectTransfer"]

    fileprivate var filterSnapshortImages: [UIImage?]
    fileprivate var selectedIndex = 0

    public var isPreviewFilterImageHidden = false {
        didSet {
            if isViewLoaded {
                self.imageView.isHidden = isPreviewFilterImageHidden
            }
        }
    }

    public var backgroundColor: UIColor = .black {
        didSet {
            if isViewLoaded {
                view.backgroundColor = backgroundColor
            }
        }
    }

    public init(editorContext: MediaEditorContext, animationContext: AnimationTranslationContext) {
        self.editorContext = editorContext
        self.animationContext = animationContext
        filterSnapshortImages = [UIImage?](repeating: nil, count: filterNameList.count)
        if let name = editorContext.editorResult.filterResult?.filterName {
            selectedIndex = filterNameList.index(of: name) ?? 0
        }
        super.init(nibName: nil, bundle: nil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = backgroundColor
        imageView.isHidden = isPreviewFilterImageHidden
        animationContext.stateChangeSignal().startWithValues { [weak self] state in
            switch state {
            case .willTranslationOut:
                self?.imageView.isHidden = true
                self?.collectionView.isHidden = true
            default: break
            }
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageView.reset()
        let actions: (_ image: UIImage?) -> Void = { [weak self] (image: UIImage?) in
            guard let image = image else {
                return
            }
            self?.originalImage = image
            self?.imageView.image = self?.editorContext.editorResult.applyTo(image: image)
            self?.loadFilterImages(image: image)
        }
        if let thumbnailSignal = editorContext.thumbnailSignal {
            thumbnailSignal.take(during: reactive.lifetime).startWithValues({ image in
                actions(image)
            })
        }
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let indexItems = collectionView.indexPathsForSelectedItems, let first = indexItems.first {
            if first.item == 0 {
                imageView.image = noneProcessedImage
                editorContext.filterSignal.input.send(value: originalImage)
            } else if let originalImage = self.originalImage {
                editorContext.filterSignal.input.send(value: applyFilter(image: originalImage, filterName: filterNameList[first.item]))
            }
        }
    }

    public override func loadView() {
        super.loadView()

        view.addSubview(imageView)
        view.addSubview(collectionView)

        layout(size: view.bounds.size)
    }

    func loadFilterImages(image: UIImage) {
        noneProcessedImage = image
        DispatchQueue.global().async {
            let image = image.scaled(to: CGSize(width: 200, height: 200), scalingMode: .aspectFill)
            self.filterSnapshortImages[0] = image
            for (index, item) in self.filterNameList.enumerated() {
                if index > 0 {
                    self.filterSnapshortImages[index] = applyFilter(image: image, filterName: item)
                }
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.collectionView.selectItem(at: IndexPath(item: self.selectedIndex, section: 0), animated: false, scrollPosition: .centeredHorizontally)
            }
        }
    }


    public func layout(size: CGSize) {
        imageView.snp.makeConstraints { (make) in
            make.left.equalTo(MediaEditorController.previewImageViewGap)
            make.right.equalTo(-MediaEditorController.previewImageViewGap)
            make.top.equalTo(0)
            make.bottom.equalTo(-MediaEditorController.operationViewHeight)
        }
        collectionView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-30)
            make.height.equalTo(filterPreviewHeight)
        }
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func tabBarImage() -> UIImage? {
        return MediaEditorImageNamed("PhotoEditorFilters")
    }

    public func animationTranslationInView() -> UIView {
        return imageView
    }

    public func animationTranslationOutView(isCancelled _: Bool) -> UIView? {
        guard let image = self.imageView.image else {
            return self.imageView
        }
        let animationImageView = UIImageView()
        animationImageView.image = editorContext.editorResult.editorImage ?? editorContext.editorResult.applyTo(image: image)
        let displaySize = ImageUtils.scaleToSize(size: image.size, maxSize: self.imageView.frame.size)
        let displayFrame = CGRect(origin: CGPoint(x: (self.imageView.frame.size.width - displaySize.width) / 2, y: (self.imageView.frame.size.height - displaySize.height) / 2), size: displaySize)
        animationImageView.frame = view.convert(displayFrame, to: view.window)
        return animationImageView
    }

    public func fillResult(result: MediaEditorResult) {
        if let indexPath = (collectionView.indexPathsForSelectedItems?.first) {
            if indexPath.item > 0 {
                result.filterResult = MediaFilterResult(name: filterNameList[indexPath.item])
            } else {
                result.filterResult = nil
            }
        }
    }

    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = self.isPreviewFilterImageHidden
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var collectionLayout: UICollectionViewFlowLayout = {
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.minimumLineSpacing = 1
        collectionLayout.minimumInteritemSpacing = 1
        collectionLayout.scrollDirection = .horizontal
        collectionLayout.itemSize = CGSize(width: 80, height: filterPreviewHeight)
        return collectionLayout
    }()

    internal lazy var collectionView: UICollectionView = {
        let collectionView: UICollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: self.collectionLayout)
        collectionView.alwaysBounceVertical = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .black
        collectionView.delaysContentTouches = true
        collectionView.canCancelContentTouches = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MediaFilterCell.self, forCellWithReuseIdentifier: MediaFilterCellKind)
        return collectionView
    }()
}

extension MediaFilterController: UICollectionViewDelegate, UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaFilterCellKind, for: indexPath) as! MediaFilterCell
        cell.imageView.image = filterSnapshortImages[indexPath.item]
        cell.titleLabel.text = filterTitleList[indexPath.item]
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item > 0 {
            editorContext.editorResult.filterResult = MediaFilterResult(name: filterNameList[indexPath.item])
        } else {
            editorContext.editorResult.filterResult = nil
        }
        if indexPath.item == 0 {
            imageView.image = noneProcessedImage
        } else if let image = noneProcessedImage {
            imageView.image = editorContext.editorResult.applyTo(image: image)
        }
        selectedIndex = indexPath.item
        collectionView.deselectItem(at: (collectionView.indexPathsForSelectedItems?.first)!, animated: false)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }

    public func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return filterTitleList.count
    }
}
