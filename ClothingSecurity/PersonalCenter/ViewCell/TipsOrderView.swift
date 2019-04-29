//
//  TipsOrderView.swift
//  Labeauty
//
//  Created by 宋昌鹏 on 2019/4/29.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation

class TipsOrderView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 176.0 / 255.0, green: 205.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0)
        addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        layer.cornerRadius = 2.0
        layer.masksToBounds = true
    }
    
    var order: String? {
        didSet {
            if let order = order {
                label.text = order
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 13)
        label.textColor = UIColor(red: 255.0 / 255.0, green: 243.0 / 255.0, blue: 243.0 / 255.0, alpha: 1.0)
        return label
    }()
}
