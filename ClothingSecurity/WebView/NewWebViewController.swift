//
//  NewWebViewController.swift
//  blackboard
//
//  Created by 研发部－LYC on 2018/11/26.
//  Copyright © 2018 xkb. All rights reserved.
//

import UIKit
import WebKit
import Album
import HUD
import Core
import Mesh
import SwiftyJSON

class WebViewToolBar: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColorRGB(0xF5F5F5)
        configUI()
    }

    private var webView: WKWebView?

    private func configUI() {
        addSubview(line)
        line.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(1)
        }
        addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.centerX.equalToSuperview().offset(-60)
            make.width.equalTo(44)
        }
        addSubview(forwardButton)
        forwardButton.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.centerX.equalToSuperview().offset(60)
            make.width.equalTo(44)
        }
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(goForward), for: .touchUpInside)
    }

    @objc private func goBack() {
        if let web = webView, web.canGoBack {
            web.goBack()
        }
    }

    @objc private func goForward() {
        if let web = webView, web.canGoForward {
            web.goForward()
        }
    }

    let line: UIView = {
        let view = UIView()
        view.backgroundColor = UIColorRGB(0xBEBEBE)
        return view
    }()

    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "webview_ic_left"), for: .normal)
        button.setImage(UIImage(named: "webview_ic_left_no"), for: .disabled)
        button.autoHighlight = true
        return button
    }()

    let forwardButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "webview_ic_right"), for: .normal)
        button.setImage(UIImage(named: "webview_ic_right_no"), for: .disabled)
        button.autoHighlight = true
        return button
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configWebView(webView: WKWebView) {
        self.webView = webView
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
    }
}

class NewWebViewController: BaseViewController {

    var url: URL?

    var observes = [NSKeyValueObservation?]()

    let toolBar = WebViewToolBar()

    var lastContentOffset: CGFloat = 0
    var viewHeight: CGFloat = 44
    var shareImageUrl: String?

    @objc var isPresent: Bool = false
    var overlayWindow: OverlayControllerWindow?

    private var isCanShareClassroom = false

    deinit {
        for observe in observes {
            observe?.invalidate()
        }
    }

    @objc init(url: String) {
        self.url = URL(string: url)
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        if isPresent {
            let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            cancelButton.setTitle(localizedString("Common.cancel"), for: .normal)
            cancelButton.reactive.controlEvents(.touchUpInside).observeValues { [weak self] (_) in
                self?.navigationController?.dismiss(animated: true, completion: nil)
                if let window = self?.overlayWindow {
                    window.dismiss()
                }
            }
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        }

        configWebView()
        addObserve()
    }

    func configWebView() {
        view.addSubview(toolBar)
        if #available(iOS 11.0, *) {
            viewHeight += UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        }
        toolBar.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(viewHeight)
            make.bottom.equalTo(viewHeight)
        }

        view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(toolBar.snp.top)
        }
        view.addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(3)
        }
        if let url = url {
            let request = URLRequest(url: url)
            webView.load(request)
        } else {

        }
    }

    private func addObserve() {
        observes.append(webView.observe(\.estimatedProgress, options: .new) { [weak self] (webView, _) in
            guard let `self` = self else { return }
            let progress = webView.estimatedProgress > 0.15 ? webView.estimatedProgress : 0.15
            let completed = progress == 1.0
            self.progressView.setProgress(completed ? 0.0 : Float(progress), animated: !completed)
            UIApplication.shared.isNetworkActivityIndicatorVisible = !completed
        })
        observes.append(webView.observe(\.scrollView.contentOffset, options: .new) { [weak self] (webView, _) in
            guard let `self` = self else { return }
            if webView.scrollView.isDragging {
                self.setToolbarAnimation(webView: webView)
            }
        })
        observes.append(webView.observe(\.title, options: .new, changeHandler: { [weak self] (webView, _) in
            guard let `self` = self else { return }
            self.title = webView.title
            self.changeShareBtnStatus()
        }))

        observes.append(webView.observe(\.canGoBack, options: .new, changeHandler: { [weak self] (webView, _) in
            guard let `self` = self else { return }
            self.toolBar.configWebView(webView: webView)
            self.configToolbarShow(webView: webView)
        }))
        observes.append(webView.observe(\.canGoForward, options: .new, changeHandler: { [weak self] (webView, _) in
            guard let `self` = self else { return }
            self.toolBar.configWebView(webView: webView)
            self.configToolbarShow(webView: webView)
        }))
    }

    private func configToolbarShow(webView: WKWebView) {
        if webView.canGoBack || webView.canGoForward {
            self.toolBar.snp.remakeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(viewHeight)
                make.bottom.equalToSuperview()
            }
        } else {
            self.toolBar.snp.remakeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(viewHeight)
                make.bottom.equalTo(viewHeight)
            }
        }
    }

    private func setToolbarAnimation(webView: WKWebView) {
        let height = webView.scrollView.frame.size.height
        let contentOffsetY = webView.scrollView.contentOffset.y
        let bottomOffset = webView.scrollView.contentSize.height - contentOffsetY
        if contentOffsetY < 0 || bottomOffset <= height {
            return
        }
        if webView.canGoBack || webView.canGoForward {
            if self.lastContentOffset > webView.scrollView.contentOffset.y {
                self.toolBar.snp.updateConstraints({ (make) in
                    make.bottom.equalToSuperview()
                })
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                })
            } else if self.lastContentOffset < webView.scrollView.contentOffset.y {
                self.toolBar.snp.updateConstraints({ (make) in
                    make.bottom.equalTo(self.viewHeight)
                })
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                })
            }
            self.lastContentOffset = webView.scrollView.contentOffset.y
        }
    }

    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        if #available(iOS 9.0, *) {
            webView.allowsLinkPreview = true
        }
        return webView
    }()

    private let progressView: UIProgressView = {
        let view = UIProgressView()
        view.tintColor = UIColorRGB(0x80d22f)
        view.trackTintColor = .clear
        view.progress = 0.15
        return view
    }()

    let shareButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect.init(x: 0, y: 0, width: 44, height: 44)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
        button.setImage(UIImage(named: "btn_title_more"), for: .normal)
        button.isHidden = true
        return button
    }()

    func reloadWebView() {
        webView.reload()
    }


    private func detectorQRCode(sourceImage: UIImage) -> String? {
        let context = CIContext()
        guard let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]) else { return nil }
        guard let sourceImageCI = CIImage(image: sourceImage) else { return nil }
        guard let features = detector.features(in: sourceImageCI) as? [CIQRCodeFeature] else { return nil }
        if let feature = features.first {
            return feature.messageString
        }
        return nil
    }

    private func changeShareBtnStatus() {
        webView.evaluateJavaScript("document.getElementsByName(\"xiaoheiban_disable_share\")[0].content") { [weak self] (response, _) in
            if let divId = response as? String, !divId.isEmpty {
                self?.shareButton.isHidden = true
            } else {
                self?.shareButton.isHidden = false
            }
        }
    }
}

extension NewWebViewController: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        shareButton.isHidden = false
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        shareButton.isHidden = false
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        changeShareBtnStatus()
        //禁止长按
        webView.evaluateJavaScript("document.documentElement.style.webkitTouchCallout='none';", completionHandler: nil)
        webView.evaluateJavaScript("""
            function getImages(){\
            var imgs = document.getElementsByTagName('img');\
            var imgScr = '';\
            for(var i=0;i<imgs.length;i++){\
            if (i == 0){ \
            imgScr = imgs[i].src; \
            } else {\
            imgScr = imgScr +'***'+ imgs[i].src;\
            } \
            };\
            return imgScr;\
            };
        """, completionHandler: nil)
        webView.evaluateJavaScript("getImages()") { [weak self] (response, _) in
            if let result = response as? String {
                let array = result.components(separatedBy: "***")
                if let shareImage = array.first {
                    self?.shareImageUrl = shareImage
                }
            }
        }
    }

    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: localizedString("Common.alert.tip"), message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: localizedString("Common.confirm"), style: .default) { (_) in
            completionHandler()
        }
        alertController.addAction(action)
        alertController.popoverPresentationController?.sourceView = webView
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }

    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: localizedString("Common.alert.tip"), message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: localizedString("Common.confirm"), style: .default) { (_) in
            completionHandler(true)
        }
        let cancelAction = UIAlertAction(title: localizedString("Common.cancel"), style: . cancel) { (_) in
            completionHandler(false)
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        alertController.popoverPresentationController?.sourceView = webView
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }

    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String,
                        defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                        completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: prompt, message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        let okAction = UIAlertAction(title: localizedString("Common.confirm"), style: .default) { (_) in
            completionHandler(alertController.textFields?[0].text ?? "")
        }
        alertController.addAction(okAction)
        alertController.popoverPresentationController?.sourceView = webView
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if url.absoluteString.contains("//itunes.apple.com/") {
                UIApplication.shared.openURL(url)
                decisionHandler(.cancel)
                return
            } else if let scheme = url.scheme, !scheme.hasPrefix("http") {
                UIApplication.shared.openURL(url)
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
}
