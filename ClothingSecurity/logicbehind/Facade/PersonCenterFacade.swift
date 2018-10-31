//
//  PersonCenterFacade.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/31.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result
import Mesh
import SwiftyJSON

class PersonCenterFacade: NSObject {
    @objc public static let shared = PersonCenterFacade()
    func logout() {
        LoginOutPacket().sendImmediately()
    }
    
    func changeMobile(mobile: String, code: String) -> SignalProducer<LoginResponseData, NSError> {
        return ChangeMobilePacket(mobile: mobile, code: code).send()
    }
    
    func changePassword(old: String, new: String) -> SignalProducer<LoginResponseData, NSError> {
        return ChangePasswordPacket(origPassword: old, newPassword: new).send()
    }
    
    func updateAuthInfo() {
        AuthUserInfoPacket().sendImmediately()
    }
    
    func uploadHeaderImage(value: Data) {
        let url = "https://api.beedee.yituizhineng.top" + "/oss/upload"
        Mesh.upload(multipartFormData: { form in
            form.append(value, withName: "file", fileName: "\(UUID().uuidString).png", mimeType: "png")
        }, to: url) { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseData(completionHandler: { response in
                    if let data = response.data {
                        if let value = String(data: data, encoding: .utf8) {
                            print(" output value = \(value)")
                            let json = JSON(parseJSON: value)
                            let model = UploadHeaderImageResponse(json: json)
                            if let user = UserItem.current(), let model = model.imageModel {
                                user.avatar = model.url
                                UserItem.save(user)
                                PersonCenterFacade.shared.updateUserInfo(value: ["avatar": model.url]).start()
                                LoginAndRegisterFacade.shared.userChangePip.input.send(value: user)
                            }
                        }
                    }
                })
            case .failure(_):
                print("upload image failed ")
            }
        }
    }
    
    func updateUserInfo(value: [String: String]) -> SignalProducer<LoginResponseData, NSError> {
        return UpdateUserPacket(info: value).send()
    }
}
