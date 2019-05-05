//
//  ScanResultViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2019/5/5.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation

class ScanResultViewController: BaseViewController {
    let response: CommodityResponseData
    init(_ response: CommodityResponseData) {
        self.response = response
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "检测结果"
        view.addSubview(inspectView)
        inspectView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(128)
        }
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(inspectView.snp.bottom).offset(35)
        }
    }
    
    private let inspectView: UIImageView = {
        let view = UIImageView()
        view.image = imageNamed("inspect-top")
        view.contentMode = UIView.ContentMode.scaleAspectFill
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        let attributedString = NSMutableAttributedString(string: "货物追踪查询")
        attributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Semibold", size: 17.5)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: 6))
        label.attributedText = attributedString
        return label
    }()
}
