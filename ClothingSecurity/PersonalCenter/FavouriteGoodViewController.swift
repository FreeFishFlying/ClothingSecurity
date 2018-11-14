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
        loadData()
        collectionView.mj_footer = MJRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadData))
    }
    
    @objc private func loadData() {
        GoodsFacade.shared.collectList(type: .goods, page: page).startWithResult { [weak self] result in
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            self.page += 1
            self.list.append(contentsOf: value.content)
            self.collectionView.reloadData()
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