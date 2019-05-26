//
//  HideBarViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/12/3.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
class HideBarViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame = CGRect.zero
        view.backgroundColor = UIColor.white
        navigationController?.navigationBar.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: false)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
