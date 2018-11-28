//
//  ThirdLoginPacket.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/28.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Mesh
import ReactiveSwift
import SwiftyJSON

enum ThirdType {
    case wx
    case qq
    case wb
}

class ThirdLoginPacket: HttpRequestPacket<LoginResponseData> {
    private let code: String
    private let type: ThirdType
    init(code: String, type: ThirdType = .wx) {
        self.code = code
        self.type = type
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    
    override func requestUrl() -> URL {
        switch type {
        case .qq:
            return URL(string: "/login_qq")!
        case .wb:
            return URL(string: "/login_weibo")!
        default:
            return URL(string: "/login_wechat")!
        }
        
    }
    
    override func httpMethod() -> HTTPMethod {
        return .post
    }
    
    override func parameterEncoding() -> ParameterEncoding {
        return JSONEncoding.default
    }
    
    override func requestParameter() -> [String: Any]? {
        switch type {
        case .qq, .wb:
            return ["accessToken": code]
        default:
            return ["code": code]
        }
    }
}
