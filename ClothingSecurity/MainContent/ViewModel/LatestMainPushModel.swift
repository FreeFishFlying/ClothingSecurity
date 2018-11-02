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
    var height = 0
    var imageSize = 0
    private var defaultImageSize = 165
    override init() {
        if ScreenWidth < 375 {
            imageSize = 140
        } else {
            imageSize = defaultImageSize
        }
    }
    
    var models: [Good]? {
        didSet {
            if let models = models, !models.isEmpty {
                height += 65
                if models.count <= 2 {
                    height += imageSize
                } else {
                    height += imageSize * 2
                    height += 10
                }
            } else {
                height = 0
            }
        }
    }
}
