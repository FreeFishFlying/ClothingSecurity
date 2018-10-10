//
//  VerticalLayoutButton.swift
//  Components
//
//  Created by kingxt on 7/3/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import UIKit

open class VerticalLayoutButton: UIButton {

    open var kTextTopPadding: CGFloat = 3

    open override func layoutSubviews() {
        super.layoutSubviews()

        var titleLabelFrame: CGRect = titleLabel?.frame ?? CGRect.zero
        let labelSize: CGRect = titleLabel?.text?.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: bounds.height), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: titleLabel!.font], context: nil) ?? CGRect.zero
        var imageFrame: CGRect = imageView?.frame ?? CGRect.zero
        var fitBoxSize = CGSize()
        fitBoxSize.height = labelSize.size.height + kTextTopPadding + imageFrame.size.height
        fitBoxSize.width = max(imageFrame.size.width, labelSize.size.width)
        let fitBoxRect: CGRect = bounds.insetBy(dx: (bounds.size.width - fitBoxSize.width) / 2, dy: (bounds.size.height - fitBoxSize.height) / 2)
        imageFrame.origin.y = fitBoxRect.origin.y
        imageFrame.origin.x = fitBoxRect.midX - (imageFrame.size.width / 2)
        imageView?.frame = imageFrame

        titleLabelFrame.size.width = labelSize.size.width
        titleLabelFrame.size.height = labelSize.size.height
        titleLabelFrame.origin.x = (frame.size.width / 2) - (labelSize.size.width / 2)
        titleLabelFrame.origin.y = fitBoxRect.origin.y + imageFrame.size.height + kTextTopPadding
        titleLabel?.frame = titleLabelFrame
    }
}
