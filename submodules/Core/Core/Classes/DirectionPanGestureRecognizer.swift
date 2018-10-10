//
//  DirectionPanGestureRecognizer.swift
//  Components-Swift
//
//  Created by Dylan on 16/05/2017.
//  Copyright © 2017 liao. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

public class DirectionPanGestureRecognizer: UIPanGestureRecognizer {

    private var isDrag: Bool = false
    private var moveX: CGFloat = 0
    private var moveY: CGFloat = 0

    public enum PanDirection {
        case vertical
        case horizontal
    }

    let direction: PanDirection

    public init(direction: PanDirection, target: Any?, action: Selector?) {
        self.direction = direction
        super.init(target: target, action: action)
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)

        if state == .began && !touches.isEmpty {
            let point = touches.first?.location(in: view) ?? CGPoint.zero
            let prevPoint = touches.first?.previousLocation(in: view) ?? CGPoint.zero
            moveX = prevPoint.x - point.x
            moveY = prevPoint.y - point.y
            if !isDrag {
                if abs(moveX) > 5 {
                    if direction == .vertical {
                        state = .failed
                    } else {
                        isDrag = true
                    }
                } else if abs(moveY) > 5 {
                    if direction == .horizontal {
                        state = .failed
                    } else {
                        isDrag = true
                    }
                }
            }
        }
    }

    public override func reset() {
        super.reset()
        moveY = 0
        moveX = 0
        isDrag = false
    }
}
