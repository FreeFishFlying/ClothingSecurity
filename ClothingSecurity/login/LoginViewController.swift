//
//  LoginViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/9.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Core
import FDFullscreenPopGesture
import Eureka
import HUD

let headerHeight: CGFloat = 223

class LoginViewController: BaseLoginViewController {
   
    override func viewDidLoad() {
        super.viewDidLoad()
        configTableView()
        configFooter()
        configTableViewCell()
        configAnother()
        headerTitle = "登录"
    }
    
    override func back() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func configTableView() {
        tableView.snp.remakeConstraints { make in
            var value: CGFloat = 20.0
            if ScreenWidth == 320 {
                value = 10.0
            }
            make.top.equalTo(headerView.snp.bottom).offset(value)
            make.left.right.equalToSuperview()
            make.height.equalTo(112)
        }
    }
    
    private func configFooter() {
        view.addSubview(thirdView)
        thirdView.snp.makeConstraints { make in
            var value: CGFloat = -30.0
            if ScreenWidth == 320 {
                value = -20.0
            }
            make.bottom.equalToSuperview().offset(value - safeBottom)
            make.height.equalTo(40)
            make.left.right.equalToSuperview()
        }
        view.addSubview(thirdNote)
        thirdNote.snp.makeConstraints { make in
            make.centerX.equalTo(thirdView)
            var value = -30
            if ScreenWidth == 320 {
                value = -20
            }
            make.bottom.equalTo(thirdView.snp.top).offset(value)
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
                row.onCellSelection({ (_, _) in
                })
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< TextfieldInputCellRow { row in
                row.cell.imageName = "icon_password"
                row.cell.placeHolder = "请输入密码"
                row.tag = "passwordCell"
                row.cell.height = { 56 }
                row.cell.sectury = true
                row.onCellSelection({ (_, _) in
                })
        }
    }
    
    private func configAnother() {
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(48)
            make.right.equalToSuperview().offset(-48)
            make.height.equalTo(44)
            make.top.equalTo(tableView.snp.bottom).offset(20)
        }
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        view.addSubview(helpView)
        helpView.snp.makeConstraints { make in
            var value = 30
            if ScreenWidth == 320 {
                value = 20
            }
            make.top.equalTo(loginButton.snp.bottom).offset(value)
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
        }
        helpView.onForgetButtonClick = { [weak self] in
            guard let `self` = self  else { return }
            let controller = ForgetPasswordViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }
        helpView.onRegisterButtonClick = { [weak self] in
            guard let `self` = self else { return }
            let controller = RegisterViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc func login() {
        guard let mobileRow: TextfieldInputCellRow = form.rowBy(tag: "phoneCell") as? TextfieldInputCellRow else { return }
        guard let pdRow: TextfieldInputCellRow = form.rowBy(tag: "passwordCell") as? TextfieldInputCellRow else { return }
        if mobileRow.cell.textFieldText == nil {
            HUD.flashError(title: "手机号不能为空")
            return
        }
        if pdRow.cell.textFieldText == nil {
            HUD.flashError(title: "密码不能为空")
        }
        HUD.show(.progress)
        if let mobile = mobileRow.cell.textFieldText, let pd = pdRow.cell.textFieldText {
            LoginAndRegisterFacade.shared.login(mobile: mobile, password: pd).startWithResult { [weak self] result in
                HUD.hide()
                guard let `self` = self else { return }
                guard let value = result.value else { return }
                if value.isSuccess() {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                } else {
                    if let content = value.tipMesage() {
                        HUD.flashError(title: content)
                    }
                }
            }
        }
        
    }
    
    private let thirdView: ThirdParterView = ThirdParterView()
    
    private let thirdNote: UILabel = {
        let label = UILabel()
        let title = "———— 或从以下方式登录 ————"
         let attributedString = NSMutableAttributedString(string: title)
         attributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Regular", size: 13.035)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 154.0 / 255.0, green: 153.0 / 255.0, blue: 153.0 / 255.0, alpha: 1.0)
         ], range: NSRange(location: 0, length: title.length))
        label.attributedText = attributedString
        return label
    }()
    
    private let loginButton: DarkKeyButton = DarkKeyButton(title: "登录")
    
    private let helpView: LoginHelpView = LoginHelpView()
}
