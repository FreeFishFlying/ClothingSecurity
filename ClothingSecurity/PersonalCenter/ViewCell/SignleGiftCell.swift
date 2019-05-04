//
//  SignalGiftCell.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2019/5/4.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation

class SignleGiftCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clear
        selectionStyle = .none
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        container.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-14)
            make.width.equalTo(107)
            make.height.equalTo(82)
        }
        container.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalTo(icon.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        container.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(10)
            make.top.equalTo(nameLabel.snp.bottom).offset(15)
        }
        container.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(10)
            make.top.equalTo(tipLabel.snp.bottom).offset(3)
        }
    }
    
    var gift: Prize? {
        didSet {
            if let gift = gift {
                nameLabel.text = gift.name
                if let url = URL(string: gift.thumb) {
                    icon.kf.setImage(with: url)
                }
                let start = changeTimeStamp(gift.createTime, false)
                let end = changeTimeStamp(gift.updateTime, false)
                timeLabel.text = start + "-" + end
            }
        }
    }
    
    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.clipsToBounds = true
        return view
    }()
    
    private let icon: UIImageView = {
        let icon = UIImageView()
        icon.layer.cornerRadius = 5
        icon.layer.masksToBounds = true
        icon.contentMode = UIView.ContentMode.scaleAspectFill
        return icon
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        label.font = UIFont(name: "PingFangSC-Regular", size: 12.5)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let tipLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 165.0 / 255.0, green: 165.0 / 255.0, blue: 165.0 / 255.0, alpha: 1.0)
        label.font = systemFontSize(fontSize: 10)
        label.text = "提货期限"
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 165.0 / 255.0, green: 165.0 / 255.0, blue: 165.0 / 255.0, alpha: 1.0)
        label.font = systemFontSize(fontSize: 10)
        return label
    }()
}
