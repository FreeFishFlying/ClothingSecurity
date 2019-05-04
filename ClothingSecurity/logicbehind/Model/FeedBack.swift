//
//  FeedBack.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2019/5/4.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation

class FeedBack: NSObject {
    var category: String = ""
    var content: String = ""
    var isChoosed: Bool = false
    
    init(category: String, content: String, isChoosed: Bool) {
        self.category = category
        self.content = content
        self.isChoosed = isChoosed
    }
}
