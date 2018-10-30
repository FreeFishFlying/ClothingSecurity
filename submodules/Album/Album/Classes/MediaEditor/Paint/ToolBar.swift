//
//  ToolBar.swift
//  NXDrawKit
//
//  Created by Nicejinux on 7/13/16.
//  Copyright © 2016 Nicejinux. All rights reserved.
//

import UIKit
import SnapKit

open class ToolBar: UIView
{
    @objc open weak var undoButton: UIButton?
    @objc open weak var redoButton: UIButton?
    @objc open weak var clearButton: UIButton?
    
    fileprivate weak var lineView: UIView?

    // MARK: - Public Methods
    public init() {
        super.init(frame: CGRect.zero)
        self.initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func initialize() {
        self.setupViews()
        self.setupLayout()
    }
    
    // MARK: - Private Methods
    fileprivate func setupViews() {
        let lineView = UIView()
        lineView.backgroundColor = UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1.0)
        self.addSubview(lineView)
        self.lineView = lineView
        self.lineView?.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        
        var button: UIButton = self.button("清空")
        self.addSubview(button)
        self.clearButton = button
        
        button = self.button(iconName: "icon_undo")
        self.addSubview(button)
        self.undoButton = button
        
        button = self.button(iconName: "icon_redo")
        self.addSubview(button)
        self.redoButton = button
    }
    
    fileprivate func setupLayout() {
        lineView?.snp.makeConstraints({ (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        })
        undoButton?.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
        }
        redoButton?.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(undoButton!.snp.right).offset(20)
        }
        clearButton?.snp.makeConstraints({ (make) in
            make.right.equalTo(-15)
            make.centerY.equalToSuperview()
        })
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.setupLayout()
    }
    
    fileprivate func button(_ title: String? = nil, iconName: String? = nil) -> UIButton {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        
        if title != nil {
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15 * self.multiflierForDevice())
            button.setTitle(title, for: UIControl.State())
            button.setTitleColor(UIColor.white, for: UIControl.State())
            button.setTitleColor(UIColor.gray, for: .disabled)
        }

        if iconName != nil {
            button.setImage(ImageNamed(iconName!), for: UIControl.State())
        }
        
        button.isEnabled = false
        
        return button
    }
    
    fileprivate func multiflierForDevice() -> CGFloat {
        if UIScreen.main.bounds.size.width <= 320 {
            return 0.75
        } else if UIScreen.main.bounds.size.width > 375 {
            return 1.0
        } else {
            return 0.9
        }
    }
}
