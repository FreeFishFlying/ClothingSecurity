//
//  LoginOutPacket.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/31.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Mesh
import ReactiveSwift
import SwiftyJSON

class LoginOutPacket: HttpRequestPacket<HttpResponseData> {
    override func requestUrl() -> URL {
        return URL(string: "/logout")!
    }
    
    override func httpMethod() -> HTTPMethod {
        return .post
    }
    
    override func parameterEncoding() -> ParameterEncoding {
        return JSONEncoding.default
    }
}
