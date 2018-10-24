//
//  Entrance.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/10.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Core
import ESTabBarController
class Entrance: NSObject {
    @objc class func entrance() -> ESTabBarController{
        let contentController = MainContentViewController()
        contentController.tabBarItem = ESTabBarItem(title: "主页", image: imageNamed("ic_firstPage"), selectedImage: imageNamed("ic_firstPage_select"))
        styleTabbar(contentController.tabBarItem)
        let contentNav = ThemeNavigationController(rootViewController: contentController)
        let discoverController = DiscoverViewController()
        discoverController.tabBarItem = ESTabBarItem(title: "发现", image: imageNamed("ic_discover"), selectedImage: imageNamed("ic_discover_select"))
        styleTabbar(discoverController.tabBarItem)
        let discoverNav = ThemeNavigationController(rootViewController: discoverController)
        let clothController = ClothingSecurityViewController()
        clothController.tabBarItem = ESTabBarItem(title: "防伪检测", image: imageNamed("ic_security"), selectedImage: imageNamed("ic_security_select"))
        styleTabbar(clothController.tabBarItem)
        let clothNav = ThemeNavigationController(rootViewController: clothController)
        let personalController = PersonalCenterViewController()
        personalController.tabBarItem = ESTabBarItem(title: "我", image: imageNamed("ic_personal"), selectedImage: imageNamed("ic_personal_select"))
        styleTabbar(personalController.tabBarItem)
        let personNav = ThemeNavigationController(rootViewController: personalController)
        let tabBarController = ESTabBarController()
        tabBarController.view.backgroundColor = UIColor(hexString: "#2B2B2B")
        tabBarController.tabBar.backgroundImage = imageNamed("bg_bottom")
        tabBarController.selectedIndex = 0
        tabBarController.viewControllers = [contentNav, discoverNav, clothNav, personNav]
        return tabBarController
    }
    
    class func styleTabbar(_ item: UITabBarItem) {
        if item.image != nil {
            item.image = item.image?.withRenderingMode(.alwaysOriginal)
        }
        if item.selectedImage != nil {
            item.selectedImage = item.selectedImage?.withRenderingMode(.alwaysOriginal)
        }
        if let esItem = item as? ESTabBarItem {
            esItem.contentView?.image = esItem.contentView?.image?.withRenderingMode(.alwaysOriginal)
            esItem.contentView?.selectedImage = esItem.contentView?.selectedImage?.withRenderingMode(.alwaysOriginal)
            esItem.contentView?.iconColor = UIColor(hexString: "#A9AAAB")
            esItem.contentView?.highlightIconColor = UIColor.black
            esItem.contentView?.textColor = UIColor(hexString: "#A9AAAB")
            esItem.contentView?.titleLabel.font = systemFontSize(fontSize: 10)
            esItem.contentView?.highlightTextColor = UIColor.black
            esItem.badgeColor = UIColor(hexString: "#FF6688")

        }
        item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hexString: "#A9AAAB")], for: .normal)
        item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
    }
    
    class func styleNavgationBar() {
        UINavigationBar.appearance().barTintColor = UIColor(hexString: "#FEFFFF")
        UINavigationBar.appearance().barStyle = UIBarStyle.black
        UINavigationBar.appearance().shadowImage = UIImage()
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
    }
}
