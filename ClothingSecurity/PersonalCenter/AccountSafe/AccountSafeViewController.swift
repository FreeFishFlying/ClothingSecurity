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
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        title = "账户安全"
        configTableView()
        configTableViewCell()
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
                row.onCellSelection({ [weak self] (_, _) in
                    guard let `self` = self else { return }
                    self.uploadImage()
                })
                row.cell.height = { 67 }
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< SafeAccountCellRow { row in
                row.cell.title = "昵称"
                row.cell.showIcon = false
                row.onCellSelection({ [weak self] (_, _) in
                    guard let `self` = self else { return }
                    let controller = ChangeUserNameViewController()
                    self.navigationController?.pushViewController(controller, animated: true)
                })
                row.cell.height = { 67 }
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< SafeAccountCellRow { row in
                row.cell.title = "绑定手机号"
                row.cell.showIcon = false
                row.onCellSelection({ [weak self] (_, _) in
                    guard let `self` = self else { return }
                    let controller = ChangeMobileViewController()
                    self.navigationController?.pushViewController(controller, animated: true)
                })
                row.cell.height = { 67 }
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< SafeAccountCellRow { row in
                row.cell.title = "修改密码"
                row.cell.showIcon = false
                row.onCellSelection({ (_, _) in
                })
                row.cell.height = { 67 }
        }
    }
    
    private func uploadImage() {
        AppAuthorizationUtil.checkPhoto({ () in
            PopoverImagePicker.choosePhoto(actionSheetActions: [], navigationControllerClass: ThemeNavigationController.self) { image -> Void in
                if let image = image {
                    if let data = image.pngData(){
                        LoginAndRegisterFacade.shared.uploadHeaderImage(value: data).observe({ [weak self] result in
                            guard let `self` = self else { return }
                            guard let value = result.value else { return }
                            guard let model = value.imageModel else { return }
                            print("url = \(model.url)")
                        })
                    }
                }
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }

}
