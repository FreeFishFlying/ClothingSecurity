//
//  AppDescriptionViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/14.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit

class AppDescriptionViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = localizedString("APPDescription")
        configUI()
    }
    
    private func configUI() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.bottom.right.equalToSuperview()
            make.width.equalTo(ScreenWidth)
        }
        scrollView.addSubview(logoTopImage)
        logoTopImage.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top).offset(42)
            make.left.equalToSuperview().offset(15)
        }
        scrollView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(logoTopImage.snp.bottom).offset(35)
            make.left.equalToSuperview().offset(15)
            make.width.equalTo(ScreenWidth - 38)
            make.bottom.equalTo(scrollView.snp.bottom).offset(-30)
        }
        configContentLabel()
    }
    
    private func configContentLabel() {
        let firstAttributedString = NSMutableAttributedString(string: localizedString("appIntroduce"))
        firstAttributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFang-SC-Regular", size: 14.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 41.0 / 255.0, green: 41.0 / 255.0, blue: 41.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: firstAttributedString.length))
        let secontAttributedString = NSMutableAttributedString(string: localizedString("trait"))
        secontAttributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Semibold", size: 16.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: secontAttributedString.length))
        let forthAttributedString = NSMutableAttributedString(string: localizedString("firstTrait"))
        forthAttributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Regular", size: 14.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: forthAttributedString.length))
        let sixAttributedString = NSMutableAttributedString(string: localizedString("secondTrait"))
        sixAttributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFang-SC-Regular", size: 14.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 41.0 / 255.0, green: 41.0 / 255.0, blue: 41.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: sixAttributedString.length))
        let eightAttributedString = NSMutableAttributedString(string: localizedString("thirdTrait"))
        eightAttributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFang-SC-Regular", size: 14.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 41.0 / 255.0, green: 41.0 / 255.0, blue: 41.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: eightAttributedString.length))
        let nightAttributedString = NSMutableAttributedString(string: localizedString("forthTrait"))
        nightAttributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFang-SC-Regular", size: 14.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 41.0 / 255.0, green: 41.0 / 255.0, blue: 41.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: nightAttributedString.length))
        let tenAttributedString = NSMutableAttributedString(string: localizedString("fifthTrait"))
        tenAttributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFang-SC-Regular", size: 14.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 41.0 / 255.0, green: 41.0 / 255.0, blue: 41.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: tenAttributedString.length))
        firstAttributedString.append(secontAttributedString)
        firstAttributedString.append(forthAttributedString)
        firstAttributedString.append(sixAttributedString)
        firstAttributedString.append(eightAttributedString)
        firstAttributedString.append(nightAttributedString)
        firstAttributedString.append(tenAttributedString)
        contentLabel.attributedText = firstAttributedString
        view.layoutIfNeeded()
    }
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = UIColor.clear
        scroll.isScrollEnabled = true
        return scroll
    }()
    
    private let logoTopImage: UIImageView = {
        let logo = UIImageView()
        logo.image = imageNamed("logo")
        return logo
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.clipsToBounds = true
        return label
    }()
}
