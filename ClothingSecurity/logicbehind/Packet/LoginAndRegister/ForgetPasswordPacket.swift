//
//  ChangePasswordPacket.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/31.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import ReactiveSwift
import SwiftyJSON
import Mesh

class ForgetPasswordPacket: HttpRequestPacket<HttpResponseData> {
    private let mobile: String
    private let code: String
    private let password: String
    init(mobile: String, code: String, newPD: String) {
        self.mobile = mobile
        self.code = code
        self.password = newPD
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    
    override func requestUrl() -> URL {
        return URL(string: "/forgot_password")!
    }
    
    override func httpMethod() -> HTTPMethod {
        return .post
    }
    
    override func parameterEncoding() -> ParameterEncoding {
        return JSONEncoding.default
    }
    
    override func requestParameter() -> [String: Any]? {
        return ["mobile": mobile, "code": code, "newPassword": password]
    }
}

