//
//  DiscoverViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/10.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Mesh
class DiscoverViewController: BaseViewController {
    var categoryList = [SearchCategoryViewModel]()
    var subCategoryGoods = [SubCategory]()
    fileprivate var networkReachabilityManager: NetworkReachabilityManager?
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        loadSearchData()
        registerEvent()
        loadHotTerm()
    }
    
    func registerEvent() {
        if networkReachabilityManager == nil {
            networkReachabilityManager = NetworkReachabilityManager()
            networkReachabilityManager?.startListening()
            networkReachabilityManager?.listener = { status in
                switch status {
                case .notReachable:
                    break
                case let .reachable(connectionType):
                    switch connectionType {
                    case .ethernetOrWiFi:
                        self.loadSearchData()
                    case .wwan:
                        self.loadSearchData()
                    }
                case .unknown:
                    break
                }
            }
        }
    }
    
    private func configUI() {
        if #available(iOS 9.0, *) {
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "取消"
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchBar)
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.right.bottom.equalToSuperview()
        }
        containerView.addSubview(resultViewController.view)
        resultViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        resultViewController.onClickKeyWord = { [weak self] keyword in
            guard let `self` = self else { return }
            self.beginSearch(keyword)
            self.searchBar.text = keyword
        }
        resultViewController.onSelectGoodById = { [weak self] id in
            guard let `self` = self else { return }
            let controller = DetailGoodViewController(id: id)
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
            
        }
        view.addSubview(backView)
        backView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.right.bottom.equalToSuperview()
        }
        backView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(94)
        }
        searchBar.delegate = self
        searchBar.returnKeyType = .search
        backView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.equalTo(tableView.snp.right).offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview()
        }
    }
    
    private func loadSearchData() {
        GoodsFacade.shared.categoryList().startWithResult { [weak self] result in
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            if !value.list.isEmpty {
                value.list.forEach({ item in
                    self.categoryList.append(SearchCategoryViewModel(model: item))
                })
            }
            self.tableView.reloadData()
            if !self.categoryList.isEmpty {
                self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
                if let model = self.categoryList.first {
                    self.searchByCategoryId(id: model.model.id)
                }
            }
        }
    }
    
    private func loadHotTerm() {
        GoodsFacade.shared.hotTerm().startWithResult { [weak self] result in
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            if !value.value.isEmpty {
                self.searchBar.placeholder = value.value
            } else {
                self.searchBar.placeholder = "搜索产品"
            }
        }
    }
    
    private func searchByCategoryId(id: String) {
        GoodsFacade.shared.goodsGroupCategoryBy(id: id).startWithResult { [weak self] result in
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            self.subCategoryGoods.removeAll()
            self.subCategoryGoods.append(contentsOf: value.dataList)
            self.collectionView.reloadData()
        }
    }
    
    private func beginSearch(_ keyword: String) {
        GoodsFacade.shared.search(keyword).startWithResult { [weak self] result in
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            self.resultViewController.searchResult = value.content
            self.searchBar.resignFirstResponder()
        }
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(hexString: "#f7f7f7")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SearchCategoryCell.self, forCellReuseIdentifier: "SearchCategoryCell")
        return tableView
        
    }()
    
    lazy var resultViewController = DiscoverResultViewController()
    
    lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        let width = ScreenWidth - 94 - 45
        let size = floor(width / 2)
        layout.itemSize = CGSize(width: size, height: size)
        layout.headerReferenceSize = CGSize(width: ScreenWidth, height: 37)
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
    
    private let searchBar: UISearchBar = {
        let searchbar = UISearchBar(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 44))
        searchbar.showsCancelButton = false
        searchbar.placeholder = "搜索产品"
        searchbar.subviews.first?.subviews.last?.backgroundColor = UIColor(hexString: "#f7f7f7")
        return searchbar
    }()
    
    private let backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.isUserInteractionEnabled = true
        return view
    }()
    
    @objc func cancelSearch() {
       searchBar.endEditing(true)
        view.sendSubviewToBack(containerView)
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = nil

    }
}

extension DiscoverViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        view.bringSubviewToFront(containerView)
        resultViewController.beginSearch()
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let keyword = searchBar.text {
            beginSearch(keyword)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        view.sendSubviewToBack(containerView)
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = nil
    }
}

extension DiscoverViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCategoryCell", for: indexPath) as! SearchCategoryCell
        cell.render(categoryList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewModel = categoryList[safe: indexPath.row] {
            searchByCategoryId(id: viewModel.model.id)
        }
    }
}

extension DiscoverViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return subCategoryGoods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sub = subCategoryGoods[safe: section] {
            return sub.list.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer", for: indexPath)
            return view
        } else {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "DetailCategoryHeaderView", for: indexPath) as! DetailCategoryHeaderView
            let model = subCategoryGoods[indexPath.section]
            view.name = model.name
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCategoryGoodCell", for: indexPath) as! DetailCategoryGoodCell
        cell.model = subCategoryGoods[indexPath.section].list[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = subCategoryGoods[indexPath.section].list[indexPath.row]
        let controller = DetailGoodViewController(id: model.id)
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
}
