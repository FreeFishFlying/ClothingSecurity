//
//  DetailRichGoodCell.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/4.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit

class DetailRichGoodCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let container: UIView = {
        let view = UIView()
        return view
    }()
    
    func render(_ model: DetailRichGoodModel) {
        container.subviews.forEach { view in
            view.removeFromSuperview()
        }
        var contentOffset: CGFloat = 0
        if let urls = model.imageUrls {
            for (index, url) in urls.enumerated() {
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                let size = model.sizeList[index]
                container.addSubview(imageView)
                imageView.snp.makeConstraints { make in
                    make.top.equalTo(contentOffset)
                    make.left.right.equalToSuperview()
                    make.height.equalTo(size.height)
                }
                if let url = URL(string: url) {
                    imageView.kf.setImage(with: url, placeholder: imageNamed("perch_product"))
                } else {
                    imageView.image = imageNamed("perch_product")
                }
                contentOffset += size.height
                contentOffset += 10
            }
        }
        
    }
}
