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
import HUD
class RegisterViewController: BaseLoginViewController {
    var isEnable: Bool = true
    var buttonTitle: String = "获取验证码"
    var countDown: Int = 60
    var countdownTimer: TimerProxy?
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
                row.cell.onGetCode = { [weak self] in
                    guard let `self` = self else { return }
                    self.getCode()
                }
                row.cellUpdate({ [weak self] (cell, _) in
                    guard let `self` = self else { return }
                    cell.title = self.buttonTitle
                    cell.buttonEnable = self.isEnable
                })
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
        guard let mobileRow: TextfieldInputCellRow = form.rowBy(tag: "phoneCell") as? TextfieldInputCellRow else { return }
        if let text = mobileRow.cell.textFieldText, !text.isEmpty {
            LoginAndRegisterFacade.shared.requetAuthcode(mobile: text).startWithResult { [weak self] result in
                guard let `self` = self else { return }
                guard let value = result.value else { return }
                if value.isSuccess() {
                    self.isEnable = false
                    self.countdownTimer = TimerProxy(withInterval: 1.0, repeats: true, timerHandler: { [weak self] in
                        self?.doCountDown()
                    })
                } else {
                    HUD.tip(text: value.tipMesage())
                }
            }
        } else {
            HUD.tip(text: "请输入手机号")
        }
    }
    
    @objc private func readUserAgreement() {
        
    }
    
    private func doCountDown() {
        countDown -= 1
        buttonTitle = "\(countDown)s"
        if countDown == 0 {
            countdownTimer?.invalidate()
            countdownTimer = nil
            buttonTitle = "获取验证码"
            isEnable = true
            countDown = 60
        }
        if let row: InputRenderCellRow = form.rowBy(tag: "secturyCell") as? InputRenderCellRow {
            row.updateCell()
        }
    }
    
    @objc private func nextClick() {
        guard let phoneRow: TextfieldInputCellRow = form.rowBy(tag: "phoneCell") as? TextfieldInputCellRow else { return }
        guard let codeRow: InputRenderCellRow = form.rowBy(tag: "secturyCell")  as? InputRenderCellRow else { return }
        if let phone = phoneRow.cell.textFieldText, let code = codeRow.cell.code {
            if !phone.isEmpty && !code.isEmpty {
                LoginAndRegisterFacade.shared.register(mobile: phone, code: code).startWithResult { [weak self] result in
                    guard let `self` = self else { return }
                    guard let value = result.value else { return }
                    if value.isSuccess() {
                        let controller = CompleteMaterialViewController()
                        self.navigationController?.pushViewController(controller, animated: true)
                    } else {
                        if let message = value.tipMesage() {
                            HUD.flashError(title: message)
                        } else {
                            HUD.flashError(title: "注册失败,请稍后再试")
                        }
                    }
                }
            } else {
                if phone.isEmpty {
                    HUD.flashError(title: "手机号不能为空")
                    return
                }
                if code.isEmpty {
                    HUD.flashError(title: "验证码不能为空")
                    return
                }
            }
        }
        
        
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
