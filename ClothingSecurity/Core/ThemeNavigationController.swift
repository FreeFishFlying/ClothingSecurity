//
//  ThemeNavigationController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/10.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Core
import Foundation

func currentNavigationController() -> UINavigationController? {
    if let window = UIApplication.shared.keyWindow {
        if let controller = window.rootViewController as? UINavigationController {
            return controller
        }
        if let tabController = window.rootViewController as? UITabBarController {
            if let controller = tabController.selectedViewController as? UINavigationController {
                return controller
            }
        }
    }
    return nil
}

extension UIViewController {
    private static var AssociatedBackItem: UInt8 = 0
    
    @objc var autoCreateBackItem: Bool {
        get {
            return objc_getAssociatedObject(self, &UIViewController.AssociatedBackItem) as? Bool ?? true
        }
        set {
            objc_setAssociatedObject(self, &UIViewController.AssociatedBackItem, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

class ThemeNavigationController: UINavigationController, UINavigationControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = true
        navigationBar.tintColor = UIColor.black
        delegate = self
    }
    
    @objc var defaultBackItem: UIBarButtonItem {
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 55, height: 44))
        let editButton = UIButton()
        editButton.frame = CGRect(x: 0, y: 0, width: 55, height: 44)
        editButton.setImage(imageNamed("ic_app_back_nor")?.withRenderingMode(.alwaysOriginal) ?? UIImage(), for: .normal)
        editButton.setTitle("返回", for: .normal)
        editButton.setTitleColor(UIColor.black, for: .normal)
        editButton.titleLabel?.font = systemFontSize(fontSize: 15)
        editButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: -5, bottom: 6, right: 30)
        editButton.titleEdgeInsets = UIEdgeInsets(top: 6, left: -8, bottom: 6, right: 0)
        editButton.addTarget(self, action: #selector(popTopViewController), for: .touchUpInside)
        customView.addSubview(editButton)
        let editItem = UIBarButtonItem(customView: customView)
        
        return editItem // UIBarButtonItem(image: imageNamed("ic_app_back_nor")?.withRenderingMode(.alwaysOriginal) ?? UIImage(), style: .plain, target: self, action: #selector(popTopViewController))
    }
    
    func navigationController(_: UINavigationController, willShow viewController: UIViewController, animated _: Bool) {
        if viewControllers.first != viewController {
            if viewController.autoCreateBackItem {
                viewController.navigationItem.leftBarButtonItem = defaultBackItem
            }
        }
    }
    
    @objc func popTopViewController() {
        popViewController(animated: true)
    }
}
