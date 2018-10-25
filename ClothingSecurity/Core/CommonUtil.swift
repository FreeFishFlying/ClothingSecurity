//
//  CommonUtil.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/11.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Core

extension UIBarButtonItem {
    convenience init(image: UIImage?, higlightedImage: UIImage?, target: Any, action: Selector) {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 48, height: 28)
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -28)
        button.hitTestEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -28)
        button.setImage(higlightedImage, for: .highlighted)
        button.addTarget(target, action: action, for: .touchUpInside)
        self.init(customView: button)
    }
    
    convenience init(whiteTitle: String, target: Any, action: Selector) {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 48, height: 28)
        button.setTitle(whiteTitle, for: .normal)
        button.titleLabel?.font = systemFontSize(fontSize: 15)
        button.setTitleColor(UIColor(red: 50.0 / 255.0, green: 50.0 / 255.0, blue: 52.0 / 255.0, alpha: 1.0), for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        self.init(customView: button)
    }
}

class NormalHeader: UIView {
    
    class func create(title: String) -> NormalHeader {
        let header = NormalHeader(frame:  CGRect(x: 0, y: 0, width: 120, height: 20))
        header.title = title
        return header
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    var title: String? {
        didSet {
            if let title = title {
                if let image = zd_image(with: UIColor.white, size: CGSize(width: 120, height: 20), text: title, textAttributes: [
                    NSAttributedString.Key.font: UIFont(name: "PingFangSC-Semibold", size: 18)!,
                    NSAttributedString.Key.foregroundColor:UIColor(red: 50.0 / 255.0, green: 50.0 / 255.0, blue: 52.0 / 255.0, alpha: 1.0)
                    ], circular: false) {
                    imageView.image = image
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
}
