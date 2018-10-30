//
//  ActionSheetEventThroughView.swift
//  Components
//
//  Created by Dylan on 14/06/2017.
//  Copyright © 2017 liao. All rights reserved.
//

import UIKit

open class ActionSheetEventThroughView: UIView {

    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let hitView = super.hitTest(point, with: event) {
            if hitView == self {
                return nil
            } else {
                return hitView
            }
        }
        return nil
    }
}
