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
import HUD

class ChangeMobileViewController: GroupedFormViewController {
    var isEnable: Bool = true
    var buttonTitle: String = "获取验证码"
    var countDown: Int = 60
    var countdownTimer: TimerProxy?
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
                row.tag = "phoneCell"
                row.cell.placeHolder = "请输入新手机号"
                row.cell.height =  { 67 }
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< NormalSafeAccounbtVerifyCellRow { row in
                row.cell.title = "验证码"
                row.tag = "codeCell"
                row.cell.buttonTitle = "获取验证码"
                row.cell.placeHolder = "请输入手机验证码"
                row.cell.height = { 67 }
                row.cellUpdate({ [weak self] cell, _ in
                    guard let `self` = self else { return }
                    cell.buttonTitle = self.buttonTitle
                    cell.buttonEnable = self.isEnable
                })
                row.cell.onVerify = { [weak self] in
                    guard let `self` = self else { return }
                    self.getCode()
                }
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
    
    private func getCode() {
        guard let mobileRow: NormalSafeAccountCellRow = form.rowBy(tag: "phoneCell") as? NormalSafeAccountCellRow else { return }
        if let text = mobileRow.cell.content, !text.isEmpty {
            LoginAndRegisterFacade.shared.requetAuthcode(mobile: text).startWithResult { [weak self] result in
                guard let `self` = self else { return }
                guard let value = result.value else { return }
                if value.isSuccess() {
                    HUD.tip(text: "验证码已发出，请注意查收")
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
        if let row: NormalSafeAccounbtVerifyCellRow = form.rowBy(tag: "codeCell") as? NormalSafeAccounbtVerifyCellRow {
            row.updateCell()
        }
    }
    
    @objc private func change() {
        guard let phoneRow:  NormalSafeAccountCellRow = form.rowBy(tag: "phoneCell") as? NormalSafeAccountCellRow else { return }
        guard let codeRow: NormalSafeAccounbtVerifyCellRow = form.rowBy(tag: "codeCell") as? NormalSafeAccounbtVerifyCellRow else { return }
        if let phone = phoneRow.cell.content, let code = codeRow.cell.code, !phone.isEmpty && !code.isEmpty {
            HUD.show(.progress)
            PersonCenterFacade.shared.changeMobile(mobile: phone, code: code).startWithResult { [weak self] result in
                HUD.hide()
                guard let `self` = self else { return }
                guard let value = result.value else { return }
                if value.isSuccess() {
                    self.navigationController?.popToRootViewController(animated: true)
                } else {
                    if let message = value.tipMesage() {
                        HUD.flashError(title: message)
                    }
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
