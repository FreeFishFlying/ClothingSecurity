//
//  DesignHotListPacket.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/5.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import SwiftyJSON
import Mesh
import ReactiveSwift

class DesignHotListResponse: HttpResponseData {
    var content: [VideoModel]?
    required init(json: JSON?) {
        super.init(json: json)
        if let json = json {
            if let list = json["content"].array {
                list.forEach { js in
                    content?.append(VideoModel(json: js))
                }
            }
        }
    }
}

class DesignHotListPacket: HttpRequestPacket<DesignHotListResponse> {
    
}
