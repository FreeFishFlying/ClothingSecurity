//
//  IntegralFacade.swift
//  Labeauty
//
//  Created by 宋昌鹏 on 2019/4/27.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result
import Mesh
import SwiftyJSON

enum WalletDirection: String {
    case In = "IN"
    case Out = "OUT"
}

class IntegralFacade: NSObject {
    @objc public static let shared = IntegralFacade()
    
    func bonusPoint() -> SignalProducer<WalletResponseData, NSError> {
        return WalletRecordPacket().send().on()
    }
    
    func walletLog(page: Int, direction: WalletDirection) -> SignalProducer<WalletLogResponseData, NSError> {
        return WalletLogPacket(page: page, direction: direction).send().on()
    }
    
    func sign() -> SignalProducer<WalletSignResponseData, NSError> {
        return WalletSignPacket().send().on()
    }
    
    func prizeDraw() -> SignalProducer<PrizeDrawResponseData, NSError> {
        return PrizeDrawPacket().send().on()
    }
    
    func couponList(_ page: Int) -> SignalProducer<CouponResponseData, NSError> {
        return CouponPacket(page: page).send().on()
    }
}
