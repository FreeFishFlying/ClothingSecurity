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
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.bottom.equalToSuperview()
            make.width.equalTo(ScreenWidth)
        }
        configSpaceUI()
        regiestEvent()
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            guard let `self` = self else { return }
            self.loadData()
        })
        loadData()
    }
    
    @objc private func loadData() {
        GoodsFacade.shared.collectList(type: CollectType.outfit, page: page).startWithResult { [weak self] result in
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            value.content.forEach({ item in
                self.imageModels.append(ClothesPopularImageModel(model: item))
            })
            if self.tableView.mj_footer.isRefreshing {
                self.tableView.mj_footer.endRefreshing()
            }
            if value.last {
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
            } else {
                self.page += 1
                self.tableView.mj_footer.resetNoMoreData()
            }
            if value.first, self.imageModels.isEmpty {
                self.tableView.mj_footer.isHidden = true
                self.spaceView.isHidden = false
            }
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
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ClothesPopularImageCell.self, forCellReuseIdentifier: "ClothesPopularImageCell")
        return tableView
    }()
    
    private func configSpaceUI() {
        view.addSubview(spaceView)
        spaceView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        spaceView.addSubview(spaceIcon)
        spaceIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-90)
        }
        spaceView.addSubview(spaceLabel)
        spaceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(spaceIcon.snp.bottom).offset(30)
        }
        spaceView.isHidden = true
    }
    
    private let spaceView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let spaceIcon: UIImageView = {
        let icon = UIImageView()
        icon.image = imageNamed("ic_collect_blank")
        return icon
    }()
    
    private let spaceLabel: UILabel = {
        let label = UILabel()
        let attributedString = NSMutableAttributedString(string: "您还没有相关的产品收藏哦")
        attributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFang-SC-Regular", size: 14.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 153.0 / 255.0, green: 153.0 / 255.0, blue: 153.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: attributedString.length))
        label.attributedText = attributedString
        return label
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
