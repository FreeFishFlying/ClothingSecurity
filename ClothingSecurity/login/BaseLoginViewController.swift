//
//  BaseLoginViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/26.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Core
import Eureka

class BaseLoginViewController: GroupedFormViewController {
    var safeBottom: CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        autoHideKeyboard = true
        if #available(iOS 11.0, *) {
            safeBottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        }
        view.backgroundColor = UIColor(hexString: "#ffffff")
        fd_prefersNavigationBarHidden = true
        fd_interactivePopDisabled = true
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
        configHeaderView()
        configTableView()
    }
    
    var headerTitle: String? {
        didSet {
            if let title = headerTitle {
                headerView.titleLabel.text = title
            }
        }
    }
    
    func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func configHeaderView() {
        headerView.onBackButtonClick = { [weak self] in
            guard let `self` = self else { return }
            self.back()
        }
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(headerHeight)
        }
    }
    
    private func configTableView() {
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = true
        tableView.separatorColor = .clear
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 56
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.keyboardDismissMode = .onDrag
    }
    
    let headerView: HeaderView = HeaderView()
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}
