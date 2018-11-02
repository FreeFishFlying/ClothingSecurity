//
//  SearchCategory.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/3.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import SwiftyJSON

class SearchCategory: NSObject {
    var id: String = ""
    var createTime: Double = 0
    var name: String = ""
    var level: Int = 0
    
    init(json: JSON) {
        if let id = json["id"].string {
            self.id = id
        }
        if let createTime = json["createTime"].double {
            self.createTime = createTime
        }
        if let name = json["createTime"].string {
            self.name = name
        }
        if let level = json["level"].int {
            self.level = level
        }
    }
}
