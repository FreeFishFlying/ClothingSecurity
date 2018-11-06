//
//  UnCollectGoodPacket.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/5.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import SwiftyJSON
import Mesh
import ReactiveSwift

class UnCollectGoodPacket: HttpRequestPacket<HttpResponseData> {
    let id: String
    var type: String = ""
    init(id: String, type: CollectType) {
        self.id = id
        self.type = type.rawValue
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    
    override func requestUrl() -> URL {
        return URL(string: "/uncollect")!
        
    }
    
    override func httpMethod() -> HTTPMethod {
        return .post
    }
    
    override func parameterEncoding() -> ParameterEncoding {
        return JSONEncoding.default
    }
    
    override func requestParameter() -> [String: Any]? {
        return ["targetId": id, "targetType": type]
    }
}
