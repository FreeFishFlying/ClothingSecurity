//
//  PersonalCenterViewController+Extension.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/25.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Eureka
import Core

class PersonalCenterCell: Cell<String>, CellType {
    public override func setup() {
        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(15)
            make.centerY.equalToSuperview()
        }
        addSubview(nextIcon)
        nextIcon.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
        addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-0.5)
            make.height.equalTo(0.5)
        }
        layoutIfNeeded()
    }
    
    var title: String? {
        didSet {
            if let title = title {
                let attributedString = NSMutableAttributedString(string: title)
                attributedString.addAttributes([
                    NSAttributedString.Key.font: UIFont(name: "PingFangSC-Regular", size: 15.0)!,
                    NSAttributedString.Key.foregroundColor:UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
                    ], range: NSRange(location: 0, length: title.length))
                nameLabel.attributedText = attributedString
            }
        }
    }
    
    var imageName: String? {
        didSet {
            if let name = imageName {
                icon.image = imageNamed(name)
            }
        }
    }
    
    private let icon: UIImageView = {
        return UIImageView()
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let nextIcon: UIImageView = {
        return UIImageView(image: imageNamed("icon_right"))
    }()
    
    private let line: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 229.0 / 255.0, green: 229.0 / 255.0, blue: 229.0 / 255.0, alpha: 1.0)
        return view
    }()
}

final class PersonalCenterCellRow: Row<PersonalCenterCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<PersonalCenterCell>()
    }
}
