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
        view.addSubview(logoCenterImage)
        logoCenterImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        scrollView.addSubview(logoTopImage)
        logoTopImage.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top).offset(42)
            make.left.equalToSuperview().offset(15)
        }
        scrollView.addSubview(differentLabel)
        differentLabel.snp.makeConstraints { make in
            make.top.equalTo(logoTopImage.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(15)
        }
        scrollView.addSubview(englishLabel)
        englishLabel.snp.makeConstraints { make in
            make.top.equalTo(differentLabel.snp.bottom).offset(18)
            make.left.equalToSuperview().offset(15)
        }
        englishLabel.text = englishContent
        scrollView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(englishLabel.snp.bottom).offset(40)
        }
        scrollView.addSubview(chineseLabel)
        chineseLabel.text = chineseContent
        chineseLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
        }
        scrollView.addSubview(bottomLogo)
        bottomLogo.snp.makeConstraints { make in
            make.top.equalTo(chineseLabel.snp.bottom).offset(12)
            make.right.equalTo(chineseLabel.snp.right)
        }
        scrollView.contentSize = CGSize(width: ScreenWidth, height: ScreenHeight * 1.5)
    }
    
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = UIColor.clear
        scroll.isScrollEnabled = true
        return scroll
    }()
    
    private let logoCenterImage: UIImageView = {
        let logo = UIImageView()
        logo.image = imageNamed("image_brand")
        return logo
    }()
    
    private let logoTopImage: UIImageView = {
        let logo = UIImageView()
        logo.image = imageNamed("logo")
        return logo
    }()
    
    private let differentLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 14)
        label.textColor = UIColor(hexString: "#bfbebe")
        label.text = "SOMETHING DIFFERENT"
        return label
    }()
    
    private let englishLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#666666")
        label.font = systemFontSize(fontSize: 13)
        label.numberOfLines = 0
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#000000")
        label.font = UIFont(name: "PingFangSC-Medium", size: 19.0)
        label.text = "品牌理念"
        return label
    }()
    
    private let chineseLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#666666")
        label.font = systemFontSize(fontSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private let bottomLogo: UIImageView = {
        let logo = UIImageView()
        logo.image = imageNamed("image_brand_bottom")
        return logo
    }()
    
    private let englishContent = "Pursuit the 1 % Life\nConcept There are 80% of the people in the world lead\nnormal lives.\nAnd 20 % of the people will pursuit for what they want.\nMaybe only 1 % of them made it to the end.\nLuckily,they're the ones who successed.\nHoping we can be that 1 %.\nBeeDee as an original designer brand, stick to\ninnovation, stick to originalityTo share what we want.\nWe want to pass on a different design concept to those\nof you who want it.\nThanks to the 1 %  who will always be with us."
    
    private let chineseContent = "追求1%的生活理念\n世上总有80%的人过着平凡的生活\n20%的人会去追求自己想要的生活\n或许只有1%的人坚持到最后\n幸运的是他们成功了\n希望我们成为1%的那些人\nBeeDee作为设计师原创品牌，坚持创新，坚持原创\n追求我们想要的感觉\n希望把不一样的设计理念传递给有所追求的你们\n感谢那些永远跟随我们的1%"
}
