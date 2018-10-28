//
//  ChangeUserNameViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/27.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Core
import Eureka

class ChangeUserNameViewController: GroupedFormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "修改昵称"
        view.backgroundColor = UIColor.white
        configTableView()
    }
    
    private func configTableView() {
        tableView.separatorStyle = .none 
        tableView.snp.remakeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(67)
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< NormalSafeAccountCellRow { row in
                row.cell.title = "昵称"
                row.cell.model = .right
                row.cell.height = { 67 }
        }
        view.addSubview(changeButton)
        changeButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(48)
            make.right.equalToSuperview().offset(-48)
            make.top.equalTo(tableView.snp.bottom).offset(50)
            make.height.equalTo(44)
        }
        changeButton.addTarget(self, action: #selector(change), for: .touchUpInside)
    }
    
   @objc private func change() {}
    
    private let changeButton: DarkKeyButton = DarkKeyButton(title: "确定")
}
