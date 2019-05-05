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
        title = "我的礼物"
        view.backgroundColor = UIColor(red: 242.0 / 255.0, green: 242.0 / 255.0, blue: 242.0 / 255.0, alpha: 1.0)
        configTB()
    }
    
    func configTB() {
        view.addSubview(giftView)
        giftView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(55)
        }
        giftView.onClickRecordView = { [weak self] value in
            guard let `self` = self else { return }
            self.couponList(0, type: value)
        }
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(giftView.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
        tableView.register(CouponCell.self, forCellReuseIdentifier: "CouponCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.backgroundView = nil
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            guard let `self` = self else { return }
            self.couponList(self.page, type: 0)
        })
        tableView.mj_footer.beginRefreshing()
    }
    
    private func couponList(_ page: Int, type: Int) {
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
            if self.dataSources.isEmpty {
                if type == 0 {
                    self.configDiscountEmptyView()
                } else {
                    self.configGiftEmptyView()
                }
            } else {
                self.tableView.isHidden = false
            }
        }
    }
    
    private func configDiscountEmptyView() {
        giftEmptyView.removeFromSuperview()
        discountEmptyView.removeFromSuperview()
        tableView.isHidden = true
        discountEmptyView.snp.makeConstraints { make in
            make.top.equalTo(giftView.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
    }
    
    private func configGiftEmptyView() {
        giftEmptyView.removeFromSuperview()
        discountEmptyView.removeFromSuperview()
        tableView.isHidden = true
        giftEmptyView.snp.makeConstraints { make in
            make.top.equalTo(giftView.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
    }
    
    private let giftView: GiftRecordView = GiftRecordView()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let discountEmptyView: EmptyGiftView = {
        let view = EmptyGiftView()
        view.content = "亲，你暂时还没有优惠券哦"
        view.imageName = "Nocoupons"
        return view
    }()
    
    private let giftEmptyView: EmptyGiftView = {
        let view = EmptyGiftView()
        view.content = "亲，你暂时还没有实物奖品哦"
        view.imageName = "Noprizes"
        return view
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

class EmptyGiftView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(icon)
        addSubview(contentLabel)
        icon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.top.equalToSuperview().offset(60)
        }
        contentLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.top.equalTo(icon.snp.bottom).offset(60)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var imageName: String? {
        didSet {
            if let name = imageName {
                icon.image = imageNamed(name)
            }
        }
    }
    
    var content: String? {
        didSet {
            if let content = content {
                contentLabel.text = content
            }
        }
    }
    
    private let icon: UIImageView = {
        let imageview = UIImageView()
        return imageview
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 13)
        label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        return label
    }()
}
