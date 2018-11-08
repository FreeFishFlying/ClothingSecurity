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
            if let models = models, !models.isEmpty {
                height += 65
                if models.count <= 2 {
                    height += defaultImageSize
                    height += 10
                } else {
                    height += defaultImageSize * 2
                    height += 20
                }
                
            } else {
                height = 0
            }
        }
    }
}
