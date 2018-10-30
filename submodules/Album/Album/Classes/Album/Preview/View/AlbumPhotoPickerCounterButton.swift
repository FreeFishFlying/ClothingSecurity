//
//  AlbumPhotoPickerCounterButton.swift
//  VideoPlayer-Swift
//
//  Created by Dylan on 12/04/2017.
//  Copyright © 2017 kingxt. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import ReactiveCocoa
import pop

class AlbumPhotoPickerCounterButton: UIButton {

    var selectedCount: Int = 0 {
        didSet {
            if selectedCount == oldValue {
                return
            }
            let increasing = selectedCount > oldValue
            selectedCountDidChanged(animtion: true, increasing: increasing)
            let hidden = selectedCount <= 0 && !isSelected
            setIsHidden(hidden: hidden, animation: true)
        }
    }

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                wrapperView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        }
    }

    override var isSelected: Bool {
        didSet {
            if isSelected == oldValue {
                return
            }
            if selectedCount <= 0 {
                selectedSateDidChanged(animation: false)
                setIsHidden(hidden: true, animation: true)
            } else {
                selectedSateDidChanged(animation: true)
            }
        }
    }

    private lazy var wrapperView: UIView = {
        let wrapperView = UIView()
        wrapperView.isUserInteractionEnabled = false
        return wrapperView
    }()

    private lazy var backgroundView: UIImageView = {
        let backgroundView = UIImageView()
        backgroundView.image = ImageNamed("MediaPickerPhotoCounter")
        return backgroundView
    }()

    private lazy var countLabel: UILabel = {
        let countLabel = UILabel()
        countLabel.font = UIFont.systemFont(ofSize: 16)
        countLabel.textColor = UIColor.white
        return countLabel
    }()

    private lazy var crossIconView: UIImageView = {
        let crossIconView = UIImageView()
        crossIconView.contentMode = UIView.ContentMode.center
        crossIconView.isHidden = true
        crossIconView.image = ImageNamed("MediaPickerPhotoCounter_Close")
        return crossIconView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubview()
        selectedSateDidChanged(animation: false)
        isHidden = true
    }

    private func initializeSubview() {
        addSubview(wrapperView)
        wrapperView.addSubview(backgroundView)
        wrapperView.addSubview(countLabel)
        wrapperView.addSubview(crossIconView)

        wrapperView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        backgroundView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        countLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        crossIconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setIsHidden(hidden: Bool, animation: Bool) {
        if isHidden == hidden {
            return
        }
        if hidden && isSelected {
            isSelected = false
        }
        if animation {
            isHidden = false
            wrapperView.alpha = hidden ? 1 : 0
            UIView.animate(withDuration: 0.2, animations: {
                self.wrapperView.alpha = hidden ? 0 : 1
            }, completion: { _ in
                self.wrapperView.alpha = 1
                self.isHidden = hidden
            })
        } else {
            isHidden = hidden
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        wrapperView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        if bounds.contains(touch.location(in: self)) {
            wrapperView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } else {
            wrapperView.transform = CGAffineTransform.identity
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        wrapperView.transform = CGAffineTransform.identity
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        wrapperView.transform = CGAffineTransform.identity
    }

    private func selectedCountDidChanged(animtion: Bool, increasing: Bool) {
        countLabel.text = String(describing: selectedCount)
        if isSelected {
            return
        }
        if animtion {
            UIView.animate(withDuration: 0.12, animations: {
                self.wrapperView.transform = increasing ? CGAffineTransform(scaleX: 1.2, y: 1.2) : CGAffineTransform(scaleX: 0.8, y: 0.8)
            }, completion: { finished in
                if finished {
                    UIView.animate(withDuration: 0.08, animations: {
                        self.wrapperView.transform = CGAffineTransform.identity
                    })
                }
            })
        }
    }

    private func selectedSateDidChanged(animation: Bool) {
        if animation {
            crossIconView.isHidden = false
            countLabel.isHidden = false
            if isSelected {
                crossIconView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
                countLabel.transform = CGAffineTransform.identity
            }
            let crossStartRotation: CGFloat = crossIconView.layer.value(forKeyPath: "transform.rotation.z") as! CGFloat
            let labelStartRotation: CGFloat = countLabel.layer.value(forKeyPath: "transform.rotation.z") as! CGFloat

            let crossAnimation = POPSpringAnimation(propertyNamed: kPOPLayerRotation)
            crossAnimation?.springSpeed = 12
            crossAnimation?.springBounciness = 7
            crossAnimation?.fromValue = crossStartRotation
            crossAnimation?.toValue = isSelected ? 0 : CGFloat.pi / 4
            crossIconView.layer.pop_add(crossAnimation, forKey: "crossRotation")

            let labelAnimation = POPSpringAnimation(propertyNamed: kPOPLayerRotation)
            labelAnimation?.springSpeed = 12
            labelAnimation?.springBounciness = 7
            labelAnimation?.fromValue = labelStartRotation
            labelAnimation?.toValue = isSelected ? -CGFloat.pi / 4 : 0
            countLabel.layer.pop_add(labelAnimation, forKey: "labelRotation")

            UIView.animate(withDuration: 0.2, animations: {
                self.wrapperView.transform = CGAffineTransform.identity
                self.crossIconView.alpha = self.isSelected ? 1.0 : 0.0
                self.countLabel.alpha = self.isSelected ? 0.0 : 1.0
            }, completion: { _ in
                self.crossIconView.isHidden = !self.isSelected
                self.countLabel.isHidden = self.isSelected
                self.crossIconView.alpha = 1
                self.countLabel.alpha = 1
            })
        } else {
            crossIconView.pop_removeAllAnimations()
            countLabel.pop_removeAllAnimations()
            crossIconView.isHidden = !isSelected
            countLabel.isHidden = isSelected
            wrapperView.transform = CGAffineTransform.identity
            countLabel.transform = CGAffineTransform.identity
        }
    }
}
