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

    private let refreshNotification = Signal<Bool, NoError>.pipe()

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
        onUploadImage(value: value) { model in
            if let user = UserItem.current(), let model = model {
                user.avatar = model.url
                UserItem.save(user)
                PersonCenterFacade.shared.updateUserInfo(value: ["avatar": model.url]).start()
                LoginAndRegisterFacade.shared.userChangePip.input.send(value: user)
            }
        }
    }
    
    func onUploadImage(value: Data, callBack: @escaping ((ImageModel?) -> Void)) {
        let url = httpRootUrl + "/oss/upload"
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
                            callBack(model.imageModel)
                        } else {
                            print(" output value = \(encodingResult)")
                            callBack(nil)
                        }
                    }
                })
            case .failure(_):
                print(" output value = \(encodingResult)")
                callBack(nil)
            }
        }
    }
    
    func updateUserInfo(value: [String: String]) -> SignalProducer<LoginResponseData, NSError> {
        return UpdateUserPacket(info: value).send()
    }
    
    func feedback(content: [String: String])  -> SignalProducer<HttpResponseData, NSError> {
        return FeedbackPacket(params: content).send().on()
    }

    func notificationList(_ page: Int) -> SignalProducer<NotificationResponseData, NSError> {
        return NotificationPacket(page).send().on()
    }

    func unreadNotification() -> SignalProducer<UnreadNotificationResponseData, NSError> {
        return UnreadNotificationPacket().send().on()
    }

    func readNotification() -> SignalProducer<HttpResponseData, NSError> {
        return NotificationReadPacket().send().on(value: { response in
            if response.isSuccess() {
                self.refreshNotification.input.send(value: true)
            }
        })
    }

    func willRefreshNotification() -> Signal<Bool, NoError> {
        return refreshNotification.output
    }
}
