//
//  CommonUtil.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/11.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit

extension UIBarButtonItem {
    convenience init(image: UIImage?, higlightedImage: UIImage?, target: Any, action: Selector) {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 48, height: 28)
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -28)
        button.hitTestEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -28)
        button.setImage(higlightedImage, for: .highlighted)
        button.addTarget(target, action: action, for: .touchUpInside)
        self.init(customView: button)
    }
    
    convenience init(whiteTitle: String, target: Any, action: Selector) {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 48, height: 28)
        button.setTitle(whiteTitle, for: .normal)
        button.titleLabel?.font = systemFontSize(fontSize: 17)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        self.init(customView: button)
    }
}
