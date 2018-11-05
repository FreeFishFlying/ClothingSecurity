//
//  DetailPriceAndCollectCell.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/4.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit

class DetailPriceAndCollectCell: UITableViewCell {
    var onCollectClick: (() -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        addSubview(collectButton)
        collectButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(15)
            make.width.lessThanOrEqualTo(80)
        }
        collectButton.addTarget(self, action: #selector(onClick), for: .touchUpInside)
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(17)
            make.centerY.equalTo(collectButton)
            make.right.equalToSuperview().offset(-100)
        }
        addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
        }
    }
    
    @objc private func onClick() {
        onCollectClick?()
    }
    
    func render(_ model: DetailRichGoodModel) {
        collectButton.setTitle(" \(model.collectCount ?? 0)", for: .normal)
        if let collect = model.isCollect, collect {
            collectButton.setImage(imageNamed("ic_collected"), for: .normal)
        } else {
            collectButton.setImage(imageNamed("ic_uncollect"), for: .normal)
        }
        nameLabel.text = model.title
        priceLabel.text = model.price
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PingFangSC-Semibold", size: 19.0)
        label.textColor = UIColor(hexString: "#333333")
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PingFangSC-Regular", size: 19.0)
        label.textColor = UIColor(hexString: "#ff6203")
        return label
    }()
    
    private let collectButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.textColor = UIColor.red
        button.setTitleColor(UIColor(hexString: "#9e9e9e"), for: .normal)
        button.titleLabel?.font = systemFontSize(fontSize: 12)
        button.hitTestEdgeInsets = UIEdgeInsets(top: -5, left: -10, bottom: -5, right: -10)
        return button
    }()
}
