//
//  PickUpSuccessController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2019/5/4.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation

class PickUpSuccessController: BaseViewController {
    
    var isSupport: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "提交成功"
        view.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(100)
        }
        view.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(icon.snp.bottom).offset(40)
        }
        view.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(tipLabel.snp.bottom).offset(20)
        }
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(60)
            make.left.equalToSuperview().offset(48)
            make.right.equalToSuperview().offset(-48)
            make.height.equalTo(45)
        }
        button.addTarget(self, action: #selector(onClickBack), for: .touchUpInside)
        if isSupport {
            let attributedString = NSMutableAttributedString(string: "亲爱的用户我们会在10个工作日落实此类事情\n再次感谢您的建议！")
            attributedString.addAttributes([
                NSAttributedString.Key.font: UIFont(name: "PingFangSC-Regular", size: 12.0)!,
                NSAttributedString.Key.foregroundColor:UIColor(red: 139.0 / 255.0, green: 139.0 / 255.0, blue: 141.0 / 255.0, alpha: 0.7)
                ], range: NSRange(location: 0, length: 30))
            detailLabel.attributedText = attributedString
        }
    }
    
    @objc private func onClickBack() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    private let icon: UIImageView = {
        let icon = UIImageView()
        icon.image = imageNamed("PickUpSuccess")
        return icon
    }()
    
    private let tipLabel: UILabel = {
        let label = UILabel()
        let attributedString = NSMutableAttributedString(string: localizedString("pickSuccess"))
        attributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Medium", size: 20.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: 4))
        label.attributedText = attributedString
        return label
    }()
    
    private let detailLabel: UILabel = {
        let label = UILabel()
        let attributedString = NSMutableAttributedString(string: "亲爱的用户我们会尽快发出您的中奖商品\n请耐心等候")
        attributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Regular", size: 12.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 139.0 / 255.0, green: 139.0 / 255.0, blue: 141.0 / 255.0, alpha: 0.7)
            ], range: NSRange(location: 0, length: 24))
        label.attributedText = attributedString
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let button: DarkKeyButton = DarkKeyButton(title: localizedString("back"))
}
