//
//  SearchCategoryViewModel.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/3.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit

class SearchCategoryViewModel: NSObject {
    let model: SearchCategory
    init(model: SearchCategory) {
        self.model = model
        super.init()
    }
    
    let hightColor = UIColor(hexString: "#393838")
    
    let normalColor = UIColor(hexString: "#999999")
    
    var isSelected: Bool = false
    
    var title: String? {
        return model.name
    }
    
}
