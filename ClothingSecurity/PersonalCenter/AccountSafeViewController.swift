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
                row.onCellSelection({ (_, _) in
                })
                row.cell.height = { 67 }
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< SafeAccountCellRow { row in
                row.cell.title = "昵称"
                row.onCellSelection({ (_, _) in
                })
                row.cell.height = { 67 }
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< SafeAccountCellRow { row in
                row.cell.title = "绑定手机号"
                row.onCellSelection({ (_, _) in
                })
                row.cell.height = { 67 }
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< SafeAccountCellRow { row in
                row.cell.title = "修改密码"
                row.onCellSelection({ (_, _) in
                })
                row.cell.height = { 67 }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }

}
