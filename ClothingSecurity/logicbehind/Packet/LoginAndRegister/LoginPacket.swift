//
//  LoginPacket.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/29.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Mesh
import ReactiveSwift
import SwiftyJSON

public class LoginResponseData: HttpResponseData {
    var userItem: UserItem?
    public required init(json: JSON?) {
        super.init(json: json)
        guard let json = json else { return }
        if !json["data"].isEmpty {
            userItem = UserItem.create(json: json["data"])
        }
        if let user = userItem, user.id.isEmpty {
            userItem = nil
        }
    }
}

class LoginPacket: HttpRequestPacket<LoginResponseData> {
    private let mobile: String
    private let pd: String
    init(mobile: String, pd: String) {
        self.mobile = mobile
        self.pd = pd
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    
    override func requestUrl() -> URL {
        return URL(string: "/login")!
    }
    
    override func httpMethod() -> HTTPMethod {
        return .post
    }
    
    override func parameterEncoding() -> ParameterEncoding {
        return JSONEncoding.default
    }
    
    override func requestParameter() -> [String: Any]? {
        return ["mobile": mobile, "password": pd]
    }
    
    override func send() -> SignalProducer<LoginResponseData, NSError> {
        return super.send().on(value: { data in
            if let user = data.userItem {
                UserItem.save(user)
                LoginAndRegisterFacade.shared.userChangePip.input.send(value: user)
            }
        })
    }
}

class RegisterPacket: HttpRequestPacket<LoginResponseData> {
    private let mobile: String
    private let code: String
    init(mobile: String, code: String) {
        self.mobile = mobile
        self.code = code
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    
    override func requestUrl() -> URL {
        return URL(string: "/login")!
    }
    
    override func httpMethod() -> HTTPMethod {
        return .post
    }
    
    override func parameterEncoding() -> ParameterEncoding {
        return JSONEncoding.default
    }
    
    override func requestParameter() -> [String: Any]? {
        return ["mobile": mobile, "code": code]
    }
}
