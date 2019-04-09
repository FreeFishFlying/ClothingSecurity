//
//  DetailPopularWearViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/10.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit

class DetailPopularWearViewController: BaseViewController {
    var viewModel: DetailRichGoodModel?
    
    let id: String
    init(wearId: String) {
        self.id = wearId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fd_prefersNavigationBarHidden = true
        configUI()
        loadData()
        regiestEvent()
    }
    
    private func loadData() {
        GoodsFacade.shared.detailPopularWearBy(id).startWithResult { [weak self] result in
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            guard let model = value.model else { return }
            self.cycleView.setUrlsGroup(model.gallery)
            self.viewModel = DetailRichGoodModel(model: model)
            self.toolView.model = self.viewModel
            self.tableView.reloadData()
        }
    }
    
    private func configUI() {
        var safeBottom: CGFloat = 0
        if #available(iOS 11, *) {
            safeBottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        }
        view.addSubview(toolView)
        toolView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(44 + safeBottom)
        }
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-20)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(toolView.snp.top)
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
        toolView.onCollect = { [weak self] in
            self?.collect()
        }
    }
    
    private func regiestEvent() {
        LoginAndRegisterFacade.shared.obserUserItemChange().take(during: reactive.lifetime).observeValues { [weak self] item in
            guard let `self` = self else { return }
            if item != nil {
                GoodsFacade.shared.detailPopularWearBy(self.id).startWithResult({ [weak self] result in
                    guard let `self` = self else { return }
                    guard let value = result.value else { return }
                    if let model = value.model, let viewModel = self.viewModel {
                        viewModel.isCollect = model.collected
                        viewModel.collectCount = model.collectCount
                        self.toolView.model = viewModel
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
                self.toolView.model = model
                self.tableView.reloadData()
            }
        }
    }
    
    private func collect() {
        if LoginState.shared.hasLogin.value {
            if let model = viewModel, model.isCollect {
                GoodsFacade.shared.unCollect(id: id, type: CollectType.outfit).startWithResult { _ in
                }
            } else {
                GoodsFacade.shared.collect(id: id, type: CollectType.outfit).startWithResult { _ in
                }
            }
            
        } else {
            let controller = LoginViewController()
            let nav = UINavigationController(rootViewController: controller)
            navigationController?.present(nav, animated: true, completion: nil)
        }
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    private let toolView: DetailPopularWearToolView = DetailPopularWearToolView()
    
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

extension DetailPopularWearViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 6.5
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
            return model.height
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailRichGoodCell", for: indexPath) as! DetailRichGoodCell
        if let model = viewModel {
            cell.render(model)
        }
        return cell
    }
}

class DetailPopularWearToolView: UIView {
    
    var onCollect: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hexString: "#ffffff")
        addSubview(button)
        button.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(11)
            make.width.equalTo(72)
            make.height.equalTo(22)
        }
        button.addTarget(self, action: #selector(collect), for: .touchUpInside)
    }
    
    @objc private func collect() {
         onCollect?()
    }
    
    var model: DetailRichGoodModel? {
        didSet {
            if let model = model {
                setButtonStyle(model.isCollect)
            }
        }
    }
    
    private func setButtonStyle(_ collect: Bool) {
        if collect {
            button.setTitle("已关注", for: .normal)
            button.backgroundColor = UIColor(hexString: "#000000")
            button.setTitleColor(UIColor(hexString: "#ffef04"), for: .normal)
        } else {
            button.setTitle("未关注", for: .normal)
            button.backgroundColor = UIColor(hexString: "#ebebeb")
            button.setTitleColor(UIColor(hexString: "#666666"), for: .normal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let button: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 11.0
        button.layer.masksToBounds = true
        button.titleLabel?.font = systemFontSize(fontSize: 12)
        return button
    }()
}
