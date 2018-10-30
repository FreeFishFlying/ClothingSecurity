//
//  MediaVideoScrubberTrimView.swift
//  Components-Swift
//
//  Created by kingxt on 5/16/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import UIKit
import Core

public class MediaVideoScrubberTrimView: UIView, UIGestureRecognizerDelegate {

    let trimBackgroundColor = UIColorRGB(0x4D4D4D)
    private var beganInteraction: Bool = false
    private var isTracking: Bool = false
    private var endedInteraction = true

    public var didBeginEditing: ((_ start: Bool) -> Void)?
    public var startHandleMoved: ((_ translation: CGPoint) -> Void)?
    public var endHandleMoved: ((_ translation: CGPoint) -> Void)?
    public var didEndEditing: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(topShadowView)
        addSubview(leftSegmentView)
        addSubview(topSegmentView)
        addSubview(rightSegmentView)
        addSubview(bottomSegmentView)

        leftSegmentView.addSubview(leftHandleView)
        rightSegmentView.addSubview(rightHandleView)

        leftSegmentView.addGestureRecognizer(startHandlePanGestureRecognizer)
        rightSegmentView.addGestureRecognizer(endHandlePanGestureRecognizer)
    }

    @objc func handleHandlePan(gestureRecognizer: UIPanGestureRecognizer) {
        let translation: CGPoint = gestureRecognizer.translation(in: self)
        gestureRecognizer.setTranslation(CGPoint.zero, in: self)
        switch gestureRecognizer.state {
        case .began:
            if beganInteraction {
                return
            }
            isTracking = true
            if didBeginEditing != nil {
                didBeginEditing?(gestureRecognizer.view == leftSegmentView)
            }
            endedInteraction = false
            beganInteraction = true
        case .changed:
            if gestureRecognizer == startHandlePanGestureRecognizer {
                startHandleMoved?(translation)
            } else if gestureRecognizer == endHandlePanGestureRecognizer {
                endHandleMoved?(translation)
            }

        case .ended, .cancelled:
            beganInteraction = false
            if endedInteraction {
                return
            }
            isTracking = false
            didEndEditing?()
            endedInteraction = true

            break

        default:
            break
        }
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view != otherGestureRecognizer.view {
            return false
        }
        return true
    }

    public override func layoutSubviews() {
        let handleWidth: CGFloat = 12
        leftSegmentView.frame = CGRect(x: 0, y: 0, width: handleWidth, height: frame.size.height)
        rightSegmentView.frame = CGRect(x: frame.size.width - handleWidth, y: 0, width: handleWidth, height: frame.size.height)
        topSegmentView.frame = CGRect(x: leftSegmentView.frame.size.width, y: 0, width: frame.size.width - leftSegmentView.frame.size.width - rightSegmentView.frame.size.width, height: 2)
        bottomSegmentView.frame = CGRect(x: leftSegmentView.frame.size.width, y: frame.size.height - bottomSegmentView.frame.size.height, width: CGFloat(frame.size.width - leftSegmentView.frame.size.width - rightSegmentView.frame.size.width), height: 2)
        topShadowView.frame = CGRect(x: topSegmentView.frame.origin.x, y: topSegmentView.frame.size.height, width: topSegmentView.frame.size.width, height: topShadowView.frame.size.height)
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var topShadowView: UIView = {
        let topShadowView = UIView(frame: CGRect(x: 12, y: 2, width: 0, height: 1))
        topShadowView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        return topShadowView
    }()

    private lazy var leftSegmentView: UIControl = {
        let leftSegmentView = UIControl(frame: CGRect(x: 0, y: 0, width: 12, height: 36))
        leftSegmentView.backgroundColor = self.trimBackgroundColor
        leftSegmentView.hitTestEdgeInsets = UIEdgeInsets(top: -5, left: -25, bottom: -5, right: -10)
        return leftSegmentView
    }()

    private lazy var topSegmentView: UIView = {
        let topSegmentView = UIView(frame: CGRect(x: 1, y: 0, width: 0, height: 2))
        topSegmentView.backgroundColor = self.trimBackgroundColor
        return topSegmentView
    }()

    private lazy var rightSegmentView: UIControl = {
        let rightSegmentView = UIControl(frame: CGRect(x: 0, y: 0, width: 12, height: 36))
        rightSegmentView.backgroundColor = self.trimBackgroundColor
        rightSegmentView.hitTestEdgeInsets = UIEdgeInsets(top: -5, left: -10, bottom: -5, right: -25)
        return rightSegmentView
    }()

    private lazy var bottomSegmentView: UIView = {
        let bottomSegmentView = UIView(frame: CGRect(x: 12, y: 0, width: 0, height: 2))
        bottomSegmentView.backgroundColor = self.trimBackgroundColor
        return bottomSegmentView
    }()

    private lazy var leftHandleView: UIImageView = {
        let leftHandleView = UIImageView(frame: self.leftSegmentView.bounds)
        leftHandleView.contentMode = .center
        leftHandleView.image = ImageNamed("VideoScrubberLeftArrow")
        return leftHandleView
    }()

    private lazy var rightHandleView: UIImageView = {
        let rightHandleView = UIImageView(frame: self.rightSegmentView.bounds)
        rightHandleView.contentMode = .center
        rightHandleView.image = ImageNamed("VideoScrubberRightArrow")
        return rightHandleView
    }()

    private lazy var startHandlePanGestureRecognizer: UIPanGestureRecognizer = {
        let startHandlePanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handleHandlePan))
        startHandlePanGestureRecognizer.delegate = self
        return startHandlePanGestureRecognizer
    }()

    private lazy var endHandlePanGestureRecognizer: UIPanGestureRecognizer = {
        let endHandlePanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handleHandlePan))
        endHandlePanGestureRecognizer.delegate = self
        return endHandlePanGestureRecognizer
    }()
}
