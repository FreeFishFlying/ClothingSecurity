import UIKit
import ReactiveSwift

private var AssociatedUIControlHandle: UInt8 = 0
private var AssociatedHighlightDisposableHandle: UInt8 = 0

public extension UIControl {

    @objc public var hitTestEdgeInsets: UIEdgeInsets {
        get {
            let value: NSValue? = objc_getAssociatedObject(self, &AssociatedUIControlHandle) as? NSValue
            if value != nil {
                return value!.uiEdgeInsetsValue
            }
            return UIEdgeInsets.zero
        }
        set {
            let value = NSValue(uiEdgeInsets: newValue)
            objc_setAssociatedObject(self, &AssociatedUIControlHandle, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if UIEdgeInsetsEqualToEdgeInsets(hitTestEdgeInsets, UIEdgeInsets.zero) || !isEnabled || isHidden {
            return super.point(inside: point, with: event)
        }
        let relativeFrame: CGRect = bounds
        let hitFrame: CGRect = relativeFrame.inset(by: hitTestEdgeInsets)
        return hitFrame.contains(point)
    }
}

private var AssociatedUIButtonHandle: UInt8 = 0

extension UIButton {

    public var highlightDisposable: Disposable? {
        get {
            return objc_getAssociatedObject(self, &AssociatedHighlightDisposableHandle) as? Disposable
        }
        set {
            objc_setAssociatedObject(self, &AssociatedHighlightDisposableHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    @objc public var autoHighlight: Bool {
        get {
            let value: NSNumber? = objc_getAssociatedObject(self, &AssociatedUIButtonHandle) as? NSNumber
            if value != nil {
                return value!.boolValue
            }
            return false
        }
        set {
            if #available(iOS 9, *) {
                let value = NSNumber(value: newValue)
                objc_setAssociatedObject(self, &AssociatedUIButtonHandle, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

                if newValue {
                    highlightDisposable?.dispose()
                    highlightDisposable = reactive.signal(for: #selector(setter: isHighlighted)).take(during: reactive.lifetime).observeValues({ [weak self] _ in
                        if let strongSelf = self {
                            let alpha: CGFloat = (strongSelf.isHighlighted ? 0.4 : 1.0) * (strongSelf.isEnabled ? 1.0 : 0.5)
                            strongSelf.alpha = alpha
                        }
                    })
                } else {
                    highlightDisposable?.dispose()
                }
            }
        }
    }
}
