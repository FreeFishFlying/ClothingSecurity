//
//  Apperance.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/9.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import ESTabBarController

func imageNamed(_ name: String) -> UIImage? {
    return UIImage(named: name)
}

func systemFontSize(fontSize: CGFloat) -> UIFont {
    if #available(iOS 9.0, *) {
        return UIFont(name: "PingFangSC-Light", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    } else {
        return UIFont.systemFont(ofSize: fontSize)
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    func getNSForegroundColorAttribute() -> [String: UIColor] {
        return [NSAttributedString.Key.foregroundColor.rawValue: self]
    }
}

func applyStyle() {
    let attrs = [
        NSAttributedString.Key.foregroundColor: UIColor(red: 50.0 / 255.0, green: 50.0 / 255.0, blue: 52.0 / 255.0, alpha: 1.0),
        NSAttributedString.Key.font: UIFont(name: "PingFangSC-Semibold", size: 18)!
    ]
    UINavigationBar.appearance().titleTextAttributes = attrs
    UINavigationBar.appearance().barTintColor = UIColor.white
    UINavigationBar.appearance().barStyle =  UIBarStyle.default
    UINavigationBar.appearance().shadowImage = UIImage()
    UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: true)
    
    if let esTabVc = UIApplication.shared.keyWindow?.rootViewController as? ESTabBarController {
        esTabVc.view.backgroundColor = UIColor.white
    }
}

func zd_image(with color: UIColor, size: CGSize, text: String, textAttributes: [AnyHashable : Any]?, circular isCircular: Bool) -> UIImage? {
    if  size.width <= 0 || size.height <= 0 {
        return nil
    }
    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    UIGraphicsBeginImageContextWithOptions(rect.size, _: false, _: 0)
    let context = UIGraphicsGetCurrentContext()
    
    // circular
    if isCircular {
        let path = CGPath(ellipseIn: rect, transform: nil)
        context?.addPath(path)
        context?.clip()
    }
    // color
    context?.setFillColor(color.cgColor)
    context?.fill(rect)
    
    // text
    let textSize: CGSize? = text.size(withAttributes: textAttributes as? [NSAttributedString.Key : Any])
    text.draw(in: CGRect(x: (size.width - (textSize?.width ?? 0.0)) / 2, y: (size.height - (textSize?.height ?? 0.0)) / 2, width: textSize?.width ?? 0.0, height: textSize?.height ?? 0.0), withAttributes: textAttributes as? [NSAttributedString.Key : Any])
    let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}
