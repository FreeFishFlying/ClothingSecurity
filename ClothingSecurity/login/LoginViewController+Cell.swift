//  LoginViewController+cell.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/25.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Core
import Eureka

class NormalTableViewCell: Cell<String>, CellType {
    public override func setup() {
        super.setup()
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
        }
        addSubview(nextIcon)
        nextIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
        }
        addSubview(subLabel)
        subLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(nextIcon.snp.left).offset(-10)
        }
        addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-0.5)
            make.height.equalTo(0.5)
        }
    }
    
    var name: String? {
        didSet {
            nameLabel.text = name
        }
    }
    
    var subContent: String? {
        didSet {
            subLabel.text = subContent
        }
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 15)
        label.textColor = UIColor(hexString: "#333333")
        return label
    }()
    
    private let nextIcon: UIImageView = {
        let icon = UIImageView()
        icon.image = imageNamed("ic_arrows_right")
        return icon
    }()
    
    private let line: UIImageView = {
        let line = UIImageView()
        line.backgroundColor = UIColor(red: 229.0 / 255.0, green: 229.0 / 255.0, blue: 229.0 / 255.0, alpha: 1.0)
        return line
    }()
    
    private let subLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 14)
        label.textColor = UIColor(hexString: "#666666")
        return label
    }()
}

final class NormalTableViewCellRow: Row<NormalTableViewCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<NormalTableViewCell>()
    }
}

class TextfieldInputCell: Cell<String>, CellType {
    
    public override func setup() {
        super.setup()
        backgroundColor = .clear 
        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(26)
        }
        addSubview(textField)
        textField.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(20)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
            make.right.equalToSuperview().offset(-20)
        }
        addSubview(line)
        line.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-0.5)
            make.height.equalTo(0.5)
        }
        layoutIfNeeded()
    }
    
    var placeHolder: String? {
        didSet {
            if let placeHolder = placeHolder {
                textField.placeholder = placeHolder
            }
        }
    }
    
    var imageName: String? {
        didSet {
            if let imageName = imageName {
                icon.image = imageNamed(imageName)
            }
        }
    }
    
    var textFieldText: String? {
        return textField.text
    }
    
    var sectury: Bool = false {
        didSet {
            textField.isSecureTextEntry = sectury
        }
    }
    
    private let icon: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFill
        return icon
    }()
    
    private let textField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor.clear
        return tf
    }()
    
    private let line: UIImageView = {
        let line = UIImageView()
        line.backgroundColor = UIColor(red: 229.0 / 255.0, green: 229.0 / 255.0, blue: 229.0 / 255.0, alpha: 1.0)
        return line
    }()
}

final class TextfieldInputCellRow: Row<TextfieldInputCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<TextfieldInputCell>()
    }
}
