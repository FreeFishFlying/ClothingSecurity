//
//  GoodsFacade.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/2.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result
import Mesh
import SwiftyJSON

class GoodsFacade: NSObject {
    @objc public static let shared = GoodsFacade()
    
    func popularWear(page: Int) -> SignalProducer<PopularWearResponse, NSError> {
        return PopularWearPacket(page: page).send()
    }
    
    func latestMainPush(page: Int) -> SignalProducer<PopularWearResponse, NSError> {
        return LatestMainPush(page: page).send()
    }
}
