//
//  PersonalCenterViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/10.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
class PersonalCenterViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
        
    
}

fileprivate class LoginHeaderView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.width.height.equalTo(62)
        }
        addSubview(nameLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let icon: UIImageView = {
        let icon = UIImageView()
        icon.layer.cornerRadius = 31
        icon.layer.masksToBounds = true
        icon.image = imageNamed("photo")
        return icon
    }()
    
    private let nameLabel: UILabel = {
       let label = UILabel()
        label.textColor = UIColor.black
        return label
    }()
    
    private let acountLabel: UILabel = {
        let label = UILabel()
        return label
    }()
}
