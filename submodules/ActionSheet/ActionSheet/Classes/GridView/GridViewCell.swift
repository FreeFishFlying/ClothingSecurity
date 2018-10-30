//
//  GridViewCell.swift
//  Components-Swift
//
//  Created by Dylan on 10/05/2017.
//  Copyright © 2017 liao. All rights reserved.
//

import UIKit

open class GridViewCell: UICollectionViewCell {
}

extension UIImage {
    public func image(overlayColor color: UIColor) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        if let context = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage {
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.setBlendMode(.multiply)
            context.draw(cgImage, in: rect)
            context.setFillColor(color.cgColor)
            context.clip(to: rect, mask: cgImage)
            context.fill(rect)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
}
