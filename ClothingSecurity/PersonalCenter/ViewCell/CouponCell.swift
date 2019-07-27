//
//  CouponCell.swift
//  Labeauty
//
//  Created by 宋昌鹏 on 2019/5/1.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation

class CouponCell: UITableViewCell {
    var onCouponClick: ((Coupon) -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clear
        selectionStyle = .none
        addSubview(container)
        container.addSubview(subContainer)
        container.addSubview(seperateView)
        container.addSubview(useView)
        container.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview()
        }
        useView.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.width.equalTo(98)
        }
        seperateView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.right.equalTo(useView.snp.left)
            make.height.equalTo(84)
            make.width.equalTo(19)
        }
        subContainer.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.right.equalTo(seperateView.snp.left)
        }
        configSubContainer()
        configUseView()
    }
    
    private func configSubContainer() {
        subContainer.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(14)
        }
        subContainer.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(80)
            make.top.equalToSuperview().offset(10)
        }
        subContainer.addSubview(descLabel)
        descLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(80)
            make.top.equalToSuperview().offset(36)
        }
        subContainer.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(80)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    private func configUseView() {
        useView.addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(82)
            make.height.equalTo(25)
        }
        button.addTarget(self, action: #selector(onClick), for: .touchUpInside)
    }
    
    @objc private func onClick() {
        if let model = model {
            onCouponClick?(model )
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var model: Coupon? {
        didSet {
            if let model = model {
                setBackgroundStyle(model.reduceRule)
                if model.reduceRule == .VALUE {
                    let price = "￥\(model.reduceValue)"
                    let attributedString = NSMutableAttributedString(string: price)
                    attributedString.addAttributes([
                        NSAttributedString.Key.font: UIFont(name: "PingFangSC-Regular", size: 11.0)!,
                        NSAttributedString.Key.foregroundColor:UIColor(red: 176.0 / 255.0, green: 205.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0)
                        ], range: NSRange(location: 0, length: 1))
                    attributedString.addAttributes([
                        NSAttributedString.Key.font: UIFont(name: "DINAlternate-Bold", size: 30.0)!,
                        NSAttributedString.Key.foregroundColor:UIColor(red: 176.0 / 255.0, green: 205.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0)
                        ], range: NSRange(location: 1, length: price.length-1))
                    priceLabel.attributedText = attributedString
                } else {
                    let count = "\(changeReduceDiscount(model.reduceDiscount))折"
                    let attributedString = NSMutableAttributedString(string: count)
                    attributedString.addAttributes([
                        NSAttributedString.Key.font: UIFont(name: "DINAlternate-Bold", size: 30.0)!,
                        NSAttributedString.Key.foregroundColor:UIColor(red: 176.0 / 255.0, green: 205.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0)
                        ], range: NSRange(location: 0, length: count.length-1))
                    attributedString.addAttributes([
                        NSAttributedString.Key.font: UIFont(name: "PingFangSC-Regular", size: 11.0)!,
                        NSAttributedString.Key.foregroundColor:UIColor(red: 176.0 / 255.0, green: 205.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0)
                        ], range: NSRange(location: count.length-1, length: 1))
                    priceLabel.attributedText = attributedString
                }
                nameLabel.text = model.name
                descLabel.text = model.desc
                let start = changeTimeStamp(model.beginTime, false)
                let end = changeTimeStamp(model.endTime, false)
                timeLabel.text = start + "-" + end
            }
        }
    }
    
    private func setBackgroundStyle(_ type: ReduceRule) {
        if type == .VALUE {
            useView.backgroundColor = UIColor.white
            subContainer.backgroundColor = UIColor.white
            seperateView.image = imageNamed("whiteSeperate")
        } else {
            useView.backgroundColor = UIColor(red: 226.0 / 255.0, green: 235.0 / 255.0, blue: 242.0 / 255.0, alpha: 1.0)
            subContainer.backgroundColor = UIColor(red: 226.0 / 255.0, green: 235.0 / 255.0, blue: 242.0 / 255.0, alpha: 1.0)
            seperateView.image = imageNamed("blueSeperate")
        }
    }
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 13)
        label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let descLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 10)
        label.textColor = UIColor(red: 165.0 / 255.0, green: 165.0 / 255.0, blue: 165.0 / 255.0, alpha: 1.0)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 12)
        label.textColor = UIColor(red: 165.0 / 255.0, green: 165.0 / 255.0, blue: 165.0 / 255.0, alpha: 1.0)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let button: DarkKeyButton = {
        let button = DarkKeyButton(title: localizedString("immediateUse"))
        button.layer.cornerRadius = 12.5
        button.layer.masksToBounds = true
        button.titleLabel?.font = systemFontSize(fontSize: 12)
        return button
    }()
    
    private let container: UIView = {
        let view = UIView()
        return view
    }()
    
    private let subContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private let seperateView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private let useView: UIView = {
        let view = UIView()
        return view
    }()
}
