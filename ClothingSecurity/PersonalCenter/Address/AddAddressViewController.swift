//
//  AddAddressViewController.swift
//  Labeauty
//
//  Created by 宋昌鹏 on 2019/5/3.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation
import HUD
class AddAddressViewController: BaseViewController {
    var addrss: Address
    init(_ address: Address) {
        self.addrss = address
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = localizedString("fillAddress")
        autoHideKeyboard = true
        configUI()
    }
    
    private func configUI() {
        view.addSubview(nameLabel)
        view.addSubview(nameTF)
        view.addSubview(mobileLabel)
        view.addSubview(mobileTF)
        view.addSubview(detailLabel)
        view.addSubview(contentView)
        view.addSubview(addressLabel)
        view.addSubview(addressTF)
        view.addSubview(button)
        configContentView()
        nameLabel.snp.makeConstraints { make  in
            make.top.equalTo(safeAreaTopLayoutGuide).offset(15)
            make.left.equalToSuperview().offset(15)
        }
        nameTF.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(40)
        }
        mobileLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(nameTF.snp.bottom).offset(16)
        }
        mobileTF.snp.makeConstraints { make in
            make.top.equalTo(mobileLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(40)
        }
        detailLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(mobileTF.snp.bottom).offset(16)
        }
        contentView.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(40)
        }
        addressLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(contentView.snp.bottom).offset(16)
        }
        addressTF.delegate = self
        addressTF.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(40)
        }
        button.snp.makeConstraints { make in
            make.top.equalTo(addressTF.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(48)
            make.right.equalToSuperview().offset(-48)
            make.height.equalTo(45)
        }
        button.addTarget(self, action: #selector(onCreateNewAddress), for: .touchUpInside)
        nameTF.text = addrss.name
        mobileTF.text = addrss.mobile
        addressTF.text = addrss.address
        provinceLabel.text = addrss.province
        cityLabel.text = addrss.city
        countryLabel.text = addrss.area
    }
    
    private func configContentView() {
        let width = (ScreenWidth - 30 - 32) / 3
        contentView.addSubview(provinceLabel)
        contentView.addSubview(cityLabel)
        contentView.addSubview(countryLabel)
        provinceLabel.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(width)
        }
        cityLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(provinceLabel.snp.right).offset(16)
            make.width.equalTo(width)
        }
        countryLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(cityLabel.snp.right).offset(16)
            make.width.equalTo(width)
        }
        provinceLabel.addSubview(doutIcon_1)
        cityLabel.addSubview(doutIcon_2)
        countryLabel.addSubview(doutIcon_3)
        doutIcon_1.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
        doutIcon_2.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
        doutIcon_3.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(chooseAddrss))
        provinceLabel.addGestureRecognizer(tap)
        let tap_1 = UITapGestureRecognizer(target: self, action: #selector(chooseAddrss))
        cityLabel.addGestureRecognizer(tap_1)
        let tap_2 = UITapGestureRecognizer(target: self, action: #selector(chooseAddrss))
        countryLabel.addGestureRecognizer(tap_2)
    }
    
    @objc private func chooseAddrss() {
        let controller = HDSelecterViewController.init(defualtProvince: "", city: "", districts: "")!
        controller.title = localizedString("pleaseSelect")
        controller.completeSelectBlock = { [weak self] provice, city, districts in
            guard let `self` = self else { return }
            if let provice = provice {
                self.addrss.province = provice
            }
            if let city = city {
                self.addrss.city = city
            }
            if let districts = districts {
                self.addrss.area = districts
            }
            self.loadContentData()
            self.dismiss(animated: true, completion: nil)
        }
        present(controller, animated: true, completion: nil)
    }
    
    @objc private func onCreateNewAddress() {
        addrss.name = nameTF.text ?? ""
        addrss.mobile = mobileTF.text ?? ""
        addrss.address = addressTF.text ?? ""
        if addrss.name.isEmpty {
            HUD.flashError(title: "请填写收货姓名")
            return
        }
        if addrss.mobile.isEmpty {
            HUD.flashError(title: "请填写手机号码")
            return
        }
        if addrss.province.isEmpty || addrss.city.isEmpty || addrss.area.isEmpty {
            HUD.flashError(title: "请选择收货地址")
            return
        }
        if addrss.address.isEmpty {
            HUD.flashError(title: "请输入详细地址")
            return
        }
        if addrss.id.isEmpty {
            AddressFacade.shared.createAddress(addrss).startWithResult { [weak self] response in
                guard let `self` = self else { return }
                guard let value = response.value else { return }
                if value.isSuccess() {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            AddressFacade.shared.updateAddress(addrss).startWithResult { [weak self] response in
                guard let `self` = self else { return }
                guard let value = response.value else { return }
                if value.isSuccess() {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    private func loadContentData() {
        provinceLabel.text = self.addrss.province
        cityLabel.text = self.addrss.city
        countryLabel.text = self.addrss.area
    }
    
    private let nameTF: UITextField = {
        let tf = UITextField()
        tf.borderStyle = UITextField.BorderStyle.none
        tf.font = systemFontSize(fontSize: 12)
        tf.layer.borderWidth = 0.5
        tf.layer.borderColor = UIColor(red: 221.0 / 255.0, green: 221.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0).cgColor
        tf.leftView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        tf.leftViewMode = UITextField.ViewMode.always
        tf.placeholder = " 请填写收货人姓名"
        return tf
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "收货人"
        label.font = UIFont(name: "PingFangSC-Regular", size: 14.0)
        label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        return label
    }()
    
    private let mobileTF: UITextField = {
        let tf = UITextField()
        tf.font = systemFontSize(fontSize: 12)
        tf.layer.borderWidth = 0.5
        tf.layer.borderColor = UIColor(red: 221.0 / 255.0, green: 221.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0).cgColor
        tf.leftView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        tf.leftViewMode = UITextField.ViewMode.always
        tf.placeholder = " 请填写手机号码"
        return tf
    }()
    
    private let mobileLabel: UILabel = {
        let label = UILabel()
        label.text = "电话"
        label.font = UIFont(name: "PingFangSC-Regular", size: 14.0)
        label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        return label
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.text = "省/市/区"
        label.font = UIFont(name: "PingFangSC-Regular", size: 14.0)
        label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        return label
    }()
    
    private let addressTF: UITextField = {
        let tf = UITextField()
        tf.layer.borderWidth = 0.5
        tf.font = systemFontSize(fontSize: 12)
        tf.layer.borderColor = UIColor(red: 221.0 / 255.0, green: 221.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0).cgColor
        tf.leftView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        tf.leftViewMode = UITextField.ViewMode.always
        tf.placeholder = localizedString("请输入详细地址")
        tf.tag = 999
        return tf
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.text = localizedString("detailAddress")
        label.font = UIFont(name: "PingFangSC-Regular", size: 14.0)
        label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        return label
    }()
    
    private let button = DarkKeyButton(title: "确认")
    
    private let provinceLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 13)
        label.textColor = UIColor(red: 139.0 / 255.0, green: 139.0 / 255.0, blue: 141.0 / 255.0, alpha: 1.0)
        label.layer.borderColor = UIColor(red: 221.0 / 255.0, green: 221.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0).cgColor
        label.layer.borderWidth = 0.5
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 13)
        label.textColor = UIColor(red: 139.0 / 255.0, green: 139.0 / 255.0, blue: 141.0 / 255.0, alpha: 1.0)
        label.layer.borderColor = UIColor(red: 221.0 / 255.0, green: 221.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0).cgColor
        label.layer.borderWidth = 0.5
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let countryLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 13)
        label.textColor = UIColor(red: 139.0 / 255.0, green: 139.0 / 255.0, blue: 141.0 / 255.0, alpha: 1.0)
        label.layer.borderColor = UIColor(red: 221.0 / 255.0, green: 221.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0).cgColor
        label.layer.borderWidth = 0.5
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let doutIcon_1: UIImageView = {
        let icon = UIImageView()
        icon.image = imageNamed("Addressdrop-down")
        icon.contentMode = UIView.ContentMode.scaleAspectFill
        return icon
    }()
    
    private let doutIcon_2: UIImageView = {
        let icon = UIImageView()
        icon.image = imageNamed("Addressdrop-down")
        icon.contentMode = UIView.ContentMode.scaleAspectFill
        return icon
    }()
    
    private let doutIcon_3: UIImageView = {
        let icon = UIImageView()
        icon.image = imageNamed("Addressdrop-down")
        icon.contentMode = UIView.ContentMode.scaleAspectFill
        return icon
    }()
}

extension AddAddressViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 999 {
            nameLabel.snp.updateConstraints { make in
                make.top.equalTo(safeAreaTopLayoutGuide).offset(-70)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 999 {
            nameLabel.snp.updateConstraints { make in
                make.top.equalTo(safeAreaTopLayoutGuide).offset(15)
            }
        }
    }
}
