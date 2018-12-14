//
//  DiscoverNewGoodViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/3.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import HUD
class DetailGoodViewController: BaseViewController {
    var viewModel: DetailRichGoodModel?
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
            if let model = value.model {
                self.cycleView.setUrlsGroup(model.gallery)
                self.viewModel = DetailRichGoodModel(model: model)
            } else {
                HUD.tip(text: "商品不存在")
            }
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fd_prefersNavigationBarHidden = true
        configUI()
        loadData()
        regiestEvent()
    }
    
    private func regiestEvent() {
        LoginAndRegisterFacade.shared.obserUserItemChange().take(during: reactive.lifetime).observeValues { [weak self] item in
            guard let `self` = self else { return }
            if item != nil {
                GoodsFacade.shared.detailGoodBy(self.id).startWithResult({ [weak self] result in
                    guard let `self` = self else { return }
                    guard let value = result.value else { return }
                    if let model = value.model, let viewModel = self.viewModel {
                        viewModel.isCollect = model.collected
                        viewModel.collectCount = model.collectCount
                        self.tableView.reloadData()
                        if !viewModel.isCollect {
                            self.collect()
                        }
                    }
                })
            }
        }
        GoodsFacade.shared.obserCollectState().take(during: reactive.lifetime).observeValues { [weak self] result in
            guard let `self` = self else { return }
            guard let id = result.id else { return }
            guard let collect = result.collect else { return }
            if id == self.id, let model = self.viewModel {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: false)
    }
    
    private func configUI() {
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
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.register(DetailPriceAndCollectCell.self, forCellReuseIdentifier: "DetailPriceAndCollectCell")
        tableView.register(DetailRichGoodCell.self, forCellReuseIdentifier: "DetailRichGoodCell")
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
        if viewModel != nil {
            return 2
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 6.5
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel != nil {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let model = viewModel {
            if indexPath.section == 0 {
                return 75
            } else {
                return model.height
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailPriceAndCollectCell", for: indexPath) as! DetailPriceAndCollectCell
            if let model = viewModel {
                cell.render(model)
            }
            cell.onCollectClick = { [weak self] in
                guard let `self` = self else { return }
                self.collect()
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailRichGoodCell", for: indexPath) as! DetailRichGoodCell
            if let model = viewModel {
                cell.render(model)
            }
            return cell
        }
    }
    
    private func collect() {
        if LoginState.shared.hasLogin {
            if let model = viewModel, model.isCollect {
                 GoodsFacade.shared.unCollect(id: id, type: CollectType.goods).startWithResult { _ in
                }
            } else {
                GoodsFacade.shared.collect(id: id, type: CollectType.goods).startWithResult { _ in
                }
            }
            
        } else {
            let controller = LoginViewController()
            let nav = UINavigationController(rootViewController: controller)
            navigationController?.present(nav, animated: true, completion: nil)
        }
    }
}
