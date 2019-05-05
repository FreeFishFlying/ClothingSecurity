//
//  NotificationViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2019/5/5.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation
import MJRefresh

class NotificationViewController: BaseViewController {
    var list: [Notification] = []
    var page: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的消息"
        view.backgroundColor = UIColor(red: 242.0 / 255.0, green: 242.0 / 255.0, blue: 242.0 / 255.0, alpha: 1.0)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.bottom.right.equalToSuperview()
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            self.loadData(0)
        })
        tableView.mj_footer.beginRefreshing()
        PersonCenterFacade.shared.readNotification().startWithResult { _ in
        }
    }

    private func loadData(_ page: Int) {
        PersonCenterFacade.shared.notificationList(page).startWithResult { [weak self] result in
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            if value.first {
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
            if self.list.isEmpty {
                self.configEmptyView()
            } else {
                self.removeEmptyState()
            }
        }
    }
    
    private func configEmptyView() {
        messageEmptyView.removeFromSuperview()
        tableView.isHidden = true
        view.addSubview(messageEmptyView)
        messageEmptyView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.bottom.right.equalToSuperview()
        }
    }
    
    private func removeEmptyState() {
        messageEmptyView.removeFromSuperview()
        tableView.isHidden = false
    }

    private let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.backgroundColor = UIColor.clear
        table.backgroundView = nil
        table.register(NotificitionCell.self, forCellReuseIdentifier: "NotificitionCell")
        return table
    }()
    
    private let messageEmptyView: EmptyGiftView = {
        let view = EmptyGiftView()
        view.content = "亲，你还没有消息哦"
        view.imageName = "nomessage"
        return view
    }()
}

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 136
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificitionCell", for: indexPath) as! NotificitionCell
        cell.model = list[indexPath.row]
        return cell
    }
}


