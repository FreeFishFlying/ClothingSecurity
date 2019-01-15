//
//  LatestMainPushCell.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/1.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit

class LatestMainPushCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private var goods = [Good]()
    var onTapLatestMainPushItem: ((String) -> Void)?
    var onMore: (() -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        addSubview(button)
        button.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(30)
            make.height.equalTo(30)
        }
        button.addTarget(self, action: #selector(more), for: .touchUpInside)
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(button.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(13.5)
            make.right.equalToSuperview().offset(-13.5)
            make.bottom.equalToSuperview()
        }
    }
    
    @objc func more() {
        onMore?()
    }
    
    func render(_ model: LatestMainPushModel) {
        if let models = model.models {
            goods = models
        }
        collectionView.reloadData()
    }
    
    private let button: HeaderCellButton = HeaderCellButton("最新主推")
    
    private let backView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        let width = ScreenWidth - 42
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
        collection.isScrollEnabled = false
        collection.backgroundColor = .clear
        collection.register(DetailCategoryGoodCell.self, forCellWithReuseIdentifier: "DetailCategoryGoodCell")
        collection.register(DetailCategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "DetailCategoryHeaderView")
        collection.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
        return collection
    }()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return goods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCategoryGoodCell", for: indexPath) as! DetailCategoryGoodCell
        cell.model = goods[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let model = goods[safe: indexPath.row] {
            onTapLatestMainPushItem?(model.id)
        }
    }
}
