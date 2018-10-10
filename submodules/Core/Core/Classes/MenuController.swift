//
//  MenuController.swift
//  Components
//
//  Created by kingxt on 6/28/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

private class MenuButton: UIButton {

    fileprivate var isMultiline = false
    fileprivate var maxWidth: CGFloat = 100
    fileprivate var onHighlighted: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        highlightedView.backgroundColor = UIColor(white: 1.0, alpha: 0.25)
        addSubview(highlightedView)
        highlightedView.isHidden = true
    }

    override var isHighlighted: Bool {
        didSet {
            super.isHighlighted = isHighlighted
            super.isHighlighted = isHighlighted || isSelected
            highlightedView.isHidden = !(isHighlighted || isSelected)
            onHighlighted?()
        }
    }

    override var isSelected: Bool {
        didSet {
            super.isSelected = isSelected
            super.isSelected = isSelected || isHighlighted
            highlightedView.isHidden = !(isHighlighted || isSelected)
            onHighlighted?()
        }
    }

    override func sizeToFit() {
        let title: NSString = (attributedTitle(for: .normal)?.string ?? "") as NSString
        guard let titleLabel = self.titleLabel else {
            return super.sizeToFit()
        }
        if isMultiline {
            let size = title.boundingRect(with: CGSize(width: maxWidth - 18.0, height: CGFloat.greatestFiniteMagnitude), options: .usesFontLeading, attributes: [NSAttributedString.Key.font: titleLabel.font], context: nil)
            frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: ceil(size.width) + 18, height: max(41.0, ceil(size.height) + 20.0))
        } else {
            frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: title.size(withAttributes: [NSAttributedString.Key.font: titleLabel.font]).width + 34, height: 41)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        highlightedView.frame = CGRect(x: 0, y: -20.0, width: frame.size.width, height: frame.size.height + 40.0)
    }

    private lazy var highlightedView: UIView = {
        UIView()
    }()

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class MenuController: UIView, UIScrollViewDelegate {

    public var maxWidth: CGFloat = 310
    public var forceArrowOnTop: Bool = false
    public var multiline: Bool = false

    private var arrowLocation: CGFloat = 50
    private var buttonViews: [MenuButton] = [MenuButton]()
    private var separatorViews: [UIImageView] = [UIImageView]()
    private var arrowOnTop: Bool = false
    private var containerMaskView: UIImageView?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        alpha = 0
        layer.anchorPoint = CGPoint.zero
        transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        addSubvews()
    }

    private func addSubvews() {
        addSubview(arrowTopView)
        addSubview(arrowBottomView)
        addSubview(buttonContainerContainer)
        buttonContainerContainer.addSubview(effectView)
        buttonContainerContainer.addSubview(backgroundView)
        buttonContainerContainer.addSubview(buttonContainer)
        addSubview(leftPagerButton)
        addSubview(rightPagerButton)
    }

    public func addAction(title: String, handler: @escaping (MenuController) -> Void) {
        addAction(title: NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]), handler: handler)
    }

    @objc(addAttributedAction:handler:) public func addAction(title: NSAttributedString, handler: @escaping (MenuController) -> Void) {
        let buttonView = MenuButton()
        if multiline {
            buttonView.titleLabel?.numberOfLines = 0
            buttonView.isMultiline = true
            buttonView.maxWidth = maxWidth
        }
        buttonView.setTitleColor(UIColor.white, for: .normal)
        buttonView.setTitleColor(UIColorRGBA(0xFFFFFF, 0.5), for: .disabled)
        buttonView.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        buttonView.setAttributedTitle(title, for: .normal)
        buttonView.reactive.controlEvents(.touchUpInside).observeValues { [weak self] _ in
            if let strongSelf = self {
                handler(strongSelf)
                strongSelf.hide()
            }
        }
        buttonViews.append(buttonView)
    }

    private func layoutButtons() {
        for buttonView: MenuButton in buttonViews {
            buttonContainer.addSubview(buttonView)
        }
        if buttonViews.count != 0 {
            while separatorViews.count < buttonViews.count - 1 {
                let separatorView: UIImageView = UIImageView()
                separatorView.backgroundColor = highlightColor()
                buttonContainer.addSubview(separatorView)
                separatorViews.append(separatorView)
            }
        }
        if buttonViews.count != 0 {
            while separatorViews.count > buttonViews.count - 1 {
                let separatorView: UIImageView? = separatorViews.last
                separatorView?.removeFromSuperview()
                separatorViews.removeLast()
            }
        }

        var index: Int = -1
        for buttonView: MenuButton in buttonViews {
            index += 1
            buttonView.sizeToFit()
            if index == 0 || index == Int(buttonViews.count) - 1 {
                var buttonFrame: CGRect = buttonView.frame
                buttonFrame.size.width += 1
                buttonView.frame = buttonFrame
            }
        }
        updateBackgrounds()
        setNeedsLayout()
    }

    private func updateBackgrounds() {
        for buttonView: MenuButton in buttonViews {
            let titleInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0)
            buttonView.titleEdgeInsets = titleInset
        }
    }

    public override func sizeToFit() {
        var transform: CGAffineTransform = self.transform
        transform = CGAffineTransform.identity
        var buttonHeight: CGFloat = 41.0
        var pages = [[MenuButton]]()
        var currentPageButtons = [MenuButton]()
        var currentPageWidth: CGFloat = 0.0

        for buttonView: MenuButton in buttonViews {
            let buttonWidth: CGFloat = buttonView.frame.size.width
            var added: Bool = false
            if currentPageWidth + buttonWidth > maxWidth {
                if currentPageButtons.count == 0 {
                    currentPageButtons.append(buttonView)
                    added = true
                }
                pages.append(currentPageButtons)
                currentPageButtons = [MenuButton]()
                currentPageWidth = 0.0
            }
            if !added {
                currentPageWidth += buttonWidth
                currentPageButtons.append(buttonView)
            }
        }

        if currentPageButtons.count != 0 {
            pages.append(currentPageButtons)
        }

        var maxPageWidth: CGFloat = 0.0
        var pageIndex: Int = -1
        for buttons: [MenuButton] in pages {
            var sumWidth: CGFloat = 0.0
            var buttonIndex: Int = -1
            for button: MenuButton in buttons {
                button.sizeToFit()
                buttonIndex += 1
                if buttonIndex != 0 {
                    sumWidth += 1.0
                }
                sumWidth += button.frame.size.width
                if multiline {
                    buttonHeight = max(buttonHeight, button.frame.size.height)
                }
            }
            if pages.count > 1 {
                if pageIndex == Int(pages.count) - 1 {
                    sumWidth += pagerButtonWidth
                } else {
                    sumWidth += pagerButtonWidth * 2.0
                }
            }
            maxPageWidth = max(maxPageWidth, min(maxWidth, sumWidth))
        }

        var nextSeparatorIndex: Int = 0
        let diff: CGFloat = buttonHeight - 41.0
        var currentPageStart: CGFloat = 0.0
        pageIndex = -1

        for buttons: [MenuButton] in pages {
            pageIndex += 1
            var sumWidth: CGFloat = 0.0
            var buttonIndex: Int = -1
            for button: MenuButton in buttons {
                buttonIndex += 1
                if buttonIndex != 0 {
                    sumWidth += 1.0
                }
                sumWidth += button.frame.size.width
            }

            var leftOffset: CGFloat = 0.0
            var pageContentWidth: CGFloat = maxPageWidth
            if pages.count > 1 {
                if pageIndex == 0 {
                    pageContentWidth -= pagerButtonWidth
                } else if pageIndex == Int(pages.count) - 1 {
                    leftOffset = pagerButtonWidth
                    pageContentWidth -= pagerButtonWidth
                } else {
                    leftOffset = pagerButtonWidth
                    pageContentWidth -= pagerButtonWidth * 2.0
                }
            }

            let factor: CGFloat = pageContentWidth / sumWidth
            var buttonStart: CGFloat = currentPageStart + leftOffset
            buttonIndex = -1
            for button: UIView in buttons {
                buttonIndex += 1
                if buttonIndex != 0 {
                    let separatorView: UIView = separatorViews[nextSeparatorIndex]
                    separatorView.frame = CGRect(x: buttonStart, y: 0, width: 1, height: 36.0 + 20.0)
                    buttonStart += 1.0
                    nextSeparatorIndex += 1
                }
                var buttonWidth: CGFloat = floor(button.frame.size.width * factor)
                if buttonIndex == buttons.count - 1 {
                    buttonWidth = max(buttonWidth, currentPageStart + leftOffset + pageContentWidth - buttonStart)
                }
                button.frame = CGRect(x: buttonStart, y: -2.0 + 10.0, width: buttonWidth, height: button.frame.size.height)
                buttonStart += buttonWidth
            }
            currentPageStart += maxPageWidth
        }

        buttonContainerContainer.frame = CGRect(x: 0, y: 2.0 - 10.0, width: maxPageWidth, height: 36.0 + 20.0 + diff)
        buttonContainer.frame = buttonContainerContainer.bounds
        buttonContainer.contentSize = CGSize(width: maxPageWidth * CGFloat(pages.count), height: buttonContainer.frame.size.height)
        buttonContainer.contentOffset = CGPoint.zero
        leftPagerButton.frame = CGRect(x: 0, y: 2.0, width: pagerButtonWidth, height: 36.0)
        rightPagerButton.frame = CGRect(x: maxPageWidth - pagerButtonWidth, y: 2.0, width: pagerButtonWidth, height: 36.0)
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: maxPageWidth, height: buttonHeight)

        let minArrowX: CGFloat = 10.0
        let maxArrowX: CGFloat = frame.size.width - 10.0
        var arrowX: CGFloat = floor(arrowLocation - arrowTopView.frame.size.width / 2)
        arrowX = min(max(minArrowX, arrowX), maxArrowX)
        arrowTopView.frame = CGRect(x: arrowX, y: -9.5, width: arrowTopView.frame.size.width, height: arrowTopView.frame.size.height)
        arrowBottomView.frame = CGRect(x: arrowX, y: 37.0 + diff, width: arrowBottomView.frame.size.width, height: arrowBottomView.frame.size.height)
        arrowTopView.isHidden = !arrowOnTop
        arrowBottomView.isHidden = arrowOnTop
        if containerMaskView == nil {
            containerMaskView = UIImageView()
        }

        containerMaskView?.image = highlightMask()
        containerMaskView?.sizeToFit()
        buttonContainerContainer.layer.mask = containerMaskView?.layer
        scrollViewDidScroll(buttonContainer)
        self.transform = transform
    }

    func sizeToFit(maxWidth: CGFloat) {
        self.maxWidth = maxWidth - 20.0
        sizeToFit()
    }

    public func show(in view: UIView, from rect: CGRect) {
        show(in: view, from: rect, animated: true)
    }

    public func show(in view: UIView, from rect: CGRect, animated: Bool) {
        view.addSubview(self)
        let transform: CGAffineTransform = self.transform
        self.transform = CGAffineTransform.identity

        layoutButtons()
        sizeToFit(maxWidth: view.frame.size.width)

        var frame: CGRect = self.frame
        frame.origin.x = floor(rect.origin.x + rect.size.width / 2 - frame.size.width / 2)
        if frame.origin.x < 4 {
            frame.origin.x = 4
        }
        if frame.origin.x + frame.size.width > view.frame.size.width - 4 {
            frame.origin.x = view.frame.size.width - 4 - frame.size.width
        }
        frame.origin.y = rect.origin.y - frame.size.height - 14
        if forceArrowOnTop {
            arrowOnTop = true
        } else {
            if frame.origin.y < 2 {
                frame.origin.y = rect.origin.y + rect.size.height + 17
                if frame.origin.y + frame.size.height > view.frame.size.height - 14 {
                    frame.origin.y = floor((view.frame.size.height - frame.size.height) / 2)
                    arrowOnTop = false
                } else {
                    arrowOnTop = true
                }
            } else {
                arrowOnTop = false
            }
        }

        arrowLocation = floor(rect.origin.x + rect.size.width / 2) - frame.origin.x
        layer.anchorPoint = CGPoint(x: CGFloat(max(0.0, min(1.0, arrowLocation / frame.size.width))), y: CGFloat(arrowOnTop ? -0.2 : 1.2))
        self.frame = frame
        sizeToFit()
        self.transform = transform
        layer.rasterizationScale = UIScreen.main.scale
        layer.shouldRasterize = true
        alpha = 1.0

        if animated {
            UIView.animate(withDuration: 0.142, delay: 0, options: [.curveEaseOut, .beginFromCurrentState], animations: { () -> Void in
                self.transform = CGAffineTransform(scaleX: 1.07, y: 1.07)
            }, completion: { (_ finished: Bool) -> Void in
                if finished {
                    UIView.animate(withDuration: 0.08, delay: 0, options: .beginFromCurrentState, animations: { () -> Void in
                        self.transform = CGAffineTransform(scaleX: 0.967, y: 0.967)
                    }, completion: { (_ finished: Bool) -> Void in
                        if finished {
                            UIView.animate(withDuration: 0.06, delay: 0, options: [.curveEaseOut, .beginFromCurrentState], animations: { () -> Void in
                                self.transform = CGAffineTransform.identity
                            }, completion: { (_ finished: Bool) -> Void in
                                if finished {
                                    self.layer.shouldRasterize = false
                                }
                            })
                        }
                    })
                }
            })
        } else {
            self.transform = .identity
            alpha = 0.0
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.alpha = 1.0
            })
        }
    }

    public func hide(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState, animations: { () -> Void in
            self.alpha = 0.0
        }, completion: { (_ finished: Bool) -> Void in
            if finished {
                self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                completion?()
            }
        })
    }

    @objc private func pagerButtonPressed(button: UIButton) {
        var targetOffset: CGFloat = buttonContainer.contentOffset.x
        if button == leftPagerButton {
            let page = Int(buttonContainer.contentOffset.x) / Int(buttonContainer.bounds.size.width)
            if page > 0 {
                targetOffset = CGFloat(page - 1) * buttonContainer.bounds.size.width
            }
        } else if button == rightPagerButton {
            let page = Int(buttonContainer.contentOffset.x) / Int(buttonContainer.bounds.size.width)
            if page + 1 < Int(buttonContainer.contentSize.width / buttonContainer.bounds.size.width) {
                targetOffset = CGFloat(page + 1) * buttonContainer.bounds.size.width
            }
        }
        if abs(targetOffset - buttonContainer.contentOffset.x) > CGFloat.ulpOfOne {
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
                self.buttonContainer.contentOffset = CGPoint(x: targetOffset, y: 0)
            })
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == buttonContainer {
            if scrollView.contentSize.width > scrollView.bounds.size.width + CGFloat.ulpOfOne {
                let leftDistance: CGFloat = scrollView.contentOffset.x
                let rightDistance: CGFloat = scrollView.contentSize.width - (scrollView.contentOffset.x + scrollView.bounds.size.width)
                leftPagerButton.alpha = max(0.0, min(1.0, leftDistance / leftPagerButton.frame.size.width))
                rightPagerButton.alpha = max(0.0, min(1.0, rightDistance / rightPagerButton.frame.size.width))
            } else {
                leftPagerButton.alpha = 0.0
                rightPagerButton.alpha = 0.0
            }
        }
        leftPagerButton.isHidden = leftPagerButton.alpha <= 0
        rightPagerButton.isHidden = rightPagerButton.alpha <= 0
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result: UIView? = super.hitTest(point, with: event)
        if result == self || result == nil {
            hide()
            return nil
        }
        return result
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate lazy var arrowTopView: UIImageView = {
        let arrowTopView = UIImageView()
        arrowTopView.frame = CGRect(x: 0, y: 0, width: 20.0, height: 12.0)
        return arrowTopView
    }()

    fileprivate lazy var arrowBottomView: UIImageView = {
        let arrowBottomView = UIImageView()
        arrowBottomView.frame = CGRect(x: 0, y: 0, width: 20.0, height: 14.5)
        return arrowBottomView
    }()

    fileprivate lazy var buttonContainerContainer: UIView = {
        UIView()
    }()

    private lazy var effectView: UIVisualEffectView = {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectView.frame = CGRect(x: 0, y: -20.0, width: 0.0, height: 40.0)
        return effectView
    }()

    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.frame = self.effectView.frame
        return view
    }()

    fileprivate lazy var buttonContainer: UIScrollView = {
        let buttonContainer = UIScrollView()
        buttonContainer.clipsToBounds = true
        buttonContainer.alwaysBounceHorizontal = false
        buttonContainer.alwaysBounceVertical = false
        buttonContainer.showsHorizontalScrollIndicator = false
        buttonContainer.showsVerticalScrollIndicator = false
        buttonContainer.isPagingEnabled = true
        buttonContainer.delaysContentTouches = false
        buttonContainer.canCancelContentTouches = true
        buttonContainer.delegate = self
        buttonContainer.isScrollEnabled = false
        return buttonContainer
    }()

    private lazy var leftPagerButton: UIButton = {
        let leftPagerButton = UIButton()
        leftPagerButton.setBackgroundImage(self.pagerLeftButtonImage(), for: .normal)
        leftPagerButton.setBackgroundImage(self.pagerLeftButtonHighlightedImage(), for: .highlighted)
        leftPagerButton.addTarget(self, action: #selector(self.pagerButtonPressed), for: .touchUpInside)
        return leftPagerButton
    }()

    private lazy var rightPagerButton: UIButton = {
        let rightPagerButton = UIButton()
        rightPagerButton.setBackgroundImage(self.pagerLeftButtonImage(), for: .normal)
        rightPagerButton.setBackgroundImage(self.pagerLeftButtonHighlightedImage(), for: .highlighted)
        rightPagerButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        rightPagerButton.addTarget(self, action: #selector(self.pagerButtonPressed), for: .touchUpInside)
        return rightPagerButton
    }()
}

private let pagerButtonWidth: CGFloat = 32
private let diameter: CGFloat = 16.0

fileprivate extension MenuController {

    fileprivate func highlightMask() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(buttonContainer.bounds.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setFillColor(UIColor.white.cgColor)
        menuBackgroundMask()?.draw(in: CGRect(x: 0, y: 10.0, width: buttonContainer.bounds.size.width, height: buttonContainer.bounds.size.height - 20.0))

        if !arrowBottomView.isHidden {
            var arrow: CGPoint = arrowBottomView.convert(arrowBottomView.bounds, to: buttonContainerContainer).origin
            arrow.x += 1.0
            context.beginPath()
            context.move(to: CGPoint(x: CGFloat(arrow.x), y: CGFloat(arrow.y)))
            context.addLine(to: CGPoint(x: CGFloat(arrow.x + 18.0), y: CGFloat(arrow.y)))
            context.addLine(to: CGPoint(x: CGFloat(arrow.x + 18.0 / 2.0), y: CGFloat(arrow.y + 10.0)))
            context.closePath()
            context.fillPath()
        } else if !arrowTopView.isHidden {
            var arrow: CGPoint = arrowTopView.convert(arrowTopView.bounds, to: buttonContainerContainer).origin
            arrow.x += 1.0
            arrow.y += 1.0
            context.beginPath()
            context.move(to: CGPoint(x: CGFloat(arrow.x), y: CGFloat(arrow.y + 10.0)))
            context.addLine(to: CGPoint(x: CGFloat(arrow.x + 18.0 / 2.0), y: CGFloat(arrow.y)))
            context.addLine(to: CGPoint(x: CGFloat(arrow.x + 18.0), y: CGFloat(arrow.y + 10.0)))
            context.closePath()
            context.fillPath()
        }
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    func menuBackgroundMask() -> UIImage? {
        let color = UIColor.white
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: CGRect(x: CGFloat(0.0), y: 0, width: diameter, height: diameter))
        let image = UIGraphicsGetImageFromCurrentImageContext()?.stretchableImage(withLeftCapWidth: NSInteger(diameter / 2.0), topCapHeight: NSInteger(diameter / 2.0))
        UIGraphicsEndImageContext()
        return image
    }

    func pagerLeftButtonImage() -> UIImage? {
        let size = CGSize(width: pagerButtonWidth, height: 36.0)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setFillColor(UIColor.white.cgColor)
        context.saveGState()
        context.translateBy(x: size.width / 2.0, y: size.height / 2.0)
        context.scaleBy(x: -0.5, y: 0.5)
        context.translateBy(x: -size.width / 2.0 + 8.0, y: -size.height / 2.0 + 7.0)
        drawSvgPath(context: context, path: "M0,0 L0,22 L18,11 L0,0 L0,0 Z ")
        context.setFillColor(highlightColor().cgColor)
        context.restoreGState()
        context.setFillColor(highlightColor().cgColor)
        context.fill(CGRect(x: size.width - 1.0, y: 0, width: 1.0, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    func pagerLeftButtonHighlightedImage() -> UIImage? {
        let size = CGSize(width: pagerButtonWidth, height: 36.0)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setFillColor(highlightColor().cgColor)
        menuHighlightedBackground()?.draw(in: CGRect(x: 0, y: 0, width: size.width * 2.0, height: size.height))
        context.setFillColor(UIColor.white.cgColor)
        context.saveGState()
        context.translateBy(x: size.width / 2.0, y: size.height / 2.0)
        context.scaleBy(x: -0.5, y: 0.5)
        context.translateBy(x: -size.width / 2.0 + 8.0, y: -size.height / 2.0 + 7.0)
        drawSvgPath(context: context, path: "M0,0 L0,22 L18,11 L0,0 L0,0 Z ")
        context.setFillColor(highlightColor().cgColor)
        context.restoreGState()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    func menuHighlightedBackground() -> UIImage? {
        let color: UIColor = highlightColor()
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: CGRect(x: 0, y: 0, width: diameter, height: diameter))
        let image = UIGraphicsGetImageFromCurrentImageContext()?.stretchableImage(withLeftCapWidth: NSInteger(diameter / 2.0), topCapHeight: NSInteger(diameter / 2.0))
        UIGraphicsEndImageContext()
        return image
    }

    func highlightColor() -> UIColor {
        return UIColor(white: 1.0, alpha: 0.25)
    }
}
