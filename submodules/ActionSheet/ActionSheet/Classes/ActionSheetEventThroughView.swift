//
//  ActionSheetEventThroughView.swift
//  Components
//
//  Created by Dylan on 14/06/2017.
//  Copyright © 2017 liao. All rights reserved.
//

import UIKit

open class ActionSheetEventThroughView: UIView {

    public var hasRadius = false
    
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
    
    private let maskLayer = CAShapeLayer()
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        if hasRadius {
            let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 8, height: 8))
            maskLayer.frame = bounds
            maskLayer.path = maskPath.cgPath
            layer.mask = maskLayer
        }
    }
}
