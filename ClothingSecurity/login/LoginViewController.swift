//
//  LoginViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/9.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import ZCycleView
import SnapKit
import Core
import FDFullscreenPopGesture
import Eureka

let headerHeight: CGFloat = 223

class LoginViewController: GroupedFormViewController {
    var safeBottom: CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        autoHideKeyboard = true
        if #available(iOS 11.0, *) {
            safeBottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        }
        view.backgroundColor = UIColor(hexString: "#EBEBEB")
        fd_prefersNavigationBarHidden = true
        fd_interactivePopDisabled = true
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
        configHeaderView()
        configTableView()
        configFooter()
        configTableViewCell()
        configAnother()
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
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.separatorColor = .clear
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 56
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
    }
    
    private func configHeaderView() {
        headerView.onBackButtonClick = { [weak self] in
            guard let `self` = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(headerHeight)
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
        helpView.onForgetButtonClick = {
        }
        helpView.onRegisterButtonClick = { [weak self] in
            guard let `self` = self else { return }
            let controller = RegisterViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc func login() {
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    private let headerView: HeaderView = HeaderView()
    
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
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.black
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 18.0)
        button.setTitle("登录", for: .normal)
        button.setTitleColor(UIColor(red: 255.0 / 255.0, green: 239.0 / 255.0, blue: 4.0 / 255.0, alpha: 1.0), for: .normal)
        return button
    }()
    
    private let helpView: LoginHelpView = LoginHelpView()
}
