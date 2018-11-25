//
//  PopularWearViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/5.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit
import MJRefresh
class PopularWearViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    var page: Int = 0
    var videoModel: ClothesMakingVideoModel?
    var imageModels = [ClothesPopularImageModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "人气穿搭"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.right.bottom.equalToSuperview()
        }
        loadVideo()
        loadImageData()
        regiestEvent()
        tableView.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: { [weak self] in
            self?.loadImageData()
        })
    }
    
    private func loadVideo() {
        GoodsFacade.shared.hotDesignList().startWithResult { [weak self] result in
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            if !value.content.isEmpty {
                self.videoModel = ClothesMakingVideoModel.init(models: value.content)
                self.tableView.reloadData()
            }
        }
    }
    
    private func loadImageData() {
        GoodsFacade.shared.popularWear(page: page, size: 10).startWithResult { [weak self] result in
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
        tableView.register(ClothesMakingVideoCell.self, forCellReuseIdentifier: "ClothesMakingVideoCell")
        tableView.register(ClothesPopularImageCell.self, forCellReuseIdentifier: "ClothesPopularImageCell")
        return tableView
    }()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if videoModel != nil {
                return 1
            }
        } else {
            return imageModels.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if let model = videoModel {
                return model.height
            }
        } else {
            if let model = imageModels[safe: indexPath.row] {
                return model.height
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if videoModel != nil {
                return 58
            }
            return 0.1
        } else {
            return 58
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 58))
        let label = UILabel()
        label.font = UIFont(name: "PingFangSC-Medium", size: 19.0)
        label.textColor = UIColor(hexString: "#000000")
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        if section == 0 {
            if videoModel != nil {
                label.text = "衣服制作视频"
            } else {
                return nil
            }
        } else {
            if !imageModels.isEmpty {
                label.text = "搭配推荐"
            } else {
                return nil
            }
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ClothesMakingVideoCell", for: indexPath) as! ClothesMakingVideoCell
            if let model = videoModel {
                cell.render(model)
                cell.onPlayView = { [weak self] url in
                    if let remoteUrl = URL(string: url) {
                        let player = AVPlayer(url: remoteUrl)
                        let playController = AVPlayerViewController()
                        playController.player = player
                        self?.present(playController, animated: true, completion: {
                            playController.player?.play()
                        })
                    }
                }
            }
            return cell
        } else {
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1, let model = imageModels[safe: indexPath.row] {
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

