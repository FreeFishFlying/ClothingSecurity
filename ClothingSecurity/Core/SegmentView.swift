//
//  SegmentView.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/11.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Core
import UIKit

class SegmentView: UIView {
    var titles: [String]
    let width: CGFloat
    let height: CGFloat
    var bottomView = UIView()
    var defaultIndex: Int = 0
    var defaultTextColor: UIColor = UIColor(hexString: "#666666")
    var selectedTextColor: UIColor = UIColor(hexString: "#333333")
    var lineColor: UIColor = UIColor.black
    var isDefaultLineWidth = true
    var lineWidth: CGFloat = 50
    var isDisplaySeperatorLine = false
    var seperatorLineWidth: CGFloat = 1
    var seperatorLineColor: UIColor = UIColor(red: 239 / 255.0, green: 239 / 255.0, blue: 239 / 255.0, alpha: 1.0)
    var textFont: UIFont? = UIFont(name: "PingFang-SC-Bold", size: 16.0)
    
    public var selectSegment: ((_ index: Int) -> Void)?
    
    public var isSlideBottom: Bool = true
    
    init(frame: CGRect, titles: [String]) {
        self.titles = titles
        width = frame.size.width / CGFloat(titles.count)
        height = frame.size.height - 2
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configTitles(titles: titles)
    }
    
    private func configTitles(titles: [String]) {
        lineWidth = isDefaultLineWidth ? 50 : frame.size.width / CGFloat(titles.count)
        for i in 0 ..< titles.count {
            let button = UIButton()
            button.tag = 1000 + i
            button.setTitle(titles[i], for: .normal)
            if i == defaultIndex {
                button.setTitleColor(selectedTextColor, for: .normal)
            } else {
                button.setTitleColor(defaultTextColor, for: .normal)
            }
            button.titleLabel?.font = textFont
            button.frame = CGRect(x: CGFloat(i) * width, y: 0, width: width, height: height)
            button.addTarget(self, action: #selector(onButtonClick(button:)), for: .touchUpInside)
            addSubview(button)
            let badge = BadgeView()
            badge.minBadgeSize = CGSize(width: 20, height: 20)
            badge.badgeColor = UIColor.clear
            badge.textColor = UIColor.black
            badge.font = systemFontSize(fontSize: 13)
            badge.tag = 100 + i
            addSubview(badge)
            badge.frame = CGRect(x: button.frame.origin.x + button.frame.size.width - 12.0, y: (height - 20) / 2.0, width: 20, height: 20)
            badge.isHidden = true
        }
        
        bottomView.frame = CGRect(x: (width - lineWidth) / 2, y: height, width: lineWidth, height: 2)
        bottomView.backgroundColor = lineColor
        addSubview(bottomView)
        
        if isDisplaySeperatorLine {
            configSeperatorLine()
        }
    }
    
    func configSeperatorLine() {
        let padding: CGFloat = 12
        for i in 1 ..< titles.count {
            let line = UIView(frame: CGRect(x: width * CGFloat(i) - seperatorLineWidth / 2.0, y: padding, width: seperatorLineWidth, height: self.frame.size.height - padding * 2.0))
            line.backgroundColor = seperatorLineColor
            addSubview(line)
        }
    }
    
    var badgeTitles: [Int]? {
        didSet {
            if let titles = badgeTitles {
                for (index, title) in titles.enumerated() {
                    if let badgeView: BadgeView = self.subviews.filter({ $0.isKind(of: BadgeView.self) && $0.tag == 100 + index }).first as? BadgeView {
                        if title > 0 {
                            badgeView.isHidden = false
                            if title <= 99 {
                                badgeView.text = "\(title)"
                            } else {
                                badgeView.text = "99+"
                            }
                            let frame = badgeView.frame
                            if title > 9 {
                                let rect = CGRect(x: frame.origin.x, y: frame.origin.y, width: 28, height: 20)
                                badgeView.frame = rect
                                badgeView.adjustsFontSizeToFitWidth = true
                                
                            } else {
                                let rect = CGRect(x: frame.origin.x, y: frame.origin.y, width: 20, height: 20)
                                badgeView.frame = rect
                            }
                        } else {
                            badgeView.isHidden = true
                        }
                    }
                }
            }
        }
    }
    
    @objc private func onButtonClick(button: UIButton) {
        selectTheSegment(index: button.tag - 1000, animation: true)
    }
    
    public func selectTheSegment(index: Int, animation: Bool) {
        selectSegment?(index)
        if !isSlideBottom {
            return
        }
        var buttons = [UIButton]()
        self.subviews.forEach { view in
            if let button = view as? UIButton {
                buttons.append(button)
            }
        }
        buttons.forEach { $0.setTitleColor(defaultTextColor, for: .normal) }
        buttons[safe: index]?.setTitleColor(selectedTextColor, for: .normal)
        
        if animation {
            UIView.animate(withDuration: 0.2, animations: {
                self.bottomView.frame = CGRect(x: CGFloat(index) * self.width + (self.width - self.lineWidth) / 2, y: self.height, width: self.lineWidth, height: 2)
            })
        } else {
            bottomView.frame = CGRect(x: CGFloat(index) * width + (width - lineWidth) / 2, y: height, width: lineWidth, height: 2)
        }
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
