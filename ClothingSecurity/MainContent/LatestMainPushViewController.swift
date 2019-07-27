//
//  LatestMainPushViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/4.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import MJRefresh
class LatestMainPushViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var page: Int = 0
    private var dataSource = [Good]()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = localizedString("latestHas")
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview()
        }
        loadData()
        collectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            self?.loadData()
        })
    }
    
    private func loadData() {
        GoodsFacade.shared.latestMainPush(page: page, size: 10).startWithResult { [weak self] result in
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
            self.dataSource.append(contentsOf: value.content)
            
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
        collection.register(DetailCategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "DetailCategoryHeaderView")
        collection.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
        return collection
    }()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCategoryGoodCell", for: indexPath) as! DetailCategoryGoodCell
        cell.model = dataSource[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let model = dataSource[safe: indexPath.row] {
            let controller = DetailGoodViewController(id: model.id)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}
