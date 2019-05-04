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
    
    private let refreshAddressPipe = Signal<Bool, NoError>.pipe()
    
    func addressWillRefresh() -> Signal<Bool, NoError> {
        return refreshAddressPipe.output
    }
    
    func addressList(_ page: Int) -> SignalProducer<AddressResponseData, NSError> {
        return AddressPacket(page: page).send().on()
    }
    
    func createAddress(_ address: Address) -> SignalProducer<NewAddressResponseData, NSError> {
        return NewAddressPacket(address: address).send().on(value: { response in
            if response.isSuccess() {
                self.refreshAddressPipe.input.send(value: true)
            }
        })
    }
    
    func updateAddress(_ address: Address) -> SignalProducer<NewAddressResponseData, NSError> {
        return UpdateAddressPacket(address: address).send().on(value: { response in
            if response.isSuccess() {
                self.refreshAddressPipe.input.send(value: true)
            }
        })
    }
    
    func deleteAddress(_ id: String) -> SignalProducer<HttpResponseData, NSError> {
        return DeleteAddressPacket(id: id).send().on(value: { response in
            if response.isSuccess() {
                self.refreshAddressPipe.input.send(value: true)
            }
        })
    }
    
    func bindPrized(prizeLogId: String, addressId: String) -> SignalProducer<HttpResponseData, NSError> {
        return BindAddressPacket.init(prizeId: prizeLogId, addressId: addressId).send().on()
    }
}
