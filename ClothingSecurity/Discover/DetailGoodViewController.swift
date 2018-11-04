//
//  DiscoverNewGoodViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/3.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit

class DetailGoodViewController: BaseViewController {
    var model: Good?
    let id: String
    init(id: String) {
        self.id = id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadData() {
        GoodsFacade.shared.detailGoodBy(id).startWithResult { [weak self] result in
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            self.model = value.model
            if let model = self.model {
                self.cycleView.setUrlsGroup(model.gallery)
            }
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fd_prefersNavigationBarHidden = true
        configUI()
        loadData()
    }
    
    
    
    private func configUI() {
        view.backgroundColor = UIColor.red
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-20)
            make.left.bottom.right.equalToSuperview()
        }
        tableView.tableHeaderView = cycleView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 0
        cycleView.imageContentMode = .scaleAspectFill
        cycleView.pageControlIndictirColor = UIColor(hexString: "#bfbfbf")
        cycleView.pageControlCurrentIndictirColor = UIColor.black
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(33)
        }
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.register(DetailPriceAndCollectCell.self, forCellReuseIdentifier: "DetailPriceAndCollectCell")
        return tableView
    }()
    
    private let cycleView: ZCycleView = {
        let view = ZCycleView(frame:CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenWidth))
        view.placeholderImage = imageNamed("perch_product_inside")
        return view
    }()
    
    private let backButton: DefaultBackButton = DefaultBackButton()
}

extension DetailGoodViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if model != nil {
            return 2
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 6.5
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if model != nil {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailPriceAndCollectCell", for: indexPath) as! DetailPriceAndCollectCell
            cell.model = model
            return cell
        }
        return UITableViewCell()
    }
}
