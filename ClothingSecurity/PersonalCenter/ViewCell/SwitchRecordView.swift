//
//  SwitchRecordView.swift
//  Labeauty
//
//  Created by 宋昌鹏 on 2019/4/27.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation

class GiftRecordView: SwitchRecordView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        container.snp.updateConstraints { make in
            make.top.equalToSuperview()
        }
        setTipView(true)
        firstButton.setTitle(localizedString("coupon"), for: .normal)
        firstButton.setTitle(localizedString("coupon"), for: .selected)
        secondButton.setTitle(localizedString("TrueObject"), for: .normal)
        secondButton.setTitle(localizedString("TrueObject"), for: .selected)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SwitchRecordView: UIView {
    var onClickRecordView: ((Int) -> Void)?
    var onSign: (() -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.bottom.right.equalToSuperview()
        }
        addSubview(tipView)
        tipView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalTo(135)
            make.centerX.equalToSuperview()
        }
        tipView.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        container.addSubview(firstButton)
        container.addSubview(secondButton)
        let buttonWidth = (ScreenWidth - 30)/2
        firstButton.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(buttonWidth)
        }
        secondButton.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.width.equalTo(buttonWidth)
        }
        container.addSubview(selectLine_1)
        container.addSubview(selectLine_2)
        selectLine_1.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-1)
            make.centerX.equalTo(firstButton.snp.centerX)
            make.width.equalTo(65)
            make.height.equalTo(4)
        }
        selectLine_2.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-1)
            make.centerX.equalTo(secondButton.snp.centerX)
            make.width.equalTo(65)
            make.height.equalTo(4)
        }
        container.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(1)
        }
        configState(0)
        firstButton.addTarget(self, action: #selector(click(_ :)), for: .touchUpInside)
        secondButton.addTarget(self, action: #selector(click(_ :)), for: .touchUpInside)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickSign))
        tipView.addGestureRecognizer(tap)
    }
    
    @objc private func clickSign() {
        onSign?()
    }
    
    @objc private func click(_ sender: UIButton) {
        configState(sender.tag)
        onClickRecordView?(sender.tag)
    }
    
    func setTipView(_ hide: Bool) {
        tipView.isHidden = hide
    }
    
    func configState(_ tag: Int) {
        if tag == 0 {
            firstButton.isSelected = true
            selectLine_1.isHidden = false
            secondButton.isSelected = false
            selectLine_2.isHidden = true
        } else {
            firstButton.isSelected = false
            selectLine_1.isHidden = true
            secondButton.isSelected = true
            selectLine_2.isHidden = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let firstButton: UIButton = {
        let button = UIButton()
        button.setTitle(localizedString("pointsRecord"), for: .normal)
        button.setTitle(localizedString("pointsRecord"), for: .selected)
        button.setTitleColor(UIColor(red: 176/255.0, green: 205/255.0, blue: 232/255.0, alpha: 1), for: .selected)
        button.setTitleColor(UIColor(red: 34/255.0, green: 34/255.0, blue: 34/255.0, alpha: 1), for: .normal)
        button.titleLabel?.font = systemFontSize(fontSize: 18)
        button.tag = 0
        return button
    }()
    
    let secondButton: UIButton = {
        let button = UIButton()
        button.setTitle(localizedString("pointsConsume"), for: .normal)
        button.setTitle(localizedString("pointsConsume"), for: .selected)
        button.setTitleColor(UIColor(red: 176/255.0, green: 205/255.0, blue: 232/255.0, alpha: 1), for: .selected)
        button.setTitleColor(UIColor(red: 34/255.0, green: 34/255.0, blue: 34/255.0, alpha: 1), for: .normal)
        button.titleLabel?.font = systemFontSize(fontSize: 18)
        button.tag = 1
        return button
    }()
    
    private let tipView: UIView = {
        let style = UIView()
        style.layer.cornerRadius = 10
        style.layer.backgroundColor = UIColor(red: 180.0 / 255.0, green: 195.0 / 255.0, blue: 228.0 / 255.0, alpha: 1.0).cgColor
        style.alpha = 0.6
        style.isUserInteractionEnabled = true
        return style
    }()
    
    private let tipLabel: UILabel = {
        let label = UILabel()
        let title = localizedString("firstLogin")
        let attributedString = NSMutableAttributedString(string: title)
         attributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Regular", size: 10.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
         ], range: NSRange(location: 0, length: title.length))
        label.attributedText = attributedString
        return label
    }()
    
    let container: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    private let selectLine_1: UIView = {
        let style = UIView(frame: CGRect(x: 69, y: 223, width: 65, height: 4))
        style.layer.cornerRadius = 2
        style.layer.backgroundColor = UIColor(red: 176.0 / 255.0, green: 205.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0).cgColor
        style.alpha = 1
        return style
    }()
    
    private let selectLine_2: UIView = {
        let style = UIView(frame: CGRect(x: 69, y: 223, width: 65, height: 4))
        style.layer.cornerRadius = 2
        style.layer.backgroundColor = UIColor(red: 176.0 / 255.0, green: 205.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0).cgColor
        style.alpha = 1
        return style
    }()
    
    private let line: UIView = {
        let style = UIView()
        style.layer.backgroundColor = UIColor(red: 239.0 / 255.0, green: 239.0 / 255.0, blue: 239.0 / 255.0, alpha: 1.0).cgColor
        style.alpha = 1
        return style
    }()
}
