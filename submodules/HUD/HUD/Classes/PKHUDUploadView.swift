//
//  PKHUDUploadView.swift
//  ActionSheet
//
//  Created by 研发部-mzy on 2018/5/24.
//

import Foundation

open class PKHUDUploadView: PKHUDSquareBaseView, PKHUDAnimating {
    
    class UploadProgressView: UIView {
        struct Constant {
            static let lineWidth: CGFloat = 5
            static let trackColor = UIColor(red: 85/255.0, green: 85/255.0, blue: 85/255.0, alpha: 1)
            static let progressColoar = UIColor(red: 248/255.0, green: 231/255.0, blue: 28/255.0, alpha: 1)
        }
        
        let trackLayer = CAShapeLayer()
        let progressLayer = CAShapeLayer()
        let path = UIBezierPath()
        
        @IBInspectable var progress: Int = 0 {
            didSet {
                if progress > 100 {
                    progress = 100
                }else if progress < 0 {
                    progress = 0
                }
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = UIColor.clear
        }
        
        override func draw(_ rect: CGRect) {
            path.addArc(withCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                        radius: bounds.size.width/2 - Constant.lineWidth,
                        startAngle: angleToRadian(-90), endAngle: angleToRadian(270), clockwise: true)
            trackLayer.frame = bounds
            trackLayer.fillColor = UIColor.clear.cgColor
            trackLayer.strokeColor = Constant.trackColor.cgColor
            trackLayer.lineWidth = Constant.lineWidth
            trackLayer.path = path.cgPath
            layer.addSublayer(trackLayer)
            
            progressLayer.frame = bounds
            progressLayer.fillColor = UIColor.clear.cgColor
            progressLayer.strokeColor = Constant.progressColoar.cgColor
            progressLayer.lineWidth = Constant.lineWidth
            progressLayer.path = path.cgPath
            progressLayer.strokeStart = 0
            progressLayer.strokeEnd = CGFloat(progress)/100.0
            layer.addSublayer(progressLayer)
        }
        
        func setProgress(_ pro: Int,animated anim: Bool) {
            setProgress(pro, animated: anim, withDuration: 0.5)
        }
        
        func setProgress(_ pro: Int,animated anim: Bool, withDuration duration: Double) {
            progress = pro
            CATransaction.begin()
            CATransaction.setDisableActions(!anim)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name:
                CAMediaTimingFunctionName.easeInEaseOut))
            CATransaction.setAnimationDuration(duration)
            progressLayer.strokeEnd = CGFloat(progress)/100.0
            CATransaction.commit()
        }
        
        fileprivate func angleToRadian(_ angle: Double)->CGFloat {
            return CGFloat(angle/Double(180.0) * M_PI)
        }
    }
    
    public func startAnimation() {
        
    }
    
    public init(percent: Int, title: String? = nil, subtitle: String? = nil) {
        super.init(title: title, subtitle: subtitle)
        frame = CGRect(origin: CGPoint.zero, size: CGSize(width: frame.size.width + 20, height: frame.size.height + 140))
        if !self.subviews.contains(percentView) {
            commonInit()
        }
        updateProgress(percent: percent)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        addSubview(percentView)
        addSubview(percentLabel)
        addSubview(tipLabel)
        percentView.frame = CGRect(origin: CGPoint(x: (frame.size.width - 70) / 2, y: 20), size: CGSize(width: 70, height: 70))
        percentLabel.frame = CGRect(origin: CGPoint(x: 0, y: 47), size: CGSize(width: frame.size.width, height: 16))
        tipLabel.frame = CGRect(origin: CGPoint(x: 0, y: frame.size.height - 40), size: CGSize(width: frame.size.width, height: 20))
    }
    
    func updateProgress(percent: Int) {
        percentView.progress = percent
        percentLabel.text = "\(percentView.progress)%"
    }
    
    private let percentView: UploadProgressView = {
        let view = UploadProgressView()
        return view
    }()
    
    private let percentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = PKHUDTextView.systemFontSize(fontSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    private let tipLabel: UILabel = {
        let label = UILabel()
        label.text = "正在上传"
        label.textColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
        label.font = PKHUDTextView.systemFontSize(fontSize: 16)
        label.textAlignment = .center
        return label
    }()
}
