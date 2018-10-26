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
    override func setup() {
        super.setup()
        backgroundColor = .clear
    }
    
    private func configUI() {
        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalToSuperview()
        }
        addSubview(verifyButton)
        verifyButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(15)
            make.width.equalTo(98)
        }
        addSubview(textField)
        textField.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(-15)
            make.right.equalTo(verifyButton.snp.left).offset(15)
        }
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
        return line
    }()
    
    private let verifyButton: UIButton = {
        let button = UIButton()
        return button
    }()
}

