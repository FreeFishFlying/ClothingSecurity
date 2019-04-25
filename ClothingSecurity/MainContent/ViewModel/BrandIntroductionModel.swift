//
//  BrandIntroductionModel.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/1.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
class BrandIntroductionModel: NSObject {
    var height: CGFloat = 0
    var contentViewHeight: CGFloat = 0
    override init() {
        super.init()
        getHeight()
    }
    
    let title: String = "ANCILA"
    
    let content: String = "林之野在《琥珀屋》中说过\n “一个女人只有二十年的生命，其余的时间都在衰老。”\nAANCILA品牌自2013年成立以来，\n一直遵从内心本真，与时间对抗，与美丽为伍。"
    
    private func getHeight() {
        let width = ScreenWidth - 35 - 114
        height += 60
        height += 5
        height += 25
        var contentHeight: CGFloat = 20
        contentHeight += getTextHeigh(textStr: title, font: systemFontSize(fontSize: 15), width: width)
        contentHeight += 4
        contentHeight += getTextHeigh(textStr: content, font: systemFontSize(fontSize: 12), width: width)
        contentHeight += 18
        contentViewHeight = contentHeight
        height += contentHeight
    }
    
    

}
