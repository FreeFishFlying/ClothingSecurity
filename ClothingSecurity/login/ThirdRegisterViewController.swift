//
//  ThirdRegisterViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/28.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation

class ThirdRegisterViewController: RegisterViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.setTitle("完成", for: .normal)
    }
    
    override func complete(_ user: UserItem?) {
        if let user = user {
            LoginState.shared.hasLogin = true
            UserItem.save(user)
            LoginAndRegisterFacade.shared.userChangePip.input.send(value: user)
        }
        self.dismiss(animated: true, completion: nil)
    }
}
