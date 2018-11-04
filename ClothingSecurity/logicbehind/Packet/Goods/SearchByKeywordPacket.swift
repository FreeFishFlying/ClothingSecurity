//
//  SearchByKeywordPacket.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/4.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Mesh

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
