//
//  MediaSelectionStripContext.swift
//  VideoPlayer-Swift
//
//  Created by Dylan on 14/04/2017.
//  Copyright © 2017 kingxt. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

class MediaSelectionStripContext {

    var assetItems = [MediaAsset]()

    private lazy var contextChangePipe: (output: Signal<StripContextChange, NoError>, input: Signal<StripContextChange, NoError>.Observer) = {
        Signal<StripContextChange, NoError>.pipe()
    }()

    init(items: [MediaAsset]) {
        assetItems.append(contentsOf: items)
    }

    func addSelectedItem(item: MediaAsset) {
        let exist = assetItems.contains { (asset: MediaAsset) -> Bool in
            return asset.uniqueIdentifier() == item.uniqueIdentifier()
        }
        if exist {
            return
        }
        assetItems.append(item)
        let change = StripContextChange(assetItems: assetItems, animated: true, add: true, index: assetItems.count - 1)
        contextChangePipe.input.send(value: change)
    }

    func removeSelectedItem(item: MediaSelectableItem) {
        let assetItemCount = assetItems.count
        for i in 0 ..< assetItemCount {
            let asset = assetItems[i]
            if asset.uniqueIdentifier() == item.uniqueIdentifier() {
                assetItems.remove(at: i)
                let change = StripContextChange(assetItems: assetItems, animated: true, add: false, index: i)
                contextChangePipe.input.send(value: change)
                break
            }
        }
    }

    func getTotalCount() -> Int {
        return assetItems.count
    }

    func dataSourceChangeSignal() -> Signal<StripContextChange, NoError> {
        return contextChangePipe.output
    }

    struct StripContextChange {
        var assetItems: [MediaAsset]
        var animated: Bool = true
        var add: Bool = false
        var index: Int
    }
}
