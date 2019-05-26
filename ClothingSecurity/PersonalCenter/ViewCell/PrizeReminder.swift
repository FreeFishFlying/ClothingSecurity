//
//  PrizeReminder.swift
//  Labeauty
//
//  Created by 宋昌鹏 on 2019/4/29.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation

class PrizeReminder: UIView {
    var onGiftButtonClick: ((Prize, prizeLog) -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
        backgroundColor = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.8)
        addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(164)
            make.centerX.equalToSuperview()
            make.width.equalTo(275)
            make.height.equalTo(242)
        }
        container.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(18)
        }
        container.addSubview(button)
        button.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-18)
            make.width.equalTo(240)
            make.height.equalTo(40)
        }
        container.addSubview(prizeContentView)
        prizeContentView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.bottom.equalTo(button.snp.top)
            make.left.right.equalToSuperview()
        }
        prizeContentView.addSubview(prizeImage)
        prizeContentView.addSubview(prizeTitle)
        prizeContentView.addSubview(titleLabel)
        prizeContentView.addSubview(tipLabel)
        addSubview(line)
        line.snp.makeConstraints { make in
            make.top.equalTo(container.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalTo(56)
            make.width.equalTo(2)
        }
        addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(line.snp.bottom)
            make.height.width.equalTo(32)
        }
        button.addTarget(self, action: #selector(onButtonClick), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(onDeleteButtonClick), for: .touchUpInside)
    }
    
    @objc private func onButtonClick() {
        if let model = model, let log = log {
            onGiftButtonClick?(model, log)
            removeFromSuperview()
        }
    }
    
    @objc private func onDeleteButtonClick() {
        removeFromSuperview()
    }
    
    func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    var log: prizeLog?
    
    var model: Prize? {
        didSet {
            if let model = model {
                if model.targetType == .empty {
                    titleLabel.text = "很遗憾，未中奖！"
                    prizeImage.image = imageNamed("Noprize")
                    tipLabel.text = "继续努力，总能成为那个幸运儿的"
                    button.setTitle("继续抽奖", for: .normal)
                } else if model.targetType == .gift {
                    titleLabel.text = "恭喜您，中奖了！"
                    if let url = URL(string: model.thumb) {
                        prizeImage.kf.setImage(with: url)
                    }
                    prizeTitle.text = model.name
                    tipLabel.text = "中奖礼物请尽快填写地址哦"
                    button.setTitle("立即提货", for: .normal)
                } else if model.targetType == .coupon {
                    titleLabel.text = "恭喜您，中奖了！"
                    if let url = URL(string: model.thumb) {
                        prizeImage.kf.setImage(with: url)
                    }
                    tipLabel.text = "优惠券请在规定的时间内使用，过期无效"
                    button.setTitle("点击领取", for: .normal)
                } else if model.targetType == .point {
                    titleLabel.text = "恭喜您，中奖了！"
                    if let url = URL(string: model.thumb) {
                        prizeImage.kf.setImage(with: url)
                    }
                    tipLabel.text = "积分已存入您的账户"
                }
                configUIWithState(model.targetType)
            }
        }
    }
    
    private func configUIWithState(_ state: TargetType) {
        if state == .empty {
            prizeImage.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.width.equalTo(67)
                make.height.equalTo(54)
                make.top.equalToSuperview().offset(30)
            }
        } else if state == .gift {
            prizeImage.snp.makeConstraints { make in
                make.width.equalTo(97)
                make.height.equalTo(81)
                make.top.equalToSuperview().offset(7)
                make.centerX.equalToSuperview()
            }
            prizeTitle.snp.makeConstraints { make in
                make.top.equalTo(prizeImage.snp.bottom).offset(1)
                make.centerX.equalToSuperview()
            }
        } else if state == .coupon || state == .point {
            prizeImage.snp.makeConstraints { make in
                make.width.equalTo(148)
                make.height.equalTo(63)
                make.top.equalToSuperview().offset(24)
                make.centerX.equalToSuperview()
            }
        }
        tipLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let container: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5.0
        view.layer.masksToBounds = true
        view.layer.backgroundColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0).cgColor
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 18)
        label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        return label
    }()
    
    private let prizeContentView: UIView = {
        let contentView = UIView()
        return contentView
    }()
    
    private let prizeImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let prizeTitle: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 10)
        label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        return label
    }()
    
    private let tipLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 10)
        label.textColor = UIColor(red: 139.0 / 255.0, green: 139.0 / 255.0, blue: 141.0 / 255.0, alpha: 1.0)
        return label
    }()
    
    private let button: DarkKeyButton = {
        let button = DarkKeyButton(title: "")
        button.layer.cornerRadius = 20.0
        button.layer.masksToBounds = true
        return button
    }()
    
    private let line: UIView = {
        let style = UIView()
        style.backgroundColor = UIColor(red: 153.0 / 255.0, green: 153.0 / 255.0, blue: 153.0 / 255.0, alpha: 1.0)
        style.alpha = 1
        return style
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(imageNamed("ic_creat_class_close"), for: .normal)
        button.hitTestEdgeInsets = UIEdgeInsets(top: -5, left: -5, bottom: -5, right: -5)
        return button
    }()
}
