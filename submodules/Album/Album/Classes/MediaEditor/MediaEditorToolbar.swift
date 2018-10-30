//
//  MediaEditorToolbar.swift
//  Components-Swift
//
//  Created by kingxt on 5/18/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import ReactiveSwift
import Core

class MediaEditorToolbar: UIView {

    public var didCancel: (() -> Void)?
    public var didConfirm: (() -> Void)?
    public var cropMediaCallback: (() -> Void)?

    private var editorButtons: [UIButton] = [UIButton]()
    private let taps: [UIImage]

    public private(set) var selectedIndex: MutableProperty<Int> = MutableProperty<Int>(0)

    init(taps: [UIImage]) {
        self.taps = taps
        super.init(frame: CGRect.zero)
        
        let backgroundView = UIView()
        addSubview(backgroundView)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        backgroundView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(200)
        }
        
        for image in taps {
            editorButtons.append(createEditButtons(image: image))
        }
        addSubview(cancelButton)
        addSubview(confirmButton)

        for (index, button) in editorButtons.enumerated() {
            addSubview(button)
            if index == selectedIndex.value {
                button.isSelected = true
            }
        }
    }

    func layout(isVerticalLayout: Bool) {
        if isVerticalLayout {
            let doneButtonWidth: CGFloat = max(40, confirmButton.frame.size.width)
            cancelButton.frame = CGRect(x: 0, y: 0, width: max(60.0, cancelButton.frame.size.width), height: 44)
            confirmButton.frame = CGRect(x: frame.size.width - doneButtonWidth, y: 0, width: doneButtonWidth, height: 44)
            if editorButtons.count == 1 {
                let button: UIView = editorButtons.first!
                button.frame = CGRect(x: frame.size.width / 2 - button.frame.size.width / 2, y: (frame.size.height - button.frame.size.height) / 2, width: button.frame.size.width, height: button.frame.size.height)
            } else if editorButtons.count == 2 {
                let leftButton: UIView = editorButtons.first!
                let rightButton: UIView = editorButtons.last!
                leftButton.frame = CGRect(x: frame.size.width / 5 * 2 - 5 - leftButton.frame.size.width / 2, y: (frame.size.height - leftButton.frame.size.height) / 2, width: leftButton.frame.size.width, height: leftButton.frame.size.height)
                rightButton.frame = CGRect(x: frame.size.width - leftButton.frame.origin.x - rightButton.frame.size.width, y: (frame.size.height - rightButton.frame.size.height) / 2, width: rightButton.frame.size.width, height: rightButton.frame.size.height)
            } else if editorButtons.count == 3 {
                let leftButton: UIView = editorButtons.first!
                let centerButton: UIView = editorButtons[1]
                let rightButton: UIView = editorButtons.last!
                centerButton.frame = CGRect(x: frame.size.width / 2 - centerButton.frame.size.width / 2, y: (frame.size.height - centerButton.frame.size.height) / 2, width: centerButton.frame.size.width, height: centerButton.frame.size.height)
                leftButton.frame = CGRect(x: frame.size.width / 6 * 2 - 5 - leftButton.frame.size.width / 2, y: (frame.size.height - leftButton.frame.size.height) / 2, width: leftButton.frame.size.width, height: leftButton.frame.size.height)
                rightButton.frame = CGRect(x: frame.size.width - leftButton.frame.origin.x - rightButton.frame.size.width, y: (frame.size.height - rightButton.frame.size.height) / 2, width: rightButton.frame.size.width, height: rightButton.frame.size.height)
            }
        } else {
            confirmButton.snp.remakeConstraints { make in
                make.centerX.equalTo(self)
                make.bottom.equalTo(self).offset(-10)
            }
            cancelButton.snp.remakeConstraints { make in
                make.centerX.equalTo(self)
                make.top.equalTo(self).offset(10)
            }
        }
    }

    @objc private func changeIndex(button: UIButton) {
        if button.isSelected {
            return
        }
        selectedIndex.value = editorButtons.index(of: button) ?? 0
        for button in editorButtons {
            button.isSelected = false
        }
        button.isSelected = true
    }

    @objc private func cancelClick() {
        didCancel?()
    }

    @objc private func confirmClick() {
        didConfirm?()
    }

    @objc private func cropMedia() {
        cropMediaCallback?()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func createEditButtons(image: UIImage) -> UIButton {
        let button = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 26, height: 26)))
        button.autoHighlight = true
        button.hitTestEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        button.addTarget(self, action: #selector(cropMedia), for: .touchUpInside)
        button.setImage(image, for: .normal)
        button.setImage(image.tintImage(color: UIColorRGB(0x171717)), for: .selected)
        button.setBackgroundImage(selectedImageBackground(size: CGSize(width: 26, height: 26)) ?? UIImage(), for: .selected)
        button.addTarget(self, action: #selector(changeIndex(button:)), for: .touchUpInside)
        return button
    }

    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle(SLLocalized("Common.Done"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(confirmClick), for: .touchUpInside)
        button.setTitleColor(.gray, for: .disabled)
        button.autoHighlight = true
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.setTitle(SLLocalized("MediaAssetsPicker.Cancel"), for: .normal)
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelClick), for: .touchUpInside)
        cancelButton.setTitleColor(.gray, for: .disabled)
        cancelButton.autoHighlight = true
        return cancelButton
    }()

    private func selectedImageBackground(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context: CGContext? = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColorRGB(0xD1D1D1).cgColor)
        let path = UIBezierPath(roundedRect: CGRect(origin: CGPoint.zero, size: size), cornerRadius: 2)
        path.fill()
        let selectionBackground = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets(top: frame.size.height / 4.0, left: frame.size.height / 4.0, bottom: frame.size.height / 4.0, right: frame.size.height / 4.0))
        UIGraphicsEndImageContext()
        return selectionBackground
    }
}
