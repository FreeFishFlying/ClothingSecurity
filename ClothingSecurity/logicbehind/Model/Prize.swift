//
//  Prize.swift
//  Labeauty
//
//  Created by 宋昌鹏 on 2019/4/29.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation
import SwiftyJSON

enum TargetType: String {
    case empty = "EMPTY"
    case gift = "GIFT"
    case coupon = "COUPON"
}

class Prize: NSObject {
    var id: String = ""
    var createTime: TimeInterval = 0
    var updateTime: TimeInterval = 0
    var name: String = ""
    var thumb: String = ""
    var targetId: String = ""
    var targetType: TargetType = .empty
    
    init(json: JSON) {
        id = json["id"].stringValue
        createTime = json["createTime"].doubleValue
        updateTime = json["updateTime"].doubleValue
        name = json["name"].stringValue
        thumb = json["thumb"].stringValue
        targetId = json["targetId"].stringValue
        targetType = TargetType(rawValue: json["targetType"].stringValue) ?? .empty
    }
}