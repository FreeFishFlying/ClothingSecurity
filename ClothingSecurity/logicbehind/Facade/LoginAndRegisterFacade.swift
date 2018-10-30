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
    
    private let uploadImagePip = Signal<UploadHeaderImageResponse, NoError>.pipe()
    
    let userChangePip = Signal<UserItem, NoError>.pipe()
    
    func obserUserItemChange() -> Signal<UserItem, NoError> {
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
    
    func updateUserInfo(value: [String: String]) -> SignalProducer<LoginResponseData, NSError> {
        return UpdateUserPacket(info: value).send()
    }
    
    func updateAuthInfo() {
        AuthUserInfoPacket().sendImmediately()
    }
    
    func uploadHeaderImage(value: Data) -> Signal<UploadHeaderImageResponse, NoError> {
        let url = "https://api.beedee.yituizhineng.top" + "/oss/upload"
        Mesh.upload(multipartFormData: { form in
            form.append(value, withName: "file", fileName: "\(UUID().uuidString).png", mimeType: "png")
        }, to: url) { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseData(completionHandler: { response in
                    if let data = response.data {
                        if let value = String(data: data, encoding: .utf8) {
                            let json = JSON(parseJSON: value)
                            let model = UploadHeaderImageResponse(json: json)
                            self.uploadImagePip.input.send(value: model)
                            self.uploadImagePip.input.sendCompleted()
                            if let user = UserItem.current(), let model = model.imageModel {
                                user.avatar = model.url
                                UserItem.save(user)
                                LoginAndRegisterFacade.shared.userChangePip.input.send(value: user)
                            }
                        }
                    }
                })
            case .failure(_):
                self.uploadImagePip.input.sendCompleted()
            }
        }
        return uploadImagePip.output
    }
}
