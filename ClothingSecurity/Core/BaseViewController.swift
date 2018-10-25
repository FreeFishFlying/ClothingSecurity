//
//  BaseViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/9.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift

class BaseViewController: UIViewController {
    
    let isAppear: MutableProperty = MutableProperty<Bool>(false)
    let isWillAppear: MutableProperty = MutableProperty<Bool>(false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        automaticallyAdjustsScrollViewInsets = false
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isWillAppear.value = true
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isWillAppear.value = false
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isAppear.value = true
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isAppear.value = false
    }
    
    let imageHeader: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 109, height: 20))
        return view
    }()
    
    let titleHeader: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
        return view
    }()
}
