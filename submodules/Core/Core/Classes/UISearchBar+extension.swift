//
//  UISearchBar+extension.swift
//  Love
//
//  Created by kingxt on 7/23/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import UIKit

private let activityIndicatorViewTag = 12

public extension UISearchBar {

    private static var AssociatedUIButtonHandle: UInt8 = 0
    private static var AssociatedSearchIcon: UInt8 = 0

    private var searchIcon: UIImage? {
        get {
            return objc_getAssociatedObject(self, &UISearchBar.AssociatedSearchIcon) as? UIImage
        }
        set {
            objc_setAssociatedObject(self, &UISearchBar.AssociatedSearchIcon, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public var isSearching: Bool {
        get {
            let value: NSNumber? = objc_getAssociatedObject(self, &UISearchBar.AssociatedUIButtonHandle) as? NSNumber
            return value?.boolValue ?? false
        }
        set {
            let value = NSNumber(value: newValue)
            objc_setAssociatedObject(self, &UISearchBar.AssociatedUIButtonHandle, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            if newValue && viewWithTag(activityIndicatorViewTag) == nil {
                searchIcon = image(for: .search, state: .normal)
                setImage(UIImage(), for: .search, state: .normal)
                let indicator = UIActivityIndicatorView(style: .gray)
                indicator.tag = 12
                indicator.startAnimating()
                addSubview(indicator)
                indicator.snp.makeConstraints({ make in
                    make.centerY.equalTo(self)
                    make.left.equalTo(activityIndicatorViewTag)
                })
            } else {
                viewWithTag(activityIndicatorViewTag)?.removeFromSuperview()
                setImage(searchIcon, for: .search, state: .normal)
            }
        }
    }
}
