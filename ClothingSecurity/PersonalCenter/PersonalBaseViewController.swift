//
//  PersonalBaseViewController.swift
//  Labeauty
//
//  Created by 宋昌鹏 on 2019/4/6.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation
import Core
import Eureka
import SnapKit
class  PersonalBaseViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        autoHideKeyboard = true
        view.backgroundColor = UIColor(hexString: "#f1f1f1")
        fd_prefersNavigationBarHidden = true
        fd_interactivePopDisabled = true
        configContainer()
        view.sendSubviewToBack(container)
        view.bringSubviewToFront(tableView)
    }
    
    public func configContainer() {
        view.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.right.equalToSuperview()
            make.height.equalTo(235)
            if #available(iOS 11, *) {
                let safeAreaTop = UIApplication.shared.keyWindow!.safeAreaInsets.top
                if safeAreaTop > 0 {
                    make.height.equalTo(235 + safeAreaTop)
                } else {
                    make.height.equalTo(235)
                }
            } else {
                make.top.equalTo(235)
            }
        }
        container.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(safeAreaTopLayoutGuide)
        }
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            if #available(iOS 11, *) {
                let safeAreaTop = UIApplication.shared.keyWindow!.safeAreaInsets.top
                if safeAreaTop > 0 {
                    make.top.equalTo(173 + safeAreaTop)
                } else {
                    make.top.equalTo(173)
                }
            } else {
                make.top.equalTo(173)
            }
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview()
        }
    }
    
    var headerTitle: String? {
        didSet {
            if let title = headerTitle {
                let attributedString = NSMutableAttributedString(string: title)
                attributedString.addAttributes([
                    NSAttributedString.Key.font: UIFont(name: "PingFangSC-Semibold", size: 18)!,
                    NSAttributedString.Key.foregroundColor:UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
                    ], range: NSRange(location: 0, length: title.length))
                headerView.attributedText = attributedString
            }
        }
    }
    
    public let container: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = true
        view.image = imageNamed("headerBack")
        return view
    }()
    
    let headerView: UILabel = {
        let lab = UILabel()
        lab.font = systemFontSize(fontSize: 17)
        lab.textColor = UIColor(hexString: "#333333")
        return lab
    }()
    
    public let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .white
        tableView.isScrollEnabled = true
        tableView.separatorColor = .clear
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 56
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.keyboardDismissMode = .onDrag
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        return tableView
    }()
}

class NormalCenterCell: UITableViewCell {
    var onClickCell: (() -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        isUserInteractionEnabled = true
        config()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(onClick))
        addGestureRecognizer(tap)
    }
    
    @objc func onClick() {
        onClickCell?()
    }
    
    var title: String? {
        didSet {
            if let title = title {
                nameLabel.text = title
            }
        }
    }
    
    var imageName: String? {
        didSet {
            if let name = imageName {
                icon.image = imageNamed(name)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func config() {
        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(15)
            make.centerY.equalToSuperview()
        }
        addSubview(nextIcon)
        nextIcon.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
        layoutIfNeeded()
    }
    
    private let icon: UIImageView = {
        let icon = UIImageView()
        return icon
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 15)
        label.textColor = UIColor(hexString: "#333333")
        return label
    }()
    
    private let nextIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = imageNamed("icon_right")
        return imageView
    }()
}
