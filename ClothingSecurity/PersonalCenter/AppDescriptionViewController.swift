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
        let firstAttributedString = NSMutableAttributedString(string: "为了净化市场，减少假冒产品给我们顾客及BEEDEE带来的负面影响和损失，维护企业的形象和声誉，增强消费者购正规商品的信心我们亲历推出本款APP，以便于每个消费者都成为打假的行家，BEEDEE作为原创品牌我们坚持创新，坚持原创，希望把不一样的设计理念传递给有所追求的你们。\n\n近年来广大消费者及许多企业饱受假冒坑害之苦，有关调查资料表明，90%以上的消费者和几乎所有名牌产品的生产企业均曾受到过假冒的侵扰。\n\n\n")
        firstAttributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFang-SC-Regular", size: 14.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 41.0 / 255.0, green: 41.0 / 255.0, blue: 41.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: firstAttributedString.length))
        let secontAttributedString = NSMutableAttributedString(string: "当前，我国的假冒有以下几个特点： \n\n")
        secontAttributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Semibold", size: 16.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: secontAttributedString.length))
        let thirdAttributedString = NSMutableAttributedString(string: "特点之一：\n")
        thirdAttributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Semibold", size: 15.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: thirdAttributedString.length))
        let forthAttributedString = NSMutableAttributedString(string: "假冒商品品种多、数量大。从生产资料到生活日用品，从内销到外贸出口，从一般到高档耐用消费者，从日常生活用品到高科技产品，假冒伪劣几乎无所不有，尤以制作利润高、销售快的假冒名烟、名酒和药品的问题最为严重。 \n\n")
        forthAttributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Regular", size: 14.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: forthAttributedString.length))
        let fifithAttributedString = NSMutableAttributedString(string: "特点之二：\n")
        fifithAttributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Semibold", size: 15.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: fifithAttributedString.length))
        let sixAttributedString = NSMutableAttributedString(string: "出现区域性“产、供、销”一条龙假冒地，违法活动更具有稳蔽性、流动性。有的地方造假已形成相当规模，有的已形成“专业村”、“集散地”、“黑窝地”，并有人提供仓库、银行帐号、代办运输等，显然是有组织的犯罪活动，具有很强的再生能力和扩散能力。由于国内打击严厉，相当一部分造假活动已发展到境内外勾结，在境外制造，通过走私偷运到国内销售，人称“走私假冒商品”。 \n\n")
        sixAttributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFang-SC-Regular", size: 14.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 41.0 / 255.0, green: 41.0 / 255.0, blue: 41.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: sixAttributedString.length))
        let sevenAttributedString = NSMutableAttributedString(string: "特点之三：\n")
        sevenAttributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Semibold", size: 15.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: sevenAttributedString.length))
        let eightAttributedString = NSMutableAttributedString(string: "假冒国外名牌的问题日益突出。\n\n")
        eightAttributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFang-SC-Regular", size: 14.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 41.0 / 255.0, green: 41.0 / 255.0, blue: 41.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: eightAttributedString.length))
        let nineAttributedString = NSMutableAttributedString(string: "特点之四：\n")
        nineAttributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Semibold", size: 15.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: nineAttributedString.length))
        let tenAttributedString = NSMutableAttributedString(string: "重大的恶性案件增多，违法数额攀升。假冒伪劣品对消费者及生产厂家的危害主要表现为：侵害名牌商标形象，真假难辨使消费者和用户望而生畏；严重影响名牌企业的经济效益；严重败坏出口商品的信誉，对我国国际贸易造成不良的影响；名牌产品被挤出了市场，使企业面监停产、甚至陷入破产倒闭的窘境等。因此，广大消费者和企业应增强自我保护意识，在打击假冒，保卫名牌活动中奋起自卫。")
        tenAttributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFang-SC-Regular", size: 14.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 41.0 / 255.0, green: 41.0 / 255.0, blue: 41.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: tenAttributedString.length))
        
        firstAttributedString.append(secontAttributedString)
        firstAttributedString.append(thirdAttributedString)
        firstAttributedString.append(forthAttributedString)
        firstAttributedString.append(fifithAttributedString)
        firstAttributedString.append(sixAttributedString)
        firstAttributedString.append(sevenAttributedString)
        firstAttributedString.append(eightAttributedString)
        firstAttributedString.append(nineAttributedString)
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
