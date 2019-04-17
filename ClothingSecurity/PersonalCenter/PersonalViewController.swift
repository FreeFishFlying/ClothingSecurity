//
//  PersonalViewController.swift
//  Labeauty
//
//  Created by 宋昌鹏 on 2019/4/6.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation
import Eureka
class PersonalViewController: PersonalBaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(NormalCenterCell.self, forCellReuseIdentifier: "NormalCenterCell")
        headerTitle = "我的"
        tableView.delegate = self
        tableView.dataSource = self
        configUI()
        registerEvent()
        addTapClick()
        self.currentUser = UserItem.current()
    }
    
    private func addTapClick() {
        let tap_0 = UITapGestureRecognizer(target: self, action: #selector(tap))
        logo.addGestureRecognizer(tap_0)
        let tap_1 = UITapGestureRecognizer(target: self, action: #selector(tap))
        nameLabel.addGestureRecognizer(tap_1)
    }
    
    @objc private func tap() {
        if !LoginState.shared.hasLogin.value {
            let controller = LoginViewController()
            let nav = UINavigationController(rootViewController: controller)
            navigationController?.present(nav, animated: true, completion: nil)
        }
    }
    
    private func configUI() {
        container.addSubview(logo)
        container.addSubview(nameLabel)
        container.addSubview(accountLabel)
        container.addSubview(newButton)
        logo.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(86)
            make.height.width.equalTo(62)
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(logo.snp.right).offset(12)
            make.centerY.equalTo(logo.snp.centerY)
        }
        accountLabel.snp.makeConstraints { make in
            make.left.equalTo(logo.snp.right).offset(12)
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
        }
        
    }
    
    var currentUser: UserItem? {
        didSet {
            if let user = currentUser {
                nameLabel.text = user.nickName
                accountLabel.text = user.mobile
                if let path = URL(string: user.avatar) {
                    logo.kf.setImage(with: path, placeholder: imageNamed("Defaulthead"), options: nil, progressBlock: nil, completionHandler: nil)
                } else {
                    logo.image = imageNamed("Defaulthead")
                }
                nameLabel.snp.remakeConstraints { make in
                    make.left.equalTo(logo.snp.right).offset(12)
                    make.bottom.equalTo(logo.snp.centerY).offset(5)
                    make.right.equalToSuperview().offset(-15)
                }
            } else {
                nameLabel.text = "登录/注册"
                accountLabel.text = nil
                logo.image = imageNamed("Defaulthead")
                nameLabel.snp.remakeConstraints { make in
                    make.left.equalTo(logo.snp.right).offset(12)
                    make.centerY.equalTo(logo.snp.centerY)
                }
            }
        }
    }
    
    func registerEvent() {
        LoginAndRegisterFacade.shared.obserUserItemChange().observeValues { [weak self] item in
            guard let `self` = self else { return }
            self.currentUser = item
        }
        LoginAndRegisterFacade.shared.appWillLoginOut().take(during: reactive.lifetime).observeValues { [weak self] value in
            if value {
                UserItem.loginOut()
                let controller = LoginViewController()
                let nav = UINavigationController(rootViewController: controller)
                self?.navigationController?.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    private let logo: UIImageView = {
        let logo = UIImageView()
        logo.image = imageNamed("Defaulthead")
        logo.isUserInteractionEnabled = true
        logo.layer.cornerRadius = 31.0
        logo.layer.masksToBounds = true
        return logo
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "登录/注册"
        label.font = systemFontSize(fontSize: 25)
        label.textColor = UIColor(hexString: "#424242")
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let accountLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 13)
        label.textColor = UIColor(hexString: "#333333")
        return label
    }()
    
    private let newButton: UIButton = {
        let button = UIButton()
        button.setImage(imageNamed("news"), for: .normal)
        return button
    }()
    
    private func onLogin() {
        let controller = LoginViewController()
        controller.fd_interactivePopDisabled = true
        let nav = UINavigationController(rootViewController: controller)
        navigationController?.present(nav, animated: true, completion: nil)
    }
    

    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NormalCenterCell", for: indexPath) as? NormalCenterCell  {
            switch indexPath.row {
            case 0:
                cell.title = "我的积分"
                cell.imageName = "my-integral"
            case 1:
                cell.title = "优惠券"
                cell.imageName = "my-Coupon"
            case 2:
                cell.title = "设置"
                cell.imageName = "my-Setup"
            case 3:
                cell.title = "关于我们"
                cell.imageName = "my-about"
            default:
                break
            }
            cell.onClickCell = { [weak self]  in
                if indexPath.row == 0 {
                    let controller = LotteryViewController()
                    controller.hidesBottomBarWhenPushed = true
                    self?.navigationController?.pushViewController(controller, animated: true)
                }
                else if indexPath.row == 1 {
                    
                } else if indexPath.row == 2 {
                    if LoginState.shared.hasLogin.value {
                        let controller = AccountSafeViewController()
                        controller.hidesBottomBarWhenPushed = true
                        self?.navigationController?.pushViewController(controller, animated: true)
                    } else {
                        self?.onLogin()
                    }
                } else {
                    let controller = AboutAppViewController()
                    controller.hidesBottomBarWhenPushed = true
                    self?.navigationController?.pushViewController(controller, animated: true)
                }
            }
            return cell
        }
        return UITableViewCell()
    }
}
