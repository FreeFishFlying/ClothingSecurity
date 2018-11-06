//
//  VideoModel.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/5.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import SwiftyJSON

class VideoModel: NSObject {
    var id: String = ""
    var createTime: Double = 0
    var name: String = ""
    var intro: String = ""
    var poster: String = ""
    var duration: Double = 0
    var size: Double = 0
    var url: String = ""
    
    init(json: JSON) {
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
        if let poster = json["poster"].string {
            self.poster = poster
        }
        if let duration = json["duration"].double {
            self.duration = duration
        }
        if let size = json["size"].double {
            self.size = size
        }
        if let url = json["url"].string {
            self.url = url
        }
    }
}
