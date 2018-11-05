//
//  DetailRichGoodModel.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/4.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit

class DetailRichGoodModel: NSObject {
    let gap: CGFloat = 10.0
    var height: CGFloat = 0
    var sizeList = [CGSize]()
    let model: Good
    init(model: Good) {
        self.model = model
        super.init()
        sizeList = handleImageUrls(urls: self.model.details)
        sizeList.forEach { size in
            height += size.height
            height += 10
        }
    }
    
    var imageUrls: [String]? {
        return model.details
    }
    
    var isCollect: Bool? {
        return model.collected
    }
    
    var collectCount: Int? {
        return model.collectCount
    }
    
    var price: String? {
        return "￥\(model.price)"
    }
    
    var title: String? {
        return model.name
    }
    
    private func handleImageUrls(urls: [String]) -> [CGSize]{
        var sizeList = [CGSize]()
        urls.forEach { url in
            sizeList.append(changeNormalSizeToFit(normal: singleUrlToSize(url: url)))
        }
        return sizeList
    }
    
    private func singleUrlToSize(url: String) -> CGSize {
        var list: [String] = url.components(separatedBy: "_")
        list.removeFirst()
        var width: CGFloat = 750
        var height: CGFloat = 1214
        if let widthString = list.first {
            if let newValue = Float(widthString) {
                width = CGFloat(newValue)
            }
        }
        if let last = list.last {
            let newList = last.components(separatedBy: ".")
            if let heightString = newList.first {
                if let newValue = Float(heightString) {
                    height = CGFloat(newValue)
                }
            }
        }
        return CGSize(width: width, height: height)
    }
    
    private func changeNormalSizeToFit(normal: CGSize) -> CGSize {
        var width = normal.width
        var height = normal.height
        width = ScreenWidth
        height = height / (normal.width / ScreenWidth)
        return CGSize(width: width, height: height)
    }
}
