//
//  MyDiscountCoupon.swift
//  Labeauty
//
//  Created by 宋昌鹏 on 2019/5/1.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation
import SwiftyJSON
import MJRefresh

class MyDiscountCouponViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    var dataSources: [Coupon] = []
    var page: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的优惠券"
        view.backgroundColor = UIColor(red: 242.0 / 255.0, green: 242.0 / 255.0, blue: 242.0 / 255.0, alpha: 1.0)
        configTB()
    }
    
    func configTB() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.register(CouponCell.self, forCellReuseIdentifier: "CouponCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.backgroundView = nil
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            guard let `self` = self else { return }
            self.couponList(self.page)
        })
        tableView.mj_footer.beginRefreshing()
    }
    
    private func couponList(_ page: Int) {
        IntegralFacade.shared.couponList(page).startWithResult { [weak self] result in
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            if self.page == 0 {
                self.dataSources.removeAll()
            }
            self.page += 1
            if value.last {
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
            } else {
                self.tableView.mj_footer.resetNoMoreData()
            }
            self.dataSources.append(contentsOf: value.data)
            if !value.data.isEmpty {
                self.tableView.reloadData()
            }
        }
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        return tableView
    }()
}

extension MyDiscountCouponViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CouponCell", for: indexPath) as! CouponCell
        cell.model = dataSources[indexPath.row]
        cell.onCouponClick = { [weak self] model in
            let controller = DetailCouponViewController.init(model)
            self?.navigationController?.pushViewController(controller, animated: true)
        }
        return cell
    }
    
}
