//
//  CategoryListPacket.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/3.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Mesh
import ReactiveSwift
import SwiftyJSON

class CategoryListResponseData: HttpResponseData {
    var list = [SearchCategory]()
    required init(json: JSON?) {
        super.init(json: json)
        if let json = json {
            if let data = json["data"].array {
                data.forEach { item in
                    list.append(SearchCategory(json: item))
                }
            }
        }
    }
}

class CategoryListPacket: HttpRequestPacket<CategoryListResponseData> {
    override func requestUrl() -> URL {
        return URL(string: "/category/list")!
    }
    
    override func httpMethod() -> HTTPMethod {
        return .get
    }
}
