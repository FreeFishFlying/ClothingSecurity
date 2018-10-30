//
//  ActionSheetItemView.swift
//  Components-Swift
//
//  Created by Dylan on 17/05/2017.
//  Copyright © 2017 liao. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import SnapKit
import Core

open class ActionSheetItemView: ActionSheetEventThroughView {

    public weak var actionSheetController: ActionSheetViewController?

    open var preferredHeight: CGFloat {
        return 50
    }

    public func invalidatePreferredHeight() {
        actionSheetController?.invalidatePreferredHeight()
    }
}

public class ActionSheetButtonItemView: ActionSheetItemView {

    public let button: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColorRGB(0x00B1F8), for: .normal)
        button.setTitleColor(UIColor.gray, for: .disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.setBackgroundImage(UIImageForm(color: UIColorRGB(0xDCDCDC)), for: .highlighted)
        button.autoHighlight = true
        return button
    }()

    public var title: String? {
        didSet {
            button.setTitle(title, for: .normal)
        }
    }

    public var clickSignal: Signal<UIButton, NoError> {
        return button.reactive.controlEvents(.touchUpInside).take(during: reactive.lifetime)
    }
    
    public let separatorView = UIView()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        separatorView.backgroundColor = UIColorRGB(0xDCDCDC)
        addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
