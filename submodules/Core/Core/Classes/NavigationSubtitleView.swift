//
//  NavigationSubtitleView.swift
//  Components
//
//  Created by kingxt on 7/18/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import UIKit

open class NavigationSubtitleView: UIView {
    
    public var isSilence: Bool = false {
        didSet {
            silenceImageView.isHidden = !isSilence
        }
    }
    
    public var isSecured: Bool = false {
        didSet {
            securedImageView.isHidden = !isSecured
        }
    }
    
    public var titleColor: UIColor = .black {
        didSet {
            titleLabel.textColor = titleColor
        }
    }
    
    public var subtitleColor: UIColor = .lightGray {
        didSet {
            subtitleLabel.textColor = subtitleColor
        }
    }
    
    public var regularTitleFont: UIFont = UIFont.boldSystemFont(ofSize: 17) {
        didSet {
            titleLabel.font = regularTitleFont
        }
    }
    
    public var regularSubtitleFont: UIFont = UIFont.systemFont(ofSize: 12) {
        didSet {
            subtitleLabel.font = regularSubtitleFont
        }
    }
    
    public var spacing: CGFloat = 2 {
        didSet {
            layout()
            setNeedsLayout()
        }
    }
    
    public var offset: CGFloat = 0 {
        didSet {
            layout()
            setNeedsLayout()
        }
    }
    
    public var animateChanges: Bool = true
    
    public var subtitleView: UIView? {
        didSet {
            if oldValue == subtitleView {
                return
            }
            if oldValue != nil {
                oldValue?.removeFromSuperview()
            }
            if subtitleView != nil {
                addSubview(subtitleView!)
            }
            layout()
            setNeedsLayout()
        }
    }
    
    public var subtitle: String? {
        didSet {
            if subtitle == nil {
                subtitleView = nil
            } else {
                subtitleLabel.text = subtitle
                subtitleView = subtitleLabel
            }
            layout()
            setNeedsLayout()
        }
    }
    
    public var title: String = "" {
        didSet {
            if titleLabel.superview == nil {
                addSubview(titleLabel)
            }
            titleLabel.text = title
            layout()
            setNeedsLayout()
        }
    }
    
    open func layout() {
        if subtitleView != nil {
            titleLabel.snp.remakeConstraints({ make in
                make.centerX.equalToSuperview().offset(offset)
                if #available(iOS 11, *) {
                    make.top.equalToSuperview().offset(0)
                } else {
                    make.top.equalToSuperview().offset(10)
                }
                make.width.lessThanOrEqualToSuperview()
            })
            subtitleView?.snp.remakeConstraints({ make in
                make.top.equalTo(titleLabel.snp.bottom).offset(spacing)
                make.centerX.equalToSuperview().offset(offset)
                make.width.lessThanOrEqualToSuperview()
                make.height.lessThanOrEqualTo(20)
            })
        } else {
            titleLabel.snp.remakeConstraints({ make in
                make.centerX.equalToSuperview().offset(offset)
                make.centerY.equalToSuperview()
                make.width.lessThanOrEqualToSuperview()
            })
            titleLabel.font = UIFont.boldSystemFont(ofSize: 19)
        }
        
        securedImageView.snp.remakeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalTo(titleLabel.snp.left).offset(-3)
        }
        silenceImageView.snp.remakeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.left.equalTo(titleLabel.snp.right).offset(3)
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        var width = frame.size.width
        width = min(max(subtitleView?.frame.size.width ?? 0, titleLabel.frame.size.width), frame.size.width)
        return CGSize(width: width, height: 64)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(securedImageView)
        addSubview(silenceImageView)
    }
    
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var titleLabel: UILabel = {
        let lable = UILabel()
        lable.lineBreakMode = .byTruncatingTail
        lable.textAlignment = .center
        lable.font = self.regularTitleFont
        return lable
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let lable = UILabel()
        lable.font = self.regularSubtitleFont
        return lable
    }()
    
    public let silenceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        return imageView
    }()
    
    public let securedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        return imageView
    }()
}
