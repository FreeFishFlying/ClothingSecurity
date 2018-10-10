//
//  RichTextParserProvider.swift
//  Components
//
//  Created by kingxt on 7/6/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import UIKit

public protocol RichTextImageParserProvider {

    var regularExpression: NSRegularExpression { get }

    func map(match: String) -> UIImage?
}

public protocol RichTextLinkParserProvider {
    func detactLinks(text: String) -> [ClickableLink]
}

private let zeroUnicodeScalar: UnicodeScalar = "0"
private let nineUnicodeScalar: UnicodeScalar = "9"
private let slashUnicodeScalar: UnicodeScalar = "/"
private let nbUnicodeScalar: UnicodeScalar = "\n"
private let tbUnicodeScalar: UnicodeScalar = "\t"
private let spaceUnicodeScalar: UnicodeScalar = " "
private let atUnicodeScalar: UnicodeScalar = "@"
private let underlineUnicodeScalar: UnicodeScalar = "_"
private let dotUnicodeScalar: UnicodeScalar = "."
private let commaUnicodeScalar: UnicodeScalar = ":"

public class RichTextLinkParserDefaultProvider: RichTextLinkParserProvider {

    public static let `default` = RichTextLinkParserDefaultProvider()

    public static let detectTypes: NSTextCheckingResult.CheckingType = [.link, .phoneNumber]
    private static let dataDetector = try! NSDataDetector(types: NSTextCheckingTypes(detectTypes.rawValue))
    private static let characterSet = CharacterSet.alphanumerics

    public func detactLinks(text: String) -> [ClickableLink] {
        if !RichTextLinkParserDefaultProvider.shouldCheckDataLink(text) {
            return []
        }
        var detectCheckingResult = [ClickableLink]()
        let result = RichTextLinkParserDefaultProvider.dataDetector.matches(in: text, options: [.reportProgress], range: NSRange(location: 0, length: text.count))
        for item in result {
            detectCheckingResult.append(item)
        }
        return detectCheckingResult
    }

    class func shouldCheckDataLink(_ text: String) -> Bool {
        if text.length < 3 || text.length > 1024 * 10 {
            return false
        }
        var containsSomething: Bool = false
        var digitsInRow: Int = 0
        var schemeSequence: Int = 0
        var dotSequence: Int = 0
        var lastChar: UnicodeScalar?
        var iterator: String.UnicodeScalarView.Iterator = text.unicodeScalars.makeIterator()
        while let c = iterator.next() {
            if c >= zeroUnicodeScalar && c <= nineUnicodeScalar {
                digitsInRow += 1
                if digitsInRow >= 6 {
                    containsSomething = true
                    break
                }
                schemeSequence = 0
                dotSequence = 0
            } else if c != spaceUnicodeScalar && digitsInRow > 0 {
                digitsInRow = 0
            }
            if c == commaUnicodeScalar {
                if schemeSequence == 0 {
                    schemeSequence = 1
                } else {
                    schemeSequence = 0
                }
            } else if c == slashUnicodeScalar {
                containsSomething = true
                break
            } else if c == dotUnicodeScalar {
                if dotSequence == 0 && lastChar != spaceUnicodeScalar {
                    dotSequence += 1
                } else {
                    dotSequence = 0
                }
            } else if c != spaceUnicodeScalar && lastChar == dotUnicodeScalar && dotSequence == 1 {
                containsSomething = true
                break
            } else {
                dotSequence = 0
            }
            lastChar = c
        }
        return containsSomething
    }
}

public struct CommandTextCheckingResult: ClickableLink {
    let range: NSRange
    public let text: String

    public func linkRange() -> NSRange {
        return range
    }
}
