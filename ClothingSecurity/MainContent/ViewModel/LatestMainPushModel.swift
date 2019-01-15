//
//  LatestMainPushModel.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/1.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
class LatestMainPushModel: NSObject {
    var height: CGFloat = 0
    private var defaultImageSize = (ScreenWidth - 42)/2
    override init() {
    }
    
    var models: [Good]? {
        didSet {
            height = 0
            if let models = models, !models.isEmpty {
                height += 65
                let gap: CGFloat = 10
                height += CGFloat(ceil(Double(models.count) / 2) * Double((defaultImageSize + gap)))
            } else {
                height = 0
            }
        }
    }
}
