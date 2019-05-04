//
//  AddressCell.swift
//  Labeauty
//
//  Created by 宋昌鹏 on 2019/5/3.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation

class AddressCell: UITableViewCell {
    var onSetDefaultAddress: ((Address) -> Void)?
    var onEditAddress: ((Address) -> Void)?
    var onDeleteAddress: ((Address) -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clear
        selectionStyle = .none
        configUI()
        defaultButton.addTarget(self, action: #selector(setDefaultAddress), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editAddress), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteAddress), for: .touchUpInside)
    }
    
    @objc private func setDefaultAddress() {
        if let address = address {
            onSetDefaultAddress?(address)
        }
    }
    
    @objc private func editAddress() {
        if let address = address {
            onEditAddress?(address)
        }
    }
    
    @objc private func deleteAddress() {
        if let address = address {
            onDeleteAddress?(address)
        }
    }
    
    private func configUI() {
        addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.bottom.right.equalToSuperview()
        }
        
        container.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(13)
        }
        container.addSubview(mobileLabel)
        mobileLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right).offset(10)
            make.centerY.equalTo(nameLabel)
        }
        container.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(11)
            make.left.equalToSuperview().offset(15)
        }
        container.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-44)
            make.height.equalTo(1)
        }
        container.addSubview(defaultButton)
        defaultButton.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(15)
            make.width.equalTo(90)
            make.height.equalTo(24)
        }
        container.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom).offset(12)
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(70)
            make.height.equalTo(24)
        }
        container.addSubview(editButton)
        editButton.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom).offset(12)
            make.right.equalTo(deleteButton.snp.left).offset(-20)
            make.width.equalTo(70)
            make.height.equalTo(24)
        }
    }
    
    var address: Address? {
        didSet {
            if let address = address {
                nameLabel.text = address.name
                mobileLabel.text = address.mobile
                addressLabel.text = address.detailedAddress
                if address.defaultAddress {
                    defaultButton.setTitleColor(UIColor(red: 176.0 / 255.0, green: 205.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0), for: .normal)
                    defaultButton.setImage(imageNamed("hook"), for: .normal)
                } else {
                    defaultButton.setTitleColor(UIColor(red: 153.0 / 255.0, green: 153.0 / 255.0, blue: 153.0 / 255.0, alpha: 1.0), for: .normal)
                    defaultButton.setImage(imageNamed("gender"), for: .normal)
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PingFangSC-Medium", size: 17.5)
        label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        return label
    }()
    
    private let mobileLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PingFangSC-Regular", size: 15.0)
        label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PingFangSC-Regular", size: 14.0)
        label.textColor = UIColor(red: 139.0 / 255.0, green: 139.0 / 255.0, blue: 141.0 / 255.0, alpha: 1.0)
        return label
    }()
    
    private let defaultButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = systemFontSize(fontSize: 13)
        button.setTitleColor(UIColor(red: 153.0 / 255.0, green: 153.0 / 255.0, blue: 153.0 / 255.0, alpha: 1.0), for: .normal)
        button.setImage(imageNamed("gender"), for: .normal)
        button.setTitle("默认地址", for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)
        return button
    }()
    
    private let editButton: UIButton = {
        let button =  UIButton()
        button.titleLabel?.font = systemFontSize(fontSize: 13)
        button.setTitleColor(UIColor(red: 153.0 / 255.0, green: 153.0 / 255.0, blue: 153.0 / 255.0, alpha: 1.0), for: .normal)
        button.setImage(imageNamed("edit"), for: .normal)
        button.setTitle("编辑", for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button =  UIButton()
        button.titleLabel?.font = systemFontSize(fontSize: 13)
        button.setTitleColor(UIColor(red: 153.0 / 255.0, green: 153.0 / 255.0, blue: 153.0 / 255.0, alpha: 1.0), for: .normal)
        button.setImage(imageNamed("Deletebutton"), for: .normal)
        button.setTitle("删除", for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)
        return button
    }()
    
    private let line: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(red: 221.0 / 255.0, green: 221.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0)
        return line
    }()
}
