//
//  CollectListPacket.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/10.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Mesh
import ReactiveSwift
import SwiftyJSON

class CollectListPacketResponse: HttpResponseData {
    var page = 0
    var size = 0
    var total = 0
    var last: Bool = false
    var first: Bool = false
    var content = [Good]()
    required init(json: JSON?) {
        super.init(json: json)
        if let json = json {
            if !json["data"].isEmpty {
                let data = json["data"]
                page  = data["page"].intValue
                size = data["size"].intValue
                total = data["total"].intValue
                last = data["last"].boolValue
                first = data["first"].boolValue
                if let contentValues = data["content"].array {
                    contentValues.forEach { js in
                        if !js["target"].isEmpty {
                            content.append(Good(json: js["target"]))
                        }
                    }
                }
            }
        }
    }
}

class CollectListPacket: HttpRequestPacket<CollectListPacketResponse> {
    let targetType: CollectType
    let page: Int
    init(type: CollectType, page: Int) {
        targetType = type
        self.page = page
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    

    
    override func requestUrl() -> URL {
        return URL(string: "/collect/list?targetType=\(targetType.rawValue)&page=\(page)&size=20")!
        
    }
    override func httpMethod() -> HTTPMethod {
        return .get
    }
}
