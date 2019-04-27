//
//  CommonUtil.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/11.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Core

class TimerProxy {
    
    var timer: Timer!
    var timerHandler: (() -> Void)?
    
    init(withInterval interval: TimeInterval, repeats: Bool, timerHandler: (() -> Void)?) {
        self.timerHandler = timerHandler
        timer = Timer.scheduledTimer(timeInterval: interval,
                                     target: self,
                                     selector: #selector(timerDidFire(_:)),
                                     userInfo: nil,
                                     repeats: repeats)
    }
    
    @objc func timerDidFire(_: Timer) {
        timerHandler?()
    }
    
    func invalidate() {
        timer.invalidate()
    }
}

extension UIBarButtonItem {
    convenience init(image: UIImage?, higlightedImage: UIImage?, target: Any, action: Selector) {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 48, height: 28)
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -28)
        button.hitTestEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -28)
        button.setImage(higlightedImage, for: .highlighted)
        button.addTarget(target, action: action, for: .touchUpInside)
        self.init(customView: button)
    }
    
    convenience init(whiteTitle: String, target: Any, action: Selector) {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 48, height: 28)
        button.setTitle(whiteTitle, for: .normal)
        button.titleLabel?.font = systemFontSize(fontSize: 15)
        button.setTitleColor(UIColor(red: 50.0 / 255.0, green: 50.0 / 255.0, blue: 52.0 / 255.0, alpha: 1.0), for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        self.init(customView: button)
    }
}

class DarkKeyButton: UIButton {
    init(title: String) {
        super.init(frame: .zero)
        setBackgroundImage(imageNamed("Loginbutton"), for: .normal)
        setTitleColor(UIColor(hexString: "#ffffff"), for: .normal)
        layer.cornerRadius = 22
        layer.masksToBounds = true
        setTitle(title, for: .normal)
        showsTouchWhenHighlighted = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HeaderCellButton: UIButton {
    init(_ title: String) {
        super.init(frame: .zero)
        backgroundColor = UIColor.clear
        setTitleColor(UIColor(hexString: "#323333"), for: .normal)
        setTitle(title, for: .normal)
        titleLabel?.font = UIFont(name: "PingFangSC-Semibold", size: 19.0)
        setImage(imageNamed("icon_right"), for: .normal)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 10)
        imageEdgeInsets = UIEdgeInsets(top: 0, left: 95, bottom: 0, right: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DefaultBackButton: UIButton {
     init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 55, height: 44))
        setImage(imageNamed("ic_app_back_nor")?.withRenderingMode(.alwaysOriginal) ?? UIImage(), for: .normal)
        setTitle("返回", for: .normal)
        setTitleColor(UIColor.black, for: .normal)
        titleLabel?.font = systemFontSize(fontSize: 15)
        imageEdgeInsets = UIEdgeInsets(top: 6, left: -5, bottom: 6, right: 30)
        titleEdgeInsets = UIEdgeInsets(top: 6, left: -8, bottom: 6, right: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func getTextHeigh(textStr: String, font: UIFont, width: CGFloat) -> CGFloat {
    let normalText: String = textStr
    let size = CGSize(width: width, height: 200)
    let dic = [NSAttributedString.Key.font: font]
    let stringSize = normalText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic, context:nil).size
    return stringSize.height
}
