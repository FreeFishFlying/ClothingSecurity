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
    
    let title: String = "BEEDEE"
    
    let explain: String = "Pursuit the 1% Life, something different."
    
    let content: String = "追求1%的生活理念\nBeeDee作为设计师原创品牌，坚持创新\n坚持原创追求我们想要的感觉。"
    
    private func getHeight() {
        let width = ScreenWidth - 35 - 114
        height += 60
        height += 5
        height += 25
        var contentHeight: CGFloat = 20
        contentHeight += getTextHeigh(textStr: title, font: systemFontSize(fontSize: 15), width: width)
        contentHeight += 4
        contentHeight += getTextHeigh(textStr: explain, font: systemFontSize(fontSize: 12), width: width)
        contentHeight += 8
        contentHeight += getTextHeigh(textStr: content, font: systemFontSize(fontSize: 12), width: width)
        contentHeight += 18
        contentViewHeight = contentHeight
        height += contentHeight
    }
    
    

}
