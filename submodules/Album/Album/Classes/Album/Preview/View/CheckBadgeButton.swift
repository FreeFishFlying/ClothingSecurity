//
//  CheckBadgeButton.swift
//  Pods
//
//  Created by 研发部－LYC on 2019/4/17.
//

import Foundation
import Core

class CheckBadgeButton: UIButton {

    let buttonSize: CGSize
    let fontSize: CGFloat
    public init(buttonSize: CGSize = CGSize(width: 32.0, height: 32.0), fontSize: CGFloat = 14) {
        self.buttonSize = buttonSize
        self.fontSize = fontSize
        super.init(frame: CGRect(x: 0, y: 0, width: buttonSize.width, height: buttonSize.height))
        setBackgroundImage(ImageNamed("ic_camera_list_select"), for: .normal)
        addSubview(badgeView)
        badgeView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private lazy var badgeView: UILabel = {
        let badgeView = UILabel()
        badgeView.layer.masksToBounds = true
        badgeView.layer.cornerRadius = self.buttonSize.width / 2
        badgeView.backgroundColor = UIColorRGB(0xF8E71C)
        badgeView.textAlignment = .center
        badgeView.font = UIFont.systemFont(ofSize: fontSize)
        badgeView.textColor = UIColorRGB(0x222222)
        badgeView.isHidden = true
        return badgeView
    }()
    
    public func setChecked(_ checkedIndex: Int, animated: Bool) {
        let checked: Bool = checkedIndex == 0 ? false : true
        if checked {
            setBackgroundImage(nil, for: .normal)
            badgeView.isHidden = false
            badgeView.text = "\(checkedIndex)"
            if animated {
                UIView.animate(withDuration: 0.12, delay: 0, options: .curveEaseOut, animations: { () -> Void in
                    self.badgeView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                }, completion: { (_ finished: Bool) -> Void in
                    if finished {
                        UIView.animate(withDuration: 0.12, delay: 0, options: .curveEaseIn, animations: { () -> Void in
                            self.badgeView.transform = CGAffineTransform.identity
                        }, completion: { _ in })
                    }
                })
            }
        } else {
            setBackgroundImage(ImageNamed("ic_camera_list_select"), for: .normal)
            badgeView.isHidden = true
        }
        super.isSelected = checked
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
