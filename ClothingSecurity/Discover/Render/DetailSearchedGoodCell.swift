//
//  DetailSearchedGoodCell.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/4.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit

class DetailSearchedGoodCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(75)
        }
        addSubview(nextIcon)
        nextIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(17)
        }
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(20)
            make.centerY.equalToSuperview()
            make.right.equalTo(nextIcon.snp.left).offset(-10)
        }
        addSubview(line)
        line.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-0.5)
            make.height.equalTo(0.5)
        }
    }
    
    var model: Good?  {
        didSet {
            if let model = model {
                if let url = URL(string: model.thumb) {
                    icon.kf.setImage(with: url, placeholder: imageNamed("perch_search"))
                } else {
                    icon.image = imageNamed("perch_search")
                }
                nameLabel.text = model.name
            }
        }
    }
    
    private let icon: UIImageView = {
        let icon = UIImageView()
        icon.image = imageNamed("perch_search")
        icon.contentMode = .scaleAspectFill
        icon.clipsToBounds = true 
        return icon
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 15)
        label.textColor = UIColor(hexString: "#000000")
        return label
    }()
    
    private let nextIcon: UIImageView = {
        let next = UIImageView()
        return next
    }()
    
    private let line: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "#ebebeb")
        return view
    }()
}
