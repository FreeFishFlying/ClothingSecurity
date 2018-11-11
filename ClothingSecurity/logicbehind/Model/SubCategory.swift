//
//  SubCategory.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/3.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import SwiftyJSON

class SubCategory: NSObject {
    var id: String = ""
    var createTime: Double = 0
    var name: String = ""
    var level: Int = 0
    var list = [Good]()
    init(json: JSON) {
        super.init()
        if let categoryItem = json["category"].dictionary {
            if let id = categoryItem["id"]?.string {
                self.id = id
            }
            if let createTime = categoryItem["createTime"]?.double {
                self.createTime = createTime
            }
            if let name = categoryItem["name"]?.string {
                self.name = name
            }
            if let level = categoryItem["level"]?.int {
                self.level = level
            }
        }
        if let dataList = json["list"].array {
            dataList.forEach { js in
                list.append(Good(json: js))
            }
        }
    }
}
