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
    var list: [Prize] = []
    var page: Int = 0
    var type = 0
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
            self.type = value
            self.page = 0
            self.couponList(self.page, type: value)
        }
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(giftView.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
        tableView.register(CouponCell.self, forCellReuseIdentifier: "CouponCell")
        tableView.register(SignleGiftCell.self, forCellReuseIdentifier: "SignleGiftCell")
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
        if type == 0 {
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
                    self.removeEmptyState()
                }
            }
        } else {
            IntegralFacade.shared.giftList(page).startWithResult { [weak self] result in
                guard let `self` = self else { return }
                guard let value = result.value else { return }
                if self.page == 0 {
                    self.list.removeAll()
                }
                self.page += 1
                if value.last {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    self.tableView.mj_footer.resetNoMoreData()
                }
                self.list.append(contentsOf: value.data)
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
                    self.removeEmptyState()
                }
            }
        }
        
    }
    
    private func configDiscountEmptyView() {
        giftEmptyView.removeFromSuperview()
        discountEmptyView.removeFromSuperview()
        tableView.isHidden = true
        view.addSubview(discountEmptyView)
        discountEmptyView.snp.makeConstraints { make in
            make.top.equalTo(giftView.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
    }
    
    private func configGiftEmptyView() {
        giftEmptyView.removeFromSuperview()
        discountEmptyView.removeFromSuperview()
        tableView.isHidden = true
        view.addSubview(giftEmptyView)
        giftEmptyView.snp.makeConstraints { make in
            make.top.equalTo(giftView.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
    }
    
    private func removeEmptyState() {
        giftEmptyView.removeFromSuperview()
        discountEmptyView.removeFromSuperview()
        tableView.isHidden = false
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
        if type == 0 {
            return 94.0
        }
        return 118
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if type == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CouponCell", for: indexPath) as! CouponCell
            if !self.dataSources.isEmpty {
                cell.model = dataSources[indexPath.row]
                cell.onCouponClick = { [weak self] model in
                    let controller = DetailCouponViewController.init(model)
                    self?.navigationController?.pushViewController(controller, animated: true)
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SignleGiftCell", for: indexPath) as! SignleGiftCell
            if !list.isEmpty {
                let gift = list[indexPath.row]
                cell.gift = gift
                cell.showTime = gift.sendTime
                cell.hideButton = false
                cell.onButtonClick = { [weak self] gift in
                    guard let `self` = self else { return }
                    let controller = PickUpImmediatelyController.init(gift, gift.prizeLogId)
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
            return cell
        }
    }
}

class EmptyGiftView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(icon)
        addSubview(contentLabel)
        icon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(60)
        }
        contentLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
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
