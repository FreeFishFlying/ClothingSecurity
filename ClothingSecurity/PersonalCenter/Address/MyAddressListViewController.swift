//
//  MyAddressListViewController.swift
//  Labeauty
//
//  Created by 宋昌鹏 on 2019/5/3.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation
import MJRefresh

class MyAddressListViewController: BaseViewController {
    var dataSources: [Address] = []
    var onSelectAddress: ((Address) -> Void)?
    var needClickBack: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        title = localizedString("myAddress")
        view.backgroundColor = UIColor(red: 242.0 / 255.0, green: 242.0 / 255.0, blue: 242.0 / 255.0, alpha: 1.0)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.bottom.right.equalToSuperview()
        }
        tableView.delegate = self
        tableView.dataSource = self
        loadData(0)
        AddressFacade.shared.addressWillRefresh().observeValues { value in
            if value {
                self.loadData(0)
            }
        }
    }
    
    func loadData(_ page: Int) {
        AddressFacade.shared.addressList(page).startWithResult { [weak self] result in
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            if value.first {
                self.dataSources.removeAll()
            }
            self.dataSources.append(contentsOf: value.data)
            self.tableView.reloadData()
            if self.dataSources.isEmpty {
                self.tableView.isHidden = true
                self.configEmptyView()
            } else {
                self.tableView.isHidden = false
                self.emptyView.isHidden = true
            }
        }
    }
    
    private func configEmptyView() {
        emptyView.removeFromSuperview()
        view.addSubview(emptyView)
        emptyView.isHidden = false
        emptyView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.bottom.right.equalToSuperview()
        }
        emptyView.addSubview(emptyIcon)
        emptyIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(40)
        }
        emptyView.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emptyIcon.snp.bottom).offset(40)
        }
        emptyView.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.top.equalTo(emptyLabel.snp.bottom).offset(64)
            make.left.equalToSuperview().offset(47)
            make.right.equalToSuperview().offset(-47)
            make.height.equalTo(45)
        }
        addButton.addTarget(self, action: #selector(addAdddress), for: .touchUpInside)
    }
    
    @objc private func addAdddress() {
        let controller = AddAddressViewController(Address(json: nil))
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.backgroundColor = UIColor.clear
        table.backgroundView = nil
        table.register(AddressCell.self, forCellReuseIdentifier: "AddressCell")
        return table
    }()
    
    private let emptyView: UIView  = {
        let empty = UIView()
        empty.backgroundColor = UIColor.white
        return empty
    }()
    
    private let emptyIcon: UIImageView = {
        let icon = UIImageView()
        icon.image = imageNamed("Noaddress")
        icon.contentMode = UIView.ContentMode.scaleAspectFill
        return icon
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PingFangSC-Regular", size: 12.99)
        label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        label.text = localizedString("noAddress")
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor(red: 176.0 / 255.0, green: 205.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0).cgColor
        button.layer.borderWidth = 1
        button.backgroundColor = UIColor.white
        button.setTitle("+ \(localizedString("AddAddress"))", for: .normal)
        button.setTitleColor(UIColor(red: 176.0 / 255.0, green: 205.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0), for: .normal)
        button.layer.cornerRadius = 22.5
        button.layer.masksToBounds = true
        return button
    }()
    
    private let tableButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor(red: 176.0 / 255.0, green: 205.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0).cgColor
        button.layer.borderWidth = 1
        button.backgroundColor = UIColor.white
        button.setTitle("+ \(localizedString("AddAddress"))", for: .normal)
        button.setTitleColor(UIColor(red: 176.0 / 255.0, green: 205.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0), for: .normal)
        button.layer.cornerRadius = 22.5
        button.layer.masksToBounds = true
        return button
    }()
}

extension MyAddressListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if dataSources.isEmpty {
            return nil
        }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 90))
        view.addSubview(tableButton)
        tableButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(45)
            make.left.equalToSuperview().offset(47)
            make.right.equalToSuperview().offset(-47)
            make.height.equalTo(45)
        }
        tableButton.addTarget(self, action: #selector(addAdddress), for: .touchUpInside)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 136.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell", for: indexPath) as! AddressCell
        cell.address = dataSources[indexPath.row]
        cell.onSetDefaultAddress = { [weak self] address in
            self?.setDefaultAddress(address)
        }
        
        cell.onEditAddress = { [weak self] address in
            self?.editAddress(address)
        }
        
        cell.onDeleteAddress = { [weak self] address in
            self?.deleteAddress(address)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let address = dataSources[indexPath.row]
        onSelectAddress?(address)
        if needClickBack {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func setDefaultAddress(_ address: Address) {
        address.defaultAddress = !address.defaultAddress
        AddressFacade.shared.updateAddress(address).startWithResult { _ in
        }
    }
    
    private func editAddress(_ address: Address) {
        let controller = AddAddressViewController(address)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func deleteAddress(_ address: Address) {
        AddressFacade.shared.deleteAddress(address.id).startWithResult { _ in
        }
    }
}
