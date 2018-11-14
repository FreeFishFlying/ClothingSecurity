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
class FeedbackViewController: BaseViewController {
    private let maxNumber = "200"
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "问题反馈"
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
        container.addSubview(countButton)
        countButton.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(30)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalTo(container.snp.bottom).offset(-20)
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
            if let content = content {
                if content.length > 200 {
                    self.countButton.setTitle("200/200", for: .normal)
                } else {
                    self.countButton.setTitle("\(content.length)/\(self.maxNumber)", for: .normal)
                }
            } else {
               self.countButton.setTitle("0/\(self.maxNumber)", for: .normal)
            }
        }
    }
    
    @objc func sure() {
        
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
    
    private let countButton: UIButton = {
        let button = WordCountButton()
        button.setTitle("0/200", for: .normal)
        return button
    }()
    
    private let sureButton = DarkKeyButton(title: "提交")
}

class WordCountButton: UIButton {
    override init(frame _: CGRect) {
        super.init(frame: .zero)
        setTitleColor(UIColor(hexString: "#333333"), for: .normal)
        backgroundColor = UIColor.clear
        titleLabel?.font = systemFontSize(fontSize: 15)
        addTarget(self, action: #selector(clickButton(sender:)), for: .touchUpInside)
        layer.masksToBounds = true
        layer.cornerRadius = 10
    }
    
    override var buttonType: UIButton.ButtonType {
        return .custom
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal var wordString: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.setTitle(self.wordString, for: .normal)
            }
        }
    }
    
    internal var clickTagClosure: ((_ label: String) -> Void)?
    
    @objc func clickButton(sender _: UIButton) {
        //        self.clickTagClosure?(tagString)
    }
}
