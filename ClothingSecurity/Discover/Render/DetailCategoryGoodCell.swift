//
//  DetailCategoryGoodCell.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/3.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
class DetailCategoryGoodCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        containerView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(1)
            make.bottom.right.equalToSuperview().offset(-1)
        }
    }
    
    var model: Good? {
        didSet {
            if let model = model {
                if let url = URL(string: model.thumb) {
                    imageView.kf.setImage(with: url, placeholder: imageNamed("perch_search"))
                } else {
                    imageView.image = imageNamed("perch_search")
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor(hexString: "#ebebeb").cgColor
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
}
