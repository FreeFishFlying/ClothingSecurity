//
//  CompleteMaterialViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/26.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Core
import Eureka

class CompleteMaterialViewController: BaseLoginViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        headerTitle = "完善信息"
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
    
    @objc func complete() {
        
    }
    
    private func configTableViewCell() {
        form +++ fixHeightHeaderSection(height: 0)
            <<< TextfieldInputCellRow { row in
                row.cell.imageName = "icon_nickname"
                row.cell.placeHolder = "请输入昵称"
                row.tag = "nicknameCell"
                row.cell.height = { 56 }
                row.cell.sectury = false
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< ChooseSexCellRow { row in
                row.cell.sex = HumanSex.man
                row.cell.onSexChoose = { _ in
                }
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< TextfieldInputCellRow { row in
                row.cell.imageName = "icon_sectury"
                row.cell.placeHolder = "请输入密码"
                row.tag = "secturyCell"
                row.cell.height = { 56 }
                row.cell.sectury = true
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< TextfieldInputCellRow { row in
                row.cell.imageName = "icon_sectury"
                row.cell.placeHolder = "请确认密码"
                row.tag = "secturyAgainCell"
                row.cell.height = { 56 }
                row.cell.sectury = true
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 20 }
        return 0.001
    }
    
    private let sureButton: DarkKeyButton = DarkKeyButton(title: "完成")
}
