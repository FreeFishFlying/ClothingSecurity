//
//  OverlayControllerWindow.h
//  ContactChat-iphone
//
//  Created by kingxt on 12/7/15.
//  Copyright © 2015 liaoliao. All rights reserved.
//
import UIKit

private let windowLevelRange: Range = Range<CGFloat>(uncheckedBounds: (9_999_000, 9_999_900))

open class OverlayControllerWindow: UIWindow {

    public private(set) var hasShown: Bool = false
    
    @objc public static var defaultOrientationSupport = true
    
    @objc open var orientationSupport: Bool = OverlayControllerWindow.defaultOrientationSupport

    @objc
    public var pinTop: Bool = false {
        didSet {
            addToStack()
        }
    }

    public var aboveStatusBar: Bool = true

    private func addToStack() {
        if hasShown {
            associatedTopWindowStack.remove(object: self)
            associatedWindowStack.remove(object: self)

            if pinTop {
                associatedTopWindowStack.append(self)
            } else {
                associatedWindowStack.append(self)
            }
        }
    }

    public var resetPortraitAfterDismiss: Bool = !isIpad()

    public init(contentController: OverlayViewController) {
        super.init(frame: UIScreen.main.bounds)
        rootViewController = contentController
    }

    public func updateWindowsLevel() {
        var windowLevel: CGFloat = max(windowLevelRange.lowerBound, UIWindow.Level.statusBar.rawValue)
        let os = ProcessInfo().operatingSystemVersion
        if os.majorVersion <= 11 {
            if let window = applicationKeyboardWindow() {
                windowLevel = max(windowLevel, window.windowLevel.rawValue)
            }
        }
        windowLevel += 1
        for (index, window) in associatedWindowStack.enumerated() {
            if window.aboveStatusBar {
                window.windowLevel = UIWindow.Level(rawValue: windowLevel)
            } else {
                window.windowLevel = UIWindow.Level.statusBar - 1000 + CGFloat(index)
            }
            windowLevel += 1
        }
        associatedTopWindowStack.forEach { window in
            window.windowLevel = UIWindow.Level(rawValue: windowLevel)
            windowLevel += 1
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc open func show() {
        if operatingSystem.majorVersion >= 11 {
            UIApplication.shared.windows.forEach {
                if $0 != self {
                    $0.endEditing(true)
                }
            }
        }
        isHidden = false
        hasShown = true
        addToStack()
        updateWindowsLevel()
    }

    @objc open func dismiss() {
        hasShown = false
        if resetPortraitAfterDismiss {
            UIView.performWithoutAnimation {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
        }
        associatedWindowStack.remove(object: self)
        associatedTopWindowStack.remove(object: self)
        rootViewController?.viewWillDisappear(false)
        isHidden = true
        rootViewController?.viewDidDisappear(false)
        rootViewController = nil
    }

    @discardableResult public static func presentControllerOnWindow(controller: UIViewController, animated: Bool, completion _: (() -> Swift.Void)? = nil) -> UIWindow {
        let window = OverlayControllerWindow(frame: UIScreen.main.bounds)
        window.present(controller: controller, animated: animated)
        return window
    }

    public func present(controller: UIViewController, animated: Bool, forceEndEditing: Bool = false, completion: (() -> Swift.Void)? = nil) {
        backgroundColor = .clear
        rootViewController = UIViewController()
        show()
        AssociatedWindowTag += 1
        let tag = AssociatedWindowTag
        self.tag = tag
        controller.reactive.lifetime.observeEnded {
            UIApplication.shared.windows.forEach({ window in
                if window.tag == tag {
                    (window as? OverlayControllerWindow)?.dismiss()
                }
            })
        }
        if operatingSystem.majorVersion >= 11 || forceEndEditing {
            UIApplication.shared.windows.forEach {
                if $0 != self {
                    $0.endEditing(true)
                }
            }
        }
        rootViewController?.present(controller, animated: animated, completion: completion)
    }
}

private var associatedWindowStack = [OverlayControllerWindow]()
private var associatedTopWindowStack = [OverlayControllerWindow]()

private var AssociatedWindowTag = 12389
