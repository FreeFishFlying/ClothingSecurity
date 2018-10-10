//
//  HUD.swift
//  PKHUD
//
//  Created by Eugene Tartakovsky on 29/01/16.
//  Copyright © 2016 Eugene Tartakovsky, NSExceptional. All rights reserved.
//  Licensed under the MIT license.
//

import UIKit

internal func ImageNamed(_ name: String) -> UIImage? {
    var bundle = Bundle(for: HUD.self)
    if let path = bundle.path(forResource: "HUD", ofType: "bundle") {
        if let mainBundle = Bundle(path: path) {
            bundle = mainBundle
        }
    }
    return UIImage(named: name, in: bundle, compatibleWith: nil)
}

public enum HUDContentType {
    case success
    case error
    case progress
    case image(UIImage?)
    case rotatingImage(UIImage?)
    case upload(Int)

    case labeledSuccess(title: String?, subtitle: String?)
    case labeledError(title: String?, subtitle: String?)
    case labeledProgress(title: String?, subtitle: String?)
    case labeledImage(image: UIImage?, title: String?, subtitle: String?)
    case labeledRotatingImage(image: UIImage?, title: String?, subtitle: String?)

    case label(String?)
    case tip(text: String?)
    
    case systemActivity
}

public final class HUD {
    
    private static var tipContainer = [PKHUD]()

    // MARK: Properties
    public static var dimsBackground: Bool {
        get { return PKHUD.sharedHUD.dimsBackground }
        set { PKHUD.sharedHUD.dimsBackground = newValue }
    }

    public static var allowsInteraction: Bool {
        get { return PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled }
        set { PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = newValue }
    }

    public static var isVisible: Bool { return PKHUD.sharedHUD.isVisible }

    // MARK: Public methods, PKHUD based
    public static func show(_ content: HUDContentType, onView view: UIView? = nil, dimsBackground: Bool = true, userInteraction: Bool = false) {
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = userInteraction
        PKHUD.sharedHUD.contentView = contentView(content)
        PKHUD.sharedHUD.show(onView: view, dimsBackground: dimsBackground)
    }
    
    public static func tip(text: String?, onView view: UIView? = nil, textColor: UIColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1), backgroundColor: UIColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.9)) {
        var window = UIApplication.shared.keyWindow!
        for item in UIApplication.shared.windows {
            if !item.isHidden && String(describing: item) != "UITextEffectsWindow" && item.windowLevel > window.windowLevel {
                window = item
            }
        }
        let tipView = PKHUDTextView(text: text, offset: CGSize(width: 40, height: 20))
        tipView.titleLabel.textColor = textColor
        tipView.backgroundColor = backgroundColor
        let hud = PKHUD()
        hud.userInteractionOnUnderlyingViewsEnabled = true
        hud.contentView = tipView
        HUD.tipContainer.append(hud)
        hud.show(onView: view ?? window, dimsBackground: false)
        hud.hide(afterDelay: 2) { [weak hud] (_) in
            if let index = HUD.tipContainer.index(where: { (item) -> Bool in
                return item == hud
            }) {
                HUD.tipContainer.remove(at: index)
            }
        }
    }
    
    private static func removeAllTip() {
        HUD.tipContainer.forEach { (item) in
            item.contentView.removeFromSuperview()
        }
        HUD.tipContainer = [PKHUD]()
    }

    public static func flashError(title: String? = nil) {
        flash(.labeledError(title: title, subtitle: nil), dimsBackground: false)
    }

    public static func flashSuccess(title: String? = nil) {
        flash(.labeledSuccess(title: title, subtitle: nil), dimsBackground: false)
    }

    public static func hide(_ completion: ((Bool) -> Void)? = nil) {
        HUD.removeAllTip()
        PKHUD.sharedHUD.hide(animated: false, completion: completion)
    }

    public static func hide(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        HUD.removeAllTip()
        PKHUD.sharedHUD.hide(animated: animated, completion: completion)
    }

    public static func hide(afterDelay delay: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        HUD.removeAllTip()
        PKHUD.sharedHUD.hide(afterDelay: delay, completion: completion)
    }

    // MARK: Public methods, HUD based
    public static func flash(_ content: HUDContentType, onView view: UIView? = nil, dimsBackground: Bool = true) {
        HUD.flash(content, onView: view, delay: 2, dimsBackground: dimsBackground, completion: nil)
    }

    public static func flash(_ content: HUDContentType, onView view: UIView? = nil, delay: TimeInterval, dimsBackground: Bool = true, completion: ((Bool) -> Void)? = nil) {
        HUD.show(content, onView: view, dimsBackground: dimsBackground, userInteraction: true)
        HUD.hide(afterDelay: delay, completion: completion)
    }

    // MARK: Private methods
    fileprivate static func contentView(_ content: HUDContentType) -> UIView {
        switch content {
        case .success:
            return PKHUDSuccessView()
        case .error:
            return PKHUDErrorView()
        case .progress:
            return PKHUDProgressView()
        case let .image(image):
            return PKHUDSquareBaseView(image: image)
        case let .rotatingImage(image):
            return PKHUDRotatingImageView(image: image)
        case let .upload(percent):
            return PKHUDUploadView(percent: percent)

        case let .labeledSuccess(title, subtitle):
            return PKHUDSuccessView(title: title, subtitle: subtitle)
        case let .labeledError(title, subtitle):
            return PKHUDErrorView(title: title, subtitle: subtitle)
        case let .labeledProgress(title, subtitle):
            return PKHUDProgressView(title: title, subtitle: subtitle)
        case let .labeledImage(image, title, subtitle):
            return PKHUDSquareBaseView(image: image, title: title, subtitle: subtitle)
        case let .labeledRotatingImage(image, title, subtitle):
            return PKHUDRotatingImageView(image: image, title: title, subtitle: subtitle)

        case let .label(text):
            return PKHUDTextView(text: text)
        case let .tip(text):
            return PKHUDTextView(text: text, offset: CGSize(width: 40, height: 20))
        case .systemActivity:
            return PKHUDSystemActivityIndicatorView()
        }
    }
}
