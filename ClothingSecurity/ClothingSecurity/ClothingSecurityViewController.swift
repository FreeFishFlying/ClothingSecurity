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
            make.top.equalTo(tipLabel.snp.bottom).offset(36)
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
        let scan = ScanningViewController()
        scan.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(scan, animated: true)
//        let hideController = HideBarViewController()
//        hideController.view.frame = CGRect.zero
//        hideController.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(hideController, animated: false)
//        S2iCodeModule.shared()?.start(within: nil, uiNavigationController: navigationController)
//        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.2) {
//            if let childControllers = self.navigationController?.viewControllers {
//                var newChildens = childControllers
//                if let child = newChildens.first(where: {$0.isKind(of: HideBarViewController.self)}) {
//                   newChildens.remove(object: child)
//                   self.navigationController?.viewControllers = newChildens
//                }
//            }
//        }
    }
}
