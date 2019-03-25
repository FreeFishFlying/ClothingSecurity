//
//  AccountSafeViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/25.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Core
import Eureka
import Album
import HUD
import PopoverImagePicker
import Mesh
import SwiftyJSON

class AccountSafeViewController: GroupedFormViewController {
    var userItem = UserItem.current()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        title = "账户安全"
        configTableView()
        configTableViewCell()
        LoginAndRegisterFacade.shared.obserUserItemChange().observeValues { [weak self] item in
            self?.userItem = item
            self?.tableView.reloadData()
        }
        tableView.snp.remakeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(270)
        }
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(48)
            make.right.equalToSuperview().offset(-48)
            make.height.equalTo(44)
            make.top.equalTo(tableView.snp.bottom).offset(30)
        }
        button.addTarget(self, action: #selector(loginOut), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func loginOut() {
        UserItem.loginOut()
        PersonCenterFacade.shared.logout()
        navigationController?.popToRootViewController(animated: true)
        
    }
    
    private func configTableView() {
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.separatorColor = .clear
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
    }
    
    private func configTableViewCell() {
        form +++ fixHeightHeaderSection(height: 0)
            <<< SafeAccountCellRow { row in
                row.cell.title = "头像"
                row.cell.showIcon = true
                row.cell.url = userItem?.avatar
                row.onCellSelection({ [weak self] (_, _) in
                    guard let `self` = self else { return }
                    self.uploadImage()
                })
                row.cell.height = { 67 }
                row.cellUpdate({ [weak self] cell, _ in
                    cell.url = self?.userItem?.avatar
                })
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< SafeAccountCellRow { row in
                row.cell.title = "昵称"
                row.cell.showIcon = false
                row.cell.content = userItem?.nickName
                row.onCellSelection({ [weak self] (_, _) in
                    guard let `self` = self else { return }
                    let controller = ChangeUserNameViewController(nickName: self.userItem?.nickName)
                    self.navigationController?.pushViewController(controller, animated: true)
                })
                row.cell.height = { 67 }
                row.cellUpdate({ [weak self] cell, _ in
                    cell.content = self?.userItem?.nickName
                })
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< SafeAccountCellRow { row in
                row.cell.title = "绑定手机号"
                row.cell.showIcon = false
                row.cell.content = userItem?.mobile
                row.onCellSelection({ [weak self] (_, _) in
                    guard let `self` = self else { return }
                    let controller = DetailMobileViewController()
                    self.navigationController?.pushViewController(controller, animated: true)
                })
                row.cell.height = { 67 }
                row.cellUpdate({ [weak self] cell, _ in
                    cell.content = self?.userItem?.mobile
                })
        }
        if let hasPD = userItem?.hasPassword, hasPD {
            form +++ fixHeightHeaderSection(height: 0)
                <<< SafeAccountCellRow { row in
                    row.cell.title = "修改密码"
                    row.cell.showIcon = false
                    row.onCellSelection({ [weak self] (_, _) in
                        guard let `self` = self else { return }
                        let controller = ChangePasswordViewController()
                        self.navigationController?.pushViewController(controller, animated: true)
                    })
                    row.cell.height = { 67 }
            }
        }
    }
    
    private func uploadImage() {
        AppAuthorizationUtil.checkPhoto({ () in
            PopoverImagePicker.choosePhoto(actionSheetActions: [], navigationControllerClass: ThemeNavigationController.self) { image -> Void in
                if let image = image {
                    if let data = image.asJPEGData(0.4) {
                        PersonCenterFacade.shared.uploadHeaderImage(value: data)
                    }
                }
            }
        })
    }
    
    private let button: DarkKeyButton = DarkKeyButton(title: "退出登录")
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }

}
