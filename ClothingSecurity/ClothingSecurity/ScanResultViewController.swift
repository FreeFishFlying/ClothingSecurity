//
//  ScanResultViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/28.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import SnapKit

class ScanResultViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "检测结果"
        configSpaceUI()
    }
    
    private func configSpaceUI() {
        view.addSubview(spaceView)
        spaceView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        spaceView.addSubview(spaceIcon)
        spaceIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-90)
        }
        spaceView.addSubview(spaceLabel)
        spaceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(spaceIcon.snp.bottom).offset(30)
        }
        spaceView.addSubview(button)
        button.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(48)
            make.right.equalToSuperview().offset(-48)
            make.top.equalTo(spaceLabel.snp.bottom).offset(70)
            make.height.equalTo(44)
        }
        button.addTarget(self, action: #selector(clickButtonEvent), for: .touchUpInside)
        //spaceView.isHidden = true
    }
    
    @objc private func clickButtonEvent() {
        navigationController?.popViewController(animated: true)
    }
    
    private let spaceView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let spaceIcon: UIImageView = {
        let icon = UIImageView()
        icon.image = imageNamed("ic_scan_blank")
        return icon
    }()
    
    private let spaceLabel: UILabel = {
        let label = UILabel()
        let attributedString = NSMutableAttributedString(string: "未扫描出该产品信息")
        attributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFang-SC-Regular", size: 14.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 153.0 / 255.0, green: 153.0 / 255.0, blue: 153.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: attributedString.length))
        label.attributedText = attributedString
        return label
    }()
    
    private let button = DarkKeyButton(title: "返回")
}
