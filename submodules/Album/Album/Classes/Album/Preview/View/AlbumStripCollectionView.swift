//
//  DraggeableCollectionView.swift
//  VideoPlayer-Swift
//
//  Created by Dylan on 13/04/2017.
//  Copyright © 2017 kingxt. All rights reserved.
//

import UIKit

class AlbumStripCollectionView: UICollectionView {
}

class AlbumStripCollectionViewLayout: UICollectionViewFlowLayout {
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) {
            attributes.transform3D = CATransform3DMakeTranslation(0, 0, CGFloat(itemIndexPath.row + 1))
            attributes.zIndex = itemIndexPath.row + 1
            return attributes
        }
        return nil
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let attributes = super.layoutAttributesForItem(at: indexPath) {
            attributes.transform3D = CATransform3DMakeTranslation(0, 0, CGFloat(indexPath.row + 1))
            attributes.zIndex = indexPath.row + 1 + 1000
            return attributes
        }
        return nil
    }
}
