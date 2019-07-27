//
//  BaseFavouriteViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/10.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit

class BaseFavouriteViewController: BaseViewController, UIScrollViewDelegate {
    var titles: [String] = ["穿搭收藏", "产品收藏"]
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        extendedLayoutIncludesOpaqueBars = true
        title = localizedString("collection")
        view.addSubview(segmentView)
        segmentView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        view.addSubview(scrollView)
        scrollView.delegate = self
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(segmentView.snp.bottom)
            make.left.bottom.equalToSuperview()
            make.width.equalTo(ScreenWidth)
        }
        scrollView.contentSize = CGSize(width: ScreenWidth * 2, height: 0)
        let popularController = FavouritePopularWearController()
        popularController.view.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight - 44)
        self.addChild(popularController)
        scrollView.addSubview(popularController.view)
        let goodController = FavouriteGoodViewController()
        goodController.view.frame = CGRect(x: ScreenWidth, y: 0, width: ScreenWidth, height: ScreenHeight - 44)
        scrollView.addSubview(goodController.view)
        self.addChild(goodController)
        segmentView.selectSegment = { [weak self] index in
            guard let `self` = self else {
                return
            }
            let x = index * Int((self.view.bounds.width))
            self.scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        }
    }
    
    private lazy var segmentView: SegmentView = {
        let segmentView = SegmentView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 44), titles: titles)
        return segmentView
    }()
    
    private let scrollView: UIScrollView = {
        let scrool = UIScrollView(frame: CGRect(x: 0, y: 44, width: ScreenWidth, height: ScreenHeight - 44))
        scrool.showsVerticalScrollIndicator = false
        scrool.showsHorizontalScrollIndicator = false
        scrool.bounces = false
        scrool.isPagingEnabled = true
        return scrool
    }()
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = scrollView.contentOffset.x / scrollView.bounds.width
        segmentView.selectTheSegment(index: Int(index), animation: true)
    }
}
