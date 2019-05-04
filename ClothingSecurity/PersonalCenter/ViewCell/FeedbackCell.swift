//
//  FeedbackCell.swift
//  Labeauty
//
//  Created by 宋昌鹏 on 2019/4/25.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation
import Core
import Eureka

class FeedBackCell: UITableViewCell {
    var onSelectOption: ((FeedBack) -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        configUI()
        
    }
    private func configUI() {
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        addSubview(descLabel)
        descLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right).offset(14)
            make.centerY.equalToSuperview()
        }
        addSubview(button)
        button.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-17)
        }
        button.addTarget(self, action: #selector(chooseOption), for: .touchUpInside)
    }
    
    var feedBack: FeedBack? {
        didSet {
            if let feed = feedBack {
                nameLabel.text = feed.category
                descLabel.text = feed.content
                setButtonStyle(feed.isChoosed)
            }
        }
    }
    
    @objc private func chooseOption() {
        if let feed = feedBack {
            onSelectOption?(feed)
            setButtonStyle(!feed.isChoosed)
        }
    }
    
    private func setButtonStyle(_ choosed: Bool) {
        if choosed {
            button.setImage(imageNamed("hook"), for: .normal)
        } else {
            button.setImage(imageNamed("gender"), for: .normal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PingFang-SC-Medium", size: 14.135)
        label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        return label
    }()
    
    private let descLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 14)
        label.textColor = UIColor(red: 98.0 / 255.0, green: 98.0 / 255.0, blue: 98.0 / 255.0, alpha: 1.0)
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setImage(imageNamed("gender"), for: .normal)
        button.hitTestEdgeInsets = UIEdgeInsets(top: -10, left: -15, bottom: -10, right: -15)
        return button
    }()
}
