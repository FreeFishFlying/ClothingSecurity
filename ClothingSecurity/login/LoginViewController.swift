//
//  LoginViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/9.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import ZCycleView
import SnapKit
import Core
import FDFullscreenPopGesture

private let headerHeight: CGFloat = 202

class LoginViewController: BaseViewController {
    var safeBottom: CGFloat = 0
    override func viewDidLoad() {
        if #available(iOS 11.0, *) {
            safeBottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        }
        view.backgroundColor = UIColor(hexString: "#EBEBEB")
        fd_prefersNavigationBarHidden = true
        fd_interactivePopDisabled = true
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        configHeaderView()
        configFooter()
    }
    
    private func configHeaderView() {
        let header = HeaderView()
        header.titleLabel.text = "登录"
        header.onBackButtonClick = { [weak self] in
            guard let `self` = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
        view.addSubview(header)
        header.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(headerHeight)
        }
    }
    
    private func configFooter() {
        view.addSubview(thirdView)
        thirdView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-30 - safeBottom)
            make.height.equalTo(40)
            make.left.right.equalToSuperview()
        }
        view.addSubview(thirdNote)
        thirdNote.snp.makeConstraints { make in
            make.centerX.equalTo(thirdView)
            make.bottom.equalTo(thirdView.snp.top).offset(-30)
        }
    }
    
    private let thirdView: ThirdParterView = ThirdParterView()
    
    private let thirdNote: UILabel = {
        let label = UILabel()
        let title = "———— 或从以下方式登录 ————"
         let attributedString = NSMutableAttributedString(string: title)
         attributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Regular", size: 13.035)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 154.0 / 255.0, green: 153.0 / 255.0, blue: 153.0 / 255.0, alpha: 1.0)
         ], range: NSRange(location: 0, length: title.length))
        label.attributedText = attributedString
        return label
    }()
}
