//
//  LoginViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/9.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import ZCycleView
import SnapKit

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(cycleView)
        cycleView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(100)
        }
        cycleView.delegate = self
        cycleView.setUrlsGroup(["https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1539085101531&di=0a19331f8c96a95bbdbc071cb0ddfc9b&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F0117e2571b8b246ac72538120dd8a4.jpg%401280w_1l_2o_100sh.jpg","https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1539085131763&di=862da9c89e90f811015dc54384773985&imgtype=0&src=http%3A%2F%2Fpic5.nipic.com%2F20100221%2F2839526_090902782678_2.jpg","https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1539085146970&di=b9863a651171140d7aa6dd4ce72191f6&imgtype=0&src=http%3A%2F%2Fpic75.nipic.com%2Ffile%2F20150819%2F9252150_121944566343_2.jpg","https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1539085167397&di=61df32a193e4a1d47e435febb1cba337&imgtype=0&src=http%3A%2F%2Fpic15.nipic.com%2F20110619%2F7763155_101852942332_2.jpg","https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1539085188029&di=0eda705880563ce4fb7629c05f990e29&imgtype=0&src=http%3A%2F%2Fpic8.nipic.com%2F20100705%2F4711921_083420065579_2.jpg"])
    }
    
    private let cycleView: ZCycleView = {
        let view = ZCycleView(frame: .zero)
        view.placeholderImage = imageNamed("boart")
        return view
    }()
}

extension LoginViewController: ZCycleViewProtocol {
    func cycleViewDidScrollToIndex(_ index: Int) {
    }
    
    func cycleViewDidSelectedIndex(_ index: Int) {
        print("select index = \(index)")
    }
}
