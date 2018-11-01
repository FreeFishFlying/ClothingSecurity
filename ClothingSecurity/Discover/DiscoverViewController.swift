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
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
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
        searchBar.delegate = self
        searchBar.returnKeyType = .search
    
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
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
