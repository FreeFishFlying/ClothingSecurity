//
//  HorizontalFlowLayout.swift
//  Components
//
//  Created by kingxt on 7/25/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import UIKit

class HorizontalFlowLayout: UICollectionViewLayout {

    var itemSize = CGSize.zero {
        didSet {
            invalidateLayout()
        }
    }

    var sectionInset: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            invalidateLayout()
        }
    }

    private var cellCount = 0
    private var boundsSize = CGSize.zero

    override func prepare() {
        guard let collectionView = self.collectionView else {
            return
        }
        cellCount = collectionView.numberOfItems(inSection: 0)
        boundsSize = collectionView.bounds.size
    }

    override var collectionViewContentSize: CGSize {
        if itemSize.width == 0 || itemSize.height == 0 {
            return CGSize.zero
        }
        if boundsSize.width == 0 || boundsSize.height == 0 {
            return CGSize.zero
        }
        let verticalItemsCount = Int(floor(boundsSize.height / itemSize.height))
        let horizontalItemsCount = Int(floor(boundsSize.width / itemSize.width))

        let itemsPerPage = verticalItemsCount * horizontalItemsCount
        let numberOfItems = cellCount
        let numberOfPages = Int(ceil(Double(numberOfItems) / Double(itemsPerPage)))

        var size = boundsSize
        size.width = CGFloat(numberOfPages) * boundsSize.width
        return size
    }

    override func layoutAttributesForElements(in _: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var allAttributes = [UICollectionViewLayoutAttributes]()
        for i in 0 ..< cellCount {
            let indexPath = IndexPath(row: i, section: 0)
            let attr = computeLayoutAttributesForCellAtIndexPath(indexPath: indexPath)
            allAttributes.append(attr)
        }
        return allAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return computeLayoutAttributesForCellAtIndexPath(indexPath: indexPath)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return newBounds.size.equalTo(collectionView!.bounds.size)
    }

    func computeLayoutAttributesForCellAtIndexPath(indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        let row = indexPath.row
        let bounds = collectionView!.bounds

        let verticalItemsCount = Int(floor(boundsSize.height / itemSize.height))
        let horizontalItemsCount = Int(floor(boundsSize.width / itemSize.width))
        let itemsPerPage = verticalItemsCount * horizontalItemsCount

        let columnPosition = row % horizontalItemsCount
        let rowPosition = (row / horizontalItemsCount) % verticalItemsCount
        let itemPage = Int(floor(Double(row) / Double(itemsPerPage)))

        let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)

        var frame = CGRect.zero
        frame.origin.x = CGFloat(itemPage) * bounds.size.width + CGFloat(columnPosition) * itemSize.width + sectionInset.left
        frame.origin.y = CGFloat(rowPosition) * itemSize.height + sectionInset.top
        frame.size = itemSize
        attr.frame = frame

        return attr
    }
}
