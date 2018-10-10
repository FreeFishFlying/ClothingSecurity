//
//  RichTextLabel.swift
//  Components-Swift
//
//  Created by kingxt on 4/26/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import UIKit
import CoreText

private let truncationTokenUnicode: UnicodeScalar = UnicodeScalar(Int(0x2026))!
private let truncationTokenString: String = String(truncationTokenUnicode)

private let attachmentUnicode: UnicodeScalar = UnicodeScalar(Int(0xFFFC))!
private let attachmentTokenString: String = String(attachmentUnicode)

private let attactmentKey = "attactmentKey"

public enum TextVerticalAlignment: Int {
    case top
    case center
    case bottom
}

public struct RichTextLabelAttachment {

    let content: Any
    let contentMode: UIView.ContentMode
    let size: CGSize

    public init(content: Any, contentMode: UIView.ContentMode, size: CGSize) {
        self.content = content
        self.contentMode = contentMode
        self.size = size
    }
}

private class TextRunDelegate {
    var ascent: CGFloat = 0
    var descent: CGFloat = 0
    var width: CGFloat = 0
}

private func getCTRunDelegate(delegate: TextRunDelegate) -> CTRunDelegate {
    var imageCallback = CTRunDelegateCallbacks(version: kCTRunDelegateVersion1, dealloc: { (refCon) -> Void in
        refCon.assumingMemoryBound(to: TextRunDelegate.self).deinitialize()
    }, getAscent: { (refCon) -> CGFloat in
        refCon.load(as: TextRunDelegate.self).ascent
    }, getDescent: { (refCon) -> CGFloat in
        refCon.load(as: TextRunDelegate.self).descent
    }, getWidth: { (refCon) -> CGFloat in
        refCon.load(as: TextRunDelegate.self).width
    })
    let delegatePtr = UnsafeMutablePointer<TextRunDelegate>.allocate(capacity: 1)
    delegatePtr.initialize(to: delegate)
    return CTRunDelegateCreate(&imageCallback, delegatePtr)!
}

public extension NSAttributedString {

    public class func attachmentString(attachment: RichTextLabelAttachment, alignToFont font: UIFont, alignment: TextVerticalAlignment = .center) -> NSAttributedString {
        let atr = NSMutableAttributedString(string: attachmentTokenString)
        atr.setAttributes([NSAttributedString.Key(rawValue: attactmentKey): attachment], range: NSRange(location: 0, length: atr.length))
        let delegate = TextRunDelegate()
        let attachmentSize = attachment.size
        delegate.width = attachmentSize.width
        switch alignment {
        case .top:
            delegate.ascent = font.ascender
            delegate.descent = attachmentSize.height - font.ascender
            if delegate.descent < 0 {
                delegate.descent = 0
                delegate.ascent = attachmentSize.height
            }
        case .center:
            let fontHeight: CGFloat = font.ascender - font.descender
            let yOffset: CGFloat = font.ascender - fontHeight * 0.5
            delegate.ascent = attachmentSize.height * 0.5 + yOffset
            delegate.descent = attachmentSize.height - delegate.ascent
            if delegate.descent < 0 {
                delegate.descent = 0
                delegate.ascent = attachmentSize.height
            }
        case .bottom:
            delegate.ascent = attachmentSize.height + font.descender
            delegate.descent = -font.descender
            if delegate.ascent < 0 {
                delegate.ascent = 0
                delegate.descent = attachmentSize.height
            }
        }
        let delegateRef = getCTRunDelegate(delegate: delegate)
        atr.addAttribute(NSAttributedString.Key(rawValue: kCTRunDelegateAttributeName as String), value: delegateRef, range: NSRange(location: 0, length: atr.length))
        return atr
    }
}

public protocol ClickableLink {
    func linkRange() -> NSRange
}

extension NSTextCheckingResult: ClickableLink {

    public func linkRange() -> NSRange {
        return range
    }
}

/**

 Reused data to fast label layout

 */
open class RichTextLabelLayout {

    public struct LinePosition {
        public let offset: CGFloat
        public let lineWidth: CGFloat
        var hasAttachment: Bool = true

        public init(offset: CGFloat, lineWidth: CGFloat, hasAttachment: Bool = true) {
            self.offset = offset
            self.lineWidth = lineWidth
            self.hasAttachment = hasAttachment
        }
    }

    public struct AttachmentData {
        let item: RichTextLabelAttachment
        let attachmentsRect: CGRect
    }

    public class LinkData {
        let range: NSRange
        let clickableLink: ClickableLink

        public var topRegion: CGRect = CGRect.zero
        public var middleRegion: CGRect = CGRect.zero
        public var bottomRegion: CGRect = CGRect.zero

        public init(range: NSRange, clickableLink: ClickableLink) {
            self.range = range
            self.clickableLink = clickableLink
        }
    }

    // The max width limit display rich text
    public var maxWidth: CGFloat = CGFloat.greatestFiniteMagnitude

    // Link color for NSTextCheckingResult
    public var linkColor: UIColor = UIColorRGB(0x004BAD)
    public var linkShouldUnderline = true

    // Link background color for NSTextCheckingResult when user press
    public var linkHighlightColor: UIColor = UIColor(red: 19 / 255.0, green: 144 / 255.0, blue: 255 / 255.0, alpha: 1)

    public var customCheckingResult: [ClickableLink] = []
    public private(set) var detectCheckingResult: [ClickableLink] = []
    public var font: UIFont = UIFont.systemFont(ofSize: 15)
    public var lineSpacing: CGFloat? = nil
    public var textColor: UIColor = .black
    public var textAlignment: NSTextAlignment = .left
    public var detectTypes: NSTextCheckingResult.CheckingType = [.link, .phoneNumber]
    public var autoDetectLinks: Bool = false
    public var maxNumberOfLines: Int?
    public var ellipsisString: String?
    public var lineBreakMode: NSLineBreakMode = .byTruncatingTail
    public var imageParserProvider: RichTextImageParserProvider?
    public var richTextLinkParserProvider: RichTextLinkParserProvider?
    public var enlargeEmojiIfOnlyContainsSingle = true

    public private(set) var lastLineWidth: CGFloat = 0
    public private(set) var fontLineHeight: CGFloat = 0
    open private(set) var size: CGSize = CGSize.zero
    public private(set) var hasLayoutDataBefore = false

    private var allCheckingResults: [ClickableLink] = []

    public private(set) var linkRangs: [NSRange] = []
    public private(set) var links: [LinkData] = [LinkData]()
    public private(set) var attachments: [AttachmentData] = []

    public private(set) var textLines: [CTLine] = []
    public private(set) var lineOrigins: [LinePosition] = []
    public private(set) var originalStringLineCount = 0

    fileprivate var attributeString: NSMutableAttributedString

    private var setAttributeOnLayout = false

    public convenience init(text: String) {
        self.init(attributeString: NSAttributedString(string: text))
        setAttributeOnLayout = true
    }

    public init(attributeString: NSAttributedString) {
        self.attributeString = NSMutableAttributedString(attributedString: attributeString)
    }

    private func detectLinks() {
        do {
            if let richTextLinkParserProvider = self.richTextLinkParserProvider {
                detectCheckingResult.append(contentsOf: richTextLinkParserProvider.detactLinks(text: attributeString.string))
            } else {
                let dataDetector = try NSDataDetector(types: NSTextCheckingTypes(detectTypes.rawValue))
                let string = attributeString.string
                let result = dataDetector.matches(in: string, options: [.reportProgress], range: NSRange(location: 0, length: string.characters.count))
                for item in result {
                    detectCheckingResult.append(item)
                }
            }
        } catch {
            print(error)
        }
    }

    public func layoutIfNot() {
        if !hasLayoutDataBefore {
            layout()
        }
    }

    private func clean() {
        textLines.removeAll()
        links.removeAll()
        attachments.removeAll()
        lineOrigins.removeAll()
        linkRangs.removeAll()
        allCheckingResults.removeAll()
        detectCheckingResult.removeAll()
    }

    open func layout() {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        clean()
        allCheckingResults.append(contentsOf: customCheckingResult)
        hasLayoutDataBefore = true

        if setAttributeOnLayout {
            attributeString.withForegroundColor(textColor).withFont(font)
            if let lineSpacing = lineSpacing {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = lineSpacing
                attributeString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: attributeString.length))
            }
        }
        if enlargeEmojiIfOnlyContainsSingle && attributeString.string.length == 1 {
            if attributeString.string.unicodeScalars.contains(where: { $0.isEmoji }) {
                font = UIFont.systemFont(ofSize: 34)
                attributeString.withFont(font)
            }
        }

        if autoDetectLinks {
            detectLinks()
            allCheckingResults.append(contentsOf: detectCheckingResult)
        }
        styleLinks()
        parseImageIfNeed()

        let typesetter: CTFramesetter = CTFramesetterCreateWithAttributedString(attributeString)
        let ctfont: CTFont = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
        let fontAscent: CGFloat = CTFontGetAscent(ctfont)
        let fontDescent: CGFloat = CTFontGetDescent(ctfont)
        fontLineHeight = (fontAscent + fontDescent).rounded(.down)
        let fontLineSpacing: CGFloat = (fontLineHeight * 1.12).rounded(.down)
        let maxNumberOfLines = self.maxNumberOfLines == nil ? 0 : self.maxNumberOfLines!

        let maxHeight: CGFloat = 10_000_000
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: maxWidth.rounded(.down), height: maxHeight))
        let frame = CTFramesetterCreateFrame(typesetter, CFRangeMake(0, attributeString.length), path.cgPath, nil)
        let lines: [CTLine] = CTFrameGetLines(frame) as! Array
        if lines.count == 0 {
            return
        }
        originalStringLineCount = lines.count
        var originsArray = [CGPoint](repeating: CGPoint.zero, count: lines.count)
        let range: CFRange = CFRangeMake(0, lines.count)
        CTFrameGetLineOrigins(frame, range, &originsArray)

        var truncatedLine: CTLine?
        let needTruncation = maxNumberOfLines != 0 && lines.count > maxNumberOfLines
        var width: CGFloat = 0
        for (index, line) in lines.enumerated() {
            if maxNumberOfLines != 0 && maxNumberOfLines - 1 == textLines.count {
                if needTruncation {
                    let truncationTokenAttributes: [NSAttributedString.Key : Any] = [
                        NSAttributedString.Key.font : self.font,
                        NSAttributedString.Key.foregroundColor : self.textColor.cgColor,
                    ]

                    let tokenString = NSAttributedString(string: ellipsisString == nil ? truncationTokenString : ellipsisString!, attributes: truncationTokenAttributes)
                    let truncationToken: CTLine = CTLineCreateWithAttributedString(tokenString)
                    var truncationType: CTLineTruncationType = .end
                    switch lineBreakMode {
                    case .byTruncatingHead:
                        truncationType = .start
                    case .byTruncatingMiddle:
                        truncationType = .middle
                    case .byTruncatingTail:
                        truncationType = .end
                    default:
                        truncationType = .end
                    }
                    truncatedLine = CTLineCreateTruncatedLine(line, CTLineGetTypographicBounds(line, nil, nil, nil) - CTLineGetTrailingWhitespaceWidth(line) - 0.1, truncationType, truncationToken)
                }
            }
            if truncatedLine != nil {
                textLines.append(truncatedLine!)
            } else {
                textLines.append(line)
            }
            let lineWidth = CTLineGetTypographicBounds(line, nil, nil, nil) - CTLineGetTrailingWhitespaceWidth(line)
            let offsetHeight = maxHeight - originsArray[index].y
            let linePosition = LinePosition(offset: offsetHeight, lineWidth: CGFloat(lineWidth))
            lineOrigins.append(linePosition)
            lastLineWidth = CGFloat(lineWidth)

            width = max(width, CGFloat(lineWidth))
            calculateAttachment(line: line, offset: offsetHeight)
            if maxNumberOfLines != 0 && maxNumberOfLines == textLines.count {
                break
            }
        }
        size.width = width
        size.height = lineOrigins.last!.offset + fontDescent
        calculateRegion(fontLineHeight: fontLineHeight, fontLineSpacing: fontLineSpacing)
    }
    
    public func addLine(_ line: CTLine, lineOrigin: LinePosition) {
        textLines.append(line)
        lineOrigins.append(lineOrigin)
    }
    
    public func addLink(_ linkData: LinkData) {
        links.append(linkData)
    }

    private func parseImageIfNeed() {
        if let imageParserProvider = self.imageParserProvider {
            let regularExpression = imageParserProvider.regularExpression
            let string = attributeString.string
            let newAttributedString = NSMutableAttributedString()
            let matches = regularExpression.matches(in: string, options: .reportProgress, range: NSRange(location: 0, length: string.length))
            var location: Int = 0
            for match in matches {
                let range = match.range
                if range.location > location {
                    newAttributedString.append(attributeString.attributedSubstring(from: NSRange(location: location, length: range.location - location)))
                }
                location = range.location + range.length
                var tagName = (string as NSString).substring(with: range)
                if tagName.length > 2 {
                    tagName = tagName.substring(with: NSRange(location: 1, length: range.length - 2))
                }
                if tagName.length > 0 {
                    if let image = imageParserProvider.map(match: tagName) {
                        newAttributedString.append(NSAttributedString.attachmentString(attachment: RichTextLabelAttachment(content: image, contentMode: .scaleAspectFit, size: CGSize(width: 22, height: 20)), alignToFont: font))
                        continue
                    }
                }
                newAttributedString.append(attributeString.attributedSubstring(from: range))
            }
            if location < attributeString.length {
                newAttributedString.append(attributeString.attributedSubstring(from: NSRange(location: location, length: attributeString.length - location)))
            }
            attributeString = newAttributedString
        }
    }

    private func calculateAttachment(line: CTLine, offset: CGFloat) {
        let runs = CTLineGetGlyphRuns(line) as! Array<CTRun>
        for run in runs {
            let glyphCount: CFIndex = CTRunGetGlyphCount(run)
            if glyphCount == 0 {
                continue
            }
            let attrs: [AnyHashable: Any] = (CTRunGetAttributes(run) as! [AnyHashable: Any])
            let attachment: RichTextLabelAttachment? = attrs[attactmentKey] as? RichTextLabelAttachment
            if let attachment = attachment {
                var runPosition = CGPoint.zero
                CTRunGetPositions(run, CFRangeMake(0, 1), &runPosition)

                var ascent: CGFloat = 0.0
                var descent: CGFloat = 0.0
                var leading: CGFloat = 0.0
                var runWidth: CGFloat = 0.0
                var runTypoBounds = CGRect.zero
                runWidth = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading))
                runPosition.y = offset - runPosition.y
                runTypoBounds = CGRect(x: CGFloat(runPosition.x), y: CGFloat(runPosition.y - ascent), width: CGFloat(runWidth), height: CGFloat(ascent + descent))

                attachments.append(AttachmentData(item: attachment, attachmentsRect: runTypoBounds))
            }
        }
    }

    private func styleLinks() {
        if allCheckingResults.count != 0 {
            let underlineStyle = NSNumber(value: NSUnderlineStyle.single.rawValue)
            for (_, match) in allCheckingResults.enumerated() {
                let linkRange = match.linkRange()
                links.append(LinkData(range: linkRange, clickableLink: match))
                if linkRange.location + linkRange.length <= attributeString.length {
                    CFAttributedStringSetAttribute(attributeString, CFRangeMake(linkRange.location, linkRange.length), kCTForegroundColorAttributeName, linkColor)
                    if linkShouldUnderline {
                        CFAttributedStringSetAttribute(attributeString, CFRangeMake(linkRange.location, linkRange.length), kCTUnderlineStyleAttributeName, underlineStyle)
                    }
                    let style = NSMutableParagraphStyle()
                    style.lineBreakMode = .byCharWrapping
                    let attributes: [NSAttributedString.Key: AnyObject] = [
                        NSAttributedString.Key.paragraphStyle: style
                    ]
                    attributeString.addAttributes(attributes, range: NSRange(location: linkRange.location, length: linkRange.length))
                }
            }
        }
    }

    private func calculateRegion(fontLineHeight: CGFloat, fontLineSpacing: CGFloat) {
        for (iLine, line) in textLines.enumerated() {
            let lineRange: CFRange = CTLineGetStringRange(line)
            let linePosition = lineOrigins[iLine]
            let lineOrigin = CGPoint(x: CGFloat(textAlignment == .left ? 0.0 : (Float(CTLineGetPenOffsetForFlush(line, textAlignment == .center ? 0.5 : 1.0, Double(size.width))))), y: CGFloat(linePosition.offset))
            for linkData in links {
                let intersectionRange = NSIntersectionRange(linkData.range, NSRange(location: lineRange.location, length: lineRange.length))
                if intersectionRange.length > 0 {
                    var startX = ceil(CTLineGetOffsetForStringIndex(line, intersectionRange.location, nil) + lineOrigin.x)
                    var endX = ceil(CTLineGetOffsetForStringIndex(line, intersectionRange.location + intersectionRange.length, nil) + lineOrigin.x)
                    if startX > endX {
                        let tmp: CGFloat = startX
                        startX = endX
                        endX = tmp
                    }
                    var tillEndOfLine: Bool = false
                    if intersectionRange.location + intersectionRange.length >= Int(lineRange.location + lineRange.length) && abs(endX - size.width) < 16 {
                        tillEndOfLine = true
                        endX = size.width + lineOrigin.x
                    }
                    let region = CGRect(x: CGFloat(ceil(startX - 3)), y: CGFloat(ceil(lineOrigin.y - fontLineHeight + fontLineHeight * 0.1)), width: CGFloat(ceil(endX - startX + 6)), height: CGFloat(ceil(fontLineSpacing)))
                    if linkData.topRegion.size.height == 0 {
                        linkData.topRegion = region
                    } else {
                        if linkData.middleRegion.size.height == 0 {
                            linkData.middleRegion = region
                        } else if intersectionRange.location == Int(lineRange.location) && intersectionRange.length == Int(lineRange.length) && tillEndOfLine {
                            linkData.middleRegion.size.height += region.size.height
                            linkData.middleRegion.size.width = max(linkData.middleRegion.size.width, region.size.width)
                        } else {
                            linkData.bottomRegion = region
                        }
                    }
                }
            }
        }
    }

    public func link(at point: CGPoint) -> LinkData? {
        for linkData in links {
            if (linkData.topRegion.size.height != 0 && linkData.topRegion.insetBy(dx: CGFloat(-2), dy: CGFloat(-2)).contains(point)) || (linkData.middleRegion.size.height != 0 && linkData.middleRegion.insetBy(dx: CGFloat(-2), dy: CGFloat(-2)).contains(point)) || (linkData.bottomRegion.size.height != 0 && linkData.bottomRegion.insetBy(dx: CGFloat(-2), dy: CGFloat(-2)).contains(point)) {
                return linkData
            }
        }
        return nil
    }

    public func invalide() {
        hasLayoutDataBefore = false
    }
}

public protocol RichTextLabelDelegate: class {
    func didPressLink(result: ClickableLink)
    func didLongPressLink(result: ClickableLink)
}

private let longPressGapTime: Double = 0.5

open class RichTextLabel: UIView {

    public weak var delegate: RichTextLabelDelegate?

    private var selectedElement: RichTextLabelLayout.LinkData?
    private var latestTouchLinkTime: Date?
    public private(set) var touchBegin: Bool = false

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var layoutData: RichTextLabelLayout? {
        didSet {
            touchBegin = false
            latestTouchLinkTime = nil
            selectedElement = nil
            setNeedsDisplay()
        }
    }

    open override var intrinsicContentSize: CGSize {
        if let layoutData = self.layoutData {
            layoutData.layoutIfNot()
            return layoutData.size
        }
        return frame.size
    }

    open override func draw(_ rect: CGRect) {
        if let layoutData = self.layoutData {
            layoutData.layoutIfNot()

            let lines = layoutData.textLines
            if lines.count == 0 {
                return
            }
            let createContext: CGContext? = UIGraphicsGetCurrentContext()
            guard let context = createContext else {
                return
            }
            context.saveGState()
            let rect: CGRect = bounds
            context.textMatrix = CGAffineTransform(scaleX: 1.0, y: -1.0)
            context.translateBy(x: rect.origin.x, y: rect.origin.y)

            let clipRect: CGRect = context.boundingBoxOfClipPath

            let lineOrigins = layoutData.lineOrigins
            var lineHeight: CGFloat = 64.0
            if lineOrigins.count >= 2 {
                lineHeight = abs(lineOrigins[0].offset - lineOrigins[1].offset)
            }
            let upperOriginBound: CGFloat = clipRect.origin.y
            let lowerOriginBound: CGFloat = clipRect.origin.y + clipRect.size.height + lineHeight

            for (index, line) in lines.enumerated() {
                let linePosition = lineOrigins[index]
                var horizontalOffset: CGFloat = 0.0
                switch layoutData.textAlignment {
                case .center:
                    horizontalOffset = ((rect.size.width - linePosition.lineWidth) / 2.0).rounded(.down)
                case .right:
                    horizontalOffset = rect.size.width - linePosition.lineWidth
                default:
                    break
                }

                let lineOrigin = CGPoint(x: horizontalOffset, y: CGFloat(linePosition.offset))
                if lineOrigin.y < upperOriginBound || lineOrigin.y > lowerOriginBound {
                    continue
                }

                context.textPosition = CGPoint(x: CGFloat(lineOrigin.x), y: CGFloat(lineOrigin.y))
                CTLineDraw(line, context)
            }

            context.restoreGState()

            drawAttachment()
        } else {
            super.draw(rect)
        }
    }

    fileprivate func drawAttachment() {
        if let layoutData = self.layoutData {
            if layoutData.attachments.count == 0 {
                return
            }
            let createContext: CGContext? = UIGraphicsGetCurrentContext()
            guard let context = createContext else {
                return
            }
            for attachment in layoutData.attachments {
                var image: UIImage?
                var view: UIView?
                if attachment.item.content is UIImage {
                    image = attachment.item.content as? UIImage
                }
                if attachment.item.content is UIView {
                    view = attachment.item.content as? UIView
                }
                var rect: CGRect = attachment.attachmentsRect
                let size: CGSize = image != nil ? image!.size : view != nil ? view!.frame.size : CGSize.zero
                rect = rect.fit(size: size, mode: attachment.item.contentMode)
                rect = rect.roundPixel()
                rect = rect.standardized
                if image != nil {
                    let ref: CGImage? = image?.cgImage
                    if let cgImage = ref {
                        context.saveGState()
                        context.translateBy(x: 0, y: rect.maxY + rect.minY)
                        context.scaleBy(x: 1, y: -1)
                        context.draw(cgImage, in: rect)
                        context.restoreGState()
                    }
                } else if view != nil {
                    if view?.superview != self {
                        view?.removeFromSuperview()
                        addSubview(view!)
                    }
                    view?.frame = rect
                }
            }
        }
    }

    // MARK: - Handle UI touch link
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if onTouch(touch) { return }
        super.touchesBegan(touches, with: event)
    }

    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if onTouch(touch) { return }
        super.touchesMoved(touches, with: event)
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        _ = onTouch(touch)
        super.touchesCancelled(touches, with: event)
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if onTouch(touch) { return }
        super.touchesEnded(touches, with: event)
    }

    func onTouch(_ touch: UITouch) -> Bool {
        if layoutData?.links.count == 0 {
            return false
        }
        let location = touch.location(in: self)
        var avoidSuperCall = false

        if touch.phase == .began {
            touchBegin = true
        }
        switch touch.phase {
        case .began, .moved:
            if let element = layoutData?.link(at: location) {
                if latestTouchLinkTime == nil {
                    latestTouchLinkTime = Date()
                    let when = DispatchTime.now() + Double(Int64(longPressGapTime * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.fireLongPressIfNeed()
                    }
                }
                if element.range.location != selectedElement?.range.location || element.range.length != selectedElement?.range.length {
                    updateAttributesWhenSelected(false)
                    selectedElement = element
                    updateAttributesWhenSelected(true)
                }
                fireLongPressIfNeed()
                avoidSuperCall = true
            } else {
                if selectedElement == nil {
                    return avoidSuperCall
                }
                clearHighlight()
            }
        case .ended:
            guard let selectedElement = selectedElement else { return avoidSuperCall }
            clearHighlight()
            if touchBegin {
                touchBegin = false
                didPressLink(data: selectedElement)
            }
            avoidSuperCall = true
        case .cancelled:
            if selectedElement == nil {
                return avoidSuperCall
            }
            clearHighlight()
        case .stationary:
            break
        }

        return avoidSuperCall
    }

    fileprivate func clearHighlight() {
        updateAttributesWhenSelected(false)
        selectedElement = nil
        latestTouchLinkTime = nil
    }

    fileprivate func fireLongPressIfNeed() {
        guard let latestTouchLinkTime = self.latestTouchLinkTime else {
            return
        }
        guard let selectedElement = self.selectedElement else {
            return
        }
        if latestTouchLinkTime.timeIntervalSinceNow < -longPressGapTime {
            clearHighlight()
            if touchBegin {
                touchBegin = false
                didLongPressLink(data: selectedElement)
            }
        }
    }

    fileprivate func updateAttributesWhenSelected(_ isSelected: Bool) {
        guard let selectedElement = selectedElement else {
            return
        }

        highLightLayer.isHidden = !isSelected
        if isSelected {
            highLightLayer.frame = bounds
            let returnPath: (_ rect: CGRect, _ corners: UIRectCorner) -> UIBezierPath = {
                UIBezierPath(roundedRect: $0, byRoundingCorners: $1, cornerRadii: CGSize(width: 4, height: 4))
            }
            let path: UIBezierPath = UIBezierPath()
            let insert = UIEdgeInsets(top: 0, left: 0, bottom: -2, right: 0)
            if selectedElement.topRegion.width > 0 && selectedElement.middleRegion.width == 0 {
                path.append(returnPath(selectedElement.topRegion.inset(by: insert), UIRectCorner.allCorners))
            } else {
                path.append(returnPath(selectedElement.topRegion, [.topLeft, .topRight]))
            }
            if selectedElement.middleRegion.width > 0 && selectedElement.bottomRegion.width == 0 {
                path.append(returnPath(selectedElement.middleRegion.inset(by: insert), [.bottomLeft, .bottomRight]))
            } else {
                path.append(returnPath(selectedElement.middleRegion, []))
            }
            if selectedElement.bottomRegion.width > 0 {
                path.append(returnPath(selectedElement.bottomRegion.inset(by: insert), [.bottomLeft, .bottomRight]))
            }
            highLightLayer.path = path.cgPath
        }
    }

    fileprivate func didPressLink(data: RichTextLabelLayout.LinkData) {
        delegate?.didPressLink(result: data.clickableLink)
    }

    fileprivate func didLongPressLink(data: RichTextLabelLayout.LinkData) {
        delegate?.didLongPressLink(result: data.clickableLink)
    }

    private lazy var highLightLayer: CAShapeLayer = {
        let highLightLayer = CAShapeLayer()
        highLightLayer.frame = self.bounds

        if let layoutData = self.layoutData {
            highLightLayer.fillColor = layoutData.linkHighlightColor.withAlphaComponent(0.2).cgColor
        }

        self.layer.addSublayer(highLightLayer)
        return highLightLayer
    }()
}
