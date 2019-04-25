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
        title = "APP说明"
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
        let firstAttributedString = NSMutableAttributedString(string: "为了净化市场，减少假冒产品给我们顾客及LABEAUTY带来的负面影响和损失，维护企业和ANCILA品牌的形象和声誉，增强消费者购正规商品的信心，我们亲历推出本款APP。\n\n\n")
        firstAttributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFang-SC-Regular", size: 14.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 41.0 / 255.0, green: 41.0 / 255.0, blue: 41.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: firstAttributedString.length))
        let secontAttributedString = NSMutableAttributedString(string: "App特点： \n\n")
        secontAttributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Semibold", size: 16.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: secontAttributedString.length))
        let thirdAttributedString = NSMutableAttributedString(string: "1、")
        thirdAttributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Semibold", size: 15.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: thirdAttributedString.length))
        let forthAttributedString = NSMutableAttributedString(string: "扫描商品二维码，快速检验真伪。 \n\n")
        forthAttributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Regular", size: 14.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: forthAttributedString.length))
        let fifithAttributedString = NSMutableAttributedString(string: "2、")
        fifithAttributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Semibold", size: 15.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: fifithAttributedString.length))
        let sixAttributedString = NSMutableAttributedString(string: "完整展示labeauty产品，加深顾客对正品印象。 \n\n")
        sixAttributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFang-SC-Regular", size: 14.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 41.0 / 255.0, green: 41.0 / 255.0, blue: 41.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: sixAttributedString.length))
        let sevenAttributedString = NSMutableAttributedString(string: "3‘")
        sevenAttributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Semibold", size: 15.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: sevenAttributedString.length))
        let eightAttributedString = NSMutableAttributedString(string: "专业的防伪溯源技术保障，专业技术团队。\n\n")
        eightAttributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFang-SC-Regular", size: 14.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 41.0 / 255.0, green: 41.0 / 255.0, blue: 41.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: eightAttributedString.length))
        
        firstAttributedString.append(secontAttributedString)
        firstAttributedString.append(thirdAttributedString)
        firstAttributedString.append(forthAttributedString)
        firstAttributedString.append(fifithAttributedString)
        firstAttributedString.append(sixAttributedString)
        firstAttributedString.append(sevenAttributedString)
        firstAttributedString.append(eightAttributedString)
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
