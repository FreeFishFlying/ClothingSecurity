//
//  AboutAppViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/11.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import Core

class AboutAppViewController: GroupedFormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = localizedString("aboutUs")
        view.backgroundColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1)
        configUI()
        configTB()
        configCell()
    }
    
    private func configUI() {
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(170)
        }
        containerView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(containerView.snp.centerY).offset(-10)
        }
    }
    
    private func configTB() {
        tableView.snp.remakeConstraints { make in
            make.top.equalTo(containerView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(201)
        }
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
    }
    
    private func configCell() {
        form +++ fixHeightHeaderSection(height: 0)
            <<< NormalTableViewCellRow { row in
                row.cell.height = { 67 }
                row.cell.name = localizedString("APPDescription")
                row.onCellSelection({ [weak self] (_, _) in
                    guard let `self` = self else { return }
                    let controller = AppDescriptionViewController()
                    self.navigationController?.pushViewController(controller, animated: true)
                })
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< NormalTableViewCellRow { row in
                row.cell.height = { 67 }
                row.cell.name = localizedString("APPVersion")
                row.cell.subContent = "\(localizedString("Version")) V" + (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< NormalTableViewCellRow { row in
                row.cell.height = { 67 }
                row.cell.name = localizedString("feedback")
                row.onCellSelection({ [weak self] (_, _) in
                    guard let `self` = self else { return }
                    let controller = FeedbackViewController()
                    self.navigationController?.pushViewController(controller, animated: true)
                })
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    private let icon: UIImageView = {
        let icon = UIImageView()
        icon.image = imageNamed("login_logo")
        return icon
    }()
    
    private let versionLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#666666")
        label.text = "版本 V" + (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
        label.font = UIFont(name: "PingFang-SC-Medium", size: 14.0)
        return label
    }()
}
