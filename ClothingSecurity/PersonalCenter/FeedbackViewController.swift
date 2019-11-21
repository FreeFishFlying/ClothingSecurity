//
//  FeedbackViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/14.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import Core
import HUD
class FeedbackViewController: BaseViewController, UITextFieldDelegate {
    private let maxNumber = "200"
    var dataSources: [FeedBack] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        title = localizedString("suggestions")
        configData()
        configUI()
        autoHideKeyboard = true
    }
    
    private func configUI() {
        view.backgroundColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(212)
        }
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(145)
        }
        let attributedString = NSMutableAttributedString(string: localizedString("someSuggestion"))
        attributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Regular", size: 14.135)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 139.0 / 255.0, green: 139.0 / 255.0, blue: 141.0 / 255.0, alpha: 1.0)
        ], range: NSRange(location: 0, length: attributedString.length))
        textView.attributedPlaceholder = attributedString
        view.addSubview(telephoneView)
        telephoneView.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        telephoneView.textFiled.delegate = self
        view.addSubview(sureButton)
        sureButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(48)
            make.right.equalToSuperview().offset(-48)
            make.height.equalTo(45)
            make.bottom.equalToSuperview().offset(-40)
        }
        sureButton.addTarget(self, action: #selector(sure), for: .touchUpInside)
    }
    
    private func configData() {
        let first = FeedBack(category: localizedString("dysfunction"), content: localizedString("existingFunction"), isChoosed: false)
        let second = FeedBack(category: localizedString("useAdvice"), content: localizedString("someSuggestions"), isChoosed: false)
        let third = FeedBack(category: localizedString("demand"), content: localizedString("meetDemand"), isChoosed: false)
        dataSources.append(first)
        dataSources.append(second)
        dataSources.append(third)
    }
     
    @objc func sure() {
        if let item = dataSources.first(where: {$0.isChoosed}) {
            if self.textView.text.isEmpty {
                HUD.tip(text: "请输入内容")
                return
            }
            var params: [String: String] = ["content": self.textView.text, "category": item.category]
            if let contact = telephoneView.content() {
                params["contact"] = contact
            }
            PersonCenterFacade.shared.feedback(content: params).startWithResult { [weak self] result in
                guard let `self` = self else { return }
                guard let value = result.value else { return }
                if value.isSuccess() {
                    let controller = PickUpSuccessController()
                    controller.isSupport = true
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        } else {
            HUD.flashError(title: "请选择反馈类型")
            return
        }
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(FeedBackCell.self, forCellReuseIdentifier: "FeedBackCell")
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.clear
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private let textView: GrowingTextView = {
        let textView = GrowingTextView()
        textView.backgroundColor = UIColor.white
        textView.placeholder = localizedString("someSuggestion")
        return textView
    }()
    
    private let telephoneView: TelephoneView = TelephoneView()
    
    private let sureButton = DarkKeyButton(title: localizedString("submitImmediately"))
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tableView.snp.updateConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide).offset(-100)
        }
        tableView.layoutIfNeeded()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        tableView.snp.updateConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
        }
        tableView.layoutIfNeeded()
    }
}

extension FeedbackViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 40))
        view.backgroundColor = UIColor.clear
        let label = UILabel()
        label.textColor = UIColor(red: 139.0 / 255.0, green: 139.0 / 255.0, blue: 141.0 / 255.0, alpha: 1.0)
        label.font = UIFont(name: "PingFangSC-Regular", size: 14.0)
        label.text = localizedString("problemType")
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(14)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 40))
        view.backgroundColor = UIColor.clear
        let label = UILabel()
        label.textColor = UIColor(red: 139.0 / 255.0, green: 139.0 / 255.0, blue: 141.0 / 255.0, alpha: 1.0)
        label.font = UIFont(name: "PingFangSC-Regular", size: 14.0)
        label.text = localizedString("detailDescription")
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(14)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedBackCell", for: indexPath) as! FeedBackCell
        cell.feedBack = dataSources[indexPath.row]
        cell.onSelectOption = { [weak self] feed in
            guard let `self` = self else { return }
            self.handleDataSources(feed)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataSources[indexPath.row]
        handleDataSources(item)
    }
    
    func handleDataSources(_ value: FeedBack) {
        dataSources.forEach { item in
            if item.category != value.category {
                item.isChoosed = false
            } else {
                item.isChoosed = !item.isChoosed
            }
        }
        self.tableView.reloadData()
    }
}

class TelephoneView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(topLine)
        backgroundColor = UIColor.white
        topLine.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(65)
        }
        addSubview(seperateLine)
        seperateLine.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(nameLabel.snp.right)
            make.width.equalTo(0.5)
        }
        addSubview(textFiled)
        textFiled.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(seperateLine.snp.right).offset(15)
            make.right.equalToSuperview().offset(-15)
        }
    }

    func content() -> String? {
        return textFiled.text
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let topLine: UIView = {
        let style = UIView()
        style.layer.backgroundColor = UIColor(red: 221.0 / 255.0, green: 221.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0).cgColor
        style.alpha = 1
        return style
    }()
    
    private let seperateLine: UIView = {
        let style = UIView()
        style.layer.backgroundColor = UIColor(red: 221.0 / 255.0, green: 221.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0).cgColor
        style.alpha = 1
        return style
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        let attributedString = NSMutableAttributedString(string: localizedString("phoneNumber"))
        attributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFang-SC-Medium", size: 14.135)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 35.0 / 255.0, green: 24.0 / 255.0, blue: 21.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: 3))
        label.attributedText = attributedString
        return label
    }()
    
    let textFiled: UITextField = {
        let tf = UITextField()
        tf.font = systemFontSize(fontSize: 14)
        tf.placeholder = "方便我们更快向你反馈哦~"
        return tf
    }()
}
