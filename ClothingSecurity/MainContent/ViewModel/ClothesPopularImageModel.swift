//
//  ClothesPopularImageModel.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/6.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit

class ClothesPopularImageModel: NSObject {
    let model: Good
    var isCollect: Bool = false
    var collectCount: Int = 0
    var height: CGFloat = 0
    init(model: Good) {
        self.model = model
        height = imageViewSize.height
        isCollect = model.collected
        collectCount = model.collectCount
    }
    
    let imageViewSize: CGSize = CGSize(width: ScreenWidth - 30, height: (ScreenWidth - 30) / 16 * 9 + 41)
    
    var title: String {
        return model.name
    }
    
    var url: String {
        return model.thumb
    }
    
    var id: String {
        return model.id
    }
}
