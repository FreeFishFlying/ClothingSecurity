//
//  AccountSafeViewController+Cell.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/28.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Eureka
import Core

class NormalSafeAccountCell: Cell<String>, CellType {
    
    var title: String? {
        didSet {
            if let title = title {
                nameLabel.text = title
            }
        }
    }
    
    var placeHolder: String? {
        didSet {
            if let placeHolder = placeHolder {
                textField.placeholder = placeHolder
            }
        }
    }
    
    var model: NSTextAlignment = .left {
        didSet {
            textField.textAlignment = model
        }
    }
    
    var content: String? {
        set {
            textField.text = newValue
        }
        get {
            return textField.text
        }
    }
    
    override func setup() {
        super.setup()
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15)
        }
        addSubview(textField)
        textField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(103)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.height.equalTo(44)
        }
        addSubview(line)
        line.snp.makeConstraints { make in
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
    
    let textField: UITextField = {
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

final class NormalSafeAccountCellRow: Row<NormalSafeAccountCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<NormalSafeAccountCell>()
    }
}

class NormalSafeAccounbtVerifyCell: Cell<String>, CellType {
    var onVerify: (() -> Void)?
    
    var title: String? {
        didSet {
            if let title = title {
                nameLabel.text = title
            }
        }
    }
    
    var placeHolder: String? {
        didSet {
            if let placeHolder = placeHolder {
                textField.placeholder = placeHolder
            }
        }
    }
    
    var buttonTitle: String? {
        didSet {
            verifyButton.setTitle(buttonTitle, for: .normal)
        }
    }
    
    var code: String? {
        return textField.text
    }
    
    var buttonEnable: Bool? {
        didSet {
            if let enalbe = buttonEnable {
                verifyButton.isEnabled = enalbe
                if enalbe {
                    verifyButton.backgroundColor = UIColor.black
                    verifyButton.setTitleColor(UIColor(red: 255.0 / 255.0, green: 239.0 / 255.0, blue: 4.0 / 255.0, alpha: 1.0), for: .normal)
                } else {
                    verifyButton.backgroundColor = UIColor(hexString: "#d9d9d9")
                    verifyButton.setTitleColor(UIColor.white, for: .normal)
                }
            }
        }
    }
    
    override func setup() {
        super.setup()
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        addSubview(verifyButton)
        verifyButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.height.equalTo(34)
            make.width.equalTo(97)
        }
        addSubview(textField)
        textField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(103)
            make.right.equalTo(verifyButton.snp.left).offset(-10)
            make.centerY.equalToSuperview()
        }
        addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-0.5)
            make.height.equalTo(0.5)
        }
        verifyButton.addTarget(self, action: #selector(verify), for: .touchUpInside)
        layoutIfNeeded()
    }
    
    @objc private func verify() {
        onVerify?()
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 15)
        label.textColor = UIColor(hexString: "#333333")
        return label
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
    
    private let verifyButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = systemFontSize(fontSize: 15)
        button.setTitleColor(UIColor(red: 255.0 / 255.0, green: 239.0 / 255.0, blue: 4.0 / 255.0, alpha: 1.0), for: .normal)
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor.black
        return button
    }()
}

final class NormalSafeAccounbtVerifyCellRow: Row<NormalSafeAccounbtVerifyCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<NormalSafeAccounbtVerifyCell>()
    }
}
