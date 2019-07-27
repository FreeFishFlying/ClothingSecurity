//
//  DetailMobileViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/31.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
class DetailMobileViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = localizedString("bindPhone")
        view.addSubview(mobileLabel)
        mobileLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(safeAreaTopLayoutGuide).offset(120)
        }
        mobileLabel.text = UserItem.current()?.mobile
        view.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(mobileLabel.snp.bottom).offset(10)
        }
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(48)
            make.right.equalToSuperview().offset(-48)
            make.height.equalTo(44)
            make.top.equalTo(tipLabel.snp.bottom).offset(40)
        
        }
        button.addTarget(self, action: #selector(change), for: .touchUpInside)
    }
    
    @objc func change() {
        let controller = ChangeMobileViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private let mobileLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PingFangSC-Regular", size: 24.0)
        label.textColor = UIColor(red: 43.0 / 255.0, green: 43.0 / 255.0, blue: 43.0 / 255.0, alpha: 1.0)
        label.textAlignment = .center
        return label
    }()
    
    private let tipLabel: UILabel = {
        let label = UILabel()
        label.font =  UIFont(name: "PingFangSC-Thin", size: 13.0)
        label.textColor = UIColor(red: 168.0 / 255.0, green: 168.0 / 255.0, blue: 168.0 / 255.0, alpha: 1.0)
        label.text = localizedString("currentBindNumber")
        label.textAlignment = .center
        return label
    }()
    
    private let button: DarkKeyButton = DarkKeyButton(title: localizedString("changePhone"))
}
