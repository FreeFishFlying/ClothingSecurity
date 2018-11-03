//
//  DiscoverResultViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/3.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit

class DiscoverResultViewController: BaseViewController {
    var onClickKeyWord: ((String) -> Void)?
    var onSelectGoodById: ((String) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.bottom.right.equalToSuperview()
        }
        tableView.isHidden = true
        SearchHistory.save("陈年往事肉发我")
        view.addSubview(searchHistoryView)
        searchHistoryView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide).offset(45)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(200)
        }
        searchHistoryView.onHideSearchView = { [weak self] in
            guard let `self` = self else { return }
            self.searchHistoryView.isHidden = true
        }
        searchHistoryView.onClickKeyword = { [weak self] keyword in
            guard let `self` = self else { return }
            self.onClickKeyWord?(keyword)
        }
    }
    
    func beginSearch() {
        searchHistoryView.reset()
        searchHistoryView.isHidden = false
        tableView.isHidden = true
    }
    
    var searchResult: [Good]? {
        didSet {
            if let reslut = searchResult, !reslut.isEmpty {
                searchHistoryView.isHidden = true
                tableView.isHidden = false
                tableView.reloadData()
            }
        }
    }
    
    private let searchHistoryView: SearchHistoryView = SearchHistoryView()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.register(DetailSearchedGoodCell.self, forCellReuseIdentifier: "DetailSearchedGoodCell")
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
}

extension DiscoverResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailSearchedGoodCell", for: indexPath) as! DetailSearchedGoodCell
        if let result = searchResult {
            cell.model = result[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let results = searchResult {
            let model = results[indexPath.row]
            onSelectGoodById?(model.id)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    }
}
