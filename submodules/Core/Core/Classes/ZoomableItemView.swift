//
//  ZoomableItemView.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 4/18/17.
//  Copyright © 2017 kingxt. All rights reserved.
//

import Foundation
import UIKit

public class ZoomableItemView: UIView, UIScrollViewDelegate {

    public var scrollViewDidScrollCallback: ((UIScrollView) -> Void)?

    public init() {
        super.init(frame: CGRect.zero)
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        initGesture()
    }

    public func setZoomableView(_ view: UIView) {
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        scrollView.addSubview(view)
        scrollView.contentSize = CGSize(width: 0, height: view.frame.size.height)
    }

    public var maximumZoomScale: CGFloat = 1 {
        didSet {
            scrollView.maximumZoomScale = maximumZoomScale
        }
    }

    public private(set) lazy var doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapGesture(_:)))

    fileprivate func initGesture() {
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }

    public func reset() {
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
    }
    
    public func scrollViewShouldEnabled(enabled: Bool) {
        scrollView.isUserInteractionEnabled = enabled
    }

    @objc fileprivate func doubleTapGesture(_ doubleTap: UITapGestureRecognizer) {
        let pointInView = doubleTap.location(in: self)
        if scrollView.zoomScale <= scrollView.minimumZoomScale + CGFloat.ulpOfOne {
            let newZoomScale: CGFloat = scrollView.maximumZoomScale
            let scrollViewSize: CGSize = scrollView.bounds.size
            let w: CGFloat = scrollViewSize.width / newZoomScale
            let h: CGFloat = scrollViewSize.height / newZoomScale
            let x: CGFloat = pointInView.x - (w / 2.0)
            let y: CGFloat = pointInView.y - (h / 2.0)
            let rectToZoomTo = CGRect(x: x, y: y, width: w, height: h)
            scrollView.zoom(to: rectToZoomTo, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }

    public func viewForZooming(in _: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let callback = scrollViewDidScrollCallback {
            callback(scrollView)
        }
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.bounds)
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        }
        return scrollView
    }()
}
