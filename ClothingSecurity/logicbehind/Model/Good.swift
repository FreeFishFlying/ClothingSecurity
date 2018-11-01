//
//  Good.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/2.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import SwiftyJSON
class Good: NSObject {
    var id: String = ""
    var createTime: Double = 0
    var name: String = ""
    var intro: String = ""
    var thumb: String = ""
    var price: Double = 0
    var collected: Bool = false
    var collectCount: Int = 0
    
    init(json: JSON)  {
        if let id = json["id"].string {
            self.id = id
        }
        if let createTime = json["createTime"].double {
            self.createTime = createTime
        }
        if let name = json["name"].string {
            self.name = name
        }
        if let intro = json["intro"].string {
            self.intro = intro
        }
        if let thumb = json["thumb"].string {
            self.thumb = thumb
        }
        if let price = json["price"].double {
            self.price = price
        }
        if let collected = json["collected"].bool {
            self.collected = collected
        }
        if let collectCount = json["collectCount"].int {
            self.collectCount = collectCount
        }
    }
}
