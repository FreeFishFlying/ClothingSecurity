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
    
    func popularWear(page: Int, size: Int) -> SignalProducer<PopularWearResponse, NSError> {
        return PopularWearPacket(page: page, size: size).send()
    }
    
    func latestMainPush(page: Int, size: Int) -> SignalProducer<PopularWearResponse, NSError> {
        return LatestMainPush(page: page, size: size).send()
    }
    
    func bannerList() -> SignalProducer<BannerListResponse, NSError> {
        return BannerListPacket().send()
    }
    
    func categoryList() -> SignalProducer<CategoryListResponseData, NSError> {
        return CategoryListPacket().send()
    }
}
