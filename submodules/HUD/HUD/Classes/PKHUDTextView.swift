//
//  PKHUDTextView.swift
//  PKHUD
//
//  Created by Philip Kluz on 6/12/15.
//  Copyright (c) 2016 NSExceptional. All rights reserved.
//  Licensed under the MIT license.
//

import UIKit

/// PKHUDTextView provides a wide, three line text view, which you can use to display information.
open class PKHUDTextView: PKHUDWideBaseView {
    
    private let offset: CGSize

    public init(text: String?, offset: CGSize = CGSize(width: 60, height: 40)) {
        self.offset = offset
        super.init()
        commonInit(text)
        
        layoutSubviews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit(_ text: String?) {
        titleLabel.text = text
        addSubview(titleLabel)
    }

    class func systemFontSize(fontSize: CGFloat) -> UIFont {
        if #available(iOS 9.0, *) {
            return UIFont(name: "PingFangSC-Light", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        } else {
            return UIFont.systemFont(ofSize: fontSize)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.font = PKHUDTextView.systemFontSize(fontSize: 16.0)
        let size = titleLabel.sizeThatFits(PKHUDWideBaseView.defaultWideBaseViewFrame.size)
        titleLabel.frame.size = size
        self.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: size.width + offset.width, height: size.height + offset.height))
        titleLabel.center = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
    }

    public let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 17.0)
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 3
        return label
    }()
}
