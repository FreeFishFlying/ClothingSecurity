//
//  FundationExtensions.swift
//  Components-Swift
//
//  Created by kingxt on 4/27/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation

extension String {

    public var length: Int {
        return self.unicodeScalars.contains(where: { $0.isEmoji }) ? self.utf16.count : count
    }

    public func substring(with range: NSRange) -> String {
        guard range.location + range.length <= length else {
            return self
        }
        if self.unicodeScalars.contains(where: { $0.isEmoji }) {
            let start = self.utf16.index(startIndex, offsetBy: range.location)
            let end = self.utf16.index(start, offsetBy: range.length)
            guard end <=  self.utf16.endIndex else {
                return self
            }
            return String(self[start ..< end])
        } else {
            let start = index(startIndex, offsetBy: range.location)
            let end = index(start, offsetBy: range.length)
            guard end <= endIndex else {
                return self
            }
            return String(self[start ..< end])
        }

    }
}

public extension Int {
    public static func random(lower: Int = min, upper: Int = max) -> Int {
        let rand = arc4random_uniform(UInt32(upper)) + UInt32(lower)
        return Int(rand)
    }
}

public extension Array {
    public subscript(safe index: Int) -> Element? {
        return indices ~= index ? self[index] : .none
    }
}

public extension Array where Element: Equatable {

    // Remove first collection element that is equal to the given `object`:
    public mutating func remove(object: Element) {
        if let index = firstIndex(of: object) {
            remove(at: index)
        }
    }
}

public extension UnicodeScalar {

    public var isEmoji: Bool {
        switch value {
        case 0x1F600 ... 0x1F64F, // Emoticons
             0x1F300 ... 0x1F5FF, // Misc Symbols and Pictographs
             0x1F680 ... 0x1F6FF, // Transport and Map
             0x2600 ... 0x26FF, // Misc symbols
             0x2700 ... 0x27BF, // Dingbats
             0xFE00 ... 0xFE0F, // Variation Selectors
             0x1F900 ... 0x1F9FF, // Supplemental Symbols and Pictographs
             65024 ... 65039, // Variation selector
             8400 ... 8447: // Combining Diacritical Marks for Symbols
            return true
        default: return false
        }
    }

    public var isZeroWidthJoiner: Bool {
        return value == 8205
    }
}
