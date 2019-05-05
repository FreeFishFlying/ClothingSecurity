//
//  Agency.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2019/5/5.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation
import SwiftyJSON
class Agency: NSObject {
    var id: String = ""
    var createTime: TimeInterval = 0
    var updateTime: TimeInterval = 0
    var userId: String = ""
    var logo: String = ""
    var sn: String = ""
    var name: String = ""
    var intro: String = ""
    var address: String = ""
    
    init(json: JSON) {
        id = json["id"].stringValue
        createTime = json["createTime"].doubleValue
        updateTime = json["updateTime"].doubleValue
        userId = json["userId"].stringValue
        logo = json["logo"].stringValue
        sn = json["sn"].stringValue
        name = json["name"].stringValue
        intro = json["intro"].stringValue
        address = json["address"].stringValue
    }
}


class GoodAttr: NSObject {
    var key: String = ""
    var value: String = ""
    init(json: JSON) {
        key = json["key"].stringValue
        value = json["value"].stringValue
    }
}
