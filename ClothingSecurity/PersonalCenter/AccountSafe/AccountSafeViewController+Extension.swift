//
//  AccountSafeViewController+Extension.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/25.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Eureka
import Core
class SafeAccountCell: Cell<String>, CellType {
    
    var showIcon: Bool = false {
        didSet {
            icon.isHidden = !showIcon
        }
    }
    
    var title: String? {
        didSet {
            if let title = title {
                nameLabel.text = title
            }
        }
    }
    
    var content: String? {
        didSet {
            if let content = content {
                contentLabel.text = content
            }
        }
    }
    
    var url: String? {
        didSet {
            if let url = url, let path = URL(string: url) {
                icon.kf.setImage(with: path, placeholder: imageNamed("ic_defalult_logo"), options: nil, progressBlock: nil, completionHandler: nil)
            } else {
                icon.image = imageNamed("ic_defalult_logo")
            }
        }
    }
    
    public override func setup() {
        super.setup()
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        addSubview(nextIcon)
        nextIcon.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-29)
            make.width.height.equalTo(47)
        }
        addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-29)
            make.centerY.equalToSuperview()
        }
        addSubview(line)
        line.snp.makeConstraints { make  in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-0.5)
            make.height.equalTo(0.5)
        }
        layoutIfNeeded()
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 15)
        label.textColor = UIColor(hexString: "#333333")
        return label
    }()
    
    private let icon: UIImageView = {
        let icon = UIImageView()
        icon.image = imageNamed("ic_defalult_logo")
        return icon
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 15)
        label.textColor = UIColor(hexString: "#333333")
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

final class SafeAccountCellRow: Row<SafeAccountCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<SafeAccountCell>()
    }
}
