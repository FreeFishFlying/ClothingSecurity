//
//  LatestMainPushPacket.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/4.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Mesh

class LatestMainPush: PopularWearPacket {
    override func requestUrl() -> URL {
        return URL(string: "/goods/list_hot?size=\(size)&page=\(page)")!
        
    }
    override func httpMethod() -> HTTPMethod {
        return .get
    }
}
