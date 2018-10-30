//
//  UpdateUserPacket.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/29.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Mesh
import ReactiveSwift
import SwiftyJSON

class UploadHeaderImageResponse: HttpResponseData {
    var imageModel: ImageModel?
    public required init(json: JSON?) {
        super.init(json: json)
        guard let json = json else { return }
        imageModel = ImageModel(json: json["data"])
    }
}

class UpdateUserPacket: HttpRequestPacket<LoginResponseData> {
    private let updateInfo: [String: String]
    init(info: [String: String]) {
        updateInfo = info
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    
    override func requestUrl() -> URL {
        return URL(string: "/user/update")!
    }
    
    override func httpMethod() -> HTTPMethod {
        return .post
    }
    
    override func parameterEncoding() -> ParameterEncoding {
        return JSONEncoding.default
    }
    
    override func requestParameter() -> [String: Any]? {
        return updateInfo
    }
    
    override func send() -> SignalProducer<LoginResponseData, NSError> {
        return super.send().on(value: { data in
            if let user = data.userItem {
                LoginAndRegisterFacade.shared.userChangePip.input.send(value: user)
            }
        })
    }
}
