//
//  LoginAndRegisterFacade.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/29.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

class LoginAndRegisterFacade: NSObject {
    @objc public static let shared = LoginAndRegisterFacade()
    
    private let needLoginPip = Signal<Bool, NoError>.pipe()
    
    func requetAuthcode(mobile: String) -> SignalProducer<HttpResponseData, NSError> {
        return GetAuthCodePacket(mobile: mobile).send()
    }
    
    func register(mobile: String, code: String) -> SignalProducer<LoginResponseData, NSError> {
        return RegisterPacket(mobile: mobile, code: code).send()
    }
    
    func login(mobile: String, password: String) -> SignalProducer<LoginResponseData, NSError> {
        return LoginPacket(mobile: mobile, pd: password).send()
    }
    
    func appWillLoginOut() -> Signal<Bool, NoError> {
        return needLoginPip.output
    }
    
    func changeLoginState(value: Bool) {
        needLoginPip.input.send(value: value)
    }
    
    func updateUserInfo(value: [String: String]) -> SignalProducer<LoginResponseData, NSError> {
        return UpdateUserPacket(info: value).send()
    }
    
    func updateAuthInfo() {
        AuthUserInfoPacket().sendImmediately()
    }
}
