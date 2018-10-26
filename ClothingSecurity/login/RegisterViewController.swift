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
class RegisterViewController: BaseLoginViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configTableView()
        configTableViewCell()
        configAgreement()
        configNextButton()
        headerTitle = "注册"
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
    
    private func configTableViewCell() {
        form +++ fixHeightHeaderSection(height: 0)
            <<< TextfieldInputCellRow { row in
                row.cell.imageName = "icon_phone"
                row.cell.placeHolder = "请输入手机号"
                row.tag = "phoneCell"
                row.cell.height = { 56 }
                row.cell.sectury = false
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< InputRenderCellRow { row in
                row.cell.imageName = "icon_sectury"
                row.cell.placeHolder = "请输入验证码"
                row.cell.title = "获取验证码"
                row.tag = "secturyCell"
                row.cell.height = { 56 }
                row.cellUpdate({ (_, _) in
                })
                row.cell.onGetCode = { [weak self] in
                    guard let `self` = self else { return }
                    self.getCode()
                }
        }
    }
    
    private func configAgreement() {
        view.addSubview(userAgreement)
        userAgreement.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(20)
            make.right.equalToSuperview().offset(-15)
        }
        userAgreement.addTarget(self, action: #selector(readUserAgreement), for: .touchUpInside)
        view.addSubview(userAgreementHeader)
        userAgreementHeader.snp.makeConstraints { make in
            make.right.equalTo(userAgreement.snp.left)
            make.centerY.equalTo(userAgreement)
        }
        view.addSubview(agreeButton)
        agreeButton.snp.makeConstraints { make in
            make.right.equalTo(userAgreementHeader.snp.left).offset(-5)
            make.centerY.equalTo(userAgreementHeader)
        }
    }
    
    private func configNextButton() {
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(48)
            make.right.equalToSuperview().offset(-48)
            make.height.equalTo(44)
            make.top.equalTo(agreeButton.snp.bottom).offset(40)
        }
        nextButton.addTarget(self, action: #selector(nextClick), for: .touchUpInside)
    }
    
    private func getCode() {
        
    }
    
    @objc private func readUserAgreement() {
        
    }
    
    @objc private func nextClick() {
        let controller = CompleteMaterialViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private let nextButton: DarkKeyButton = DarkKeyButton(title: "下一步")
    
    private let userAgreement: UIButton = {
        let button = UIButton()
        let title = "《用户使用协议》"
        let attributeTitle = NSMutableAttributedString(string: title)
        attributeTitle.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(hexString: "#666666"), NSAttributedString.Key.font: UIFont(name: "PingFangSC-Regular", size: 14.0)!, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 0, length: title.length))
        button.setAttributedTitle(attributeTitle, for: .normal)
        return button
    }()
    
    private let userAgreementHeader: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PingFangSC-Regular", size: 14.0)
        label.textColor = UIColor(hexString: "#666666")
        label.text = "我已阅读并同意"
        return label
    }()
    
    private let agreeButton: UIButton = {
        let button = UIButton()
        button.setImage(imageNamed("ic_agreement_select"), for: .normal)
        return button
    }()
}
