//
//  ImageContact.swift
//  Pods
//
//  Created by Dylan on 03/07/2017.
//
//

import Foundation
import Mesh
import ReactiveSwift
import Result

public protocol ContactNameAvatar {
    var name: String { get }
    var referId: Int? { get }
    var size: CGSize { get }
}

private var ContactGradientColors: [(from: UIColor, to: UIColor)] = [
    (UIColorRGB(0xFF516A), UIColorRGB(0xFF885E)),
    (UIColorRGB(0xFFA85C), UIColorRGB(0xFFCD6A)),
    (UIColorRGB(0x54CB68), UIColorRGB(0xA0DE7E)),
    (UIColorRGB(0x2A9EF1), UIColorRGB(0x72D5FD)),
    (UIColorRGB(0x665FFF), UIColorRGB(0x82B1FF)),
    (UIColorRGB(0xD669ED), UIColorRGB(0xE0A2F3)),
]

public func generalContactNameAvatar(data: ContactNameAvatar) -> SignalProducer<UIImage?, NoError> {
    return SignalProducer<UIImage?, NoError> { observer, _ in
        let cacheKey = data.cacheKey
        ImageCache.default.retrieveImage(forKey: cacheKey, completionHandler: { image, _ in
            if image != nil {
                observer.send(value: image)
                observer.sendCompleted()
            } else {
                let initials = generalInitial(name: data.name)
                let index: Int
                if let referId = data.referId {
                    if referId > 0 {
                        index = referId % ContactGradientColors.count
                    } else {
                        index = initials.hash % ContactGradientColors.count
                    }
                } else {
                    index = initials.hash % ContactGradientColors.count
                }
                let colors = ContactGradientColors[index]
                let fontSize = data.size.width / 2
                if let image = drawImageForContactNameAvatar(initials: initials, size: data.size, colors: colors, textColor: .white, font: UIFont.systemFont(ofSize: CGFloat(fontSize - 1))) {
                    ImageCache.default.store(image, forKey: cacheKey)
                    observer.send(value: image)
                    observer.sendCompleted()
                } else {
                    observer.send(value: nil)
                    observer.sendCompleted()
                }
            }
        })
    }
}

private extension ContactNameAvatar {
    var cacheKey: String {
        let initials = generalInitial(name: name)
        if let referId = referId {
            return "\(initials)-\(Int(size.width))-\(Int(size.height))-\(referId)"
        } else {
            return "\(initials)-\(Int(size.width))-\(Int(size.height))"
        }
    }
}

private func generalInitial(name: String) -> String {
    if name.length > 0 {
        let index = name.index(name.startIndex, offsetBy: 1)
        let initial = name[..<index]
        return initial.uppercased()
    }
    return ""
}

private func drawImageForContactNameAvatar(initials: String, size: CGSize, colors: (from: UIColor, to: UIColor), textColor: UIColor, font: UIFont) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, 2)
    if let context = UIGraphicsGetCurrentContext() {
        context.beginPath()
        context.addEllipse(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        context.clip()

        let colours = [colors.from.cgColor, colors.to.cgColor] as CFArray
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        if let gradient = CGGradient(colorsSpace: colorSpace, colors: colours, locations: nil) {
            context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: size.height), options: CGGradientDrawingOptions.drawsBeforeStartLocation)
        }

        let dic = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor]
        let attri = NSAttributedString(string: initials, attributes: dic)

        let textSize = attri.size()
        attri.draw(in: CGRect(x: size.width / 2 - textSize.width / 2, y: size.height / 2 - font.lineHeight / 2, width: textSize.width, height: textSize.height))

        return UIGraphicsGetImageFromCurrentImageContext()
    }
    return nil
}
