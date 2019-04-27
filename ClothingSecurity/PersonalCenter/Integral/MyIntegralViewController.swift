//
//  MyIntegralViewController.swift
//  Labeauty
//
//  Created by 宋昌鹏 on 2019/4/27.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation


class MyIntegralViewController: PersonalBaseViewController {
    var dataSources: [IntegralItem] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        headerTitle = "我的积分"
        container.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.centerY.equalTo(headerView)
            make.left.equalToSuperview().offset(15)
        }
        backButton.addTarget(self, action: #selector(clickBack), for: .touchUpInside)
        container.addSubview(integarlLabel)
        integarlLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(62)
            make.left.equalToSuperview().offset(42)
        }
        container.addSubview(resultLabel)
        resultLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(42)
            make.top.equalTo(integarlLabel.snp.bottom).offset(10)
        }
        container.addSubview(clickButton)
        clickButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(89)
            make.width.equalTo(122)
            make.height.equalTo(35)
        }
        clickButton.layer.cornerRadius = 17.5
        clickButton.addTarget(self, action: #selector(lottery), for: .touchUpInside)
        tableView.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(173+64)
        }
        view.addSubview(recordView)
        recordView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalTo(tableView.snp.top)
            make.height.equalTo(64)
        }
        recordView.onClickRecordView = { [weak self] value in
            guard let `self` = self else { return }
            print(value)
        }
        
        IntegralFacade.shared.bonusPoint().startWithResult { [weak self] result in
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            self.resultLabel.text = value.bonusPoints
        }
        
        IntegralFacade.shared.walletLog(page: 0).startWithResult { [weak self] result in
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            self.dataSources = value.data
            self.tableView.reloadData()
        }
    }
    
    @objc private func clickBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func lottery() {
        let controller = LotteryViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func configContainer() {
        super.configContainer()
    }
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(imageNamed("whiteBack"), for: .normal)
        button.hitTestEdgeInsets = UIEdgeInsets.init(top: -5, left: -5, bottom: -5, right: -10)
        return button
    }()
    
    private let integarlLabel: UILabel = {
        let label = UILabel()
        let attributedString = NSMutableAttributedString(string: "可用积分")
        attributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Regular", size: 13)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: 4))
        label.attributedText = attributedString
        return label
    }()
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
        label.font = systemFontSize(fontSize: 40)
        return label
    }()
    
    private let clickButton: DarkKeyButton = DarkKeyButton(title: "抽奖")
    
    private let recordView: SwitchRecordView = SwitchRecordView()
}
