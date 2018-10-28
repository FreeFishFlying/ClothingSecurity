//
//  PersonalCenterViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/10.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Core
import Eureka

class PersonalCenterViewController: GroupedFormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        automaticallyAdjustsScrollViewInsets = false
        extendedLayoutIncludesOpaqueBars = true
        configHeader()
        configTableView()
        configTabViewCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: false)
    }
    
    private func configTableView() {
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.separatorColor = .clear
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.snp.remakeConstraints { make in
            make.top.equalTo(header.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    private func configHeader() {
        view.addSubview(header)
        header.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(120)
        }
        header.title = "登录/注册"
        header.onLoginClick = { [weak self] in
            guard let `self` = self else { return }
            let controller = LoginViewController()
            controller.hidesBottomBarWhenPushed = true
            controller.fd_interactivePopDisabled = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    private func configTabViewCell() {
        form +++ fixHeightHeaderSection(height: 0)
            <<< PersonalCenterCellRow { row in
                row.cell.title = "我的收藏"
                row.cell.imageName = "ic_myFavourite"
                row.onCellSelection({ (_, _) in
                })
                row.cell.height = { 67 }
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< PersonalCenterCellRow { row in
                row.cell.title = "账号安全"
                row.cell.imageName = "ic_accountSafe"
                row.onCellSelection({ [weak self] (_, _) in
                    guard let `self` = self else { return }
                    let controller = AccountSafeViewController()
                    controller.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(controller, animated: true)
                })
                row.cell.height = { 67 }
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< PersonalCenterCellRow { row in
                row.cell.title = "关于我们"
                row.cell.imageName = "ic_aboutMe"
                row.onCellSelection({ (_, _) in
                })
                row.cell.height = { 67 }
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< PersonalCenterCellRow { row in
                row.cell.title = "设置"
                row.cell.imageName = "ic_set"
                row.onCellSelection({ (_, _) in
                })
                row.cell.height = { 67 }
        }
        
    }
    
    private let header: LoginHeaderView = LoginHeaderView()
        
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}

fileprivate class LoginHeaderView: UIView {
    
    var onLoginClick: (() -> Void)?
    
    var item: (url: String, name: String, account: String)? {
        didSet {
            if let item = item {
                title = item.name
                accountLabel.text = item.account
                nameLabel.snp.remakeConstraints { make in
                    make.left.equalTo(icon.snp.right).offset(12)
                    make.bottom.equalTo(icon.snp.centerY)
                }
            }
        }
    }
    
    var title: String? {
        didSet {
            if let title = title {
                let attributedString = NSMutableAttributedString(string: title)
                attributedString.addAttributes([
                    NSAttributedString.Key.font: UIFont(name: "PingFangSC-Semibold", size: 25.0)!,
                    NSAttributedString.Key.foregroundColor:UIColor(red: 66.0 / 255.0, green: 66.0 / 255.0, blue: 66.0 / 255.0, alpha: 1.0)
                    ], range: NSRange(location: 0, length: title.length))
                nameLabel.attributedText = attributedString
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.width.height.equalTo(62)
        }
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(12)
            make.centerY.equalTo(icon.snp.centerY)
        }
        addSubview(accountLabel)
        accountLabel.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(12)
            make.top.equalTo(nameLabel.snp.bottom).offset(7)
        }
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(loginClick))
        nameLabel.addGestureRecognizer(tap)
    }
    
    @objc func loginClick() {
        onLoginClick?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let icon: UIImageView = {
        let icon = UIImageView()
        icon.layer.cornerRadius = 31
        icon.layer.masksToBounds = true
        icon.image = imageNamed("photo")
        return icon
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let accountLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 13)
        label.textColor = UIColor(red: 165.0 / 255.0, green: 165.0 / 255.0, blue: 165.0 / 255.0, alpha: 1.0)
        return label
    }()
}
