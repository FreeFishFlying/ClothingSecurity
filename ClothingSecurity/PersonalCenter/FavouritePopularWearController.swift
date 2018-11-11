//
//  FavouritePopularWearController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/10.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import MJRefresh

class FavouritePopularWearController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    var page: Int = 0
    var imageModels = [ClothesPopularImageModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(ScreenWidth)
        }
        loadData()
        regiestEvent()
        tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(loadData))
    }
    
    @objc private func loadData() {
        GoodsFacade.shared.collectList(type: CollectType.outfit, page: page).startWithResult { [weak self] result in
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            self.page += 1
            value.content.forEach({ item in
                self.imageModels.append(ClothesPopularImageModel(model: item))
            })
            self.tableView.reloadData()
        }
    }
    
    private func regiestEvent() {
        GoodsFacade.shared.obserCollectState().take(during: reactive.lifetime).observeValues { [weak self] result in
            guard let `self` = self else { return }
            guard let id = result.id else { return }
            guard let collect = result.collect else { return }
            if let model = self.imageModels.first(where: {$0.id == id}) {
                model.isCollect = collect
                if collect {
                    model.collectCount += 1
                } else {
                    model.collectCount -= 1
                }
                self.tableView.reloadData()
            }
        }
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ClothesPopularImageCell.self, forCellReuseIdentifier: "ClothesPopularImageCell")
        return tableView
    }()
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageModels.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let model = imageModels[safe: indexPath.row] {
            return model.height
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClothesPopularImageCell", for: indexPath) as! ClothesPopularImageCell
        if let model = imageModels[safe: indexPath.row] {
            cell.render(model)
            cell.onCollectClick = { [weak self] model in
                guard let `self` = self else { return }
                self.collect(model)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if  let model = imageModels[safe: indexPath.row] {
            let controller = DetailPopularWearViewController(wearId: model.id)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    private func collect(_ model: ClothesPopularImageModel) {
        if LoginState.shared.hasLogin {
            if  model.isCollect {
                GoodsFacade.shared.unCollect(id: model.id, type: CollectType.outfit).startWithResult { _ in
                }
            } else {
                GoodsFacade.shared.collect(id: model.id, type: CollectType.outfit).startWithResult { _ in
                }
            }
        } else {
            let controller = LoginViewController()
            let nav = UINavigationController(rootViewController: controller)
            navigationController?.present(nav, animated: true, completion: nil)
        }
    }
}
