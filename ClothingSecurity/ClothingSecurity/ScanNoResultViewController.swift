//
//  ScanResultViewController.swift
//  Labeauty
//
//  Created by 宋昌鹏 on 2019/4/5.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation

class ScanNoResultViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = localizedString("testResult")
        view.addSubview(backView)
        backView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(50)
        }
        view.addSubview(labContent)
        labContent.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(backView.snp.bottom).offset(30)
        }
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.top.equalTo(labContent.snp.bottom).offset(80)
            make.left.equalToSuperview().offset(48)
            make.right.equalToSuperview().offset(-48)
            make.height.equalTo(44)
        }
        button.addTarget(self, action: #selector(backClick), for: .touchUpInside)
    }
    
    @objc private func backClick() {
        navigationController?.popViewController(animated: true)
    }
    
    private let button = DarkKeyButton(title: "返回")
    
    private let backView: UIImageView = {
        let view = UIImageView()
        view.image = imageNamed("notscanned")
        return view
    }()
    
    private let labContent: UILabel = {
        let lab = UILabel()
        lab.font = systemFontSize(fontSize: 14)
        lab.textColor = UIColor(hexString: "a5a5a5")
        lab.textAlignment = .center
        lab.text = "未扫描出该产品信息"
        return lab
    }()
}
