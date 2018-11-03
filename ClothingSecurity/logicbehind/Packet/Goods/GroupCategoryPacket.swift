//
//  GroupCategoryPacket.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/3.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Mesh
import ReactiveSwift
import SwiftyJSON

class GroupCategoryResponseData: HttpResponseData {
    var dataList = [SubCategory]()
    required init(json: JSON?) {
        super.init(json: json)
        if let json = json,let dataList = json["data"].array {
            dataList.forEach { item in
                self.dataList.append(SubCategory(json: item))
            }
        }
    }
}

class GroupCategoryPacket: HttpRequestPacket<GroupCategoryResponseData> {
    let id: String
    init(categoryId: String)
    {
        id = categoryId
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    
    override func requestUrl() -> URL {
        return URL(string: "/goods/group_by_category?categoryId=\(id)")!
    }
    
    override func httpMethod() -> HTTPMethod {
        return .get
    }
}

class SearchByKeywordPacket: HttpRequestPacket<PopularWearResponse> {
    let keyword: String
    init(keyword: String) {
        self.keyword = keyword
        SearchHistory.save(keyword)
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    
    override func requestUrl() -> URL {
        let url = "/outfit/list_hot?keyword=\(keyword)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return URL(string: url)!
    }
    
    override func httpMethod() -> HTTPMethod {
        return .get
    }
    
    override func parameterEncoding() -> ParameterEncoding {
        return URLEncoding.queryString
    }
}
