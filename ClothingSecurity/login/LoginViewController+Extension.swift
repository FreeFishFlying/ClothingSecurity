//
//  LoginViewController+Extension.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/25.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit


class ThirdParterView: UIView {
    
    var onQQClick: (() -> Void)?
    var onWXClick: (() -> Void)?
    var onWBClick: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
//        addSubview(qqButton)
//        qqButton.snp.makeConstraints { make in
//            make.center.equalToSuperview()
//            make.width.height.equalTo(40)
//        }
//        qqButton.addTarget(self, action: #selector(qqClick), for: .touchUpInside)
//        if WXApi.isWXAppInstalled() {
//            addSubview(wxButton)
//            wxButton.snp.makeConstraints { make in
//                make.centerY.equalToSuperview()
//                make.right.equalTo(qqButton.snp.left).offset(-43)
//                make.width.height.equalTo(40)
//            }
//            wxButton.addTarget(self, action: #selector(wxClick), for: .touchUpInside)
//        }
//        addSubview(wbButton)
//        wbButton.snp.makeConstraints { make in
//            make.left.equalTo(qqButton.snp.right).offset(43)
//            make.centerY.equalToSuperview()
//            make.width.height.equalTo(40)
//        }
//        wbButton.addTarget(self, action: #selector(wbClick), for: .touchUpInside)
        if WXApi.isWXAppInstalled() {
            addSubview(wxButton)
            wxButton.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(40)
            }
            wxButton.addTarget(self, action: #selector(wxClick), for: .touchUpInside)
        }
    }
    
    @objc func qqClick() {
        onQQClick?()
    }
    
    @objc func wxClick() {
        onWXClick?()
    }
    
    @objc func wbClick() {
        onWBClick?()
    }
    let qqButton: UIButton = {
        let button = UIButton()
        button.setImage(imageNamed("login_qq"), for: .normal)
        return button
    }()
    
    let wxButton: UIButton = {
        let button = UIButton()
        button.setImage(imageNamed("login_wx"), for: .normal)
        return button
    }()
    
    let wbButton: UIButton = {
        let button = UIButton()
        button.setImage(imageNamed("login_wb"), for: .normal)
        return button
    }()
}

class HeaderView: UIView {
    
    var onBackButtonClick: (() -> Void)?
    
    var onChooseLogo: (() -> Void)?
    
    var imageUrl: String? {
        didSet {
            if let imageUrl = imageUrl {
                if let url = URL(string: imageUrl) {
                    logo.kf.setImage(with: url, placeholder: imageNamed("login_logo"))
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(178)
        }
        addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.width.equalTo(44)
            if #available(iOS 11, *) {
                let safeAreaTop = UIApplication.shared.keyWindow!.safeAreaInsets.top
                if safeAreaTop > 0 {
                    make.top.equalTo(8 + safeAreaTop)
                } else {
                    make.top.equalTo(30)
                }
            } else {
                make.top.equalTo(45)
            }
        }
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.centerX.equalToSuperview()
        }
        addSubview(logo)
        logo.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backgroundView.snp.bottom)
            make.height.width.equalTo(105)
        }
        logo.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapChooseLogo))
        logo.addGestureRecognizer(tap)
        backButton.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
    }
    
    public func noLogoUI() {
        backgroundView.snp.updateConstraints { make in
            make.height.equalTo(64)
        }
        logo.snp.updateConstraints { make in
            make.height.equalTo(0)
        }
    }
    
    @objc func backButtonClick() {
        onBackButtonClick?()
    }
    
    @objc func tapChooseLogo() {
        onChooseLogo?()
    }
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 55, height: 44)
        button.setImage(imageNamed("back_white"), for: .normal)
        button.setTitle("返回", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = systemFontSize(fontSize: 15)
        button.imageEdgeInsets = UIEdgeInsets(top: 6, left: -5, bottom: 6, right: 30)
        button.titleEdgeInsets = UIEdgeInsets(top: 6, left: -8, bottom: 6, right: 0)
        return button
    }()
    
    public let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PingFangSC-Semibold", size: 18)!
        label.textColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        return label
    }()
    
    private let logo: UIImageView = {
        let logo = UIImageView()
        logo.image = imageNamed("login_logo")
        return logo
    }()
    
    private let backgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = imageNamed("backdrop")
        return imageView
    }()
}

class LoginHelpView: UIView {
    
    var onForgetButtonClick: (() -> Void)?
    var onRegisterButtonClick: (() ->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        addSubview(line)
        line.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(0.5)
            make.height.equalTo(11)
        }
        addSubview(forgetButton)
        forgetButton.snp.makeConstraints { make in
            make.right.equalTo(line.snp.left).offset(-16)
            make.centerY.equalToSuperview()
        }
        forgetButton.addTarget(self, action: #selector(forget), for: .touchUpInside)
        addSubview(registerButton)
        registerButton.snp.makeConstraints { make in
            make.left.equalTo(line.snp.right).offset(16)
            make.centerY.equalToSuperview()
        }
        registerButton.addTarget(self, action: #selector(register), for: .touchUpInside)
    }
    
    @objc func forget() {
        onForgetButtonClick?()
    }
    
    @objc func register() {
        onRegisterButtonClick?()
    }
    
    private let forgetButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(hexString: "#353535"), for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFang-SC-Medium", size: 15.0) ?? systemFontSize(fontSize: 15)
        button.setTitle("忘记密码？", for: .normal)
        return button
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(hexString: "#353535"), for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFang-SC-Medium", size: 15.0) ?? systemFontSize(fontSize: 15)
        button.setTitle("新用户注册", for: .normal)
        return button
    }()
    
    private let line: UIView = {
        let line = UIView()
        line.backgroundColor =  UIColor(red: 119.0 / 255.0, green: 119.0 / 255.0, blue: 126.0 / 255.0, alpha: 1.0)
        return line
    }()
}
