//
//  NannerListPacket.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/2.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Mesh
import ReactiveSwift
import SwiftyJSON

class BannerListResponse: HttpResponseData {
    var data = [Banner]()
    required init(json: JSON?) {
        super.init(json: json)
        if let json = json {
            if let dataItems = json["data"].array {
                dataItems.forEach { js in
                    data.append(Banner(json: js))
                }
            }
        }
    }
}

class BannerListPacket: HttpRequestPacket<BannerListResponse> {
    override func requestUrl() -> URL {
        return URL(string: "/banner/list")!
    }
    
    override func httpMethod() -> HTTPMethod {
        return .get
    }
}
