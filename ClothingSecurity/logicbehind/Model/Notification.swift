//
//  Notification.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2019/5/5.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation
import SwiftyJSON

class Notification: NSObject {
    var id: String = ""
    var createTime: TimeInterval = 0
    var userId: String = ""
    var title: String = ""
    var content = ""
    var type: String = ""

    init(json: JSON) {
        id = json["id"].stringValue
        createTime = json["createTime"].doubleValue
        userId = json["userId"].stringValue
        title = json["title"].stringValue
        content = json["content"].stringValue
        type = json["type"].stringValue
    }
}
