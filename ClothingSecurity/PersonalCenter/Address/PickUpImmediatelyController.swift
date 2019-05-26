//
//  PickUpImmediatelyController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2019/5/4.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation
import HUD
class PickUpImmediatelyController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var address: Address?
    let id: String
    let model: Prize
    var log: prizeLog?
    init(_ model: Prize, _ id: String, _ log: prizeLog? = nil) {
        self.model = model
        self.id = id
        self.log = log
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "立即提货"
        view.backgroundColor = UIColor(red: 242.0 / 255.0, green: 242.0 / 255.0, blue: 242.0 / 255.0, alpha: 1.0)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(300)
        }
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(60)
            make.left.equalToSuperview().offset(46)
            make.right.equalToSuperview().offset(-46)
            make.height.equalTo(45)
        }
        tableView.delegate = self
        tableView.dataSource = self
        loadAddress()
        button.addTarget(self, action: #selector(bindAddress), for: .touchUpInside)
    }
    
    @objc func bindAddress() {
        if let address = address {
            AddressFacade.shared.bindPrized(prizeLogId: id, addressId: address.id).startWithResult { [weak self] result in
                guard let `self` = self else { return }
                guard let value = result.value else { return }
                if value.isSuccess() {
                    let controller = PickUpSuccessController()
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        } else {
            HUD.flashError(title: "请填写地址")
        }
    }
    
    private func loadAddress() {
        AddressFacade.shared.addressList(0).startWithResult { [weak self] result in
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            if !value.data.isEmpty {
                if let firstItem = value.data.first(where: {$0.defaultAddress}) {
                    self.address = firstItem
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundView = nil
        table.separatorStyle = .none
        table.backgroundColor = UIColor.clear
        table.register(SigleAddressCell.self, forCellReuseIdentifier: "SigleAddressCell")
        table.register(SignleGiftCell.self, forCellReuseIdentifier: "SignleGiftCell")
        return table
    }()
    
    private let button: DarkKeyButton = DarkKeyButton(title: "立即领取")
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 90
        }
        return 118
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SigleAddressCell", for: indexPath) as! SigleAddressCell
            cell.address = address
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SignleGiftCell", for: indexPath) as! SignleGiftCell
            cell.gift = model
            if let log = self.log {
                cell.showTime = log.createTime
            } else {
                cell.showTime = model.sendTime
            }
            cell.hideButton = true
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let controller = MyAddressListViewController()
            controller.onSelectAddress = { [weak self] address in
                self?.address = address
                self?.tableView.reloadData()
            }
            controller.needClickBack = true
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}
