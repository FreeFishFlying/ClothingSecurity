//
//  Palette.swift
//  NXDrawKit
//
//  Created by Nicejinux on 2016. 7. 12..
//  Copyright © 2016년 Nicejinux. All rights reserved.
//

import UIKit

@objc public protocol PaletteDelegate
{
    @objc optional func didChangeBrushAlpha(_ alpha:CGFloat)
    @objc optional func didChangeBrushWidth(_ width:CGFloat)
    @objc optional func didChangeBrushColor(_ color:UIColor)
    
    @objc optional func colorWithTag(_ tag: NSInteger) -> UIColor?
    @objc optional func alphaWithTag(_ tag: NSInteger) -> CGFloat
    @objc optional func widthWithTag(_ tag: NSInteger) -> CGFloat
}


open class Palette: UIView
{
    @objc open weak var delegate: PaletteDelegate?
    fileprivate var brush: Brush = Brush()

    fileprivate let buttonDiameter: CGFloat = 30
    fileprivate let buttonPadding: CGFloat = 10

    fileprivate var colorButtonList = [CircleButton]()
    
    fileprivate var totalHeight: CGFloat = 0.0;
    
    fileprivate weak var colorPaletteView: UIView?

    public init() {
        super.init(frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc open func currentBrush() -> Brush {
        return self.brush
    }
    

    // MARK: - Private Methods
    override open var intrinsicContentSize : CGSize {
        let size: CGSize = CGSize(width: UIScreen().bounds.size.width, height: self.totalHeight)
        return size;
    }
    
    @objc open func setup() {
        self.setupColorView()
        onClickColorPicker(self.colorButtonList.first!)
    }
    
    @objc open func paletteHeight() -> CGFloat {
        return self.totalHeight
    }
    
    fileprivate func setupColorView() {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        self.addSubview(view)
        self.colorPaletteView = view
        
        var preButton: CircleButton?
        for index in 1...12 {
            let color: UIColor = self.color(index)
            let button = CircleButton(diameter: self.buttonDiameter, color: color, opacity: 1.0)
            button.frame.origin = CGPoint(x: (preButton?.frame.maxX ?? 0) + buttonPadding, y: buttonPadding)
            button.addTarget(self, action:#selector(Palette.onClickColorPicker(_:)), for: .touchUpInside)
            self.colorPaletteView!.addSubview(button)
            self.colorButtonList.append(button)
            preButton = button
        }
        self.totalHeight = preButton!.frame.maxY + self.buttonPadding;
        view.contentSize = CGSize(width: preButton!.frame.maxX + buttonPadding, height: self.totalHeight)
        self.colorPaletteView?.snp.makeConstraints({ (make) in
            make.left.bottom.top.equalToSuperview()
            make.right.equalToSuperview().offset(-50)
        })
        
        
        widthPickerView.setImage(ImageNamed("PhotoEditorSaturationTool"), for: .normal)
        addSubview(widthPickerView)
        widthPickerView.hitTestEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        widthPickerView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-5)
        }
        widthPickerView.addTarget(self, action: #selector(showStepperView), for: UIControl.Event.touchUpInside)
    }
    
    private let widthPickerView = UIButton()
    
    lazy var stepper: GMStepper = {
        let stepper = GMStepper()
        stepper.alpha = 0
        stepper.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
        stepper.minimumValue = 5
        stepper.value = 20
        stepper.stepValue = 5
        stepper.maximumValue = 50
        superview!.addSubview(stepper)
        stepper.addTarget(self, action: #selector(changeBurshWidth), for: UIControl.Event.valueChanged)
        return stepper
    }()
    
    @objc private func changeBurshWidth() {
        self.brush.width = CGFloat(stepper.value)
    }
    
    func hidePickerView() {
        if stepper.alpha > 0 {
            widthPickerView.isSelected = false
            UIView.animate(withDuration: 0.2) {
                self.stepper.alpha = 0
            }
        }
    }
    
    @objc private func showStepperView() {
        if stepper.alpha > 0 {
            hidePickerView()
        } else {
            widthPickerView.isSelected = true
            stepper.snp.remakeConstraints { (make) in
                make.width.equalTo(120)
                make.height.equalTo(30)
                make.centerX.equalTo(widthPickerView)
                make.bottom.equalTo(widthPickerView.snp.top).offset(-60)
            }
            UIView.animate(withDuration: 0.2) {
                self.stepper.alpha = 1
            }
        }
    }
    
    @objc fileprivate func onClickColorPicker(_ button: CircleButton) {
        if widthPickerView.isSelected && stepper.alpha > 0 {
            hidePickerView()
        }
        self.brush.color = button.color!;
        self.resetButtonSelected(self.colorButtonList, button: button)
        
        self.delegate?.didChangeBrushColor?(self.brush.color)
    }
    
    fileprivate func resetButtonSelected(_ list: [CircleButton], button: CircleButton) {
        for aButton: CircleButton in list {
            aButton.isSelected = aButton.isEqual(button)
        }
    }
    
    fileprivate func updateColorOfButtons(_ list: [CircleButton], color: UIColor, enable: Bool = true) {
        for aButton: CircleButton in list {
            aButton.update(color)
            aButton.isEnabled = enable
        }
    }
    
    fileprivate func color(_ tag: NSInteger) -> UIColor {
        if let color = self.delegate?.colorWithTag?(tag)  {
            return color
        }

        return self.colorWithTag(tag)
    }
    
    fileprivate func colorWithTag(_ tag: NSInteger) -> UIColor {
        switch(tag) {
            case 1:
                return UIColor.black
            case 2:
                return UIColor.darkGray
            case 3:
                return UIColor.gray
            case 4:
                return UIColor.white
            case 5:
                return UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
            case 6:
                return UIColor.orange
            case 7:
                return UIColor.green
            case 8:
                return UIColor(red: 0.15, green: 0.47, blue: 0.23, alpha: 1.0)
            case 9:
                return UIColor(red: 0.2, green: 0.3, blue: 1.0, alpha: 1.0)
            case 10:
                return UIColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 1.0)
            case 11:
                return UIColor(red: 0.62, green: 0.32, blue: 0.17, alpha: 1.0)
            case 12:
                return UIColor.yellow
            default:
                return UIColor.black
        }
    }
    
    fileprivate func opacity(_ tag: NSInteger) -> CGFloat {
        if let opacity = self.delegate?.alphaWithTag?(tag) {
            if 0 > opacity || opacity > 1 {
                return CGFloat(tag) / 3.0
            }
            return opacity
        }

        return CGFloat(tag) / 3.0
    }

    fileprivate func brushWidth(_ tag: NSInteger) -> CGFloat {
        if let width = self.delegate?.widthWithTag?(tag) {
            if 0 > width || width > self.buttonDiameter {
                return self.buttonDiameter * (CGFloat(tag) / 4.0)
            }
            return width
        }
        return self.buttonDiameter * (CGFloat(tag) / 4.0)
    }
}
