//
//  NoticitionCell.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2019/5/5.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation

class NotificitionCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = UIColor.clear
        configUI()
    }

    var model: Notification? {
        didSet {
            if let model = model {
                nameLabel.text = model.title
                timeLabel.text = changeTimeStamp(model.createTime)
                contentLabel.text = model.content
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configUI() {
        addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.bottom.right.equalToSuperview()
        }
        container.addSubview(dot)
        dot.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(26)
            make.top.equalToSuperview().offset(22)
            make.width.height.equalTo(12)
        }
        container.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(dot.snp.centerY)
            make.left.equalTo(dot.snp.right).offset(23)
        }
        container.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(dot.snp.centerY)
            make.right.equalToSuperview().offset(-25)
        }
        container.addSubview(line)
        line.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(55)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        container.addSubview(labelContainer)
        labelContainer.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
        labelContainer.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(28)
            make.right.equalToSuperview().offset(-28)
        }

    }

    private let container: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor.white
        return container
    }()

    private let dot: UIImageView = {
        let view = UIImageView()
        view.image = imageNamed("notificationDot")
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        label.font = systemFontSize(fontSize: 15)
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 139.0 / 255.0, green: 139.0 / 255.0, blue: 141.0 / 255.0, alpha: 1.0)
        label.font = systemFontSize(fontSize: 13)
        return label
    }()

    private let line: UIView = {
        let style = UIView()
        style.layer.backgroundColor = UIColor(red: 230.0 / 255.0, green: 230.0 / 255.0, blue: 230.0 / 255.0, alpha: 1.0).cgColor
        style.alpha = 1
        return style
    }()

    private let labelContainer: UIView = {
        let view = UIView()
        return view
    }()

    private let contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        label.font = systemFontSize(fontSize: 14)
        label.numberOfLines = 0
        return label
    }()
}
