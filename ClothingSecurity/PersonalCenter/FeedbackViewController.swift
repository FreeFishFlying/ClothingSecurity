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
class FeedbackViewController: GroupedFormViewController {
    private let maxNumber = "200"
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "投诉建议"
        configUI()
        autoHideKeyboard = true
    }
    
    private func configUI() {
        view.backgroundColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1)
        view.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.right.equalToSuperview()
        }
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(260)
        }
        view.addSubview(sureButton)
        sureButton.snp.makeConstraints { make in
            make.top.equalTo(container.snp.bottom).offset(50)
            make.left.equalToSuperview().offset(46)
            make.right.equalToSuperview().offset(-46)
            make.height.equalTo(44)
        }
        sureButton.addTarget(self, action: #selector(sure), for: .touchUpInside)
        textView.getInputTextView().makeLimit(length: 200, signal: textView.textValues.map { $0.1 })
        textView.attributedPlaceholder = NSAttributedString(string: "请输入您的详细问题，我们将为你尽快解决。", attributes: [NSAttributedString.Key.font: systemFontSize(fontSize: 15), NSAttributedString.Key.foregroundColor: UIColor(hexString: "#bfbfbf")])
        textView.textValues.observeValues { [weak self] (view, content) in
            guard let `self` = self else { return }
        }
        textView.returnKeyType = UIReturnKeyType.done
        textView.shouldChangeTextInRange = { [weak self] _, text in
            if text == "\n" {
                self?.textView.resignFirstResponder()
                return false
            }
            return true
        }
    }
     
    @objc func sure() {
        if  !self.textView.text.isEmpty {
            PersonCenterFacade.shared.feedback(content: self.textView.text).startWithResult { [weak self] result in
                guard let `self` = self else { return }
                guard let value = result.value else { return }
                if value.isSuccess() {
                    self.navigationController?.popViewController(animated: true)
                    HUD.flashSuccess(title: "提交成功")
                } else {
                    HUD.flashError(title: "提交失败")
                }
            }
        } else {
            HUD.tip(text: "请输入内容")
        }
    }
    
    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    private let textView: GrowingTextView = {
        let textView = GrowingTextView()
        textView.backgroundColor = UIColor.white
        textView.placeholder = "请输入您的详细问题，我们将为你尽快解决。"
        return textView
    }()
    
    private let sureButton = DarkKeyButton(title: "立即提交")
}
