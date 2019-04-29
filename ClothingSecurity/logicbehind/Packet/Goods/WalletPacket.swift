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

//总积分

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

//  积分详情

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

//  签到
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

//抽奖

class PrizeDrawResponseData: HttpResponseData {
    var prizes: [Prize] = []
    var prizeIndex: Int = 0
    required init(json: JSON?) {
        super.init(json: json)
        if let json = json {
            let jsonValue = json["data"]
            if !jsonValue.isEmpty {
                prizeIndex = jsonValue["prizes"].intValue
                let list = jsonValue["prizes"].arrayValue
                list.forEach({ js in
                    prizes.append(Prize(json: js))
                })
            }
        }
    }
}

class PrizeDrawPacket: HttpRequestPacket<PrizeDrawResponseData> {
    override func requestUrl() -> URL {
        return URL(string: "/prize/draw")!
        
    }
    override func httpMethod() -> HTTPMethod {
        return .get
    }
}
