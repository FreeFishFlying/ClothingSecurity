//
//  Apperance.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/9.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit

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
