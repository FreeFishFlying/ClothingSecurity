//
//  AppDelegate.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/9.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import UIKit
import FDFullscreenPopGesture
//import S2iCodeModule
import HUD

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate, TencentSessionDelegate, WeiboSDKDelegate {
    
    enum ThirdLogin: String {
        case WX = "wx427a43532ca341f2"
        case Tencent = "1107909602"
        case WB = "2096526831"
    }
    
    var window: UIWindow?
    
    var tencentAuth: TencentOAuth!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Entrance.styleNavgationBar()
        window?.rootViewController = Entrance.entrance()
        applyStyle()
        updateAuthInfo()
        regiesterOtherLink()
        //S2iCodeModule.shared()?.initS2iCodeModule()
        return true
    }
    
//    func applicationDidEnterBackground(_ application: UIApplication) {
//        S2iCodeModule.shared()?.applicationDidEnterBackground(application)
//    }
//    
//    func applicationWillEnterForeground(_ application: UIApplication) {
//        S2iCodeModule.shared()?.applicationWillEnterForeground(application)
//    }
    
    private func login(code: String, type: ThirdType) {
        HUD.show(.progress)
        ThirdloginFacade.shared.login(code: code, type: type).startWithResult { result in
            HUD.hide()
        }
    }
    
    private func updateAuthInfo() {
        if UserItem.current() != nil {
            LoginState.shared.hasLogin.value = true
            PersonCenterFacade.shared.updateAuthInfo()
        } else {
            LoginState.shared.hasLogin.value = false
        }
    }
    
    private func regiesterOtherLink() {
        WXApi.registerApp(ThirdLogin.WX.rawValue)
        tencentAuth = TencentOAuth(appId: ThirdLogin.Tencent.rawValue, andDelegate: self)
        WeiboSDK.registerApp(ThirdLogin.WB.rawValue)
        WeiboSDK.enableDebugMode(true)
    }
    
    func onResp(_ resp: BaseResp!) {
        if resp.isKind(of: SendAuthResp.self) {
            if let authResp = resp as? SendAuthResp {
                if let code = ThirdloginFacade.shared.scopeCode(resp: authResp) {
                    login(code: code, type: .wx)
                }
            }
        }
    }
    
    func tencentDidLogin() {
        if let token = tencentAuth.accessToken {
            login(code: token, type: .qq)
        } else {
            HUD.flashError(title: "授权失败")
        }
    }
    
    func tencentDidNotLogin(_ cancelled: Bool) {
        HUD.flashError(title: "登录失败")
    }
    
    func tencentDidNotNetWork() {
        HUD.flashError(title: "当前无网络")
    }
    
    func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
    }
    
    func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
        guard let res = response as? WBAuthorizeResponse else { return }
        guard let accessToken = res.accessToken else { return }
        login(code: accessToken, type: .wb)
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        if url.scheme == ThirdLogin.WX.rawValue {
            return WXApi.handleOpen(url, delegate: self)
        } else if url.scheme == ("tencent" + ThirdLogin.Tencent.rawValue) {
            return TencentOAuth.handleOpen(url)
        } else if url.scheme == ("wb" + ThirdLogin.WB.rawValue) {
            return WeiboSDK.handleOpen(url, delegate: self)
        }
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.scheme == ThirdLogin.WX.rawValue {
           return WXApi.handleOpen(url, delegate: self)
        } else if url.scheme == ("tencent" + ThirdLogin.Tencent.rawValue) {
            return TencentOAuth.handleOpen(url)
        } else if url.scheme == ("wb" + ThirdLogin.WB.rawValue) {
            return WeiboSDK.handleOpen(url, delegate: self)
        }
        return true
    }
    
     func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == ThirdLogin.WX.rawValue {
            return WXApi.handleOpen(url, delegate: self)
        }
        if let urlKey: String = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String {
            if urlKey == "com.tencent.mqq" {
                return TencentOAuth.handleOpen(url)
            } else if urlKey == "com.sina.weibo" {
                return WeiboSDK.handleOpen(url, delegate: self)
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

