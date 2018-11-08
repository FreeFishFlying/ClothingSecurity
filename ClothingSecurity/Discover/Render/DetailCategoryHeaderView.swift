//
//  DetailCategoryHeaderView.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/3.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
class DetailCategoryHeaderView: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 14)
        label.textColor = UIColor(hexString: "#999999")
        return label
    }()
    
    var name: String? {
        didSet {
            label.text = name
        }
    }
    
}
