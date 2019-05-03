//
//  Coupon.swift
//  Labeauty
//
//  Created by 宋昌鹏 on 2019/5/1.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation
import SwiftyJSON
enum ReduceRule: String {
    case VALUE = "VALUE"
    case DISCOUNT = "DISCOUNT"
}

enum ExpireRule: String {
    case FIXED = "FIXED"
    case DURATION = "DURATION"
}

class Coupon: NSObject {
    var id: String = ""
    var createTime: TimeInterval = 0
    var updateTime: TimeInterval = 0
    var name: String = ""
    var desc: String = ""
    var instructions: String = ""
    var totalNumber: Int = 0
    var reduceRule: ReduceRule = .VALUE
    var reduceValue: Int = 0
    var reduceDiscount: CGFloat = 0
    var expireRule: ExpireRule = .FIXED
    var beginTime: TimeInterval = 0
    var endTime: TimeInterval = 0
    var duration: Double = 0
    var disabled: Bool = false
    var sendTime: TimeInterval = 0
    
    init(json: JSON) {
        id = json["id"].stringValue
        createTime = json["createTime"].doubleValue
        updateTime = json["updateTime"].doubleValue
        name = json["name"].stringValue
        desc = json["desc"].stringValue
        instructions = json["instructions"].stringValue
        totalNumber = json["totalNumber"].intValue
        reduceRule = ReduceRule(rawValue: json["reduceRule"].stringValue) ?? .VALUE
        reduceValue = json["reduceValue"].intValue
        reduceDiscount = CGFloat(json["reduceDiscount"].floatValue)
        expireRule = ExpireRule.init(rawValue: json["expireRule"].stringValue) ?? .FIXED
        beginTime = json["beginTime"].doubleValue
        endTime = json["endTime"].doubleValue
        duration = json["duration"].doubleValue
        disabled = json["disabled"].boolValue
        sendTime = json["sendTime"].doubleValue
    }
}
