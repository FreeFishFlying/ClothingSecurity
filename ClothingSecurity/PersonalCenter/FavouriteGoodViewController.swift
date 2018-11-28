//
//  FavouriteGoodViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/10.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import MJRefresh

class FavouriteGoodViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var page: Int = 0
    var list = [Good]()
    override func viewDidLoad() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.equalToSuperview().offset(15)
            make.width.equalTo(ScreenWidth - 30)
            make.bottom.equalToSuperview()
        }
        configSpaceUI()
        loadData()
        collectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadData))
    }
    
    @objc private func loadData() {
        GoodsFacade.shared.collectList(type: .goods, page: page).startWithResult { [weak self] result in
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            if value.last {
                self.collectionView.mj_footer.endRefreshingWithNoMoreData()
            } else {
                self.page += 1
                self.collectionView.mj_footer.resetNoMoreData()
            }
            if self.collectionView.mj_footer.isRefreshing {
                self.collectionView.mj_footer.endRefreshing()
            }
            self.list.append(contentsOf: value.content)
            self.collectionView.reloadData()
            if value.first, self.list.isEmpty {
                self.collectionView.mj_footer.isHidden = true
                self.spaceView.isHidden = false
            }
        }
    }
    
    lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        let width = ScreenWidth - 45
        let size = floor(width / 2)
        layout.itemSize = CGSize(width: size, height: size)
        return layout
    }()
    
    private func configSpaceUI() {
        view.addSubview(spaceView)
        spaceView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        spaceView.addSubview(spaceIcon)
        spaceIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-90)
        }
        spaceView.addSubview(spaceLabel)
        spaceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(spaceIcon.snp.bottom).offset(30)
        }
        spaceView.isHidden = true
    }
    
    private let spaceView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let spaceIcon: UIImageView = {
        let icon = UIImageView()
        icon.image = imageNamed("ic_collect_blank")
        return icon
    }()
    
    private let spaceLabel: UILabel = {
        let label = UILabel()
        let attributedString = NSMutableAttributedString(string: "您还没有相关的产品收藏哦")
        attributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFang-SC-Regular", size: 14.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 153.0 / 255.0, green: 153.0 / 255.0, blue: 153.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: attributedString.length))
        label.attributedText = attributedString
        return label
    }()
    
    lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout)
        collection.delegate = self
        collection.dataSource = self
        collection.alwaysBounceVertical = false
        collection.alwaysBounceHorizontal = false
        collection.backgroundColor = .clear
        collection.register(DetailCategoryGoodCell.self, forCellWithReuseIdentifier: "DetailCategoryGoodCell")
        return collection
    }()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCategoryGoodCell", for: indexPath) as! DetailCategoryGoodCell
        cell.model = list[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = list[indexPath.row]
        let controller = DetailGoodViewController(id: model.id)
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
}
