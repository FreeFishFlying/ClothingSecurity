//
//  ImageModel.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/30.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import SwiftyJSON

class ImageModel: NSObject {
    var id: String = ""
    var createTime: Double = 0
    var updateTime: Double = 0
    var key: String = ""
    var name: String = ""
    var type: String = ""
    var size: Double = 0
    var url: String = ""
    
    init(json: JSON) {
        if let id = json["id"].string {
            self.id = id
        }
        if let createTime = json["createTime"].double {
            self.createTime = createTime
        }
        if let updateTime = json["updateTime"].double {
            self.updateTime = updateTime
        }
        if let key = json["key"].string {
            self.key = key
        }
        if let name = json["name"].string {
            self.name = name
        }
        if let type = json["type"].string {
            self.type = type
        }
        if let size = json["size"].double {
            self.size = size
        }
        if let url = json["url"].string {
            self.url = url
        }
    }
}
