//
//  IntegralRecordCell.swift
//  Labeauty
//
//  Created by 宋昌鹏 on 2019/4/27.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation

class IntegralRecordCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        addSubview(nameLabel)
        addSubview(timeLabel)
        addSubview(valueLabel)
        addSubview(line)
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(22)
        }
        timeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(22)
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
        }
        valueLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-18)
        }
        line.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    var model: (item: IntegralItem?, type: WalletDirection)? {
        didSet {
            if let model = model, let item = model.item {
                timeLabel.text = changeTimeStamp(item.createTime)
                nameLabel.text = item.remark
                if model.type == .In {
                    valueLabel.text = "+\(item.changed)"
                } else {
                    valueLabel.text = "-\(item.changed)"
                }
            }
        }
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 53.0 / 255.0, green: 53.0 / 255.0, blue: 53.0 / 255.0, alpha: 1.0)
        label.font = systemFontSize(fontSize: 14)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 136.0 / 255.0, green: 136.0 / 255.0, blue: 136.0 / 255.0, alpha: 1.0)
        label.font = systemFontSize(fontSize: 13)
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 176.0 / 255.0, green: 205.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0)
        label.font = systemFontSize(fontSize: 18)
        return label
    }()
    
    private let line: UIView = {
        let style = UIView()
        style.layer.backgroundColor = UIColor(red: 239.0 / 255.0, green: 239.0 / 255.0, blue: 239.0 / 255.0, alpha: 1.0).cgColor
        style.alpha = 1
        return style
    }()
}
