//
//  ClothesPopularImageCell.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/6.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit

class ClothesPopularImageCell: UITableViewCell {
    var model: ClothesPopularImageModel?
    var onCollectClick: ((ClothesPopularImageModel) -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        addSubview(imageContentView)
        imageContentView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo((ScreenWidth - 30) / 16 * 9)
        }
        addSubview(collectButton)
        collectButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(snp.bottom).offset(-20)
            make.width.greaterThanOrEqualTo(60)
        }
        collectButton.addTarget(self, action: #selector(onClick), for: .touchUpInside)
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(17)
            make.centerY.equalTo(collectButton)
            make.right.lessThanOrEqualTo(collectButton.snp.left).offset(-10)
        }
    }
    
    @objc private func onClick() {
        if let model = model {
            onCollectClick?(model)
        }
    }
    
    func render(_ model: ClothesPopularImageModel) {
        self.model = model
        collectButton.setTitle(" \(model.collectCount)", for: .normal)
        if model.isCollect {
            collectButton.setImage(imageNamed("ic_collected"), for: .normal)
        } else {
            collectButton.setImage(imageNamed("ic_uncollect"), for: .normal)
        }
        nameLabel.text = model.title
        if let url = URL(string: model.url) {
            imageContentView.kf.setImage(with: url, placeholder: imageNamed("perch_match_inside"))
        } else {
            imageContentView.image = imageNamed("perch_match_inside")
        }
    }
    
    private let imageContentView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PingFangSC-Semibold", size: 15.0)
        label.textColor = UIColor(hexString: "#333333")
        return label
    }()
    
    private let collectButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.textColor = UIColor.red
        button.setTitleColor(UIColor(hexString: "#9e9e9e"), for: .normal)
        button.titleLabel?.font = systemFontSize(fontSize: 12)
        button.hitTestEdgeInsets = UIEdgeInsets(top: -5, left: -10, bottom: -5, right: -10)
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
        return button
    }()
}
