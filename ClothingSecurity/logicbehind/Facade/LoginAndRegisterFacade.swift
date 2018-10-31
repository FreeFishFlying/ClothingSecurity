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
import Mesh
import SwiftyJSON

class LoginAndRegisterFacade: NSObject {
    @objc public static let shared = LoginAndRegisterFacade()
    
    private let needLoginPip = Signal<Bool, NoError>.pipe()
    
    let userChangePip = Signal<UserItem?, NoError>.pipe()
    
    func obserUserItemChange() -> Signal<UserItem?, NoError> {
        return userChangePip.output
    }
    
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
    
    func forgetPassword(mobile: String, code: String, newPassword: String) -> SignalProducer<HttpResponseData, NSError> {
        return ForgetPasswordPacket(mobile: mobile, code: code, newPD: newPassword).send()
    }
}
