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
        view.addSubview(searchHistoryView)
        searchHistoryView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide).offset(45)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(200)
        }
        configSpaceUI()
        searchHistoryView.onHideSearchView = { [weak self] in
            guard let `self` = self else { return }
            self.searchHistoryView.isHidden = true
        }
        searchHistoryView.onClickKeyword = { [weak self] keyword in
            guard let `self` = self else { return }
            self.onClickKeyWord?(keyword)
        }
    }
    
    private func configSpaceUI() {
        view.addSubview(spaceView)
        spaceView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        spaceView.addSubview(spaceIcon)
        spaceIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
        }
        spaceView.addSubview(spaceLabel)
        spaceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(spaceIcon.snp.bottom).offset(30)
        }
        spaceView.isHidden = true
    }
    
    func beginSearch() {
        searchHistoryView.reset()
        searchHistoryView.isHidden = false
        tableView.isHidden = true
        spaceView.isHidden = true
    }
    
    var searchResult: [Good]? {
        didSet {
            if let reslut = searchResult {
                if !reslut.isEmpty {
                    tableView.isHidden = false
                    spaceView.isHidden = true
                } else {
                    tableView.isHidden = true
                    spaceView.isHidden = false
                }
                searchHistoryView.isHidden = true
                tableView.reloadData()
            } else {
                spaceView.isHidden = false
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
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    private let spaceView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let spaceIcon: UIImageView = {
        let icon = UIImageView()
        icon.image = imageNamed("ic_search_blank")
        return icon
    }()
    
    private let spaceLabel: UILabel = {
        let label = UILabel()
        let attributedString = NSMutableAttributedString(string: "抱歉，没有搜到相关内容")
        attributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFang-SC-Regular", size: 14.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 153.0 / 255.0, green: 153.0 / 255.0, blue: 153.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: attributedString.length))
        label.attributedText = attributedString
        return label
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
