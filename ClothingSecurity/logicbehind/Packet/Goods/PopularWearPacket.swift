//
//  PopularWearPacket.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/2.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Mesh
import ReactiveSwift
import SwiftyJSON

class PopularWearResponse: HttpResponseData {
    var content = [Good]()
    var page = 0
    var size = 0
    var total = 0
    var last: Bool = false
    var first: Bool = false
    required init(json: JSON?) {
        super.init(json: json)
        if let json = json {
            if let contentJson = json["data"].array {
                contentJson.forEach { item in
                    content.append(Good(json: item))
                }
            }
            self.page = json["page"].intValue
            if let size = json["size"].int {
                self.size = size
            }
            if let total = json["total"].int {
                self.total = total
            }
            if let last = json["last"].bool {
                self.last = last
            }
            if let first = json["first"].bool {
                self.first = first
            }
        }
    }
}

class PopularWearPacket: HttpRequestPacket<PopularWearResponse> {
    let page: Int
    let size: Int
    init(page: Int, size: Int ) {
        self.page = page
        self.size = size
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    
    override func requestUrl() -> URL {
        return URL(string: "/outfit/list_hot?size=\(size)&page=\(page)")!
    }
    
    override func httpMethod() -> HTTPMethod {
        return .get
    }
}
