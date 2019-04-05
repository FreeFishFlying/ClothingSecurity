//
//  PopularWeasrCell.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/1.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import Mesh

class PopularWearCell: UITableViewCell {
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
        button.addTarget(self, action: #selector(onMoreClick), for: .touchUpInside)
        addSubview(imageContentView)
        imageContentView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(209)
            make.width.equalTo(345)
            make.top.equalTo(button.snp.bottom).offset(5)
        }
        addSubview(explainLabel)
        explainLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(imageContentView.snp.bottom).offset(4)
        }
    }
    
    @objc func onMoreClick() {
        onMore?()
    }
    
    func render(_ model: PopularWearModel) {
        explainLabel.text = model.title
        if let url = model.url {
            imageContentView.kf.setImage(with: url, placeholder: nil)
        }
        imageContentView.snp.updateConstraints { make in
            make.width.equalTo(model.imageViewWidth)
            make.height.equalTo(model.imageViewHeight)
        }
    }
    
    private let button: HeaderCellButton = HeaderCellButton("视频展示")
    
    private let imageContentView: UIImageView = {
        let imageView =  UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let explainLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 15)
        label.textColor = UIColor(hexString: "#333333")
        return label
    }()
}
