//
//  DetailCouponViewController.swift
//  Labeauty
//
//  Created by 宋昌鹏 on 2019/5/1.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation

class DetailCouponViewController: BaseViewController {
    let model: Coupon
    init(_ model: Coupon) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = localizedString("Mycoupon")
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.bottom.right.equalToSuperview()
        }
        scrollView.contentSize = CGSize(width: 0, height: 667)
        scrollView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.width.equalTo(303)
            make.height.equalTo(495)
            make.top.equalToSuperview().offset(34)
            make.centerX.equalToSuperview()
        }
        scrollView.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(bgView.snp.top).offset(15)
            make.height.width.equalTo(30)
        }
        bgView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(34)
        }
        nameLabel.text = model.name
        bgView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(54)
            make.centerX.equalToSuperview()
        }
        bgView.addSubview(unitLabel)
        unitLabel.snp.makeConstraints { make in
            make.left.equalTo(priceLabel.snp.right).offset(10)
            make.bottom.equalTo(priceLabel).offset(-20)
            make.height.width.equalTo(28)
        }
        if model.reduceRule == .VALUE {
            priceLabel.text = "\(model.reduceValue)"
            unitLabel.text = "元"
        } else {
            let str = changeReduceDiscount(model.reduceDiscount)
            priceLabel.text =  str
            unitLabel.text = "折"
        }
        bgView.addSubview(typeLabel)
        typeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(priceLabel.snp.bottom).offset(20)
        }
        bgView.addSubview(descLabel)
        descLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(typeLabel.snp.bottom).offset(15)
        }
        descLabel.text = model.desc
        bgView.addSubview(container)
        container.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-33)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(109)
        }
        bgView.addSubview(second_note)
        second_note.snp.makeConstraints { make in
            make.bottom.equalTo(container.snp.top).offset(10)
            make.right.equalTo(container.snp.centerX).offset(-2)
            make.width.height.equalTo(20)
        }
        bgView.addSubview(first_note)
        first_note.snp.makeConstraints { make in
            make.right.equalTo(second_note.snp.left).offset(-2)
            make.top.equalTo(second_note)
            make.width.height.equalTo(20)
        }
        bgView.addSubview(third_note)
        third_note.snp.makeConstraints { make in
            make.left.equalTo(second_note.snp.right).offset(2)
            make.top.equalTo(second_note)
            make.width.height.equalTo(20)
        }
        bgView.addSubview(forth_note)
        forth_note.snp.makeConstraints { make in
            make.left.equalTo(third_note.snp.right).offset(2)
            make.top.equalTo(third_note)
            make.width.height.equalTo(20)
        }
        container.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-5)
        }
        contentLabel.text = model.instructions
    }
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        return scroll
    }()
    
    private let bgView: UIView = {
        let view = UIImageView()
        view.image = imageNamed("couponBackground")
        return view
    }()
    
    private let iconView: UIImageView = {
        let view = UIImageView()
        view.image = imageNamed("topIcon")
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 18)
        label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "DINAlternate-Bold", size: 100.0)
        return label
    }()
    
    private let unitLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PingFangSC-Regular", size: 15.47)
        label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        label.layer.cornerRadius = 14.0
        label.layer.masksToBounds = true
        label.backgroundColor = UIColor.white
        label.textAlignment = .center
        return label
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        let attributedString = NSMutableAttributedString(string: "优惠劵")
        attributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Regular", size: 36.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: 3))
        label.attributedText = attributedString
        return label
    }()
    
    private let descLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        label.font = UIFont(name: "PingFangSC-Regular", size: 15.0)
        return label
    }()
    
    private let container: UIView = {
        let style = UIView(frame: CGRect(x: 52, y: 451, width: 270, height: 109))
        style.layer.cornerRadius = 5
        style.layer.backgroundColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0).cgColor
        style.alpha = 0.7
        return style
    }()
    
    private let first_note: ReadNoteView = {
        let read = ReadNoteView(frame: .zero)
        read.title = "使"
        return read
    }()
    
    private let second_note: ReadNoteView = {
        let read = ReadNoteView(frame: .zero)
        read.title = "用"
        return read
    }()
    
    private let third_note: ReadNoteView = {
        let read = ReadNoteView(frame: .zero)
        read.title = "说"
        return read
    }()
    
    private let forth_note: ReadNoteView = {
        let read = ReadNoteView(frame: .zero)
        read.title = "明"
        return read
    }()

    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PingFangSC-Regular", size: 11.0)
        label.textColor = UIColor(red: 139.0 / 255.0, green: 139.0 / 255.0, blue: 141.0 / 255.0, alpha: 1.0)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
}

class ReadNoteView: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        image = imageNamed("readNote")
        addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    var title: String? {
        didSet {
            if let title = title {
                label.text = title
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PingFangSC-Regular", size: 11.0)
        label.textColor = UIColor.white
        return label
    }()
    
}
