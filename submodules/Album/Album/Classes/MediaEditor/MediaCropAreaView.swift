//
//  MediaCropAreaView.swift
//  Components-Swift
//
//  Created by kingxt on 5/19/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import UIKit
import Core

class MediaCropGridView: UIView {

    enum Mode: Int {
        case none
        case major
        case minor
    }

    private var mode: Mode = .none
    private var animatingHidden: Bool = false
    private var targetHidden: Bool = false

    init(mode: Mode) {
        super.init(frame: CGRect.zero)
        isOpaque = false
        isUserInteractionEnabled = false
        self.mode = mode
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var frame: CGRect {
        didSet {
            super.frame = frame
            if !self.isHidden {
                setNeedsDisplay()
            }
        }
    }

    override var isHidden: Bool {
        didSet {
            super.isHidden = isHidden
            setHidden(isHidden, animated: false, duration: 0, delay: 0)
        }
    }

    func setHidden(_ hidden: Bool, animated: Bool, duration: TimeInterval, delay: TimeInterval) {
        if animatingHidden && targetHidden == hidden {
            return
        }
        setNeedsDisplay()
        targetHidden = hidden
        if animated {
            animatingHidden = true
            super.isHidden = false
            UIView.animate(withDuration: duration, delay: delay, options: [.beginFromCurrentState, .curveEaseInOut], animations: { () -> Void in
                self.alpha = hidden ? 0.0 : 1.0
            }, completion: { (_ finished: Bool) -> Void in
                if finished {
                    super.isHidden = hidden
                    self.animatingHidden = false
                }
            })
        } else {
            super.isHidden = hidden
            alpha = hidden ? 0.0 : 1.0
        }
    }

    override func draw(_ rect: CGRect) {
        let width: CGFloat = rect.size.width
        let height: CGFloat = rect.size.height
        let thickness: CGFloat = 0.5

        for i in 0 ..< 3 {
            if mode == .minor {
                for j in 1 ..< 4 {
                    UIColorRGBA(0xEEEEEE, 0.7).set()
                    UIRectFill(CGRect(x: (width / 9 * CGFloat(j) + width / 3 * CGFloat(i)).rounded(), y: 0, width: thickness, height: height.rounded()))
                    UIRectFill(CGRect(x: 0, y: (height / 9 * CGFloat(j) + height / 3 * CGFloat(i)).rounded(), width: width.rounded(), height: thickness))
                }
            }
            if mode == .major {
                if i > 0 {
                    UIColor.white.set()
                    UIRectFill(CGRect(x: (width / 3 * CGFloat(i)).rounded(), y: 0, width: thickness, height: height.rounded()))
                    UIRectFill(CGRect(x: 0, y: (height / 3 * CGFloat(i)).rounded(), width: width.rounded(), height: thickness))
                }
            }
        }
    }
}

class MediaCropControl: UIControl, UIGestureRecognizerDelegate {

    fileprivate var shouldBeginResizing: ((_ sender: MediaCropControl) -> Bool)?
    fileprivate var didBeginResizing: ((_ sender: MediaCropControl) -> Void)?
    fileprivate var didResize: ((_ sender: MediaCropControl, _ translation: CGPoint) -> Void)?
    fileprivate var didEndResizing: ((_ sender: MediaCropControl) -> Void)?

    private var beganInteraction: Bool = false
    private var endedInteraction: Bool = true

    private lazy var pressGestureRecognizer: UILongPressGestureRecognizer = {
        let pressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handlePress))
        pressGestureRecognizer.delegate = self
        pressGestureRecognizer.minimumPressDuration = 0.1
        return pressGestureRecognizer
    }()

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan))
        panGestureRecognizer.delegate = self
        return panGestureRecognizer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        isExclusiveTouch = true
        addGestureRecognizer(pressGestureRecognizer)
        addGestureRecognizer(panGestureRecognizer)
    }

    @objc private func handlePress(gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            if beganInteraction {
                return
            }
            didBeginResizing?(self)
            endedInteraction = false
            beganInteraction = true
        case .ended, .cancelled:
            beganInteraction = false
            if endedInteraction {
                return
            }
            didEndResizing?(self)
            endedInteraction = true
        default:
            break
        }
    }

    @objc private func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        var translation: CGPoint = gestureRecognizer.translation(in: superview)
        translation = CGPoint(x: (translation.x).rounded(), y: translation.y)
        switch gestureRecognizer.state {
        case .began:
            if beganInteraction {
                return
            }
            didBeginResizing?(self)
            endedInteraction = false
            beganInteraction = true
        case .changed:
            didResize?(self, translation)
            gestureRecognizer.setTranslation(CGPoint.zero, in: superview)
        case .ended, .cancelled:
            beganInteraction = false
            if endedInteraction {
                return
            }
            didEndResizing?(self)
            endedInteraction = true
        default:
            break
        }
    }

    override func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        return self.shouldBeginResizing?(self) ?? true
    }

    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

let mediaCropCornerControlSize: CGSize = CGSize(width: 44, height: 44)
let mediaCropEdgeControlSize: CGFloat = 44

class MediaCropAreaView: UIControl {

    public var shouldBeginEditing: (() -> Bool)?
    public var didBeginEditing: (() -> Void)?
    public var areaChanged: (() -> Void)?
    public var didEndEditing: (() -> Void)?

    private var shouldBeginResizing: ((_ sender: MediaCropControl) -> Bool)?
    private var didBeginResizing: ((_ sender: MediaCropControl) -> Void)?
    private var didResize: ((_ sender: MediaCropControl, _ translation: CGPoint) -> Void)?
    private var didEndResizing: ((_ sender: MediaCropControl) -> Void)?

    public private(set) var cropIsTracking: Bool = false

    public var aspectRatio: CGFloat? {
        didSet {
            topEdgeHighlight.isHidden = aspectRatio == nil
            leftEdgeHighlight.isHidden = aspectRatio == nil
            rightEdgeHighlight.isHidden = aspectRatio == nil
            bottomEdgeHighlight.isHidden = aspectRatio == nil
        }
    }

    override var isTracking: Bool {
        return cropIsTracking
    }

    private var gridMode: MediaCropGridView.Mode = .none

    public func setGridMode(_ gridMode: MediaCropGridView.Mode, animated: Bool) {
        self.gridMode = gridMode
        switch gridMode {
        case .major:
            setGridView(majorGridView, hidden: false, animated: animated)
            setGridView(minorGridView, hidden: true, animated: animated)
        case .minor:
            setGridView(majorGridView, hidden: true, animated: animated)
            setGridView(minorGridView, hidden: false, animated: animated)
        default:
            setGridView(majorGridView, hidden: true, animated: animated)
            setGridView(minorGridView, hidden: true, animated: animated)
        }
    }

    func setGridView(_ gridView: MediaCropGridView, hidden: Bool, animated: Bool) {
        if animated {
            gridView.setHidden(hidden, animated: true, duration: 0.2, delay: 0.0)
        } else {
            gridView.isHidden = hidden
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupCallback()

        hitTestEdgeInsets = UIEdgeInsets(top: -16, left: -16, bottom: -16, right: -16)
        addSubview(cornersView)

        addSubview(topEdgeHighlight)
        addSubview(leftEdgeHighlight)
        addSubview(rightEdgeHighlight)
        addSubview(bottomEdgeHighlight)

        addSubview(topEdgeControl)
        addSubview(leftEdgeControl)
        addSubview(bottomEdgeControl)
        addSubview(rightEdgeControl)

        addSubview(topLeftCornerControl)
        addSubview(topRightCornerControl)
        addSubview(bottomLeftCornerControl)
        addSubview(bottomRightCornerControl)

        for view: UIView in subviews {
            if view is MediaCropControl {
                let control: MediaCropControl? = (view as? MediaCropControl)
                control?.shouldBeginResizing = shouldBeginResizing
                control?.didBeginResizing = didBeginResizing
                control?.didResize = didResize
                control?.didEndResizing = didEndResizing
            }
        }

        addSubview(majorGridView)
        addSubview(minorGridView)
    }

    private func setupCallback() {
        shouldBeginResizing = { [weak self] (_: MediaCropControl) -> Bool in
            self?.shouldBeginEditing?() ?? true
        }

        didBeginResizing = { [weak self] (_ sender: MediaCropControl) -> Void in
            if let strongSelf = self {
                strongSelf.cropIsTracking = true
                strongSelf.didBeginEditing?()
                if strongSelf.aspectRatio != nil {
                    return
                }
                if sender == self?.topEdgeControl {
                    strongSelf.topEdgeHighlight.isHidden = false
                } else if sender == strongSelf.leftEdgeControl {
                    strongSelf.leftEdgeHighlight.isHidden = false
                } else if sender == strongSelf.bottomEdgeControl {
                    strongSelf.bottomEdgeHighlight.isHidden = false
                } else if sender == strongSelf.rightEdgeControl {
                    strongSelf.rightEdgeHighlight.isHidden = false
                }
            }
        }

        didResize = { [weak self] (_ sender: MediaCropControl, _ translation: CGPoint) -> Void in
            if let strongSelf = self {
                strongSelf.handleResize(withSender: sender, translation: translation)
                strongSelf.areaChanged?()
            }
        }

        didEndResizing = { [weak self] (_ sender: MediaCropControl) -> Void in
            if let strongSelf = self {
                strongSelf.cropIsTracking = false
                strongSelf.didEndEditing?()
                if strongSelf.aspectRatio != nil {
                    return
                }
                if sender == strongSelf.topEdgeControl {
                    strongSelf.topEdgeHighlight.isHidden = true
                } else if sender == strongSelf.leftEdgeControl {
                    strongSelf.leftEdgeHighlight.isHidden = true
                } else if sender == strongSelf.bottomEdgeControl {
                    strongSelf.bottomEdgeHighlight.isHidden = true
                } else if sender == strongSelf.rightEdgeControl {
                    strongSelf.rightEdgeHighlight.isHidden = true
                }
            }
        }
    }

    func handleResize(withSender sender: MediaCropControl, translation: CGPoint) {
        var rect: CGRect = frame
        if sender == topLeftCornerControl {
            rect = CGRect(x: CGFloat(frame.origin.x + translation.x), y: frame.origin.y + translation.y, width: CGFloat(frame.size.width - translation.x), height: CGFloat(frame.size.height - translation.y))
            if let aspectRatio = aspectRatio {
                var constrainedRect: CGRect = constrainedRectFromRect(withWidth: rect, aspectRatio: aspectRatio)
                if abs(translation.x) < abs(translation.y) {
                    constrainedRect = constrainedRectFromRect(withHeight: rect, aspectRatio: aspectRatio)
                }
                constrainedRect.origin.x -= constrainedRect.size.width - rect.size.width
                constrainedRect.origin.y -= constrainedRect.size.height - rect.size.height
                rect = constrainedRect
            }
        } else if sender == topRightCornerControl {
            rect = CGRect(x: frame.origin.x, y: frame.origin.y + translation.y, width: frame.size.width + translation.x, height: frame.size.height - translation.y)
            if let aspectRatio = aspectRatio {
                var constrainedRect: CGRect = constrainedRectFromRect(withWidth: rect, aspectRatio: aspectRatio)
                if abs(translation.x) < abs(translation.y) {
                    constrainedRect = constrainedRectFromRect(withHeight: rect, aspectRatio: aspectRatio)
                }
                constrainedRect.origin.y -= constrainedRect.size.height - rect.size.height
                rect = constrainedRect
            }
        } else if sender == bottomLeftCornerControl {
            rect = CGRect(x: CGFloat(frame.origin.x + translation.x), y: frame.origin.y, width: frame.size.width - translation.x, height: frame.size.height + translation.y)
            if let aspectRatio = aspectRatio {
                var constrainedRect = CGRect.zero
                if abs(translation.x) < abs(translation.y) {
                    constrainedRect = constrainedRectFromRect(withHeight: rect, aspectRatio: aspectRatio)
                } else {
                    constrainedRect = constrainedRectFromRect(withWidth: rect, aspectRatio: aspectRatio)
                }
                constrainedRect.origin.x -= constrainedRect.size.width - rect.size.width
                rect = constrainedRect
            }
        } else if sender == bottomRightCornerControl {
            rect = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width + translation.x, height: CGFloat(frame.size.height + translation.y))
            if let aspectRatio = aspectRatio {
                if abs(translation.x) < abs(translation.y) {
                    rect = constrainedRectFromRect(withHeight: rect, aspectRatio: aspectRatio)
                } else {
                    rect = constrainedRectFromRect(withWidth: rect, aspectRatio: aspectRatio)
                }
            }
        } else if sender == topEdgeControl {
            rect = CGRect(x: frame.origin.x, y: frame.origin.y + translation.y, width: frame.size.width, height: CGFloat(frame.size.height - translation.y))
            if let aspectRatio = aspectRatio {
                rect = constrainedRectFromRect(withHeight: rect, aspectRatio: aspectRatio)
            }
        } else if sender == leftEdgeControl {
            rect = CGRect(x: CGFloat(frame.origin.x + translation.x), y: frame.origin.y, width: CGFloat(frame.size.width - translation.x), height: CGFloat(frame.size.height))
            if let aspectRatio = aspectRatio {
                rect = constrainedRectFromRect(withWidth: rect, aspectRatio: aspectRatio)
            }
        } else if sender == bottomEdgeControl {
            rect = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: CGFloat(frame.size.height + translation.y))
            if let aspectRatio = aspectRatio {
                rect = constrainedRectFromRect(withHeight: rect, aspectRatio: aspectRatio)
            }
        } else if sender == rightEdgeControl {
            rect = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width + translation.x, height: frame.size.height)
            if let aspectRatio = aspectRatio {
                rect = constrainedRectFromRect(withWidth: rect, aspectRatio: aspectRatio)
            }
        }

        let minimumWidth: CGFloat = mediaCropCornerControlSize.width
        if rect.size.width < minimumWidth {
            rect.size.width = minimumWidth
        }
        let minimumHeight: CGFloat = mediaCropCornerControlSize.height
        if rect.size.height < minimumHeight {
            rect.size.height = minimumHeight
        }

        if let aspectRatio = aspectRatio {
            var constrainedRect: CGRect = rect
            if aspectRatio > 1 {
                if rect.size.width <= minimumWidth {
                    constrainedRect.size.width = minimumWidth
                    constrainedRect.size.height = constrainedRect.size.width * aspectRatio
                }
            } else {
                if rect.size.height <= minimumHeight {
                    constrainedRect.size.height = minimumHeight
                    constrainedRect.size.width = constrainedRect.size.height / aspectRatio
                }
            }
            rect = constrainedRect
        }
        self.frame = rect
    }

    private func constrainedRectFromRect(withWidth rect: CGRect, aspectRatio: CGFloat) -> CGRect {
        var rect = rect
        let width: CGFloat = rect.size.width
        let height: CGFloat = width * aspectRatio
        rect.size = CGSize(width: width, height: height)
        return rect
    }

    private func constrainedRectFromRect(withHeight rect: CGRect, aspectRatio: CGFloat) -> CGRect {
        var rect = rect
        let height: CGFloat = rect.size.height
        let width: CGFloat = height / aspectRatio
        rect.size = CGSize(width: width, height: height)
        return rect
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view: UIView? = super.hitTest(point, with: event)
        if view is MediaCropControl {
            return view
        }
        return nil
    }

    private lazy var majorGridView: MediaCropGridView = {
        let majorGridView = MediaCropGridView(mode: .major)
        majorGridView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        majorGridView.frame = self.bounds
        majorGridView.isHidden = true
        return majorGridView
    }()

    private lazy var minorGridView: MediaCropGridView = {
        let minorGridView = MediaCropGridView(mode: .minor)
        minorGridView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        minorGridView.frame = self.bounds
        minorGridView.isHidden = true
        return minorGridView
    }()

    private lazy var cornersView: UIImageView = {
        let cornersView = UIImageView(frame: self.bounds.insetBy(dx: -2, dy: -2))
        cornersView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cornersView.image = MediaEditorImageNamed("PhotoEditorCropCorners")?.resizableImage(withCapInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        return cornersView
    }()

    private lazy var topEdgeHighlight: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: -1, width: self.frame.size.width, height: 2))
        view.autoresizingMask = .flexibleWidth
        view.backgroundColor = UIColor.white
        view.isHidden = true
        return view
    }()

    private lazy var leftEdgeHighlight: UIView = {
        let view = UIView(frame: CGRect(x: -1, y: 0, width: 2, height: self.frame.size.height))
        view.autoresizingMask = .flexibleHeight
        view.backgroundColor = UIColor.white
        view.isHidden = true
        return view
    }()

    private lazy var rightEdgeHighlight: UIView = {
        let view = UIView(frame: CGRect(x: self.frame.size.width - 1, y: 0, width: 2, height: self.frame.size.height))
        view.autoresizingMask = [.flexibleLeftMargin, .flexibleHeight]
        view.backgroundColor = UIColor.white
        view.isHidden = true
        return view
    }()

    private lazy var bottomEdgeHighlight: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 2))
        view.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        view.backgroundColor = UIColor.white
        view.isHidden = true
        return view
    }()

    private lazy var topEdgeControl: MediaCropControl = {
        let topEdgeControl = MediaCropControl(frame: CGRect(x: mediaCropCornerControlSize.width / 2, y: -mediaCropEdgeControlSize / 2, width: self.frame.size.width - mediaCropCornerControlSize.width, height: mediaCropEdgeControlSize))
        topEdgeControl.autoresizingMask = .flexibleWidth
        topEdgeControl.hitTestEdgeInsets = UIEdgeInsets(top: -16, left: 0, bottom: -16, right: 0)
        return topEdgeControl
    }()

    private lazy var leftEdgeControl: MediaCropControl = {
        let leftEdgeControl = MediaCropControl(frame: CGRect(x: -mediaCropEdgeControlSize / 2, y: mediaCropCornerControlSize.height / 2, width: mediaCropEdgeControlSize, height: self.frame.size.height - mediaCropCornerControlSize.height))
        leftEdgeControl.autoresizingMask = .flexibleHeight
        leftEdgeControl.hitTestEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: -16)
        return leftEdgeControl
    }()

    private lazy var bottomEdgeControl: MediaCropControl = {
        let bottomEdgeControl = MediaCropControl(frame: CGRect(x: mediaCropCornerControlSize.width / 2, y: self.frame.size.height - mediaCropEdgeControlSize / 2, width: self.frame.size.width - mediaCropCornerControlSize.width, height: mediaCropEdgeControlSize))
        bottomEdgeControl.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        bottomEdgeControl.hitTestEdgeInsets = UIEdgeInsets(top: -16, left: 0, bottom: -16, right: 0)
        return bottomEdgeControl
    }()

    private lazy var rightEdgeControl: MediaCropControl = {
        let rightEdgeControl = MediaCropControl(frame: CGRect(x: self.frame.size.width - mediaCropEdgeControlSize / 2, y: mediaCropCornerControlSize.height / 2, width: mediaCropEdgeControlSize, height: self.frame.size.height - mediaCropCornerControlSize.height))
        rightEdgeControl.autoresizingMask = [.flexibleLeftMargin, .flexibleHeight]
        rightEdgeControl.hitTestEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: -16)
        return rightEdgeControl
    }()

    private lazy var topLeftCornerControl: MediaCropControl = {
        let topLeftCornerControl = MediaCropControl(frame: CGRect(x: -mediaCropCornerControlSize.width / 2, y: -mediaCropCornerControlSize.height / 2, width: mediaCropCornerControlSize.width, height: mediaCropCornerControlSize.height))
        topLeftCornerControl.hitTestEdgeInsets = UIEdgeInsets(top: -16, left: -16, bottom: -16, right: -16)
        return topLeftCornerControl
    }()

    private lazy var topRightCornerControl: MediaCropControl = {
        let topRightCornerControl = MediaCropControl(frame: CGRect(x: self.frame.size.width - mediaCropCornerControlSize.width / 2, y: -mediaCropCornerControlSize.height / 2, width: mediaCropCornerControlSize.width, height: mediaCropCornerControlSize.height))
        topRightCornerControl.autoresizingMask = .flexibleLeftMargin
        topRightCornerControl.hitTestEdgeInsets = UIEdgeInsets(top: -16, left: -16, bottom: -16, right: -16)
        return topRightCornerControl
    }()

    private lazy var bottomLeftCornerControl: MediaCropControl = {
        let bottomLeftCornerControl = MediaCropControl(frame: CGRect(x: -mediaCropCornerControlSize.width / 2, y: self.frame.size.height - mediaCropCornerControlSize.height / 2, width: mediaCropCornerControlSize.width, height: mediaCropCornerControlSize.height))
        bottomLeftCornerControl.autoresizingMask = .flexibleTopMargin
        bottomLeftCornerControl.hitTestEdgeInsets = UIEdgeInsets(top: -16, left: -16, bottom: -16, right: -16)
        return bottomLeftCornerControl
    }()

    private lazy var bottomRightCornerControl: MediaCropControl = {
        let bottomRightCornerControl = MediaCropControl(frame: CGRect(x: self.frame.size.width - mediaCropCornerControlSize.width / 2, y: self.frame.size.height - mediaCropCornerControlSize.height / 2, width: mediaCropCornerControlSize.width, height: mediaCropCornerControlSize.height))
        bottomRightCornerControl.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        bottomRightCornerControl.hitTestEdgeInsets = UIEdgeInsets(top: -16, left: -16, bottom: -16, right: -16)
        return bottomRightCornerControl
    }()

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
