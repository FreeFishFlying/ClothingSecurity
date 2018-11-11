//
//  AboutAppViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/11.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit

class AboutAppViewController: GroupedFormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "关于我们"
        view.backgroundColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1)
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    private let icon: UIImageView = {
        let icon = UIImageView()
        return icon
    }()
    
    private let versionLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#666666")
        //UIDevice.current.systemVersion
        return label
    }()
}
