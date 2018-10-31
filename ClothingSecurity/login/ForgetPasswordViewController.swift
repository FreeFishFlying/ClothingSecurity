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
import HUD

class ForgetPasswordViewController: BaseLoginViewController {
    var isEnable: Bool = true
    var buttonTitle: String = "获取验证码"
    var countDown: Int = 60
    var countdownTimer: TimerProxy?
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
                row.cell.placeHolder = "请输入手机号"
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
                row.cellUpdate({ [weak self] (cell, _) in
                    guard let `self` = self else { return }
                    cell.title = self.buttonTitle
                    cell.buttonEnable = self.isEnable
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
        guard let mobileRow: TextfieldInputCellRow = form.rowBy(tag: "phoneCell") as? TextfieldInputCellRow else { return }
        if let text = mobileRow.cell.textFieldText, !text.isEmpty {
            LoginAndRegisterFacade.shared.requetAuthcode(mobile: text).startWithResult { [weak self] result in
                guard let `self` = self else { return }
                guard let value = result.value else { return }
                HUD.flashSuccess(title: "验证码已发出，请注意查收")
                if value.isSuccess() {
                    self.isEnable = false
                    self.countdownTimer = TimerProxy(withInterval: 1.0, repeats: true, timerHandler: { [weak self] in
                        self?.doCountDown()
                    })
                } else {
                    HUD.tip(text: value.tipMesage())
                }
            }
        } else {
            HUD.tip(text: "请输入手机号")
        }
    }
    
    private func doCountDown() {
        countDown -= 1
        buttonTitle = "\(countDown)s"
        if countDown == 0 {
            countdownTimer?.invalidate()
            countdownTimer = nil
            buttonTitle = "获取验证码"
            isEnable = true
            countDown = 60
        }
        if let row: InputRenderCellRow = form.rowBy(tag: "secturyCell") as? InputRenderCellRow {
            row.updateCell()
        }
    }
    
    @objc private func complete() {
        guard let phoneRow: TextfieldInputCellRow = form.rowBy(tag: "phoneCell") as? TextfieldInputCellRow else { return }
        guard let secturyRow: InputRenderCellRow = form.rowBy(tag: "secturyCell") as? InputRenderCellRow else { return }
        guard let pdRow: TextfieldInputCellRow = form.rowBy(tag: "passwordCell") as? TextfieldInputCellRow else { return }
        guard let pdAgainRow: TextfieldInputCellRow = form.rowBy(tag: "passwordAgainCell") as? TextfieldInputCellRow else { return }
        var phoneNumber: String = ""
        if let phone = phoneRow.cell.textFieldText, !phone.isEmpty {
            phoneNumber = phone
        } else {
            HUD.flashError(title: "电话号码不能为空")
            return
        }
        var code: String = ""
        if let secturyCode = secturyRow.cell.code, !secturyCode.isEmpty {
            code = secturyCode
        } else {
            HUD.flashError(title: "请输入验证码")
            return
        }
        var pd: String = ""
        if let password = pdRow.cell.textFieldText, !password.isEmpty {
            pd = password
        } else {
            HUD.flashSuccess(title: "请输入密码")
            return
        }
        var pdAgain: String = ""
        if let passAgain = pdAgainRow.cell.textFieldText, !passAgain.isEmpty {
            pdAgain = passAgain
        } else {
            HUD.flashError(title: "请确认密码")
            return
        }
        if pd != pdAgain {
            HUD.flashError(title: "两次密码输入不一致")
            return
        }
        HUD.show(.progress)
        LoginAndRegisterFacade.shared.forgetPassword(mobile: phoneNumber, code: code, newPassword: pd).startWithResult { [weak self] result in
            HUD.hide()
            guard let value = result.value else { return }
            guard let `self` = self else { return }
            if value.isSuccess() {
                HUD.flashSuccess(title: "密码修改成功")
                self.navigationController?.popViewController(animated: true)
            } else {
                if let message = value.tipMesage() {
                    HUD.flashError(title: message)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 20 }
        return 0.001
    }
    
    private let sureButton: DarkKeyButton = DarkKeyButton(title: "确定")
}
