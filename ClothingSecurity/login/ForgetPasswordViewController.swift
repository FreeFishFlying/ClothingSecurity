//
//  ForgetPasswordViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/27.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import Core
import Eureka
class ForgetPasswordViewController: BaseLoginViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        headerTitle = "忘记密码"
        configTableView()
        configTableViewCell()
        configButton()
    }
    
    private func configTableView() {
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
            make.height.equalTo(244)
        }
    }
    
    private func configTableViewCell() {
        form +++ fixHeightHeaderSection(height: 0)
            <<< TextfieldInputCellRow { row in
                row.cell.imageName = "icon_phone"
                row.cell.placeHolder = "请输入昵称"
                row.tag = "phoneCell"
                row.cell.height = { 56 }
                row.cell.sectury = false
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< InputRenderCellRow { row in
                row.cell.imageName = "icon_sectury"
                row.cell.placeHolder = "请输入验证码"
                row.cell.title = "获取验证码"
                row.tag = "secturyCell"
                row.cell.height = { 56 }
                row.cellUpdate({ (_, _) in
                })
                row.cell.onGetCode = { [weak self] in
                    guard let `self` = self else { return }
                    self.getCode()
                }
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< TextfieldInputCellRow { row in
                row.cell.imageName = "icon_password"
                row.cell.placeHolder = "请设置新密码"
                row.tag = "passwordCell"
                row.cell.height = { 56 }
                row.cell.sectury = true
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< TextfieldInputCellRow { row in
                row.cell.imageName = "icon_password"
                row.cell.placeHolder = "请再次输入新密码"
                row.tag = "passwordAgainCell"
                row.cell.height = { 56 }
                row.cell.sectury = true
        }
    }
    
    private func configButton() {
        view.addSubview(sureButton)
        sureButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(48)
            make.right.equalToSuperview().offset(-48)
            make.height.equalTo(44)
            var value = 96
            if ScreenWidth == 320 {
                value = 40
            }
            make.top.equalTo(tableView.snp.bottom).offset(value)
        }
        sureButton.addTarget(self, action: #selector(complete), for: .touchUpInside)
    }
    
    @objc private func getCode() {
        
    }
    
    @objc private func complete() {
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 20 }
        return 0.001
    }
    
    private let sureButton: DarkKeyButton = DarkKeyButton(title: "确定")
}
