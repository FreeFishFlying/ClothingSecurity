//
//  RegisterViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/25.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Core
import Eureka
class RegisterViewController: GroupedFormViewController {
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
        configTableViewCell()
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
    
    private func configTableView() {
        tableView.snp.remakeConstraints { make in
            var value: CGFloat = 20.0
            if ScreenWidth == 320 {
                value = 10.0
            }
            make.top.equalTo(headerView.snp.bottom).offset(value)
            make.left.right.equalToSuperview()
            make.height.equalTo(224)
        }
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.separatorColor = .clear
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 56
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
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
                row.cell.imageName = "icon_sectury"
                row.cell.placeHolder = "请输入验证码"
                row.tag = "secturyCell"
                row.cell.height = { 56 }
                row.onCellSelection({ (_, _) in
                })
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< TextfieldInputCellRow { row in
                row.cell.imageName = "icon_nickname"
                row.cell.placeHolder = "请输入昵称"
                row.tag = "nicknameCell"
                row.cell.height = { 56 }
                row.onCellSelection({ (_, _) in
                })
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< TextfieldInputCellRow { row in
                row.cell.imageName = "icon_password"
                row.cell.placeHolder = "请输入密码"
                row.cell.sectury = true
                row.tag = "passwordCell"
                row.cell.height = { 56 }
                row.onCellSelection({ (_, _) in
                })
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< TextfieldInputCellRow { row in
                row.cell.imageName = "icon_password"
                row.cell.placeHolder = "请确认输入密码"
                row.cell.sectury = true
                row.tag = "passwordAgainCell"
                row.cell.height = { 56 }
                row.onCellSelection({ (_, _) in
                })
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    private let headerView: HeaderView = HeaderView()
}
