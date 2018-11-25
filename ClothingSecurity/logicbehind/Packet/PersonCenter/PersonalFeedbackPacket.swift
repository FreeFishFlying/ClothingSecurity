//
//  PersonalFeedbackPacket.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/25.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Mesh
import ReactiveSwift
import SwiftyJSON

class PersonalFeedbackPacket: HttpRequestPacket<HttpResponseData> {
    let content: String
    init(content: String) {
        self.content = content
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    
    override func requestUrl() -> URL {
        return URL(string: "/feedback/post")!
    }
    
    override func httpMethod() -> HTTPMethod {
        return .post
    }
    
    override func parameterEncoding() -> ParameterEncoding {
        return JSONEncoding.default
    }
    
    override func requestParameter() -> [String: Any]? {
        return ["content": content]
    }
    
    
}
