//
//  LanguageViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2019/7/27.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation
import Core

class LanguageViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    var current: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        title = localizedString("language")
        view.backgroundColor = UIColor.white
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        current = currentLanguage()
    }
    
    private lazy var  tableView: UITableView = {
        let tb = UITableView.init(frame: .zero, style: .grouped)
        tb.register(LanguageCell.self, forCellReuseIdentifier: LanguageCell.description())
        tb.delegate = self
        tb.dataSource = self
        return tb
    }()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LanguageCell.description(), for: indexPath) as! LanguageCell
        if indexPath.row == 0 {
            cell.nameLabel.text = localizedString("chinese")
            if let language = getFirstLanuage(), language == "zh-Hans" {
                cell.icon.isHidden = false
            } else {
                cell.icon.isHidden = true
            }
        } else {
            cell.nameLabel.text = localizedString("japanese")
            if let language = getFirstLanuage(), language == "ja" {
                cell.icon.isHidden = false
            } else {
                cell.icon.isHidden = true
            }
        }
        return cell 
    }
    
    func currentLanguage() -> String {
        return  getFirstLanuage() ?? ""
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let willSetLanguage = indexPath.row == 0 ? "zh-Hans":"ja"
        setFirstLanguage(language: willSetLanguage)
        UIApplication.shared.windows.first?.rootViewController = Entrance.entrance()
    }
}

class LanguageCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(25)
        }
        
        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate let nameLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 15)
        label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        return label
    }()
    
    fileprivate let icon: UIImageView = {
        let icon = UIImageView()
        icon.image = imageNamed("hook")
        return icon
    }()
}
