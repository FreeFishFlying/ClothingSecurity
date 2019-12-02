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
//import S2iCodeModule
import AlertController

import Core
import ActionSheet
class ClothingSecurityViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = localizedString("scan")
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
//        label.text = "每个防伪码只能正确查询1次，请消费者注意查询结果\n如有疑问，可在关于我们中提交建议"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let button: UIButton = {
        let btn = UIButton()
        btn.setImage(imageNamed("scan"), for: .normal)
        btn.setBackgroundImage(imageNamed("Loginbutton"), for: .normal)
        btn.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 17.0) ?? systemFontSize(fontSize: 17)
        btn.setTitle(" " + localizedString("scan"), for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.layer.cornerRadius = 22
        btn.layer.masksToBounds = true
        return btn
    }()

    func scicode() {
        S2iCodeModule.shared().initS2iCodeModuleWtihDelegate(self)
        S2iCodeModule.shared().start(within: nil, uiNavigationController: self.navigationController!, showResult: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let controllers = self.navigationController?.viewControllers;
            if let controller = controllers?.last {
                controller.navigationController?.navigationBar.isHidden = true
                controller.navigationController?.setNavigationBarHidden(true, animated: false)
                controller.fd_interactivePopDisabled = true
            }
        }
    }

    func scan() {
        let controller = ScanningViewController()
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func scanning() {

        if LoginState.shared.hasLogin.value {
            if UserItem.current()?.role == "ADMIN" {
                let actionsheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
                actionsheet.addButton(title: localizedString("antiFake")) {
                    DispatchQueue.main.async {
                        self.scicode()
                    }
                }
                actionsheet.addButton(title: localizedString("traceToSource")) {
                    DispatchQueue.main.async {
                        self.scan()
                    }
                }
                actionsheet.addButton(title: localizedString("cancel")) {
                }
                self.present(actionsheet, animated: true, completion: nil)
            } else {
                scicode()
            }
        } else {
            let controller = LoginViewController()
            let nav = UINavigationController(rootViewController: controller)
            navigationController?.present(nav, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}
