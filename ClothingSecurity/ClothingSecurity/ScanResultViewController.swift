//
//  ScanResultViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2019/5/5.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation

class ScanResultViewController: BaseViewController {
    let response: CommodityResponseData
    init(_ response: CommodityResponseData) {
        self.response = response
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = localizedString("testResult")
        view.addSubview(inspectView)
        inspectView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(128)
        }
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(inspectView.snp.bottom).offset(35)
        }
        view.addSubview(firstIcon)
        firstIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(nameLabel.snp.bottom).offset(24)
            make.width.equalTo(4)
            make.height.equalTo(15)
        }
        view.addSubview(firstTitleLabel)
        firstTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(firstIcon)
            make.left.equalTo(firstIcon.snp.right).offset(13)
        }
        view.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalTo(firstTitleLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(28)
            make.right.equalToSuperview().offset(-15)
        }
        for i in 0...response.arrs.count-1 {
            let label = UILabel()
            label.font = systemFontSize(fontSize: 14)
            label.textColor = UIColor(red: 53.0 / 255.0, green: 53.0 / 255.0, blue: 53.0 / 255.0, alpha: 1.0)
            container.addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalToSuperview()
                make.top.equalToSuperview().offset(i*24)
                if i == response.arrs.count-1 {
                    make.bottom.equalToSuperview().offset(-15)
                }
            }
            let att = response.arrs[i]
            label.text = "\(att.key): \(att.value)"
        }
        view.addSubview(secondIcon)
        secondIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(container.snp.bottom).offset(24)
            make.width.equalTo(4)
            make.height.equalTo(15)
        }
        view.addSubview(secondTitleLabel)
        secondTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(secondIcon)
            make.left.equalTo(secondIcon.snp.right).offset(13)
        }
        let label = UILabel()
        label.font = systemFontSize(fontSize: 14)
        label.textColor = UIColor(red: 53.0 / 255.0, green: 53.0 / 255.0, blue: 53.0 / 255.0, alpha: 1.0)
        view.addSubview(label)
        label.text = response.agency?.intro
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(29)
            make.top.equalTo(secondTitleLabel.snp.bottom).offset(15)
            make.right.equalToSuperview().offset(-15)
        }
    }
    
    
    private let container: UIView = {
        let view = UIView()
        return view
    }()
    
    private let inspectView: UIImageView = {
        let view = UIImageView()
        view.image = imageNamed("inspect-top")
        view.contentMode = UIView.ContentMode.scaleAspectFill
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        let attributedString = NSMutableAttributedString(string: "货物追踪查询")
        attributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Semibold", size: 17.5)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: 6))
        label.attributedText = attributedString
        return label
    }()
    
    private let firstIcon: UIView = {
        let style = UIView()
        style.layer.backgroundColor = UIColor(red: 176.0 / 255.0, green: 205.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0).cgColor
        style.alpha = 1
        return style
    }()
    
    private let firstTitleLabel: UILabel = {
        let label = UILabel()
        let attributedString = NSMutableAttributedString(string: "产品溯源")
        attributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Regular", size: 14.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: 4))
        label.attributedText = attributedString
        return label
    }()
    
    private let secondIcon: UIView = {
        let style = UIView()
        style.layer.backgroundColor = UIColor(red: 176.0 / 255.0, green: 205.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0).cgColor
        style.alpha = 1
        return style
    }()
    
    private let secondTitleLabel: UILabel = {
        let label = UILabel()
        let attributedString = NSMutableAttributedString(string: "代理商信息")
        attributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Regular", size: 14.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: 4))
        label.attributedText = attributedString
        return label
    }()
}
