//
//  ChangeMobileViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/28.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Core
import Eureka

class ChangeMobileViewController: GroupedFormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        title = "更改手机号"
        tableView.separatorStyle = .none
        tableView.snp.remakeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(135)
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< NormalSafeAccountCellRow { row in
                row.cell.title = "新手机号"
                row.cell.placeHolder = "请输入新手机号"
                row.cell.height =  { 67 }
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< NormalSafeAccounbtVerifyCellRow { row in
                row.cell.title = "验证码"
                row.cell.placeHolder = "请输入手机验证码"
                row.cell.height = { 67 }
                row.cell.onVerify = {}
                
        }
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(48)
            make.right.equalToSuperview().offset(-48)
            make.top.equalTo(tableView.snp.bottom).offset(60)
            make.height.equalTo(44)
        }
        button.addTarget(self, action: #selector(change), for: .touchUpInside)
    }
    
    @objc private func change() {
    }
    
    private let button: DarkKeyButton = DarkKeyButton(title: "确定")
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}
