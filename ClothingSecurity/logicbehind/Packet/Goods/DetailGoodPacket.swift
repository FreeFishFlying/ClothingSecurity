//
//  DetailGoodPacket.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/4.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import SwiftyJSON
import Mesh

class DetailGoodResponseData: HttpResponseData {
    var model: Good?
    required init(json: JSON?) {
        super.init(json: json)
        if let json = json {
            model = Good(json: json["data"])
        }
    }
}

class DetailGoodPacket: HttpRequestPacket<DetailGoodResponseData> {
    let id: String
    init(id: String) {
        self.id = id
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    
    override func requestUrl() -> URL {
        return URL(string: "/goods/get?goodsId=\(id)")!
        
    }
    override func httpMethod() -> HTTPMethod {
        return .get
    }
}
