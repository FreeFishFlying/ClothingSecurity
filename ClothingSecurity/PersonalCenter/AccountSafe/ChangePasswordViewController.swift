//
//  ChangePasswordViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/31.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import Core
import Eureka
import HUD
class ChangePasswordViewController: GroupedFormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        title = "修改密码"
        tableView.separatorStyle = .none
        tableView.snp.remakeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(210)
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< NormalSafeAccountCellRow { row in
                row.cell.title = "旧密码"
                row.tag = "oldCell"
                row.cell.placeHolder = "请输入旧密码"
                row.cell.height =  { 67 }
                row.cell.textField.isSecureTextEntry = true
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< NormalSafeAccountCellRow { row in
                row.cell.title = "新密码"
                row.tag = "newCell"
                row.cell.placeHolder = "请输入新密码"
                row.cell.height =  { 67 }
                row.cell.textField.isSecureTextEntry = true
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< NormalSafeAccountCellRow { row in
                row.cell.title = "确认密码"
                row.tag = "newAgainCell"
                row.cell.placeHolder = "请再次输入新密码"
                row.cell.height =  { 67 }
                row.cell.textField.isSecureTextEntry = true
        }
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(48)
            make.right.equalToSuperview().offset(-48)
            make.height.equalTo(44)
            make.top.equalTo(tableView.snp.bottom).offset(40)
        }
        button.addTarget(self, action: #selector(changeMobile), for: .touchUpInside)
    }
    
    @objc func changeMobile() {
        guard let oldRow: NormalSafeAccountCellRow = form.rowBy(tag: "oldCell") as? NormalSafeAccountCellRow else { return }
        guard let newRow: NormalSafeAccountCellRow = form.rowBy(tag: "newCell") as? NormalSafeAccountCellRow else { return }
        guard let newAgainRow: NormalSafeAccountCellRow = form.rowBy(tag: "newAgainCell") as? NormalSafeAccountCellRow else { return }
        var oldPD: String = ""
        var newPD: String = ""
        var newAgainPD: String = ""
        if let old = oldRow.cell.content, !old.isEmpty {
            oldPD = old
        } else {
            HUD.flashError(title: "请输入旧密码")
            return
        }
        if let new = newRow.cell.content, !new.isEmpty {
            newPD = new
        } else {
            HUD.flashError(title: "请输入新密码")
            return
        }
        if let newAgain = newAgainRow.cell.content, !newAgain.isEmpty {
            newAgainPD = newAgain
        } else {
            HUD.flashError(title: "请确认新密码")
            return
        }
        if newPD != newAgainPD {
            HUD.flashError(title: "两次输入的密码不一致")
            return
        }
        HUD.show(.progress)
        PersonCenterFacade.shared.changePassword(old: oldPD, new: newPD).startWithResult { [weak self] result in
            HUD.hide()
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            if value.isSuccess() {
                self.navigationController?.popViewController(animated: true)
            } else {
                if let message = value.tipMesage() {
                    HUD.flashError(title: message)
                }
            }
        }
    }
    
    private let button: DarkKeyButton = DarkKeyButton(title: "确定")
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}
