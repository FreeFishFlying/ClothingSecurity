//
//  GoodSearchTermPacket.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/25.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Mesh
import ReactiveSwift
import SwiftyJSON

class GoodSearchTermResponse: HttpResponseData {
    var value: String = ""
    required init(json: JSON?) {
        super.init(json: json)
        if let json = json {
            let data = json["data"]
            if !data.isEmpty {
                value = data["value"].stringValue
            }
        }
    }
}

class GoodSearchTermPacket: HttpRequestPacket<GoodSearchTermResponse> {
    override func requestUrl() -> URL {
        return URL(string: "/goods/get_search_term")!
        
    }
    override func httpMethod() -> HTTPMethod {
        return .get
    }
}

