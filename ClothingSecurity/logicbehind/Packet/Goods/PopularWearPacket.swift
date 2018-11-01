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
            let data = json["data"]
            if let contentJson = data["content"].array {
                contentJson.forEach { item in
                    content.append(Good(json: item))
                }
            }
            if let page = data["page"].int {
                self.page = page
            }
            if let size = data["size"].int {
                self.size = size
            }
            if let total = data["total"].int {
                self.total = total
            }
            if let last = data["last"].bool {
                self.last = last
            }
            if let first = data["first"].bool {
                self.first = first
            }
        }
    }
}

class PopularWearPacket: HttpRequestPacket<PopularWearResponse> {
    let page: Int
    let size: Int
    init(page: Int, size: Int = 10) {
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
