//
//  BrandIntroductionCell.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/1.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit

class BrandIntroductionCell: UITableViewCell {
    var onMore: (() -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        addSubview(button)
        button.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(30)
            make.height.equalTo(30)
        }
        addSubview(backView)
        backView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(button.snp.bottom).offset(5)
            make.right.equalToSuperview().offset(-114)
            make.bottom.equalToSuperview().offset(-25)
            make.height.equalTo(100)
        }
        addSubview(logo)
        logo.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(61)
            make.width.equalTo(67)
            make.centerY.equalTo(backView.snp.centerY).offset(-10)
        }
        addSubview(moreButton)
        moreButton.snp.makeConstraints { make in
            make.centerX.equalTo(logo.snp.centerX)
            make.top.equalTo(logo.snp.bottom).offset(15)
            make.height.equalTo(20)
            make.width.equalTo(70)
        }
        backView.addSubview(brandLabel)
        brandLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(20)
        }
        backView.addSubview(explainLabel)
        explainLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(brandLabel.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-4)
        }
        backView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(explainLabel.snp.bottom).offset(8)
            make.right.equalToSuperview().offset(-4)
            make.bottom.equalToSuperview().offset(-18)
        }
        layoutIfNeeded()
        moreButton.addTarget(self, action: #selector(more), for: .touchUpInside)
        button.addTarget(self, action: #selector(more), for: .touchUpInside)
    }
    
    @objc private func more() {
        onMore?()
    }
    
    func render(_ model: BrandIntroductionModel) {
        brandLabel.text = model.title
        explainLabel.text = model.explain
        contentLabel.text = model.content
        backView.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(button.snp.bottom).offset(5)
            make.right.equalToSuperview().offset(-114)
            make.bottom.equalToSuperview().offset(-25)
            make.height.equalTo(model.contentViewHeight)
        }
        backView.layoutIfNeeded()
        layoutIfNeeded()
    }
    
    private let button: HeaderCellButton = HeaderCellButton("品牌介绍")
    
    private let backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "#f7f7f7")
        return view
    }()
    
    private let logo: UIImageView = {
        let logo = UIImageView()
        logo.image = imageNamed("ic_brand_logo")
        return logo
    }()
    
    private let moreButton: DarkKeyButton = {
        let button = DarkKeyButton(title: "了解更多")
        button.titleLabel?.font = systemFontSize(fontSize: 11)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        return button
    }()
    
    private let brandLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PingFangSC-Medium", size: 15.0)
        label.textColor = UIColor(hexString: "#000000")
        return label
    }()
    
    private let explainLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 12)
        label.textColor = UIColor(hexString: "#666666")
        label.numberOfLines = 0
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 12)
        label.textColor = UIColor(hexString: "#333333")
        label.numberOfLines = 0
        return label
    }()
}
