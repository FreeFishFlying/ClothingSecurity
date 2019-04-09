//
//  ThirdloginFacade.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/28.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import Mesh
import SwiftyJSON
class ThirdloginFacade: NSObject {
     @objc public static let shared = ThirdloginFacade()
    
    private let willRegisterSignal = Signal<Bool, NoError>.pipe()
    
    private let thirdLoginSuceessSignal = Signal<Bool, NoError>.pipe()
    
    public func scopeCode(resp: SendAuthResp) -> String? {
        if let code = resp.code {
            return code
        }
        return nil
    }
    
    func login(code: String, type: ThirdType) -> SignalProducer<LoginResponseData, NSError> {
        return ThirdLoginPacket(code: code, type: type).send().on(value: { data in
            if let user = data.userItem {
                if user.role == "USER" {
                    UserItem.save(user)
                    LoginState.shared.hasLogin.value = true
                    LoginAndRegisterFacade.shared.userChangePip.input.send(value: user)
                    self.thirdLoginSuceessSignal.input.send(value: true)
                } else if user.role == "OPEN_USER" {
                    self.willRegisterSignal.input.send(value: true)
                } else {
                    self.willRegisterSignal.input.send(value: false)
                }
            }
        })
    }
    
    func willRegister() -> Signal<Bool, NoError> {
        return willRegisterSignal.output
    }
    
    func thirdLoginSucess() -> Signal<Bool, NoError> {
        return thirdLoginSuceessSignal.output
    }
}
