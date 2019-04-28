//
//  WalletPacket.swift
//  Labeauty
//
//  Created by 宋昌鹏 on 2019/4/27.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation
import Mesh
import ReactiveSwift
import SwiftyJSON

class WalletResponseData: HttpResponseData {
    var bonusPoints: String = ""
    required init(json: JSON?) {
        super.init(json: json)
        if let json = json {
            let data = json["data"]
            if !data.isEmpty {
                bonusPoints = data["bonusPoints"].stringValue
            }
        }
    }
}

class WalletRecordPacket: HttpRequestPacket<WalletResponseData> {
    override func requestUrl() -> URL {
        return URL(string: "/wallet/get")!
        
    }
    override func httpMethod() -> HTTPMethod {
        return .get
    }
}

class WalletLogResponseData: HttpResponseData {
    var page: Int = 0
    var total: Int = 0
    var last = false
    var first = true
    var data: [IntegralItem] = []
    required init(json: JSON?) {
        super.init(json: json)
        if let json = json {
            let list = json["data"].arrayValue
            list.forEach { item in
                let item = IntegralItem(json: item)
                data.append(item)
            }
            page = json["page"].intValue
            total = json["total"].intValue
            last = json["last"].boolValue
            first = json["first"].boolValue
        }
    }
}

class WalletLogPacket: HttpRequestPacket<WalletLogResponseData> {
    let page: Int
    let direction: WalletDirection
    init(page: Int, direction: WalletDirection) {
        self.page = page
        self.direction = direction
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    override func requestUrl() -> URL {
        return URL(string: "/wallet/log/list?page=\(page)&size=10&direction=\(direction.rawValue)")!
        
    }
    override func httpMethod() -> HTTPMethod {
        return .get
    }
}

class WalletSignResponseData: HttpResponseData {
    var data: IntegralItem?
    required init(json: JSON?) {
        super.init(json: json)
        if let json = json {
            if !json["data"].isEmpty {
                let item = json["data"]
                data = IntegralItem(json: item)
            }
        }
    }
}

class WalletSignPacket: HttpRequestPacket<WalletSignResponseData> {
    override func requestUrl() -> URL {
        return URL(string: "/task/sign")!
        
    }
    override func httpMethod() -> HTTPMethod {
        return .get
    }
}
