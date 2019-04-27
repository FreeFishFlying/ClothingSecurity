//
//  IntegralItem.swift
//  Labeauty
//
//  Created by 宋昌鹏 on 2019/4/27.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation
import SwiftyJSON

class IntegralItem: NSObject {
    var id: String = ""
    var createTime: TimeInterval = 0
    var updateTime: TimeInterval = 0
    var changed: Int = 0
    var balance: Int = 0
    var userId: String = ""
    var type: String = ""
    var targetId: String = ""
    var targetType: String = ""
    var remark: String = ""
    var effectiveTime: TimeInterval = 0
    var endTime: TimeInterval = 0
    var status: Bool = true
    
    init(json: JSON) {
        id = json["id"].stringValue
        createTime = json["createTime"].doubleValue
        updateTime = json["updateTime"].doubleValue
        changed = json["changed"].intValue
        balance = json["balance"].intValue
        userId = json["userId"].stringValue
        type = json["type"].stringValue
        targetId = json["targetId"].stringValue
        targetType = json["targetType"].stringValue
        remark = json["remark"].stringValue
        effectiveTime = json["effectiveTime"].doubleValue
        endTime = json["endTime"].doubleValue
        if let state = json["status"].string, state == "SUCCESS" {
            status = true
        } else {
            status = false
        }
    }
}
