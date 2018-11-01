//
//  AuthUserInfoPacket.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/29.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Mesh
import ReactiveSwift
import SwiftyJSON

class AuthUserInfoPacket: HttpRequestPacket<LoginResponseData> {
    
    override func requestUrl() -> URL {
        return URL(string: "/get_auth_info")!
    }
    
    override func httpMethod() -> HTTPMethod {
        return .get
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
