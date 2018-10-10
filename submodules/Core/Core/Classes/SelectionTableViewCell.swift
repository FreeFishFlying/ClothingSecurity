//
//  ChatMediaController.swift
//  Love
//
//  Created by kingxt on 7/23/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import ReactiveSwift
import Result

open class SelectionTableViewCell: UITableViewCell {

    private var contentLeftConstranit: Constraint?
    private var itemInformativeSelectedDisposable: Disposable?

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.snp.remakeConstraints({ make in
            contentLeftConstranit = make.left.equalTo(0).constraint
            make.right.bottom.top.equalToSuperview()
        })
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open lazy var checkButton: CheckButtonView = {
        let checkButton = CheckButtonView()
        checkButton.addTarget(self, action: #selector(self.checkButtonPressed), for: .touchUpInside)
        return checkButton
    }()

    @objc private func checkButtonPressed() {
        onCheckButtonPressed(isChecked: checkButton.isSelected)
    }

    open func onCheckButtonPressed(isChecked _: Bool) {
    }

    open override func setEditing(_ editing: Bool, animated: Bool) {
        if editing {
            addSubview(checkButton)
            contentLeftConstranit?.layoutConstraint?.constant = 50
            if animated {
                checkButton.frame = CGRect(origin: CGPoint(x: -50, y: (frame.size.height - checkButton.frame.size.height) / 2), size: checkButton.frame.size)
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    self.checkButton.frame = CGRect(origin: CGPoint(x: 15, y: (self.frame.size.height - self.checkButton.frame.size.height) / 2), size: self.checkButton.frame.size)
                    self.layoutIfNeeded()
                }, completion: { _ in
                })
            } else {
                checkButton.frame = CGRect(origin: CGPoint(x: 15, y: (frame.size.height - checkButton.frame.size.height) / 2), size: checkButton.frame.size)
            }
        } else {
            contentLeftConstranit?.layoutConstraint?.constant = 0
            if animated {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    self.checkButton.frame = CGRect(origin: CGPoint(x: -50, y: (self.frame.size.height - self.checkButton.frame.size.height) / 2), size: self.checkButton.frame.size)
                    self.layoutIfNeeded()
                }, completion: { _ in
                    self.checkButton.removeFromSuperview()
                })
            } else {
                checkButton.removeFromSuperview()
            }
        }
    }

    open func bindingAction(selectionContext: SelectionContext, item: SelectableItem, animated: Bool) {
        itemInformativeSelectedDisposable?.dispose()
        checkButton.setChecked(selectionContext.isItemSelected(item), animated: animated)
        isSelected = checkButton.isSelected
        itemInformativeSelectedDisposable = selectionContext.itemInformativeSelectedSignal(item: item).take(during: reactive.lifetime).startWithValues({ [weak self] (change: SelectionChange) in
            if let strongSelf = self {
                strongSelf.checkButton.setChecked(change.selected, animated: change.animated)
                strongSelf.isSelected = strongSelf.checkButton.isSelected
            }
        })
    }
}
