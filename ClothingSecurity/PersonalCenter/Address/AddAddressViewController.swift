//
//  AddAddressViewController.swift
//  Labeauty
//
//  Created by 宋昌鹏 on 2019/5/3.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation

class AddAddressViewController: BaseViewController {
    var addrss: Address = Address(json: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "填写地址"
        autoHideKeyboard = true
        configUI()
    }
    
    private func configUI() {
        view.addSubview(scroll)
        scroll.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.bottom.right.equalToSuperview()
        }
        scroll.contentSize = CGSize(width: 0, height: 0)
        scroll.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make  in
            make.top.equalTo(safeAreaTopLayoutGuide).offset(15)
            make.left.equalToSuperview().offset(15)
        }
        scroll.addSubview(nameTF)
        nameTF.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(40)
        }
        scroll.addSubview(mobileLabel)
        mobileLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(nameTF.snp.bottom).offset(16)
        }
        scroll.addSubview(mobileTF)
        mobileTF.snp.makeConstraints { make in
            make.top.equalTo(mobileLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(40)
        }
        scroll.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(mobileTF.snp.bottom).offset(16)
        }
        scroll.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(40)
        }
        scroll.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(contentView.snp.bottom).offset(16)
        }
        scroll.addSubview(addressTF)
        addressTF.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(40)
        }
        scroll.addSubview(button)
        button.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(48)
            make.right.equalToSuperview().offset(-48)
            make.height.equalTo(45)
            make.bottom.equalToSuperview().offset(-40)
        }
        configContentView()
    }
    
    private func configContentView() {
        let width = (ScreenWidth - 30 - 32) / 3
        contentView.addSubview(provinceLabel)
        contentView.addSubview(cityLabel)
        contentView.addSubview(countryLabel)
        provinceLabel.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(width)
        }
        cityLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(provinceLabel.snp.right).offset(16)
            make.width.equalTo(width)
        }
        countryLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(cityLabel.snp.right).offset(16)
            make.width.equalTo(width)
        }
        provinceLabel.addSubview(doutIcon_1)
        cityLabel.addSubview(doutIcon_2)
        countryLabel.addSubview(doutIcon_3)
        doutIcon_1.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
        doutIcon_2.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
        doutIcon_3.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
    
    private let scroll: UIScrollView = {
        let scroll = UIScrollView()
        return scroll
    }()
    
    private let nameTF: UITextField = {
        let tf = UITextField()
        tf.borderStyle = UITextField.BorderStyle.none
        tf.font = systemFontSize(fontSize: 12)
        tf.layer.borderWidth = 0.5
        tf.layer.borderColor = UIColor(red: 221.0 / 255.0, green: 221.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0).cgColor
        tf.placeholder = " 请填写收货人姓名"
        return tf
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "收货人"
        label.font = UIFont(name: "PingFangSC-Regular", size: 14.0)
        label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        return label
    }()
    
    private let mobileTF: UITextField = {
        let tf = UITextField()
        tf.font = systemFontSize(fontSize: 12)
        tf.layer.borderWidth = 0.5
        tf.layer.borderColor = UIColor(red: 221.0 / 255.0, green: 221.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0).cgColor
        tf.placeholder = " 请填写手机号码"
        return tf
    }()
    
    private let mobileLabel: UILabel = {
        let label = UILabel()
        label.text = "电话"
        label.font = UIFont(name: "PingFangSC-Regular", size: 14.0)
        label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        return label
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.text = "收货人"
        label.font = UIFont(name: "PingFangSC-Regular", size: 14.0)
        label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        return label
    }()
    
    private let addressTF: UITextField = {
        let tf = UITextField()
        tf.layer.borderWidth = 0.5
        tf.font = systemFontSize(fontSize: 12)
        tf.layer.borderColor = UIColor(red: 221.0 / 255.0, green: 221.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0).cgColor
        tf.placeholder = " 请输入详细地址"
        return tf
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.text = "详细地址"
        label.font = UIFont(name: "PingFangSC-Regular", size: 14.0)
        label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        return label
    }()
    
    private let button = DarkKeyButton(title: "确认")
    
    private let provinceLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 13)
        label.textColor = UIColor(red: 139.0 / 255.0, green: 139.0 / 255.0, blue: 141.0 / 255.0, alpha: 1.0)
        label.layer.borderColor = UIColor(red: 221.0 / 255.0, green: 221.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0).cgColor
        label.layer.borderWidth = 0.5
        label.textAlignment = .center
        return label
    }()
    
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 13)
        label.textColor = UIColor(red: 139.0 / 255.0, green: 139.0 / 255.0, blue: 141.0 / 255.0, alpha: 1.0)
        label.layer.borderColor = UIColor(red: 221.0 / 255.0, green: 221.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0).cgColor
        label.layer.borderWidth = 0.5
        label.textAlignment = .center
        return label
    }()
    
    private let countryLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 13)
        label.textColor = UIColor(red: 139.0 / 255.0, green: 139.0 / 255.0, blue: 141.0 / 255.0, alpha: 1.0)
        label.layer.borderColor = UIColor(red: 221.0 / 255.0, green: 221.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0).cgColor
        label.layer.borderWidth = 0.5
        label.textAlignment = .center
        return label
    }()
    
    private let doutIcon_1: UIImageView = {
        let icon = UIImageView()
        icon.image = imageNamed("Addressdrop-down")
        icon.contentMode = UIView.ContentMode.scaleAspectFill
        return icon
    }()
    
    private let doutIcon_2: UIImageView = {
        let icon = UIImageView()
        icon.image = imageNamed("Addressdrop-down")
        icon.contentMode = UIView.ContentMode.scaleAspectFill
        return icon
    }()
    
    private let doutIcon_3: UIImageView = {
        let icon = UIImageView()
        icon.image = imageNamed("Addressdrop-down")
        icon.contentMode = UIView.ContentMode.scaleAspectFill
        return icon
    }()
}
