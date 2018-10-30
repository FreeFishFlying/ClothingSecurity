//
//  ActionSheetView.swift
//  Components-Swift
//
//  Created by Dylan on 17/05/2017.
//  Copyright © 2017 liao. All rights reserved.
//

import UIKit
import SnapKit
import ReactiveSwift
import Result
import pop
import Core

public class ActionSheetViewController: OverlayViewController {
    
    private weak var fatherViewController: UIViewController? = nil
    
    private lazy var actionSheetView: ActionSheetView = {
        let actionSheetView = ActionSheetView(frame: CGRect.zero)
        actionSheetView.actionSheetController = self
        return actionSheetView
    }()
    
    public let (dismissSignal, dismissObserver) = Signal<ActionSheetViewController, NoError>.pipe()
    
    public var contentBackgroundColor: UIColor = UIColor.white {
        didSet {
            actionSheetView.containerView.backgroundColor = contentBackgroundColor
            actionSheetView.itemContentView.backgroundColor = contentBackgroundColor
        }
    }
    
    public var headerSeperatorBackgroundColor: UIColor = UIColor.white {
        didSet {
            actionSheetView.separatorView.backgroundColor = headerSeperatorBackgroundColor
        }
    }
    
    public func show(animated: Bool, completion: ((Bool) -> Void)?) {
        super.show()
        present(animated: animated, completion: completion)
    }
    
    public func show(viewController: UIViewController, animated: Bool, completion: ((Bool) -> Void)?) {
        viewController.view.endEditing(true)
        fatherViewController = viewController
        viewController.addChild(self)
        viewController.view.addSubview(self.view)
        present(animated: animated, completion: completion)
    }
    
    private func present(animated: Bool, completion: ((Bool) -> Void)?) {
        if actionSheetView.superview == nil {
            view.addSubview(actionSheetView)
            actionSheetView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        if animated {
            actionSheetView.animateIn(completion: completion)
        } else {
            if let callback = completion {
                callback(true)
            }
        }
    }
    
    public func dismiss(animated: Bool) {
        if animated {
            actionSheetView.animationOut(velocity: 0.0) { () in
                self.finishDimiss()
            }
        } else {
            finishDimiss()
        }
    }
    
    fileprivate func finishDimiss() {
        dismissObserver.send(value: self)
        if fatherViewController != nil {
            self.view.removeFromSuperview()
            self.removeFromParent()
        } else {
            dismiss()
        }
    }
    
    public func invalidatePreferredHeight() {
        actionSheetView.updateLayout(animated: false)
    }
    
    public func setActionSheetHeaderView(_ newHeaderView: ActionSheetItemView?) {
        newHeaderView?.actionSheetController = self
        actionSheetView.setActionSheetHeaderView(newHeaderView)
    }
    
    public func setActionSheetFooterView(_ newFooterView: ActionSheetItemView?) {
        newFooterView?.actionSheetController = self
        actionSheetView.setActionSheetFooterView(newFooterView)
    }
    
    public func setActionSheetItems(_ newItems: [ActionSheetItemView]?) {
        if let newItems = newItems {
            for item in newItems {
                item.actionSheetController = self
            }
        }
        actionSheetView.setActionSheetItems(newItems)
    }
    
    public var tapAnywhereToDismiss: Bool = true {
        didSet {
            actionSheetView.tapToDismissGesture.isEnabled = tapAnywhereToDismiss
            actionSheetView.panRecognizer.isEnabled = tapAnywhereToDismiss
        }
    }
}

private class ActionSheetView: UIView {
    
    private var headerView: ActionSheetItemView?
    private var footerView: ActionSheetItemView?
    private var itemViews: [ActionSheetItemView]?
    private var itemsHeight: CGFloat = 0.0
    
    private let backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        return backgroundView
    }()
    
    fileprivate let containerView: ActionSheetEventThroughView = {
        let containerView = ActionSheetEventThroughView()
        containerView.backgroundColor = UIColor.clear
        return containerView
    }()
    
    fileprivate let itemContentView: UIView = {
        let itemContentView = UIView()
        itemContentView.backgroundColor = UIColor.white
        return itemContentView
    }()
    
    fileprivate let separatorView: UIView = {
        let separatorView = UIView()
        separatorView.backgroundColor = UIColorRGB(0xDCDCDC)
        return separatorView
    }()
    
    weak var actionSheetController: ActionSheetViewController?
    private var containerHeigthConstraint: Constraint?
    private var footerViewBottomConstraint: Constraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(backgroundView)
        addSubview(containerView)
        containerView.addSubview(itemContentView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        containerView.snp.makeConstraints { make in
            make.right.left.bottom.equalToSuperview()
            containerHeigthConstraint = make.height.equalTo(0).constraint
        }
        itemContentView.snp.makeConstraints { make in
            make.right.left.bottom.equalToSuperview()
            make.height.equalTo(0)
        }
        addGestureRecognizer(panRecognizer)
        backgroundView.addGestureRecognizer(tapToDismissGesture)
        tapToDismissGesture.require(toFail: panRecognizer)
    }
    
    lazy var panRecognizer = DirectionPanGestureRecognizer(direction: .vertical, target: self, action: #selector(panHandle))
    
    fileprivate lazy var tapToDismissGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapHandle))
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func panHandle(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            break
        case .changed:
            let translation = pan.translation(in: self)
            let offset = translation.y < 0 ? 0 : translation.y
            containerView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().offset(offset)
            }
        case .ended:
            let velocity = pan.velocity(in: self)
            let offset = pan.translation(in: self)
            if offset.y >= 100 {
                animationOut(velocity: velocity.y, completion: {
                    self.actionSheetController?.finishDimiss()
                })
            } else {
                animationToDefault(velocity: velocity.y)
            }
        case .cancelled:
            let velocity = pan.velocity(in: self)
            animationToDefault(velocity: velocity.y)
        default:
            break
        }
    }
    
    @objc private func tapHandle(tap _: UITapGestureRecognizer) {
        animationOut(velocity: 0.0) {
            self.actionSheetController?.finishDimiss()
        }
    }
    
    func setActionSheetHeaderView(_ newHeaderView: ActionSheetItemView?) {
        if headerView != nil {
            headerView?.removeFromSuperview()
            separatorView.removeFromSuperview()
        }
        headerView = newHeaderView
        if let headerView = newHeaderView {
            containerView.addSubview(headerView)
            headerView.snp.makeConstraints { make in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(headerView.preferredHeight)
            }
            containerView.addSubview(separatorView)
            separatorView.snp.makeConstraints { make in
                make.left.equalTo(10)
                make.right.equalTo(-10)
                make.height.equalTo(0.5)
                make.bottom.equalTo(headerView.snp.bottom)
            }
        }
        updateLayout(animated: false)
    }
    
    func setActionSheetFooterView(_ newFooterView: ActionSheetItemView?) {
        if footerView == newFooterView {
            return
        }
        
        let needRemoveView = footerView
        
        footerView = newFooterView
        if let footerView = newFooterView {
            containerView.addSubview(footerView)
            footerView.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                footerViewBottomConstraint = make.bottom.equalToSuperview().offset(0).constraint
                make.height.equalTo(footerView.preferredHeight)
            }
            footerView.alpha = 0.0
            containerView.layoutIfNeeded()
            updateLayout(animated: true)
            UIView.animate(withDuration: 0.3, animations: {
                footerView.alpha = 1
                needRemoveView?.alpha = 0.0
            }, completion: { _ in
                needRemoveView?.alpha = 1.0
                needRemoveView?.removeFromSuperview()
            })
        } else {
            let animator = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
            animator?.toValue = (needRemoveView?.frame.size.height ?? 0) - itemsHeight
            animator?.duration = 0.3
            footerViewBottomConstraint?.layoutConstraint?.pop_add(animator, forKey: "animationBottom")
            UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveLinear, animations: {
                needRemoveView?.alpha = 0.0
            }, completion: { _ in
                needRemoveView?.alpha = 1.0
                needRemoveView?.removeFromSuperview()
            })
        }
        updateLayout(animated: true)
    }
    
    func setActionSheetItems(_ newItems: [ActionSheetItemView]?) {
        for subview in itemContentView.subviews {
            subview.removeFromSuperview()
        }
        itemViews = newItems
        itemsHeight = 0
        
        var baseView: UIView?
        if let items = newItems {
            for (index, item) in items.enumerated() {
                itemContentView.addSubview(item)
                if baseView == nil {
                    item.snp.makeConstraints { make in
                        make.right.left.top.equalToSuperview()
                        make.height.equalTo(item.preferredHeight)
                    }
                } else {
                    item.snp.makeConstraints { make in
                        make.right.left.equalToSuperview()
                        make.top.equalTo(baseView!.snp.bottom)
                        make.height.equalTo(item.preferredHeight)
                    }
                }
                itemsHeight += item.preferredHeight
                baseView = item
                if index == items.count - 1 {
                    var safeAreaBottom: CGFloat = 0
                    if #available(iOS 11.0, *) {
                        safeAreaBottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
                    }
                    if safeAreaBottom > 0 {
                        let spaceView = UIView()
                        spaceView.backgroundColor = baseView?.backgroundColor
                        itemContentView.addSubview(spaceView)
                        spaceView.snp.makeConstraints { make in
                            make.right.left.equalToSuperview()
                            make.top.equalTo(baseView!.snp.bottom)
                            make.height.equalTo(safeAreaBottom)
                        }
                        itemsHeight += safeAreaBottom
                    }
                }
            }
        }
        updateLayout(animated: false)
    }
    
    func updateLayout(animated: Bool) {
        if let headerView = self.headerView {
            headerView.snp.updateConstraints { make in
                make.height.equalTo(headerView.preferredHeight)
            }
        }
        if !animated {
            containerView.snp.updateConstraints { make in
                make.height.equalTo(self.preferredHeight)
            }
        }
        itemContentView.snp.updateConstraints { make in
            make.height.equalTo(itemsHeight)
        }
        if animated {
            let animator = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
            animator?.toValue = self.preferredHeight
            animator?.duration = 0.3
            containerHeigthConstraint?.layoutConstraint?.pop_add(animator, forKey: "animationHeight")
        }
    }
    
    private var preferredHeight: CGFloat {
        if let footerView = footerView {
            return footerView.preferredHeight + (headerView?.preferredHeight ?? 0)
        } else {
            return itemsHeight + (headerView?.preferredHeight ?? 0)
        }
    }
    
    public func animateIn(completion: ((Bool) -> Void)?) {
        backgroundView.alpha = 0.0
        containerView.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(preferredHeight)
        }
        layoutIfNeeded()
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
            self.containerView.snp.updateConstraints { make in
                make.bottom.equalToSuperview()
            }
            self.layoutIfNeeded()
            self.backgroundView.alpha = 1
        }, completion: completion)
    }
    
    fileprivate func animationOut(velocity: CGFloat, completion: (() -> Void)? = nil) {
        let minVelocity: CGFloat = 300.0
        var v = velocity
        if abs(velocity) < minVelocity {
            v = (velocity < 0.0 ? -1.0 : 1.0) * minVelocity
        }
        let distance: CGFloat = containerView.frame.origin.y
        let duration: TimeInterval = min(0.3, Double(abs(distance) / v))
        containerView.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(preferredHeight)
        }
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: {
            self.layoutIfNeeded()
            self.backgroundView.alpha = 0.0
        }) { _ in
            self.backgroundView.alpha = 1.0
            if completion != nil {
                completion?()
            }
        }
    }
    
    fileprivate func animationToDefault(velocity _: CGFloat) {
        containerView.snp.updateConstraints { make in
            make.bottom.equalToSuperview()
        }
        UIView.animate(withDuration: 0.25) {
            self.containerView.layoutIfNeeded()
        }
    }
}
