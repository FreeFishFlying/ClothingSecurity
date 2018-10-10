//
//  ComponentsUtils.swift
//  Components-Swift
//
//  Created by kingxt on 2017/5/1.
//  Copyright © 2017年 liao. All rights reserved.
//

import Foundation
import UIKit
import Darwin
import AVFoundation

let screenScale: CGFloat = UIScreen.main.scale

public extension CGPoint {
    public func roundPixel() -> CGPoint {
        return CGPoint(x: round(x * screenScale) / screenScale, y: round(y * screenScale) / screenScale)
    }
}

public extension CGRect {
    public func roundPixel() -> CGRect {
        let origin = self.origin.roundPixel()
        let corner = CGPoint(x: self.origin.x + size.width, y: self.origin.y + size.height)
        return CGRect(origin: origin, size: CGSize(width: corner.x - origin.x, height: corner.y - origin.y))
    }

    public func fit(size: CGSize, mode: UIView.ContentMode) -> CGRect {
        var size = size
        var rect = standardized
        size.width = size.width < 0 ? -size.width : size.width
        size.height = size.height < 0 ? -size.height : size.height
        let center = CGPoint(x: CGFloat(rect.midX), y: CGFloat(rect.midY))
        switch mode {
        case .scaleAspectFit, .scaleAspectFill:
            if rect.size.width < 0.01 || rect.size.height < 0.01 || size.width < 0.01 || size.height < 0.01 {
                rect.origin = center
                rect.size = CGSize.zero
            } else {
                var scale: CGFloat = 0.0
                if mode == .scaleAspectFit {
                    if size.width / size.height < rect.size.width / rect.size.height {
                        scale = rect.size.height / size.height
                    } else {
                        scale = rect.size.width / size.width
                    }
                } else {
                    if size.width / size.height < rect.size.width / rect.size.height {
                        scale = rect.size.width / size.width
                    } else {
                        scale = rect.size.height / size.height
                    }
                }
                size.width *= scale
                size.height *= scale
                rect.size = size
                rect.origin = CGPoint(x: CGFloat(center.x - size.width * 0.5), y: CGFloat(center.y - size.height * 0.5))
            }
        case .center:
            rect.size = size
            rect.origin = CGPoint(x: CGFloat(center.x - size.width * 0.5), y: CGFloat(center.y - size.height * 0.5))
        case .top:
            rect.origin.x = center.x - size.width * 0.5
            rect.size = size
        case .bottom:
            rect.origin.x = center.x - size.width * 0.5
            rect.origin.y += rect.size.height - size.height
            rect.size = size
        case .left:
            rect.origin.y = center.y - size.height * 0.5
            rect.size = size
        case .right:
            rect.origin.y = center.y - size.height * 0.5
            rect.origin.x += rect.size.width - size.width
            rect.size = size
        case .topLeft:
            rect.size = size
        case .topRight:
            rect.origin.x += rect.size.width - size.width
            rect.size = size
        case .bottomLeft:
            rect.origin.y += rect.size.height - size.height
            rect.size = size
        case .bottomRight:
            rect.origin.x += rect.size.width - size.width
            rect.origin.y += rect.size.height - size.height
            rect.size = size
        default: break
        }
        return rect
    }

    func addHeight(_ height: CGFloat) -> CGRect {
        return CGRect(origin: origin, size: CGSize(width: size.width, height: size.height + height))
    }
}

public extension UIView {

    public func at(bottom: CGFloat, right: CGFloat) {
        let parent = superview!
        frame = CGRect(origin: CGPoint(x: parent.frame.size.width - frame.size.width + right,
                                       y: parent.frame.size.height - frame.size.height + bottom), size: frame.size)
    }

    public func at(top: CGFloat, left: CGFloat) {
        frame = CGRect(origin: CGPoint(x: left, y: top), size: frame.size)
    }

    public func at(center: CGPoint) {
        let size = frame.size
        frame = CGRect(x: center.x - size.width / 2, y: center.y - size.height / 2, width: size.width, height: size.height)
    }

    public func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    public func getSubviewsOf<T: UIView>() -> [T] {
        var subviews = [T]()

        for subview in self.subviews {
            subviews += subview.getSubviewsOf() as [T]

            if let subview = subview as? T {
                subviews.append(subview)
            }
        }

        return subviews
    }
}

public extension UIAlertController {

    convenience init(title: String?, message: String?, progressView: UIProgressView) {
        self.init(title: title, message: message ?? "" + "\n", preferredStyle: .alert)

        setupProgressView(progressView)
    }

    public class func actionSheet(title: String?) -> UIAlertController {
        return UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
    }

    public func addButton(title: String, handler: (() -> Void)?) {
        addAction(UIAlertAction(title: title, style: .default, handler: { _ in
            handler?()
        }))
    }

    private func setupProgressView(_ progressView: UIProgressView) {
        progressView.trackTintColor = UIColor(red: 0.62, green: 0.66, blue: 0.69, alpha: 1.00)
        progressView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(progressView)

        progressView.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.centerX.equalTo(view)
            make.centerY.equalTo(view).offset(3)
        }
    }
}

public func delay(_ delay: Double, closure: @escaping () -> Void) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

public func isIpad() -> Bool {
    return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
}

let timeOffset: TimeInterval = TimeInterval(TimeZone.current.secondsFromGMT() * 1000)
let millsPerDay: Int64 = 86_400_000

public func isSameDay(_ date1: TimeInterval, _ date2: TimeInterval) -> Bool {
    let dayNumber1 = Int64(date1 + timeOffset) / millsPerDay
    let dayNumber2 = Int64(date2 + timeOffset) / millsPerDay
    return dayNumber1 == dayNumber2
}

private let RemoteKeyboardWindowType = "UIRemoteKeyboardWindow"
private let TextEffectsWindowType = "UITextEffectsWindow"

private func getApplicationKeyboardWindow_Effect() -> UIWindow? {
    for window: UIWindow in UIApplication.shared.windows {
        if String(describing: type(of: window)) == TextEffectsWindowType {
            return window
        }
    }
    return nil
}

private func getApplicationKeyboardWindow_Remote() -> UIWindow? {
    for window: UIWindow in UIApplication.shared.windows {
        if String(describing: type(of: window)) == RemoteKeyboardWindowType {
            return window
        }
    }
    return nil
}

public func videoMetadata(url: URL) -> (image: UIImage?, duration: TimeInterval) {
    let asset = AVURLAsset(url: url)
    let duration = TimeInterval(CMTimeGetSeconds(asset.duration))
    let imgGenerator = AVAssetImageGenerator(asset: asset)
    imgGenerator.appliesPreferredTrackTransform = true
    let cgImage = try? imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
    if cgImage != nil {
        let thumbnail = UIImage(cgImage: cgImage!)
        return (thumbnail, duration)
    }
    return (nil, duration)
}

public func applicationKeyboardWindow() -> UIWindow? {
    let window1 = getApplicationKeyboardWindow_Effect()
    let window2 = getApplicationKeyboardWindow_Remote()
    if window1 != nil && window2 != nil {
        return window1!.windowLevel > window2!.windowLevel ? window1 : window2
    } else if window1 != nil {
        return window1
    } else if window2 != nil {
        return window2
    }
    return nil
}

public func formatTimeInterval(_ duration: TimeInterval) -> String {
    let duration = Int(ceil(duration))
    if duration >= 3600 {
        return String(format: "%02d:%02d:%02d", duration / 3600, duration / 60, duration % 60)
    } else {
        return String(format: "%02d:%02d", duration / 60, duration % 60)
    }
}

public func formatFileSize(_ byte: Int64) -> String {
    if byte <= 0 {
        return "--"
    }
    if byte < 1024 {
        return "\(Int(byte))B"
    } else if byte < 1024 * 1024 {
        return String(format: "%.1fKb", Double(byte) / 1024)
    }
    return String(format: "%.1fM", Double(byte) / (1024 * 1024))
}

public let operatingSystem: OperatingSystemVersion = ProcessInfo.processInfo.operatingSystemVersion

public func urlEncode(_ string: String) -> String {
    let generalDelimitersToEncode = ":#[]@/?" // does not include "?" or "/" due to RFC 3986 - Section 3.4
    let subDelimitersToEncode = "!$&'()*+,;="
    
    var allowedCharacterSet = CharacterSet.urlQueryAllowed
    allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
    
    var escaped = ""
    
    //==========================================================================================================
    //
    //  Batching is required for escaping due to an internal bug in iOS 8.1 and 8.2. Encoding more than a few
    //  hundred Chinese characters causes various malloc error crashes. To avoid this issue until iOS 8 is no
    //  longer supported, batching MUST be used for encoding. This introduces roughly a 20% overhead. For more
    //  info, please refer to:
    //
    //      - https://github.com/Alamofire/Alamofire/issues/206
    //
    //==========================================================================================================
    
    if #available(iOS 8.3, *) {
        escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    } else {
        let batchSize = 50
        var index = string.startIndex
        
        while index != string.endIndex {
            let startIndex = index
            let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) ?? string.endIndex
            let range = startIndex..<endIndex
            
            let substring = string[range]
            
            escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? String(substring)
            
            index = endIndex
        }
    }
    
    return escaped
}
