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
        title = localizedString("brandIntroduce")
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
        label.font = systemFontSize(fontSize: 15)
        label.numberOfLines = 0
        return label
    }()
    
    private let content = localizedString("productionStory")
}
