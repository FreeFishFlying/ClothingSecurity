//
//  UIImage+extensions.swift
//  Components
//
//  Created by kingxt on 7/21/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import UIKit

public extension UIImage {

    public func tintImage(color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context: CGContext? = UIGraphicsGetCurrentContext()
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        context?.setBlendMode(.sourceAtop)
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(origin: CGPoint.zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    public func resize(_ size: CGSize) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        return redraw(in: rect)
    }

    public func redraw(in rect: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)

        guard let context = UIGraphicsGetCurrentContext(), let cgImage = cgImage else { return nil }

        let rect = CGRect(origin: .zero, size: size)
        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: rect.size.height)

        context.concatenate(flipVertical)
        context.draw(cgImage, in: rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    public func circled(forRadius radius: CGFloat) -> UIImage? {
        let rediusSize = CGSize(width: radius, height: radius)
        let rect = CGRect(origin: .zero, size: size)

        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)

        guard let context = UIGraphicsGetCurrentContext(), let cgImage = cgImage else { return nil }

        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: rect.size.height)
        context.concatenate(flipVertical)

        let bezierPath = UIBezierPath(roundedRect: rect, byRoundingCorners: [.allCorners], cornerRadii: rediusSize)
        context.addPath(bezierPath.cgPath)
        context.clip()

        context.drawPath(using: .fillStroke)
        context.draw(cgImage, in: rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    public enum ScalingMode {
        case aspectFill
        case aspectFit

        /// Calculates the aspect ratio between two sizes
        ///
        /// - parameters:
        ///     - size:      the first size used to calculate the ratio
        ///     - otherSize: the second size used to calculate the ratio
        ///
        /// - return: the aspect ratio between the two sizes
        func aspectRatio(between size: CGSize, and otherSize: CGSize) -> CGFloat {
            let aspectWidth = size.width / otherSize.width
            let aspectHeight = size.height / otherSize.height

            switch self {
            case .aspectFill:
                return max(aspectWidth, aspectHeight)
            case .aspectFit:
                return min(aspectWidth, aspectHeight)
            }
        }
    }

    /// Scales an image to fit within a bounds with a size governed by the passed size. Also keeps the aspect ratio.
    ///
    /// - parameter:
    ///     - newSize:     the size of the bounds the image must fit within.
    ///     - scalingMode: the desired scaling mode
    ///
    /// - returns: a new scaled image.
    public func scaled(to newSize: CGSize, scalingMode: UIImage.ScalingMode = .aspectFit) -> UIImage {

        let aspectRatio = scalingMode.aspectRatio(between: newSize, and: size)

        /* Build the rectangle representing the area to be drawn */
        var scaledImageRect = CGRect.zero

        scaledImageRect.size.width = size.width * aspectRatio
        scaledImageRect.size.height = size.height * aspectRatio
        scaledImageRect.origin.x = (newSize.width - size.width * aspectRatio) / 2.0
        scaledImageRect.origin.y = (newSize.height - size.height * aspectRatio) / 2.0

        /* Draw and retrieve the scaled image */
        UIGraphicsBeginImageContext(newSize)

        draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return scaledImage!
    }

    public func areaAverage() -> UIColor {
        var bitmap = [UInt8](repeating: 0, count: 4)

        if #available(iOS 9.0, *) {
            // Get average color.
            let context = CIContext()
            let inputImage: CIImage = ciImage ?? CoreImage.CIImage(cgImage: cgImage!)
            let extent = inputImage.extent
            let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
            let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: inputExtent])!
            let outputImage = filter.outputImage!
            let outputExtent = outputImage.extent
            assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)

            // Render to bitmap.
            context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: CIFormat.RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        } else {
            // Create 1x1 context that interpolates pixels when drawing to it.
            let context = CGContext(data: &bitmap, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
            let inputImage = cgImage ?? CIContext().createCGImage(ciImage!, from: ciImage!.extent)

            // Render to bitmap.
            context.draw(inputImage!, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        }

        // Compute result.
        let result = UIColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
        return result
    }

    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }

    public func fixedOrientation() -> UIImage? {

        if imageOrientation == UIImage.Orientation.up {
            return self
        }

        var transform: CGAffineTransform = .identity

        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2))
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi / 2))
            break
        case .up, .upMirrored:
            break
        }

        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        }
        guard let cgImage = self.cgImage, let colorSpace = cgImage.colorSpace else {
            return nil
        }
        guard let ctx: CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        ctx.concatenate(transform)

        switch imageOrientation {
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored, UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
            break
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }

        let newCgImage: CGImage = ctx.makeImage() ?? cgImage
        return UIImage(cgImage: newCgImage)
    }

    public func compressedData(limitDataLength: Int = 200, limitSize: CGSize = CGSize(width: 960, height: 1280)) -> (Data?, UIImage) {
        var dataLength: CGFloat = 0
        let quality: CGFloat = 0.6
        let imageSize = size
        guard let jpegPresentationData = self.jpegData(compressionQuality: 1) else {
            return (nil, self)
        }

        if jpegPresentationData.count < limitDataLength * 1024 {
            return (jpegPresentationData, self)
        }
        let areaSize = imageSize.width * imageSize.height
        if areaSize < 1000 * 1000 {
            dataLength = 100
        } else {
            dataLength = areaSize / 40000
        }
        if dataLength < 100 {
            dataLength = 100
        }
        guard let imageData = self.jpegData(compressionQuality: quality) else {
            return (nil, self)
        }
        if imageData.count < Int(dataLength * 1024) {
            return (imageData, self)
        } else {
            let image = resizedImageToFitInSize(limitSize)
            return (image.jpegData(compressionQuality: quality), image)
        }
    }
    
    public func imageWithInsets(insets: UIEdgeInsets) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: self.size.width + insets.left + insets.right,
                   height: self.size.height + insets.top + insets.bottom), false, self.scale)
        let _ = UIGraphicsGetCurrentContext()
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageWithInsets
    }

    public func resizedImageToFitInSize(_ boundingSize: CGSize, scaleIfSmaller: Bool = false) -> UIImage {
        if !scaleIfSmaller {
            if size.width < boundingSize.width && size.height < boundingSize.height {
                return self
            }
        }
        guard let cgImage = self.cgImage else {
            return self
        }
        var boundingSize = boundingSize
        let srcSize = CGSize(width: cgImage.width, height: cgImage.height)
        let orient: UIImage.Orientation = imageOrientation
        switch orient {
        case .left, .right, .leftMirrored, .rightMirrored:
            boundingSize = CGSize(width: boundingSize.height, height: boundingSize.width)
        default:
            break
        }
        var dstSize = boundingSize
        let wRatio: CGFloat = boundingSize.width / srcSize.width
        let hRatio: CGFloat = boundingSize.height / srcSize.height
        if wRatio < hRatio {
            dstSize = CGSize(width: boundingSize.width, height: floor(srcSize.height * wRatio))
        } else {
            dstSize = CGSize(width: floor(srcSize.width * hRatio), height: boundingSize.height)
        }
        return resizedImageToSize(dstSize: dstSize)
    }

    public func resizedImageToSize(dstSize: CGSize) -> UIImage {
        guard let cgImage = self.cgImage else {
            return self
        }
        let srcSize = CGSize(width: cgImage.width, height: cgImage.height)

        if srcSize.equalTo(dstSize) {
            return self
        }
        var dstSize = dstSize
        let scaleRatio: CGFloat = dstSize.width / srcSize.width
        let orient: UIImage.Orientation = imageOrientation
        var transform = CGAffineTransform.identity
        switch orient {
        case .up:
            // EXIF = 1
            transform = CGAffineTransform.identity
        case .upMirrored:
            // EXIF = 2
            transform = CGAffineTransform(translationX: srcSize.width, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        case .down:
            // EXIF = 3
            transform = CGAffineTransform(translationX: srcSize.width, y: srcSize.height)
            transform = transform.rotated(by: .pi)
        case .downMirrored:
            // EXIF = 4
            transform = CGAffineTransform(translationX: 0.0, y: srcSize.height)
            transform = transform.scaledBy(x: 1.0, y: -1.0)
        case .leftMirrored:
            // EXIF = 5
            dstSize = CGSize(width: dstSize.height, height: dstSize.width)
        case .left:
            // EXIF = 6
            dstSize = CGSize(width: dstSize.height, height: dstSize.width)
            transform = CGAffineTransform(translationX: 0.0, y: srcSize.width)
            transform = transform.rotated(by: 3.0 * CGFloat.pi / 2)
        case .rightMirrored:
            // EXIF = 7
            dstSize = CGSize(width: dstSize.height, height: dstSize.width)
            transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            transform = transform.rotated(by: CGFloat.pi / 2)
        case .right:
            // EXIF = 8
            dstSize = CGSize(width: dstSize.height, height: dstSize.width)
            transform = CGAffineTransform(translationX: srcSize.height, y: 0.0)
            transform = transform.rotated(by: CGFloat.pi / 2)
        }

        UIGraphicsBeginImageContextWithOptions(dstSize, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return self
        }
        if orient == .right || orient == .left {
            context.scaleBy(x: -scaleRatio, y: scaleRatio)
            context.translateBy(x: -srcSize.height, y: 0)
        } else {
            context.scaleBy(x: scaleRatio, y: -scaleRatio)
            context.translateBy(x: 0, y: -srcSize.height)
        }
        context.concatenate(transform)
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: srcSize.width, height: srcSize.height))
        let resizedImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage ?? self
    }

    public func addImage(_ image: UIImage) -> UIImage? {
        return addImage(image, offset: CGPoint(x: (size.width - image.size.width) / 2, y: (size.height - image.size.height) / 2))
    }

    public func addImage(_ image: UIImage, offset: CGPoint) -> UIImage? {
        var size: CGSize = self.size
        let scale: CGFloat = self.scale
        size.width *= scale
        size.height *= scale
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        image.draw(in: CGRect(x: scale * offset.x, y: scale * offset.y, width: image.size.width * scale, height: image.size.height * scale))
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        guard let bitmapContext = context.makeImage() else {
            return nil
        }
        let destImage = UIImage(cgImage: bitmapContext, scale: image.scale, orientation: .up)
        UIGraphicsEndImageContext()
        return destImage
    }

    public convenience init(view: UIView) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let cgImage = image?.cgImage {
            self.init(cgImage: cgImage)
        } else {
            self.init()
        }
    }

    public func crop(rect: CGRect) -> UIImage? {
        var rect = rect
        let scale = UIScreen.main.scale
        rect.origin.x *= scale
        rect.origin.y *= scale
        rect.size.width *= scale
        rect.size.height *= scale
        guard let cgImage = self.cgImage else {
            return nil
        }
        let imageRef = cgImage.cropping(to: rect)
        guard let newCgImage = imageRef else {
            return nil
        }
        let image = UIImage(cgImage: newCgImage, scale: self.scale, orientation: imageOrientation)
        return image
    }
}
