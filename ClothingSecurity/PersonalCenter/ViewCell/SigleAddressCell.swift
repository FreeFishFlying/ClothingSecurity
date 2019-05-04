//
//  SigleAddressCell.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2019/5/4.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation

class SigleAddressCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clear
        selectionStyle = .none
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var address: Address? {
        didSet {
            if let address = address {
                tipLabel.isHidden = true
                nameLabel.text = address.name
                mobileLabel.text = address.mobile
                addressLabel.text = address.detailedAddress
            } else {
                tipLabel.isHidden = false
                nameLabel.text = nil
                mobileLabel.text = nil
                addressLabel.text = nil
            }
        }
    }
    
    private func configUI() {
        addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview()
        }
        container.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15)
        }
        container.addSubview(nextIcon)
        nextIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-24)
        }
        container.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(icon.snp.right).offset(15)
        }
        tipLabel.isHidden = true
        container.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(15)
            make.top.equalToSuperview().offset(13)
        }
        container.addSubview(mobileLabel)
        mobileLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right).offset(11)
            make.centerY.equalTo(nameLabel)
        }
        container.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(15)
            make.bottom.equalToSuperview().offset(-15)
        }
    }
    
    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    private let icon: UIImageView = {
        let icon = UIImageView()
        icon.image = imageNamed("addIcon")
        return icon
    }()
    
    private let nextIcon: UIImageView = {
        return UIImageView(image: imageNamed("icon_right"))
    }()
    
    private let tipLabel: UILabel = {
        let label = UILabel()
        let attributedString = NSMutableAttributedString(string: "添加收货信息")
        attributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Regular", size: 14.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: 6))
        label.attributedText = attributedString
        return label
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
}
