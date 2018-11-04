//
//  DetailRichGoodModel.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/4.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit

class DetailRichGoodModel: NSObject {
    let gap: CGFloat = 20.0
    var height: CGFloat = 0
    var size: CGSize = CGSize(width: 750, height: 1214)
    let model: Good
    init(model: Good) {
        self.model = model
        super.init()
        height += gap
        let normalImageWigth = 750
        let normalImageHeight = 1214
        let textHeight = getTextHeigh(textStr: model.intro, font: systemFontSize(fontSize: 15), width: ScreenWidth - 30)
        height += textHeight
        
    }
    
    var title: String? {
        return model.intro
    }
    
    var imageUrls: [String]? {
        return model.details
    }
}
