//
//  AddressFacade.swift
//  Labeauty
//
//  Created by 宋昌鹏 on 2019/5/3.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result
import Mesh
import SwiftyJSON

class AddressFacade: NSObject {
    @objc public static let shared = AddressFacade()
    
    func addressList(_ page: Int) -> SignalProducer<AddressResponseData, NSError> {
        return AddressPacket(page: page).send().on()
    }
}
