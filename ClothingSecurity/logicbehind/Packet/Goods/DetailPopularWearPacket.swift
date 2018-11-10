//
//  DetailPopularWearPacket.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/10.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Mesh
class DetailPopularWearPacket: HttpRequestPacket<DetailGoodResponseData> {
    let id: String
    init(id: String) {
        self.id = id
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    
    override func requestUrl() -> URL {
        return URL(string: "/outfit/get?outfitId=\(id)")!
        
    }
    override func httpMethod() -> HTTPMethod {
        return .get
    }
}
