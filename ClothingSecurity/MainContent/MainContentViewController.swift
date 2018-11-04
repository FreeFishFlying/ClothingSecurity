//
//  MainContentViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/10.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class MainContentViewController: BaseViewController {
    var bannerList = [Banner]()
    var dataSource = [Any]()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = imageHeader
        navigationItem.titleView?.addSubview(titleView)
        dataSource.append(BrandIntroductionModel())
        dataSource.append(PopularWearModel(good: nil))
        dataSource.append(LatestMainPushModel())
        configUI()
        loadData()
    }
    
    private func loadData() {
        GoodsFacade.shared.popularWear(page: 0,size: 1).startWithResult { [weak self] result in
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            if let model = self.dataSource[safe: 1] as? PopularWearModel {
                model.good = value.content.first
                self.tableView.reloadData()
            }
        }
        GoodsFacade.shared.latestMainPush(page: 0, size: 4).startWithResult { [weak self] result in
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            if let model = self.dataSource[safe: 2] as? LatestMainPushModel {
                model.models = value.content
                self.tableView.reloadData()
            }
        }
        GoodsFacade.shared.bannerList().startWithResult { [weak self] result in
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            self.bannerList.append(contentsOf: value.data)
            let urls = self.bannerList.map({$0.image})
            self.cycleView.setUrlsGroup(urls)
        }
    }
    
    private func configUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.bottom.right.equalToSuperview()
        }
        tableView.tableHeaderView = cycleView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 0
        cycleView.delegate = self
        cycleView.imageContentMode = .scaleAspectFill
        cycleView.pageControlIndictirColor = UIColor(hexString: "#bfbfbf")
        cycleView.pageControlCurrentIndictirColor = UIColor.black
    }
    
    private let cycleView: ZCycleView = {
        let view = ZCycleView(frame:CGRect(x: 0, y: 0, width: ScreenWidth, height: 192))
        view.placeholderImage = imageNamed("perch_banner")
        return view
    }()
    
    private let titleView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 109, height: 20))
        imageView.image = imageNamed("logo")
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.register(BrandIntroductionCell.self, forCellReuseIdentifier: "BrandIntroductionCell")
        tableView.register(PopularWearCell.self, forCellReuseIdentifier: "PopularWearCell")
        tableView.register(LatestMainPushCell.self, forCellReuseIdentifier: "LatestMainPushCell")
        return tableView
    }()
}

extension MainContentViewController: ZCycleViewProtocol {
    func cycleViewDidScrollToIndex(_ index: Int) {
    }
    
    func cycleViewDidSelectedIndex(_ index: Int) {
        print("select index = \(index)")
    }
}

extension MainContentViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = dataSource[indexPath.section]
        if let model = model as? BrandIntroductionModel {
            return model.height
        } else if let model = model as? PopularWearModel {
            return model.height
        } else if let model = model as? LatestMainPushModel {
            return CGFloat(model.height)
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataSource[indexPath.section]
        if let model = model as? BrandIntroductionModel {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BrandIntroductionCell", for: indexPath) as! BrandIntroductionCell
            cell.render(model)
            cell.onMore = { [weak self] in
                let controller = BrandIntroduceViewController()
                controller.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(controller, animated: true)
            }
            return cell
        } else if let model = model as? PopularWearModel {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PopularWearCell", for: indexPath) as! PopularWearCell
            cell.render(model)
            return cell
        } else if let model = model as? LatestMainPushModel {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LatestMainPushCell", for: indexPath) as! LatestMainPushCell
            cell.render(model)
            cell.onTapLatestMainPushItem = { [weak self] id in
                guard let `self` = self else { return }
                self.searchById(id)
            }
            cell.onMore = { [weak self] in
                guard let `self` = self else { return }
                let controller = LatestMainPushViewController()
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func searchById(_ id: String) {
        let controller = DetailGoodViewController(id: id)
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
}

