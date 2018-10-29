//
//  InputRender.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/26.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Eureka
import Core

class InputRenderCell: Cell<String>, CellType {
    
    var onGetCode: (() -> Void)?
    
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
    
    var title: String? {
        didSet {
            if let title = title {
                verifyButton.setTitle(title, for: .normal)
            }
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
        backgroundColor = .clear
        configUI()
        layoutIfNeeded()
    }
    
    private func configUI() {
        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(26)
        }
        addSubview(verifyButton)
        verifyButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(98)
            make.height.equalTo(34)
        }
        addSubview(textField)
        textField.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(15)
            make.right.equalTo(verifyButton.snp.left).offset(-15)
            make.centerY.equalToSuperview()
        }
        addSubview(line)
        line.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-0.5)
            make.height.equalTo(0.5)
        }
        verifyButton.addTarget(self, action: #selector(getCode), for: .touchUpInside)
    }
    
    @objc func getCode() {
        onGetCode?()
    }
    
    private let icon: UIImageView = {
        let icon = UIImageView()
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

final class InputRenderCellRow: Row<InputRenderCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<InputRenderCell>()
    }
}

