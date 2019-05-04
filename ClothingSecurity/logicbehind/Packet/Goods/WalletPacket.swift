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
    var log: prizeLog?
    required init(json: JSON?) {
        super.init(json: json)
        if let json = json {
            let jsonValue = json["data"]
            if !jsonValue.isEmpty {
                prizeIndex = jsonValue["prizeIndex"].intValue
                log = prizeLog.init(json: jsonValue["prizeLog"])
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

//优惠券
class CouponResponseData: HttpResponseData {
    var data: [Coupon] = []
    var page: Int = 0
    var last: Bool = false
    var first: Bool = false
    required init(json: JSON?) {
        super.init(json: json)
        if let json = json {
            let list = json["data"].arrayValue
            list.forEach { js in
                let coup = Coupon(json: js)
                data.append(coup)
            }
            page = json["page"].intValue
            last = json["last"].boolValue
            first = json["first"].boolValue
        }
    }
}

class CouponPacket: HttpRequestPacket<CouponResponseData> {
    let page: Int
    init(page: Int) {
        self.page = page
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    
    override func requestUrl() -> URL {
        return URL(string: "/coupon/list?page=\(page)&size=10")!
        
    }
    override func httpMethod() -> HTTPMethod {
        return .get
    }
    
}

// 查询收货地址

class AddressResponseData: HttpResponseData {
    var data: [Address] = []
    var page: Int = 0
    var last: Bool = false
    var first: Bool = false
    required init(json: JSON?) {
        super.init(json: json)
        if let json = json {
            let list = json["data"].arrayValue
            list.forEach { js in
                let add = Address(json: js)
                data.append(add)
            }
            page = json["page"].intValue
            last = json["last"].boolValue
            first = json["first"].boolValue
        }
    }
}

class AddressPacket: HttpRequestPacket<AddressResponseData> {
    let page: Int
    init(page: Int) {
        self.page = page
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    
    override func requestUrl() -> URL {
        return URL(string: "/address/list?page=\(page)&size=10")!
        
    }
    override func httpMethod() -> HTTPMethod {
        return .get
    }
}

//新增收货地址

class NewAddressResponseData: HttpResponseData {
    var address: Address? = nil
    required init(json: JSON?) {
        super.init(json: json)
        if let json = json {
            if !json["data"].isEmpty {
                address = Address(json: json["data"])
            }
        }
    }
}

class NewAddressPacket: HttpRequestPacket<NewAddressResponseData> {
    let address: Address
    init(address: Address) {
        self.address = address
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    
    override func requestUrl() -> URL {
        return URL(string: "/address/create")!
    }
    
    override func httpMethod() -> HTTPMethod {
        return .post
    }
    
    override func parameterEncoding() -> ParameterEncoding {
        return JSONEncoding.default
    }
    
    override func requestParameter() -> [String: Any]? {
        return ["province": address.province, "city": address.city, "area": address.area, "address": address.address, "name": address.name, "mobile": address.mobile, "defaultAddress": address.defaultAddress]
    }
}

//更新地址

class UpdateAddressPacket: HttpRequestPacket<NewAddressResponseData> {
    let address: Address
    init(address: Address) {
        self.address = address
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    
    override func requestUrl() -> URL {
        return URL(string: "/address/update")!
    }
    
    override func httpMethod() -> HTTPMethod {
        return .post
    }
    
    override func parameterEncoding() -> ParameterEncoding {
        return JSONEncoding.default
    }
    
    override func requestParameter() -> [String: Any]? {
        return ["id": address.id,"province": address.province, "city": address.city, "area": address.area, "address": address.address, "name": address.name, "mobile": address.mobile, "defaultAddress": address.defaultAddress]
    }
}

//删除地址

class DeleteAddressPacket: HttpRequestPacket<HttpResponseData> {
    let id: String
    init(id: String) {
        self.id = id
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    
    override func requestUrl() -> URL {
        return URL(string: "/address/delete?id=\(id)")!
        
    }
    override func httpMethod() -> HTTPMethod {
        return .get
    }
}

//绑定收货地址

class BindAddressPacket: HttpRequestPacket<HttpResponseData> {
    let prizeId: String
    let addressId: String
    init(prizeId: String, addressId: String) {
        self.prizeId = prizeId
        self.addressId = addressId
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    
    override func requestUrl() -> URL {
        return URL(string: "/prize/log/bind_address?prizeLogId=\(prizeId)&addressId=\(addressId)")!
        
    }
    override func httpMethod() -> HTTPMethod {
        return .get
    }
}
