//
//  ClothingSecurityViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/10.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
class ClothingSecurityViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(whiteTitle: "扫描", target: self, action: #selector(scanning))
    }
    
    @objc private func scanning() {
        let controller = ScanningViewController()
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
}
