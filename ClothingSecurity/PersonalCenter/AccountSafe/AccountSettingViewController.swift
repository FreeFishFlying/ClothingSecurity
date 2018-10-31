//
//  AccountSettingViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/31.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
class AccountSettingViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.equalToSuperview().offset(48)
            make.right.equalToSuperview().offset(-48)
            make.height.equalTo(44)
        }
        button.addTarget(self, action: #selector(loginOut), for: .touchUpInside)
    }
    
    @objc func loginOut() {
        UserItem.loginOut()
        PersonCenterFacade.shared.logout()
        navigationController?.popToRootViewController(animated: true)
    }
    
    private let button: DarkKeyButton = DarkKeyButton(title: "退出登录")
}
