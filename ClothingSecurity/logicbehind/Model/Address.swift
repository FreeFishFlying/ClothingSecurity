//
//  Address.swift
//  Labeauty
//
//  Created by 宋昌鹏 on 2019/5/3.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation
import SwiftyJSON

class Address: NSObject {
    var id: String = ""
    var createTime: TimeInterval = 0
    var updateTime: TimeInterval = 0
    var name: String = ""
    var userId: String = ""
    var province: String = ""
    var city: String = ""
    var area: String = ""
    var address: String = ""
    var mobile: String = ""
    var defaultAddress: Bool = false
    var detailedAddress: String = ""
    
    init(json: JSON?) {
        if let json = json {
            id = json["id"].stringValue
            createTime = json["createTime"].doubleValue
            updateTime = json["updateTime"].doubleValue
            name = json["name"].stringValue
            userId = json["userId"].stringValue
            province = json["province"].stringValue
            city = json["city"].stringValue
            area = json["area"].stringValue
            address = json["address"].stringValue
            mobile = json["mobile"].stringValue
            defaultAddress = json["defaultAddress"].boolValue
            detailedAddress = json["detailedAddress"].stringValue
        }
        
    }
}
