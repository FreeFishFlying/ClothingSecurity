//
//  RegisterAgreementWebViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/12/10.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import WebKit
class RegisterAgreementWebViewController: BaseViewController, WKNavigationDelegate {
    
    let url: URL
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fd_prefersNavigationBarHidden = true
        fd_interactivePopDisabled = true
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
        configHeaderView()
        configWeb()
        webView.load(URLRequest(url: url))
        webView.navigationDelegate = self
        
    }
    
    private func configHeaderView() {
        headerView.onBackButtonClick = { [weak self] in
            guard let `self` = self else { return }
            self.back()
        }
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(64)
        }
    }
    
    private func configWeb() {
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        headerView.titleLabel.text = webView.title
    }
    
    func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    let headerView: HeaderView = HeaderView()
    
    private let webView: WKWebView = WKWebView()
}
