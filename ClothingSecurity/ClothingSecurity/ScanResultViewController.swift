//
//  ScanResultViewController.swift
//  Labeauty
//
//  Created by 宋昌鹏 on 2019/4/5.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation

class ScanResultViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "检测结果"
    }
    
    private let button = DarkKeyButton(title: "返回")
    
    private let backView: UIImageView = {
        let view = UIImageView()
        view.image = imageNamed("notscanned")
        return view
    }()
    
    private let labContent: UILabel = {
        let lab = UILabel()
        lab.font = systemFontSize(fontSize: 14)
        lab.textColor = UIColor(hexString: "a5a5a5")
        lab.textAlignment = .center
        lab.text = "未扫描出该产品信息"
        return lab
    }()
}
