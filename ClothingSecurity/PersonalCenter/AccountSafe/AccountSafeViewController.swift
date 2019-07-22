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
    var isNotification: Bool = false
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
            make.height.equalTo(390)
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
    
    func isUserNotificationEnable() -> Bool {
        // 判断用户是否允许接收通知
        var isEnable = false
        if Float(UIDevice.current.systemVersion) ?? 0.0 >= 8.0 {
            // iOS版本 >=8.0 处理逻辑
            let setting: UIUserNotificationSettings? = UIApplication.shared.currentUserNotificationSettings
            isEnable = (nil == setting?.types) ? false : true
        } else {
            // iOS版本 <8.0 处理逻辑
            let type: UIRemoteNotificationType = UIApplication.shared.enabledRemoteNotificationTypes()
            isEnable = (0 == Int(type.rawValue)) ? false : true
        }
        return isEnable
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
                row.cell.showNext = true
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
                row.cell.showNext = true
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
                row.cell.showNext = true
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
                    row.cell.showNext = true
                    row.onCellSelection({ [weak self] (_, _) in
                        guard let `self` = self else { return }
                        let controller = ChangePasswordViewController()
                        self.navigationController?.pushViewController(controller, animated: true)
                    })
                    row.cell.height = { 67 }
            }
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< SafeAccountCellRow { row in
                row.cell.title = "填写地址"
                row.cell.showIcon = false
                row.cell.showNext = true
                row.onCellSelection({ [weak self] (_, _) in
                    let controller = MyAddressListViewController()
                    self?.navigationController?.pushViewController(controller, animated: true)
                })
                row.cell.height = { 67 }
        }

        form +++ fixHeightHeaderSection(height: 0)
            <<< SafeAccountCellRow { row in
                row.cell.title = "语言"
                row.cell.showIcon = false
                row.cell.showNext = true
                row.cell.content = currentLanguage()
                row.onCellSelection({ [weak self] (_, _) in
                    guard let `self` = self else { return }
                    let controller = ChangeUserNameViewController(nickName: self.userItem?.nickName)
                    self.navigationController?.pushViewController(controller, animated: true)
                })
                row.cell.height = { 67 }
                row.cellUpdate({ [weak self] cell, _ in
                    cell.content = self?.currentLanguage()
                })
        }
//        form +++ fixHeightHeaderSection(height: 0)
//            <<< SafeAccountCellRow { row in
//                row.cell.title = "检查更新"
//                row.cell.showIcon = false
//                row.cell.showNext = true
//                row.onCellSelection({ [weak self] (_, _) in
//                    
//                })
//                row.cell.height = { 67 }
//        }
//        form +++ fixHeightHeaderSection(height: 0)
//            <<< SafeAccountCellRow { row in
//                row.cell.title = "是否接收推送消息"
//                row.cell.showIcon = false
//                row.cell.showNext = false
//                row.cell.onSwitchValueChanged = { [weak self] in
//
//                }
//                row.cellUpdate({ [weak self] (cell, _) in
//                    cell.open = self?.isUserNotificationEnable()
//                })
//        }
    }

    private func currentLanguage() -> String {
        return "中文"
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
    
    private let button: DarkKeyButton = DarkKeyButton(title: "退出当前账号")
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }

}
