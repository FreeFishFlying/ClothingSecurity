//
//  GrowingTextView.swift
//  Components-Swift
//
//  Created by Dylan on 03/05/2017.
//  Copyright © 2017 liao. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result
import SnapKit
import MobileCoreServices

public class MediaTextView: UITextView {

    public var didPasteData: ((Data) -> Void)?
    public var willCopyData: (() -> String?)?

    public override func paste(_ sender: Any?) {
        let pasteBoard = UIPasteboard.general
        let types: [String] = pasteBoard.types
        if types.count > 0 {
            let firstType: String = types[0]
            if firstType == (kUTTypeGIF as String) || firstType == (kUTTypeImage as String) {
                if let data = pasteBoard.data(forPasteboardType: firstType) {
                    didPasteData?(data)
                    return
                }
            }
            if let image = pasteBoard.image, let data = image.jpegData(compressionQuality: 1) {
                didPasteData?(data)
                return
            }
        }
        super.paste(sender)
    }
    
    public override func copy(_ sender: Any?) {
        UIPasteboard.general.string = willCopyData?()
    }

    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if didPasteData == nil {
            return super.canPerformAction(action, withSender: sender)
        }
        if action == #selector(paste(_:)) {
            let pasteBoard = UIPasteboard.general
            let types: [String] = pasteBoard.types
            if types.count > 0 {
                let firstType: String = types[0]
                if firstType == (kUTTypeGIF as String) || firstType == (kUTTypeImage as String) {
                    return true
                } else if pasteBoard.image != nil {
                    return true
                }
            }
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

public extension UITextView {
    public var didChangeSignal: Signal<String?, NoError> {
        return reactive.continuousTextValues.filter({ [weak self] (_) -> Bool in
            if let strongSelf = self {
                if let selectedRange = strongSelf.markedTextRange {
                    if nil != strongSelf.position(from: selectedRange.start, offset: 0) {
                        return false
                    }
                }
                return true
            }
            return false
        })
    }
}

open class GrowingTextView: UIView {

    @objc public var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
            showPlaceholderIfNeed()
        }
    }

    @objc public var placeholderPrefix: String? {
        didSet {
            if placeholderPrefix != nil {
                placeholderLabel.numberOfLines = 1
                let placeholderPrefixWidth = (placeholderPrefix! as NSString).size(withAttributes: [NSAttributedString.Key.font: font]).width
                placeholderLabel.snp.updateConstraints { make in
                    make.left.equalTo(6 + placeholderPrefixWidth)
                    make.top.equalTo(5)
                    make.width.lessThanOrEqualTo(self).offset(-12 - placeholderPrefixWidth)
                }
            } else {
                placeholderLabel.snp.updateConstraints { make in
                    make.top.left.equalTo(6)
                    make.width.lessThanOrEqualTo(self).offset(-12)
                }
            }
        }
    }
    public var placeholderColor: UIColor? {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }
    @objc public var attributedPlaceholder: NSAttributedString? {
        didSet {
            placeholderLabel.attributedText = attributedPlaceholder
            showAttributPlaceholderIfNeed()
        }
    }

    public var shouldChangeTextInRange: ((_ range: NSRange, _ replacementText: String) -> Bool)?
    public var shouldBegainEditing: (() -> Bool)?

    public var font: UIFont {
        didSet {
            textView.font = font
            let lines = maxNumberOfLines
            self.maxNumberOfLines = lines
        }
    }

    public var returnKeyType: UIReturnKeyType {
        didSet {
            textView.returnKeyType = returnKeyType
        }
    }

    @objc public var text: String {
        get {
            return textView.text
        }

        set {
            textView.text = newValue
            textView.delegate?.textViewDidChange?(textView)
        }
    }

    open override var isFirstResponder: Bool {
        return textView.isFirstResponder
    }

    public var maxNumberOfLines: Int = -1 {
        didSet {
            if maxNumberOfLines > 0 {
                let string = NSMutableAttributedString()
                for _ in 0 ..< maxNumberOfLines {
                    string.append(NSAttributedString(string: "\n|W|"))
                }
                string.withFont(self.font)
                let size = string.boundingRect(with: CGSize(width: 100, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
                maxHeight = floor(size.height + 17)
            } else {
                maxHeight = CGFloat.greatestFiniteMagnitude
            }
        }
    }

    public var maxHeight: CGFloat = CGFloat.greatestFiniteMagnitude
    // MARK: text view
    fileprivate let layoutManager: NSLayoutManager
    @objc public let textStorage: NSTextStorage
    fileprivate let textContainer: NSTextContainer
    fileprivate let textView: MediaTextView
    public let placeholderLabel: UILabel

    fileprivate var lastChangeCallbackHeight: CGFloat = -1

    // MARK: Signal
    fileprivate let (heightChangeSignal, heightChangeObserver) = Signal<(GrowingTextView, CGFloat), NoError>.pipe()
    fileprivate let (textChangeSignal, textChangeObserver) = Signal<(GrowingTextView, String?), NoError>.pipe()
    fileprivate let (editingStatusSignal, editingStatusObserver) = Signal<(GrowingTextView, Bool), NoError>.pipe()

    override public init(frame: CGRect) {
        layoutManager = NSLayoutManager()
        textContainer = NSTextContainer()
        textStorage = NSTextStorage()
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        layoutManager.allowsNonContiguousLayout = true
        textContainer.widthTracksTextView = true
        textView = MediaTextView(frame: CGRect.zero, textContainer: textContainer)
        
        font = UIFont.systemFont(ofSize: 16)
        returnKeyType = UIReturnKeyType.send
        placeholderLabel = UILabel()
        super.init(frame: frame)

        initialize()
    }

    private func initialize() {
        textView.delegate = self
        textView.isScrollEnabled = true
        textView.textAlignment = NSTextAlignment.left
        textView.dataDetectorTypes = UIDataDetectorTypes.link
        textView.backgroundColor = UIColor.clear
        textView.textContainerInset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        textView.font = font
        textView.returnKeyType = returnKeyType

        addSubview(textView)
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(fieldBackgroundDidTap))
        tap.numberOfTapsRequired = 1
        tap.delegate = self
        addGestureRecognizer(tap)

        placeholderLabel.numberOfLines = 0
        placeholderLabel.backgroundColor = .clear
        placeholderLabel.textColor = UIColorRGB(0xBFBFBF)
        addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { make in
            make.left.equalTo(6)
            make.top.equalTo(4)
            make.width.lessThanOrEqualTo(self).offset(-12)
        }
        textView.willCopyData = { [weak self] in
            return self?.getTextAndSegmentContext().0
        }
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @discardableResult
    open override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        return textView.resignFirstResponder()
    }

    @discardableResult
    open override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }

    @objc public var cursor: NSRange {
        get {
            return textView.selectedRange
        }
        set {
            textView.selectedRange = newValue
        }
    }

    @objc public func getInputTextView() -> MediaTextView {
        return textView
    }

    public var fieldBackgroundDidTapClosure: (() -> Void)?

    @objc private func fieldBackgroundDidTap() {
        fieldBackgroundDidTapClosure?()
        if textView.inputView != nil {
            textView.inputView = nil
            textView.reloadInputViews()
        }
        if !textView.isFirstResponder {
            textView.becomeFirstResponder()
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        showPlaceholderIfNeed()
        showAttributPlaceholderIfNeed()
    }

    fileprivate func showPlaceholderIfNeed() {
        if let placeholder = placeholder {
            if textView.hasText {
                if placeholderPrefix != nil && getTextAndSegmentContext().0 == placeholderPrefix! {
                    placeholderLabel.isHidden = false
                } else {
                    placeholderLabel.isHidden = true
                }
            } else {
                bringSubviewToFront(placeholderLabel)
                placeholderLabel.isHidden = false
                placeholderLabel.text = placeholder
            }
        } else {
            placeholderLabel.isHidden = true
        }
    }
    
    fileprivate func showAttributPlaceholderIfNeed() {
        if let attributedPlaceholder = attributedPlaceholder {
            if textView.hasText {
                if placeholderPrefix != nil && getTextAndSegmentContext().0 == placeholderPrefix! {
                    placeholderLabel.isHidden = false
                } else {
                    placeholderLabel.isHidden = true
                }
            } else {
                bringSubviewToFront(placeholderLabel)
                placeholderLabel.isHidden = false
                placeholderLabel.attributedText = attributedPlaceholder
            }
        } else {
            placeholderLabel.isHidden = true
        }
    }
}

extension GrowingTextView: UITextViewDelegate, UIGestureRecognizerDelegate {

    public func textViewDidBeginEditing(_: UITextView) {
        editingStatusObserver.send(value: (self, true))
    }

    public func textViewDidEndEditing(_: UITextView) {
        editingStatusObserver.send(value: (self, false))
    }

    public func textViewDidChangeSelection(_ textView: UITextView) {
        textView.layoutIfNeeded()
        if let selectedTextRange = textView.selectedTextRange {
            var caretRect = textView.caretRect(for: selectedTextRange.end)
            caretRect.size.height += textView.textContainerInset.bottom
            textView.scrollRectToVisible(caretRect, animated: false)
        }
    }

    public func textViewDidChange(_ textView: UITextView) {
        let rect = layoutManager.usedRect(for: textContainer)
        if lastChangeCallbackHeight != rect.size.height {
            var limitHeight: CGFloat = maxHeight
            if limitHeight > 0 {
                limitHeight = min(limitHeight, rect.size.height)
            } else {
                limitHeight = rect.size.height
            }

            if limitHeight != lastChangeCallbackHeight {
                heightChangeObserver.send(value: (self, limitHeight))
            }
            lastChangeCallbackHeight = rect.size.height
        }
        if let selectedTextRange = textView.selectedTextRange {
            if #available(iOS 9.0, *) {
                let line = textView.caretRect(for: selectedTextRange.start)
                let overflow = line.origin.y + line.size.height - (textView.contentOffset.y + textView.bounds.size.height - textView.contentInset.bottom - textView.contentInset.top)
                
                if overflow > 0 && overflow != .infinity {
                    textView.scrollRangeToVisible(textView.selectedRange)
                    textView.isScrollEnabled = false
                    textView.isScrollEnabled = true
                }
            } else {
                textView.scrollRangeToVisible(textView.selectedRange)
            }
        }

        textChangeObserver.send(value: (self, textView.text))
        showPlaceholderIfNeed()
    }

    public func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }

    public func textView(_: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return shouldChangeTextInRange?(range, text) ?? true
    }

    public func textViewShouldBeginEditing(_: UITextView) -> Bool {
        return shouldBegainEditing?() ?? true
    }
}

public extension GrowingTextView {

    @objc public func append(image: UIImage, imageSize size: CGSize, altName alt: String?) {
        let imageAttachment = ImageTextAttachment()
        imageAttachment.alt = alt
        imageAttachment.image = image
        imageAttachment.bounds = CGRect(x: 0, y: -(size.height - font.pointSize) / 2 - 2, width: size.width, height: size.height)
        append(imageAttachment: imageAttachment)
    }

    @objc public func append(imageAttachment attachment: NSTextAttachment) {
        self.textStorage.beginEditing()
        let currentIndexLength = self.textStorage.length
        let imageAttributeString = NSAttributedString(attachment: attachment)
        self.textStorage.replaceCharacters(in: self.textView.selectedRange, with: imageAttributeString)
        self.textStorage.endEditing()
        self.textView.font = self.font
        let range = NSRange(location: 0, length: self.textStorage.length)
        if currentIndexLength == 0 || self.textView.selectedRange.location > 0 {
            self.textStorage.beginEditing()
            self.textStorage.addAttribute(NSAttributedString.Key.font, value: self.font, range: range)
            self.textStorage.addAttribute(NSAttributedString.Key.foregroundColor, value: self.textView.textColor ?? UIColor.black, range: range)
            self.textStorage.endEditing()
        }
        
        self.textView.selectedRange = NSRange(location: self.textView.selectedRange.location + 1, length: 0)
        self.textViewDidChange(self.textView)
    }

    @objc public func append(segmentText text: String?, additionData context: Dictionary<String, Any>? = nil) {
        if let text = text, let image = generalImage(from: text) {
            let attachment = SegmentTextAttachment()
            attachment.alt = text
            attachment.image = image
            attachment.bounds = CGRect(x: 0, y: -(image.size.height - font.pointSize) / 2 - 2, width: image.size.width, height: image.size.height)
            attachment.additionalData = context
            append(imageAttachment: attachment)
        }
    }

    @objc public func append(_ text: String) {
        textStorage.beginEditing()

        textStorage.append(NSAttributedString(string: text))
        if let font = textView.font {
            let range = NSMakeRange(0, textStorage.length)
            textStorage.addAttribute(NSAttributedString.Key.font, value: font, range: range)
        }
        textStorage.endEditing()
        textView.selectedRange = NSRange(location: textStorage.length, length: 0)
        textViewDidChange(textView)
    }
    
    @objc public func insert(text: String, range: NSRange) {
        textStorage.beginEditing()
        textStorage.insert(NSAttributedString(string: text), at: range.location)
        if let font = textView.font {
            let range = NSMakeRange(0, textStorage.length)
            textStorage.addAttribute(NSAttributedString.Key.font, value: font, range: range)
        }
        textStorage.endEditing()
        let newRange = NSRange(location: range.location + text.length, length: range.length)
        textView.selectedRange = newRange
        textViewDidChange(textView)
    }

    public func deleteBackward() {
        textView.deleteBackward()
    }

    private func generalImage(from text: String) -> UIImage? {
        var size: CGSize = (text as NSString).size(withAttributes: [NSAttributedString.Key.font: font])
        let maxWidth: CGFloat = max(frame.width - 50, 100)
        size = CGSize(width: CGFloat(min(maxWidth, size.width)), height: CGFloat(size.height))
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        UIColor.black.set()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        text.draw(in: CGRect(x: 0, y: 0, width: CGFloat(size.width), height: CGFloat(size.height)), withAttributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.paragraphStyle: paragraphStyle])
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    public func getTextAndSegmentContext() -> (String, [[String: Any]]) {
        var result = String()
        var context = [[String: Any]]()
        textStorage.enumerateAttributes(in: NSMakeRange(0, textStorage.length)) { attrs, range, _ in
            if let attachment = attrs[NSAttributedString.Key.attachment] {
                if let textAttachment = attachment as? SegmentTextAttachment {
                    result += textAttachment.alt ?? ""
                    if textAttachment.additionalData != nil {
                        context.append(textAttachment.additionalData!)
                    }
                } else if let imageAttachment = attachment as? ImageTextAttachment {
                    result += imageAttachment.alt ?? ""
                }
            } else {
                let item = textView.attributedText.attributedSubstring(from: range).string
                result += item
            }
        }
        return (result, context)
    }

    @objc public var richTextValue: String {
        return getTextAndSegmentContext().0
    }

    @objc public func replace(range: NSRange, text: String) {
        if range.length + range.location > textStorage.length {
            return
        }
        textStorage.beginEditing()
        textStorage.replaceCharacters(in: range, with: text)
        textStorage.endEditing()
        textView.selectedRange = NSRange(location: range.location + text.length, length: 0)
        textView.delegate?.textViewDidChange?(textView)
    }
}

public extension GrowingTextView {
    public var heightValues: Signal<(GrowingTextView, CGFloat), NoError> {
        return heightChangeSignal.take(during: self.reactive.lifetime)
    }

    public var textValues: Signal<(GrowingTextView, String?), NoError> {
        return textChangeSignal.take(during: self.reactive.lifetime)
    }

    public var statusValues: Signal<(GrowingTextView, Bool), NoError> {
        return editingStatusSignal.take(during: self.reactive.lifetime)
    }

    public var keyboardFrameValues: Signal<CGRect, NoError>? {
        // TDOO:
        return nil
    }
}

public extension GrowingTextView {
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        let menuController = UIMenuController.shared
        let wrapItem = UIMenuItem(title: "换行", action: #selector(wrap(_:)))
        menuController.menuItems = [wrapItem]
        return (action == #selector(wrap(_:)))
    }
    
    @objc func wrap(_ sender: Any?) {
        insert(text: "\n", range: textView.selectedRange)
    }
}

/// Observe textview input keyboard frame like iMessage
public class FrameObservingInputAccessoryView: UIView {

    private var centerDisposable: Disposable?
    private var frameDisposable: Disposable?

    private let (frameChangeSignal, frameChangeObserver) = Signal<CGRect, NoError>.pipe()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        removeObserverIfNeed()
        if let newSuperview = newSuperview {
            centerDisposable = newSuperview.reactive.producer(forKeyPath: "center").take(during: self.reactive.lifetime).startWithValues { [weak self] _ in
                if let strongSelf = self {
                    strongSelf.frameDidChange()
                }
            }
            frameDisposable = newSuperview.reactive.producer(forKeyPath: "frame").take(during: self.reactive.lifetime).startWithValues { [weak self] _ in
                if let strongSelf = self {
                    strongSelf.frameDidChange()
                }
            }
        }
    }

    private func removeObserverIfNeed() {
        if let centerDisposable = centerDisposable {
            centerDisposable.dispose()
            self.centerDisposable = nil
        }
        if let frameDisposable = frameDisposable {
            frameDisposable.dispose()
            self.frameDisposable = nil
        }
    }

    private func frameDidChange() {
        if let frame = superview?.frame {
            frameChangeObserver.send(value: frame)
        }
    }

    public var keyboardFrameValues: Signal<CGRect, NoError> {
        return frameChangeSignal.take(during: self.reactive.lifetime)
    }
}
