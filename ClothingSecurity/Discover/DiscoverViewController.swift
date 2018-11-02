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
class DiscoverViewController: BaseViewController {
    var searchList = [SearchCategoryViewModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        loadSearchData()
    }
    
    private func configUI() {
        if #available(iOS 9.0, *) {
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "取消"
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchBar)
        view.addSubview(backView)
        backView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.right.bottom.equalToSuperview()
        }
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(cancelSearch))
        backView.addGestureRecognizer(tap)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(94)
        }
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        searchBar.returnKeyType = .search
    
    }
    
    private func loadSearchData() {
        GoodsFacade.shared.categoryList().startWithResult { [weak self] result in
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            if !value.list.isEmpty {
                value.list.forEach({ item in
                    self.searchList.append(SearchCategoryViewModel(model: item))
                })
            }
            self.tableView.reloadData()
        }
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(hexString: "#f7f7f7")
        tableView.register(SearchCategoryCell.self, forCellReuseIdentifier: "SearchCategoryCell")
        return tableView
    }()
    
    private let searchBar: UISearchBar = {
        let searchbar = UISearchBar(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 44))
        searchbar.placeholder = "搜索产品，“羽绒服”..."
        searchbar.showsCancelButton = false
        searchbar.subviews.first?.subviews.last?.backgroundColor = UIColor(hexString: "#f7f7f7")
        return searchbar
    }()
    
    private let backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        view.isUserInteractionEnabled = true
        return view
    }()
    
    @objc func cancelSearch() {
       searchBar.endEditing(true)
    }
}

extension DiscoverViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        view.bringSubviewToFront(backView)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        view.sendSubviewToBack(backView)
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = nil
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        view.sendSubviewToBack(backView)
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = nil
    }
}

extension DiscoverViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCategoryCell", for: indexPath) as! SearchCategoryCell
        cell.render(searchList[indexPath.row])
        return cell
    }
    
    
}
