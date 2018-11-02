//
//  PopularWearModel.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/1.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit

class PopularWearModel: NSObject {
    var good: Good?
    private let defaultWidth: CGFloat = 345
    private let defaulHeight: CGFloat = 209
    var imageViewWidth: CGFloat = 0
    var imageViewHeight: CGFloat = 0
    var height: CGFloat = 0
    init(good: Good?) {
        self.good = good
        super.init()
        if ScreenWidth > 320 {
            imageViewWidth = defaultWidth
            imageViewHeight = defaulHeight
        } else {
            let scale: CGFloat = 375 / ScreenWidth
            imageViewWidth = defaultWidth / scale
            imageViewHeight = defaulHeight / scale
        }
        height += 60
        height += 5
        height += imageViewHeight
        height += 44
    }
    
    var title: String? {
        if let model = good {
            return model.name
        }
        return nil
    }
    
    var url : URL? {
        if let model = good {
            if let url = URL(string: model.thumb) {
                return url
            }
            return nil
        }
        return nil
    }
}
