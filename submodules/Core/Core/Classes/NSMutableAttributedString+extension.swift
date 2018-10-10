//
//  NSMutableAttributedString+extension.swift
//  Pods
//
//  Created by Dylan Wang on 07/08/2017.
//
//

import UIKit

public extension NSMutableAttributedString {
    @discardableResult public func withForegroundColor(_ color: UIColor) -> NSMutableAttributedString {
        addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location: 0, length: length))
        return self
    }
    
    @discardableResult public func withForegroundColor(_ color: UIColor, range: NSRange) -> NSMutableAttributedString {
        addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        return self
    }

    @discardableResult public func withFont(_ font: UIFont) -> NSMutableAttributedString {
        addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: 0, length: length))
        return self
    }
    
    @discardableResult public func withFont(_ font: UIFont, range: NSRange) -> NSMutableAttributedString {
        addAttribute(NSAttributedString.Key.font, value: font, range: range)
        return self
    }
    
    @discardableResult public func withLineSpacing(_ lineSpacing: CGFloat) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: length))
        return self
    }

    @discardableResult public func withStyles(_ styles: [(NSRange, NSMutableParagraphStyle)]) -> NSMutableAttributedString {
        for style in styles {
            addAttribute(NSAttributedString.Key.paragraphStyle, value: style.1, range: style.0)
        }
        return self
    }
    
    @discardableResult public func withStyle(_ style: NSMutableParagraphStyle) -> NSMutableAttributedString {
        addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: length))
        return self
    }
    
    @discardableResult public func withAlignment(_ alignment: NSTextAlignment) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: length))
        return self
    }

    public func removeAll() {
        deleteCharacters(in: NSRange(location: 0, length: length))
    }
}
