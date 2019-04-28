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
    var direction: WalletDirection = .In
    override func viewDidLoad() {
        super.viewDidLoad()
        headerTitle = "我的积分"
        tableView.register(IntegralRecordCell.self, forCellReuseIdentifier: "IntegralRecordCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
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
            self.direction = value == 0 ? .In : .Out
            self.getWalletLog(page: 0)
        }
        
        IntegralFacade.shared.sign().startWithResult({ [weak self] result in
            guard let `self` = self else { return }
            if self.direction == WalletDirection.In {
                self.getWalletLog(page: 0)
            }
        })
        
        IntegralFacade.shared.bonusPoint().startWithResult { [weak self] result in
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            self.resultLabel.text = value.bonusPoints
        }
        
        getWalletLog(page: 0)
    }
    
    private func getWalletLog(page: Int) {
        IntegralFacade.shared.walletLog(page: page, direction: direction).startWithResult { [weak self] result in
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            if value.first {
                self.dataSources.removeAll()
                
            }
            self.dataSources.append(contentsOf: value.data)
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

extension MyIntegralViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IntegralRecordCell", for: indexPath) as! IntegralRecordCell
        cell.model = (item: dataSources[indexPath.row], type: direction)
        return cell
    }
}
