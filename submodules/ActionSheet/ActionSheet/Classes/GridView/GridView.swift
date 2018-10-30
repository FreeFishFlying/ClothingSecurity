//
//  GridView.swift
//  Components-Swift
//
//  Created by Dylan on 09/05/2017.
//  Copyright © 2017 liao. All rights reserved.
//

import UIKit

public protocol GridViewDataSource: class {
    func numberOfCellsInGridView(gridView: GridView) -> Int
    func gridView(_ gridView: GridView, cellForIndex index: Int) -> GridViewCell
}

@objc public protocol GridViewDelegate: class {
    @objc optional func gridView(_ gridView: GridView, didSelectedCell cell: GridViewCell, atIndex index: Int)
    @objc optional func gridView(_ gridView: GridView, didLongPressCell cell: GridViewCell, atIndex index: Int)
    @objc optional func gridView(_ gridView: GridView, didDragInsideCell cell: GridViewCell, atIndex index: Int)
    @objc optional func gridViewEndLongPress(_ gridView: GridView)

    @objc optional func gridView(_ gridView: GridView, didChangeTo index: Int)
}

open class GridView: UIView {

    public var isPagingEnabled: Bool = true {
        didSet {
            collectionView.isPagingEnabled = isPagingEnabled
        }
    }

    public var numberOfRows: Int = 3 {
        didSet {
            reloadData()
        }
    }

    public var numberOfColums: Int = 6 {
        didSet {
            reloadData()
        }
    }

    public var pageMargin: CGFloat = 0 {
        didSet {
            reloadData()
        }
    }

    public var sectionInset: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            horizontalFlowLayout.sectionInset = sectionInset
            reloadData()
        }
    }

    public var numberOfPages: Int {
        if let dataSource = self.dataSource {
            let count = dataSource.numberOfCellsInGridView(gridView: self)
            let pageCount = numberOfColums * numberOfRows
            return Int(ceil(Float(count) / Float(pageCount)))
        }
        return 0
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initalizeSubviews()
    }

    public var isScrollEnable = true
    public weak var dataSource: GridViewDataSource?
    open weak var delegate: GridViewDelegate?

    public lazy var longpressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        return gesture
    }()

    private lazy var horizontalFlowLayout: HorizontalFlowLayout = HorizontalFlowLayout()

    public lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.horizontalFlowLayout)
        collectionView.register(GridViewCell.self, forCellWithReuseIdentifier: "defaultIdentifier")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        return collectionView
    }()

    fileprivate var previousSelectedIndex: Int?

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initalizeSubviews() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        collectionView.addGestureRecognizer(longpressGesture)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        reloadData()
    }

    public func reloadData() {
        if bounds.equalTo(CGRect.zero) {
            return
        }
        let width = bounds.size.width - sectionInset.left - sectionInset.right - 2 * pageMargin
        let height = bounds.size.height - sectionInset.top - sectionInset.bottom
        let colums = numberOfColums <= 0 ? 1 : numberOfColums
        let rows = numberOfRows <= 0 ? 1 : numberOfRows
        horizontalFlowLayout.itemSize = CGSize(width: floor(width / CGFloat(colums)), height: floor(height / CGFloat(rows)))
        collectionView.reloadData()
    }
}

extension GridView {

    @objc fileprivate func handleLongPress(gesture: UILongPressGestureRecognizer) {

        func generalCell() -> (GridViewCell, Int)? {
            let location = gesture.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: location) {
                if let cell = collectionView.cellForItem(at: indexPath) as? GridViewCell {
                    let index = indexPath.item
                    let count = dataSource?.numberOfCellsInGridView(gridView: self) ?? 0
                    if index >= count {
                        return nil
                    }
                    return (cell, indexPath.item)
                }
            }
            return nil
        }

        switch gesture.state {
        case .began:
            if let (cell, index) = generalCell() {
                didLongPress(cell: cell, atIndex: index)
                collectionView.isScrollEnabled = false
            }
        case .changed:
            if let (cell, index) = generalCell() {
                didDrageInside(cell: cell, atIndex: index)
                collectionView.isScrollEnabled = false
            }
        case .ended:
            fallthrough
        case .cancelled:
            endLongPress()
            collectionView.isScrollEnabled = true

        default:
            break
        }
    }

    private func didLongPress(cell: GridViewCell, atIndex index: Int) {
        previousSelectedIndex = index
        cell.isHighlighted = true
        delegate?.gridView?(self, didLongPressCell: cell, atIndex: index)
    }

    private func didDrageInside(cell: GridViewCell, atIndex index: Int) {
        if previousSelectedIndex == index {
            return
        }
        for visibleCell in collectionView.visibleCells {
            visibleCell.isHighlighted = false
        }
        cell.isHighlighted = true
        delegate?.gridView?(self, didDragInsideCell: cell, atIndex: index)
        previousSelectedIndex = index
    }

    private func endLongPress() {
        previousSelectedIndex = nil
        for visibleCell in collectionView.visibleCells {
            visibleCell.isHighlighted = false
        }
        delegate?.gridViewEndLongPress?(self)
    }
}

extension GridView: UICollectionViewDelegate, UICollectionViewDataSource {

    public func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        if let dataSource = dataSource {
            return dataSource.numberOfCellsInGridView(gridView: self)
        }
        return 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let dataSource = dataSource {
            return dataSource.gridView(self, cellForIndex: indexPath.item)
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: "defaultIdentifier", for: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let delegate = delegate {
            if let cell = collectionView.cellForItem(at: indexPath) as? GridViewCell {
                delegate.gridView?(self, didSelectedCell: cell, atIndex: indexPath.item)
            }
        }
    }

    public func register(_ cellClass: Swift.AnyClass?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }

    public func dequeueReusableCell(withReuseIdentifier identifier: String, for index: Int) -> GridViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: IndexPath(item: index, section: 0)) as! GridViewCell
    }

    public func scrollViewDidEndDecelerating(_: UIScrollView) {
        updateCurrentPageIndex()
    }

    fileprivate func updateCurrentPageIndex() {
        let pageWidth = collectionView.frame.size.width
        if pageWidth <= 0.0 {
            return
        }
        let pageIndex = Int(floor((collectionView.contentOffset.x - pageWidth / 2) / pageWidth + 1))
        if let delegate = self.delegate {
            delegate.gridView?(self, didChangeTo: pageIndex)
        }
    }
}
