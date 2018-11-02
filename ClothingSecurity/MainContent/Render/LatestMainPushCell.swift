//
//  LatestMainPushCell.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/1.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit

class LatestMainPushCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
            make.top.equalTo(button.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
    }
    
    func render(_ model: LatestMainPushModel) {
        backView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        if let models = model.models {
            for (index, good) in models.enumerated() {
                let imageView = UIImageView()
                backView.addSubview(imageView)
                imageView.snp.makeConstraints { make in
                    make.left.equalToSuperview().offset((model.imageSize + 10) * (index % 2))
                    make.top.equalToSuperview().offset(index >= 2 ? (model.imageSize + 10) : 0)
                    make.width.height.equalTo(model.imageSize)
                }
                if let url = URL(string: good.thumb) {
                    imageView.kf.setImage(with: url, placeholder: imageNamed("perch_product"))
                } else {
                    imageView.image = imageNamed("perch_product")
                }
                imageView.isUserInteractionEnabled = true
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                let tap = UITapGestureRecognizer(target: self, action: #selector(tapImageView(_:)))
                imageView.tag = index
                imageView.addGestureRecognizer(tap)
            }
        }
    }
    
    @objc private func tapImageView(_ sender: UITapGestureRecognizer) {
        
    }
    
    private let button: HeaderCellButton = HeaderCellButton("最新主推")
    
    private let backView: UIView = {
        let view = UIView()
        return view
    }()
}
