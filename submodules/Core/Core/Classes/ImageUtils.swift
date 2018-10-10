//
//  ImageUtils.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 2017/2/24.
//  Copyright © 2017 kingxt. All rights reserved.
//

import UIKit
import Darwin

public class ImageUtils {

    public class func fitSize(size: CGSize, maxSize: CGSize) -> CGSize {
        var size: CGSize = size
        if size.width < 1 {
            size.width = 1
        }
        if size.height < 1 {
            size.height = 1
        }

        if size.width > maxSize.width {
            size.height = Darwin.floor(size.height * maxSize.width / size.width)
            size.width = maxSize.width
        }
        if size.height > maxSize.height {
            size.width = Darwin.floor(size.width * maxSize.height / size.height)
            size.height = maxSize.height
        }
        return size
    }

    public class func scaleToSize(size: CGSize, maxSize: CGSize) -> CGSize {
        var size: CGSize = size
        if size.width < 1 {
            size.width = 1
        }
        if size.height < 1 {
            size.height = 1
        }
        var newSize = size
        newSize.width = maxSize.width
        newSize.height = floor(newSize.width * size.height / size.width)

        if newSize.height > maxSize.height {
            newSize.height = maxSize.height
            newSize.width = floor(newSize.height * size.width / size.height)
        }

        return newSize
    }

    public class func colorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    public class func colorFromRGBA(rgbValue: UInt, alpha: Float) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }

    public class func tintedImage(image: UIImage?, color: UIColor, opaque: Bool) -> UIImage? {
        if let image = image {
            UIGraphicsBeginImageContextWithOptions(image.size, opaque, 0.0)
            let context: CGContext? = UIGraphicsGetCurrentContext()
            if let context = context {
                image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
                context.setBlendMode(CGBlendMode.sourceAtop)
                context.setFillColor(color.cgColor)
                context.fill(CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
                let tintedImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return tintedImage
            }
            return nil
        }
        return nil
    }
}

public func rotated(contentSize: CGSize, rotation: CGFloat) -> CGSize {
    var t = CGAffineTransform(translationX: contentSize.width / 2, y: contentSize.height / 2)
    t = t.rotated(by: rotation)
    t = t.translatedBy(x: -contentSize.width / 2, y: -contentSize.height / 2)
    return CGRect(x: 0, y: 0, width: CGFloat(contentSize.width), height: CGFloat(contentSize.height)).applying(t).size
}

public func orientationIsSideward(orientation: UIImage.Orientation?) -> (sideward: Bool, mirrored: Bool) {
    guard let orientation = orientation else {
        return (false, false)
    }
    if orientation == .left || orientation == .right {
        return (true, false)
    } else if orientation == .leftMirrored || orientation == .rightMirrored {
        return (true, true)
    }
    return (false, false)
}

public func mirrorSidewardOrientation(_ orientation: UIImage.Orientation) -> UIImage.Orientation {
    var orientation = orientation
    if orientation == .left {
        orientation = .right
    } else if orientation == .right {
        orientation = .left
    }
    return orientation
}

public func rotationForOrientation(_ orientation: UIImage.Orientation) -> CGFloat {
    switch orientation {
    case .down:
        return CGFloat.pi
    case .left:
        return -CGFloat.pi / 2
    case .right:
        return CGFloat.pi / 2
    default:
        break
    }
    return 0.0
}

public func nextOrientationForOrientation(_ orientation: UIImage.Orientation) -> UIImage.Orientation {
    switch orientation {
    case .up:
        return .left
    case .left:
        return .down
    case .down:
        return .right
    case .right:
        return .up
    default:
        break
    }
    return .up
}

public func UIColorRGB(_ rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

public func UIColorRGBA(_ rgbValue: UInt, _ alpha: Float) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(alpha)
    )
}

public func UIImageForm(color: UIColor, size: CGSize = CGSize(width: 1.0, height: 1.0)) -> UIImage {
    UIGraphicsBeginImageContext(size)
    defer {
        UIGraphicsEndImageContext()
    }
    if let context = UIGraphicsGetCurrentContext() {
        context.setFillColor(color.cgColor)
        context.fill(CGRect(origin: CGPoint.zero, size: size))
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            return image
        }
    }
    return UIImage()
}

public func drawSvgPath(context: CGContext, path: String) {
    let path = UIBezierPath(svgPath: path)
    context.addPath(path.cgPath)
    context.closePath()
    context.fillPath()
}
