//
//  BrandIntroduce.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/3.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
class BrandIntroduceViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "品牌介绍"
        configUI()
    }
    
    private func configUI() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.bottom.right.equalToSuperview()
            make.width.equalTo(ScreenWidth)
        }
//        view.addSubview(logoCenterImage)
//        logoCenterImage.snp.makeConstraints { make in
//            make.center.equalToSuperview()
//        }
        scrollView.addSubview(logoTopImage)
        logoTopImage.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top).offset(42)
            make.left.equalToSuperview().offset(15)
        }

        scrollView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top).offset(80)
            make.left.equalToSuperview().offset(15)
            make.width.equalTo(ScreenWidth - 38)
        }
        contentLabel.text = content
    }
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = UIColor.clear
        scroll.isScrollEnabled = true
        return scroll
    }()
    
//    private let logoCenterImage: UIImageView = {
//        let logo = UIImageView()
//        logo.image = imageNamed("image_brand")
//        return logo
//    }()
    
    private let logoTopImage: UIImageView = {
        let logo = UIImageView()
        logo.image = imageNamed("logo")
        return logo
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#666666")
        label.font = systemFontSize(fontSize: 13)
        label.numberOfLines = 0
        return label
    }()
    
    private let content = "是一个蕴含生物科技的日本美容院线专业抗衰老品牌，致力于从生物科技中探索保持青春的生物密码。隶属日本LABEAUTY公司旗下品牌。（LABEAUTY是日本一家化妆品、美容仪器公司，于2013年在日本横滨成立，以”充满自信的美丽“为宗旨，开发和销售针对各种皮肤类型，量身定制不同的高端化妆品。）\nANCILA不仅成为日本女性冻龄护肤的秘密，并于2018年成功入驻中国市场，受到了广大消费者的喜爱。品牌主打灯塔水母系列，坚持纯粹高效的护肤态度，实现了产品的深层补水和修复亮白。其中爆款水母面膜和逆时空水母胶原蛋白水乳霜逐渐在市场上有了一定影响力，受到了张韶涵、沈梦辰等明星的倾力推荐。\n以“成为高端护肤界的领先者”为企业愿景，ANCILA一直秉承“创新护肤、合理护肤”的新理念，希望把正确的护肤理念传递给有所追求的消费者。\n"
}
