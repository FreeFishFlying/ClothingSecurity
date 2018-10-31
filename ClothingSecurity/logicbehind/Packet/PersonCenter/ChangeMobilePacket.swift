//
//  ChangeMobilePacket.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/31.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Mesh
import ReactiveSwift
import SwiftyJSON

class ChangeMobilePacket: HttpRequestPacket<LoginResponseData> {
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
        return URL(string: "/change_mobile")!
    }
    
    override func httpMethod() -> HTTPMethod {
        return .post
    }
    
    override func parameterEncoding() -> ParameterEncoding {
        return JSONEncoding.default
    }
    
    override func requestParameter() -> [String: Any]? {
        return ["newMobile": mobile, "code": code]
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
