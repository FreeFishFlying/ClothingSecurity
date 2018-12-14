//
//  Banner.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/2.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import SwiftyJSON

enum BannerType: String {
    case goods = "goods"
    case design = "design"
    case outfit = "outfit"
}

class Banner: NSObject {
    var id: String = ""
    var createTime: Double = 0
    var updateTime: Double = 0
    var title: String = ""
    var image: String = ""
    var link: String = ""
    var position: String = ""
    var goodId: String = ""
    var type: BannerType = .goods
    init(json: JSON) {
        super.init()
        if let id = json["id"].string {
            self.id = id
        }
        if let createTime = json["createTime"].double {
            self.createTime = createTime
        }
        if let updateTime = json["updateTime"].double {
            self.updateTime = updateTime
        }
        if let title = json["title"].string {
            self.title = title
        }
        if let image = json["image"].string {
            self.image = image
        }
        if let link = json["link"].string {
            self.link = link
            if let paths = URL(string: link)?.path {
                let list = paths.components(separatedBy: "/")
                if let id = list.last {
                    goodId = id
                }
                if let g_type = list.first {
                    type = BannerType(rawValue: g_type) ?? .goods
                }
            }
        }
        if let position = json["position"].string {
            self.position = position
        }
    }
}
