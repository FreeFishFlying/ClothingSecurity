//
//  SearchCategoryCell.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/3.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit

class SearchCategoryCell: UITableViewCell {
    var model: SearchCategory?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectedBackgroundView = selectedView
        backgroundColor = UIColor(hexString: "#f7f7f7")
        addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func render(_ model: SearchCategoryViewModel) {
        self.model = model.model
        label.text = model.title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let selectedView: UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: 94, height: 70))
        view.backgroundColor = UIColor.white
        return view
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#999999")
        label.font = systemFontSize(fontSize: 14)
        return label
    }()
}
