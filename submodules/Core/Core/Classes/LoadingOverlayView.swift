//  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
//
//  SLMessageLoadingOverlayView.h
//  ContactChat-iphone
//
//  Created by kingxt on 12/7/15.
//  Copyright © 2015 liaoliao. All rights reserved.
//
import UIKit
import pop

public class LoadingOverlayView: UIView {

    public enum LoadingOverlayViewType: Int {
        case none = 0
        case progress = 2
        case progressCancel = 3
        case progressNoCancel = 4
        case play = 5
        case download = 6
    }
    
    public var type: LoadingOverlayView.LoadingOverlayViewType {
        return !progressLayer.isHidden ? progressLayer.type : contentLayer.type
    }

    private lazy var blurredBackgroundLayer: CALayer = {
        var blurredBackgroundLayer = CALayer()
        blurredBackgroundLayer.frame = CGRect(x: 0.5 + 0.125, y: 0.5 + 0.125, width: 50.0 - 0.25 - 1.0, height: 50.0 - 0.25 - 1.0)
        return blurredBackgroundLayer
    }()

    private lazy var contentLayer: LoadingOverlayViewLayer = {
        var contentLayer = LoadingOverlayViewLayer()
        contentLayer.radius = 50.0
        contentLayer.frame = CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0)
        contentLayer.contentsScale = UIScreen.main.scale
        return contentLayer
    }()

    private lazy var progressLayer: LoadingOverlayViewLayer = {
        var progressLayer = LoadingOverlayViewLayer()
        progressLayer.radius = 50.0
        progressLayer.frame = CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0)
        progressLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        progressLayer.contentsScale = UIScreen.main.scale
        progressLayer.isHidden = true
        return progressLayer
    }()

    public private(set) var progress: CGFloat = 0.0

    public func setRadius(_ radius: CGFloat) {
        blurredBackgroundLayer.frame = CGRect(x: 0.5 + 0.125, y: 0.5 + 0.125, width: radius - 0.25 - 1.0, height: radius - 0.25 - 1.0)
        contentLayer.radius = radius
        contentLayer.frame = CGRect(x: 0.0, y: 0.0, width: radius, height: radius)
        let transform: CATransform3D = progressLayer.transform
        progressLayer.transform = CATransform3DIdentity
        progressLayer.radius = radius
        progressLayer.frame = CGRect(x: 0.0, y: 0.0, width: radius, height: radius)
        progressLayer.transform = transform
    }

    public func setProgress(_ progress: CGFloat, cancelEnabled: Bool, animated: Bool) {
        isHidden = false
        var progress = progress
        if progress > CGFloat(Float.ulpOfOne) {
            progress = max(progress, 0.027)
        }
        blurredBackgroundLayer.isHidden = false
        progressLayer.isHidden = false
        if !animated {
            progressLayer.transform = CATransform3DIdentity
            progressLayer.frame = CGRect(x: 0.0, y: 0.0, width: CGFloat(contentLayer.frame.size.width), height: CGFloat(contentLayer.frame.size.height))
        }
        self.progress = progress
        progressLayer.setProgress(progress, animated: animated)
        if cancelEnabled {
            contentLayer.setProgressCancel()
        } else {
            contentLayer.setProgressNoCancel()
        }
    }

    public var overlayBackgroundColorHint: UIColor? {
        didSet {
            contentLayer.overlayBackgroundColorHint = overlayBackgroundColorHint
        }
    }

    public var overlayCancelLineColor: UIColor? {
        didSet {
            contentLayer.overlayCancelLineColor = overlayCancelLineColor
        }
    }

    public var overlayProgressColor: UIColor? {
        didSet {
            progressLayer.progressCircleColor = overlayProgressColor
        }
    }

    public var overlayArrowColor: UIColor? {
        didSet {
            contentLayer.overlayArrowColor = overlayArrowColor
        }
    }
    
    public var lineWidth: CGFloat? {
        didSet {
            progressLayer.lineWidth = lineWidth
        }
    }

    public func setPlay() {
        contentLayer.setPlay()
        progressLayer.setNone()
        progressLayer.isHidden = true
        blurredBackgroundLayer.isHidden = false
        progress = 0
        isHidden = false
    }

    public func setDownload() {
        contentLayer.setDownload()
        progressLayer.setNone()
        progressLayer.isHidden = true
        blurredBackgroundLayer.isHidden = false
        progress = 0
        isHidden = false
    }

    public func setNone() {
        contentLayer.setNone()
        progressLayer.setNone()
        progressLayer.isHidden = true
        blurredBackgroundLayer.isHidden = false
        progress = 0
        isHidden = true
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = UIColor.clear
        layer.addSublayer(blurredBackgroundLayer)
        layer.addSublayer(contentLayer)
        layer.addSublayer(progressLayer)
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LoadingOverlayViewLayer: CALayer {

    internal var radius: CGFloat = 0.0
    fileprivate var type = LoadingOverlayView.LoadingOverlayViewType.none

    var overlayStyle: Int = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    var progress: CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    var overlayBackgroundColorHint: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var lineWidth: CGFloat? {
        didSet {
            setNeedsDisplay()
        }
    }

    var overlayCancelLineColor: UIColor?
    var progressCircleColor: UIColor?
    var overlayArrowColor: UIColor?

    func setNone() {
        type = LoadingOverlayView.LoadingOverlayViewType.none
        pop_removeAnimation(forKey: "progress")
        pop_removeAnimation(forKey: "progressAmbient")
        progress = 0.0
    }

    func setPlay() {
        if type != .play {
            pop_removeAnimation(forKey: "progress")
            pop_removeAnimation(forKey: "progressAmbient")
            type = .play
            setNeedsDisplay()
        }
    }

    func setDownload() {
        if type != .download {
            pop_removeAnimation(forKey: "progress")
            pop_removeAnimation(forKey: "progressAmbient")
            type = .download
            setNeedsDisplay()
        }
    }

    func setProgressCancel() {
        if type != .progressCancel {
            pop_removeAnimation(forKey: "progress")
            pop_removeAnimation(forKey: "progressAmbient")
            type = .progressCancel
            setNeedsDisplay()
        }
    }

    func setProgressNoCancel() {
        if type != .progressNoCancel {
            pop_removeAnimation(forKey: "progress")
            pop_removeAnimation(forKey: "progressAmbient")
            type = .progressNoCancel
            setNeedsDisplay()
        }
    }

    class func addAmbientProgressAnimation(_ layer: LoadingOverlayViewLayer) {
        let ambientProgress: POPBasicAnimation? = POPBasicAnimation(propertyNamed: kPOPLayerRotation)
        if let ambientProgress = ambientProgress {
            ambientProgress.fromValue = 0.0
            ambientProgress.toValue = .pi * 2.0
            ambientProgress.duration = 3.0
            ambientProgress.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            ambientProgress.repeatForever = true
            layer.pop_add(ambientProgress, forKey: "progressAmbient")
        }
    }

    func setProgress(_ progress: CGFloat, animated: Bool) {
        if type != .progress || abs(self.progress - progress) > CGFloat(Float.ulpOfOne) {
            if type != .progress {
                self.progress = 0.0
            }
            if pop_animation(forKey: "progressAmbient") == nil {
                LoadingOverlayViewLayer.addAmbientProgressAnimation(self)
            }
            type = .progress
            if animated {
                var animation: POPBasicAnimation? = pop_animation(forKey: "progress") as? POPBasicAnimation
                if animation != nil {
                    animation?.toValue = (CGFloat(progress))
                } else {
                    animation = POPBasicAnimation()
                    animation?.property = POPAnimatableProperty.property(withName: "progress", initializer: { (prop: POPMutableAnimatableProperty?) in
                        prop?.readBlock = { (_ layer: Any?, _ values: UnsafeMutablePointer<CGFloat>?) -> Void in
                            let pL: LoadingOverlayViewLayer = layer as! LoadingOverlayViewLayer
                            values![0] = pL.progress
                        }
                        prop?.writeBlock = { (_ layer: Any?, _ values: UnsafePointer<CGFloat>?) -> Void in
                            let pL: LoadingOverlayViewLayer = layer as! LoadingOverlayViewLayer
                            pL.progress = values![0]
                        }
                        prop?.threshold = 0.01
                    }) as! POPAnimatableProperty!
                    animation?.fromValue = (self.progress)
                    animation?.toValue = progress
                    animation?.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
                    animation?.duration = 0.5
                    pop_add(animation, forKey: "progress")
                }
            } else {
                self.progress = progress
                setNeedsDisplay()
            }
        }
    }

    open override func draw(in ctx: CGContext) {
        let context = ctx
        UIGraphicsPushContext(context)
        switch type {
        case .download:
            let diameter = self.radius
            let height: CGFloat = (ceil(self.radius / 2.0) - 1.0)
            let lineWidth: CGFloat = 2
            let width: CGFloat = ceil(radius / 2.5)
            context.setBlendMode(.copy)
            if let overlayBackgroundColorHint = self.overlayBackgroundColorHint {
                context.setFillColor(overlayBackgroundColorHint.cgColor)
            } else {
                context.setFillColor(UIColorRGBA(0xFFFF_FFFF, 0.8).cgColor)
            }
            context.fillEllipse(in: CGRect(x: 0, y: 0, width: diameter, height: diameter))
            context.setStrokeColor(UIColorRGBA(0xFF00_0000, 0.55).cgColor)
            context.setLineCap(.round)
            context.setLineWidth(2)

            let mainLine: [CGPoint] = [CGPoint(x: (diameter - lineWidth) / 2.0 + lineWidth / 2.0, y: (diameter - height) / 2.0 + lineWidth / 2.0), CGPoint(x: (diameter - lineWidth) / 2.0 + lineWidth / 2.0, y: (diameter + height) / 2.0 - lineWidth / 2.0)]
            let firstPoint = CGPoint(x: (diameter - lineWidth) / 2.0 + lineWidth / 2.0 - width / 2.0, y: (diameter + height) / 2.0 + lineWidth / 2.0 - width / 2.0)
            let secondPoint = CGPoint(x: (diameter - lineWidth) / 2.0 + lineWidth / 2.0, y: (diameter + height) / 2.0 + lineWidth / 2.0)
            let thirdPoint = CGPoint(x: (diameter - lineWidth) / 2.0 + lineWidth / 2.0, y: (diameter + height) / 2.0 + lineWidth / 2.0)
            let forthPoint = CGPoint(x: (diameter - lineWidth) / 2.0 + lineWidth / 2.0 + width / 2.0, y: (diameter + height) / 2.0 + lineWidth / 2.0 - width / 2.0)
            let arrowLine: [CGPoint] = [firstPoint, secondPoint, thirdPoint, forthPoint]

            context.setStrokeColor(UIColor.clear.cgColor)
            context.strokeLineSegments(between: mainLine)
            context.strokeLineSegments(between: arrowLine)
            context.setBlendMode(.normal)
            if let overlayArrowColor = overlayArrowColor {
                context.setStrokeColor(overlayArrowColor.cgColor)
            } else {
                context.setStrokeColor(UIColorRGBA(0x000000, 0.55).cgColor)
            }
            context.strokeLineSegments(between: arrowLine)
            context.setBlendMode(.copy)
            context.strokeLineSegments(between: mainLine)
        case .progressCancel, .progressNoCancel:
            let diameter: CGFloat = radius
            var inset: CGFloat = 0.5
            let lineWidth: CGFloat = self.lineWidth ?? 2.0
            var crossSize: CGFloat = 16.0
            if abs(diameter - 37.0) < 0.1 {
                crossSize = 10.0
                inset = 2.0
            }
            context.setBlendMode(CGBlendMode.copy)
            if let overlayBackgroundColorHint = self.overlayBackgroundColorHint {
                context.setFillColor(overlayBackgroundColorHint.cgColor)
            } else {
                context.setFillColor(ImageUtils.colorFromRGBA(rgbValue: 0x000000, alpha: 0.7).cgColor)
            }
            context.fillEllipse(in: CGRect(x: inset, y: inset, width: diameter - inset * 2.0, height: diameter - inset * 2.0))
            context.setLineCap(CGLineCap.round)
            context.setLineWidth(lineWidth)
            let crossLine: [CGPoint] = [CGPoint(x: CGFloat((diameter - crossSize) / 2.0), y: CGFloat((diameter - crossSize) / 2.0)), CGPoint(x: CGFloat((diameter + crossSize) / 2.0), y: CGFloat((diameter + crossSize) / 2.0)), CGPoint(x: CGFloat((diameter + crossSize) / 2.0), y: CGFloat((diameter - crossSize) / 2.0)), CGPoint(x: CGFloat((diameter - crossSize) / 2.0), y: CGFloat((diameter + crossSize) / 2.0))]
            context.setStrokeColor(UIColor.clear.cgColor)
            if type == .progressCancel {
                context.strokeLineSegments(between: crossLine)
            }
            context.setBlendMode(CGBlendMode.normal)
            if let cancelLineColor = overlayCancelLineColor {
                context.setStrokeColor(cancelLineColor.cgColor)
            } else {
                context.setStrokeColor(ImageUtils.colorFromRGBA(rgbValue: 0xFFFFFF, alpha: 1.0).cgColor)
            }
            if type == .progressCancel {
                context.strokeLineSegments(between: crossLine)
            }
        case .progress:
            let diameter: CGFloat = radius
            let lineWidth: CGFloat = self.lineWidth ?? 2.0
            context.setLineCap(CGLineCap.round)
            context.setLineWidth(lineWidth)
            context.setStrokeColor(UIColor.clear.cgColor)
            context.setBlendMode(CGBlendMode.normal)
            if let progressColor = progressCircleColor {
                context.setStrokeColor(progressColor.cgColor)
            } else {
                context.setStrokeColor(UIColor.white.cgColor)
            }
            context.setBlendMode(CGBlendMode.copy)
            let start_angle: CGFloat = CGFloat(2.0 * .pi * 0.0 - Double.pi / 2)
            let end_angle: CGFloat = CGFloat(2.0 * .pi * progress - CGFloat.pi / 2)
            var pathLineWidth: CGFloat = self.lineWidth ?? 2.0
            var pathDiameter: CGFloat = diameter - pathLineWidth
            if abs(diameter - 37.0) < 0.1 {
                pathLineWidth = 2.5
                pathDiameter = diameter - pathLineWidth - 2.5
            }
            let path = UIBezierPath(arcCenter: CGPoint(x: CGFloat(diameter / 2.0), y: CGFloat(diameter / 2.0)), radius: pathDiameter / 2.0, startAngle: start_angle, endAngle: end_angle, clockwise: true)
            path.lineWidth = pathLineWidth
            context.setLineCap(CGLineCap.round)
            path.stroke()
        case .play:
            let diameter: CGFloat = radius
            let width: CGFloat = round(diameter * 0.4)
            let height: CGFloat = round(width * 1.2)
            var offset: CGFloat = round(50.0 * 0.06)
            var verticalOffset: CGFloat = 0.0
            var alpha = 0.8
            var iconColor: UIColor = ImageUtils.colorFromRGBA(rgbValue: 0xFF00_0000, alpha: 0.45)
            if diameter <= 25.0 + CGFloat(Float.ulpOfOne) {
                offset -= 1.0
                verticalOffset += 0.5
                alpha = 1.0
                iconColor = ImageUtils.colorFromRGB(rgbValue: 0x434344)
            }
            context.setBlendMode(CGBlendMode.copy)

            context.setFillColor(ImageUtils.colorFromRGBA(rgbValue: 0xFFFFFF, alpha: Float(alpha)).cgColor)
            context.fillEllipse(in: CGRect(x: 0.0, y: 0.0, width: diameter, height: diameter))
            context.beginPath()
            context.move(to: CGPoint(x: CGFloat(offset + floor((diameter - width) / 2.0)), y: CGFloat(verticalOffset + floor((diameter - height) / 2.0))))
            context.addLine(to: CGPoint(x: CGFloat(offset + floor((diameter - width) / 2.0) + width), y: CGFloat(verticalOffset + floor(diameter / 2.0))))
            context.addLine(to: CGPoint(x: CGFloat(offset + floor((diameter - width) / 2.0)), y: CGFloat(verticalOffset + floor((diameter + height) / 2.0))))
            context.closePath()
            context.setFillColor(iconColor.cgColor)
            context.fillPath()
        default:
            break
        }

        UIGraphicsPopContext()
    }
}
