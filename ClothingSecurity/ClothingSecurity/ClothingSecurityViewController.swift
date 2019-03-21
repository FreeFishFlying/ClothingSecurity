//
//  ClothingSecurityViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/10.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import S2iCodeModule
class ClothingSecurityViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "防伪检测"
        configUI()
    }
    
    private func configUI() {
        view.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide).offset(94)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(240)
        }
        icon.image = imageNamed("schematic")
        view.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(icon.snp.bottom).offset(20)
        }
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.top.equalTo(tipLabel.snp.bottom).offset(ScreenWidth > 320 ? 36 : 16)
            make.height.equalTo(44)
            make.left.equalToSuperview().offset(48)
            make.right.equalToSuperview().offset(-48)
        }
        button.addTarget(self, action: #selector(scanning), for: .touchUpInside)
    }
    
    private let icon: UIImageView = {
        let icon = UIImageView()
        return icon
    }()
    
    private let tipLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 15)
        label.textColor = UIColor(red: 102.0 / 255.0, green: 102.0 / 255.0, blue: 102.0 / 255.0, alpha: 1.0)
        label.text = "点击开始检测，并对准条形码进行扫描"
        return label
    }()
    
    private let button: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
        btn.setImage(imageNamed("scan"), for: .normal)
        btn.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 17.0) ?? systemFontSize(fontSize: 17)
        btn.setTitle("  开始检测", for: .normal)
        btn.setTitleColor(UIColor(red: 255.0 / 255.0, green: 239.0 / 255.0, blue: 4.0 / 255.0, alpha: 1.0), for: .normal)
        btn.layer.cornerRadius = 22
        btn.layer.masksToBounds = true
        return btn
    }()
    
    @objc private func scanning() {
        if let tabController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
            tabController.tabBar.isHidden = true
            tabController.navigationController?.isNavigationBarHidden = true
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
        S2iCodeModule.shared()?.start(within: nil, uiNavigationController: currentNavigationController())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tabController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
            tabController.tabBar.isHidden = false
            tabController.navigationController?.isNavigationBarHidden = false
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
}
