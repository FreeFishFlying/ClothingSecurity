//
//  WebViewController.swift
//  Components
//
//  Created by kingxt on 7/26/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation

import UIKit
import WebKit
import SnapKit

private let titleKeyPath = "title"
private let estimatedProgressKeyPath = "estimatedProgress"
private let canGoBack = "canGoBack"

private var hasRemoveCache: Bool = false

/// An instance of `WebViewController` displays interactive web content.
@objc(CoreWebViewController) open class WebViewController: UIViewController {
    
    
    /// global scheme handler
    public static var globalHandler: ((URL) -> Bool)?
    /// gobal right navigation item handler
    public static var globalRightNavigationItemHandler: (image: UIImage, handler: (String) -> Void)?

    // MARK: Properties

    /// Returns the web view for the controller.
    public final var webView: WKWebView {
        return _webView
    }

    /// Returns the progress view for the controller.
    public final var progressBar: UIProgressView {
        return _progressBar
    }

    /// The URL request for the web view. Upon setting this property, the web view immediately begins loading the request.
    public final var urlRequest: URLRequest {
        didSet {
            webView.load(urlRequest)
        }
    }

    /**
     Specifies whether or not to display the web view title as the navigation bar title.
     The default is `false`, which sets the navigation bar title to the URL host name of the URL request.
     */
    public final var displaysWebViewTitle: Bool = true

    @objc public final var displayShareNavigationItem: Bool = true

    public final var addClosedButtonWhenCanGoBack: Bool = true

    // MARK: Private properties

    private final let configuration: WKWebViewConfiguration
    private final let activities: [UIActivity]?
    private final var defaultLeftItem: UIBarButtonItem?

    private final lazy var _webView: WKWebView = { [unowned self] in
        // FIXME: prevent Swift bug, lazy property initialized twice from `init(coder:)`
        // return existing webView if webView already added
        let views = self.view.subviews.filter { $0 is WKWebView } as! [WKWebView]
        if views.count != 0 {
            return views.first!
        }

        let webView = WKWebView(frame: CGRect.zero, configuration: self.configuration)
        self.view.addSubview(webView)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.addObserver(self, forKeyPath: titleKeyPath, options: .new, context: nil)
        webView.addObserver(self, forKeyPath: estimatedProgressKeyPath, options: .new, context: nil)
        webView.addObserver(self, forKeyPath: canGoBack, options: .new, context: nil)
        webView.allowsBackForwardNavigationGestures = true
        if #available(iOS 9.0, *) {
            webView.allowsLinkPreview = true
        }
        return webView
    }()

    private final lazy var _progressBar: UIProgressView = { [unowned self] in
        let progressBar = UIProgressView(progressViewStyle: .bar)
        progressBar.backgroundColor = .clear
        progressBar.trackTintColor = .clear
        self.view.addSubview(progressBar)
        return progressBar
    }()

    // MARK: Initialization

    /**
     Constructs a new `WebViewController`.

     - parameter urlRequest:    The URL request for the web view to load.
     - parameter configuration: The configuration for the web view.
     - parameter activities:    The custom activities to display in the `UIActivityViewController` that is presented when the action button is tapped.

     - returns: A new `WebViewController` instance.
     */
    @objc public init(urlRequest: URLRequest, configuration: WKWebViewConfiguration = WKWebViewConfiguration(), activities: [UIActivity]? = nil) {
        self.configuration = configuration
        self.urlRequest = urlRequest
        self.activities = activities
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }

    /**
     Constructs a new `WebViewController`.

     - parameter url: The URL to display in the web view.

     - returns: A new `WebViewController` instance.
     */
    @objc public convenience init(url: URL) {
        self.init(urlRequest: URLRequest(url: url))
    }

    /// :nodoc:
    public required init?(coder aDecoder: NSCoder) {
        configuration = WKWebViewConfiguration()
        urlRequest = URLRequest(url: URL(string: "http://")!)
        activities = nil
        super.init(coder: aDecoder)
    }

    deinit {
        webView.removeObserver(self, forKeyPath: titleKeyPath, context: nil)
        webView.removeObserver(self, forKeyPath: estimatedProgressKeyPath, context: nil)
        webView.removeObserver(self, forKeyPath: canGoBack, context: nil)
    }

    // MARK: View lifecycle

    /// :nodoc:
    open override func viewDidLoad() {
        super.viewDidLoad()

        if presentingViewController?.presentingViewController != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                               target: self,
                                                               action: #selector(didTapDoneButton(_:)))
        }
        if displayShareNavigationItem {
            if let globalRightNavigationItem = WebViewController.globalRightNavigationItemHandler {
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: globalRightNavigationItem.image, style: .plain, target: self, action: #selector(actionCustomHandler))
            } else {
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                                    target: self,
                                                                    action: #selector(didTapActionButton(_:)))
            }
        }

        webView.load(urlRequest)
    }
    
    @objc private func actionCustomHandler() {
        if let globalRightNavigationItem = WebViewController.globalRightNavigationItemHandler {
            if let urlString = webView.url?.absoluteString {
                globalRightNavigationItem.handler(urlString)
            } else if let urlString = urlRequest.url?.absoluteString {
                globalRightNavigationItem.handler(urlString)
            }
        }
    }

    /// :nodoc:
    open override func viewWillAppear(_ animated: Bool) {
        assert(navigationController != nil, "\(WebViewController.self) must be presented in a \(UINavigationController.self)")
        super.viewWillAppear(animated)
    }

    /// :nodoc:
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if defaultLeftItem == nil {
            defaultLeftItem = navigationItem.leftBarButtonItem
        }
        webView.stopLoading()
    }

    /// :nodoc:
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds

        if #available(iOS 11.0, *) {
            
        } else {
            let insets = UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: 0, right: 0)
            webView.scrollView.contentInset = insets
            webView.scrollView.scrollIndicatorInsets = insets
        }

        view.bringSubviewToFront(progressBar)
        progressBar.frame = CGRect(x: view.frame.minX,
                                   y: topLayoutGuide.length,
                                   width: view.frame.size.width,
                                   height: 2)
    }

    open func refreshBackItems() {
        if defaultLeftItem == nil {
            defaultLeftItem = navigationItem.leftBarButtonItem
            defaultLeftItem?.target = self
            defaultLeftItem?.action = #selector(back)
        }
        if !addClosedButtonWhenCanGoBack {
            let newBackItem = UIBarButtonItem(image: defaultLeftItem?.image, style: .plain, target: self, action: #selector(back))
            navigationItem.leftBarButtonItem = newBackItem
        } else {
            guard let backItem = defaultLeftItem else {
                return
            }
            if webView.canGoBack {
                let newBackItem = UIBarButtonItem(image: defaultLeftItem?.image, style: .plain, target: self, action: #selector(back))
                let item = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(close)) // TODO: localization
                item.setTitlePositionAdjustment(UIOffset(horizontal: -10, vertical: 0), for: .default)
                navigationItem.leftBarButtonItems = [defaultLeftItem ?? newBackItem, item]
            } else {
                navigationItem.leftBarButtonItem = backItem
            }
        }
    }

    @objc func back() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            close()
        }
    }

    @objc open func close() {
        if presentingViewController?.presentingViewController != nil {
            presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    // MARK: Actions

    @objc private func didTapDoneButton(_: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @objc private func didTapActionButton(_ sender: UIBarButtonItem) {
        if let url = urlRequest.url {
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: activities)
            activityVC.popoverPresentationController?.barButtonItem = sender
            present(activityVC, animated: true, completion: nil)
        }
    }

    // MARK: KVO

    /// :nodoc:
    open override func observeValue(forKeyPath keyPath: String?,
                                    of object: Any?,
                                    change: [NSKeyValueChangeKey: Any]?,
                                    context: UnsafeMutableRawPointer?) {
        guard let theKeyPath = keyPath, object as? WKWebView == webView else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        if displaysWebViewTitle && theKeyPath == titleKeyPath {
            title = webView.title
        }

        if theKeyPath == estimatedProgressKeyPath {
            updateProgress()
        }

        if theKeyPath == canGoBack {
            refreshBackItems()
        }
    }

    // MARK: Private

    private final func updateProgress() {
        let completed = webView.estimatedProgress == 1.0
        progressBar.setProgress(completed ? 0.0 : Float(webView.estimatedProgress), animated: !completed)
        UIApplication.shared.isNetworkActivityIndicatorVisible = !completed
    }
    
    fileprivate lazy var reloadButton: UIButton = {
        let button = UIButton()
        button.setTitle("加载失败，点击重新加载", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.view.addSubview(button)
        button.addTarget(self, action: #selector(reload), for: .touchUpInside)
        button.isHidden = true
        button.snp.makeConstraints({ (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(200)
        })
        return button
    }()
    
    @objc func reload() {
        reloadButton.isHidden = true
        if hasRemoveCache {
            webView.load(urlRequest)
        } else {
            if #available(iOS 9.0, *) {
                hasRemoveCache = true
                let websiteDataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
                let dateFrom = Date(timeIntervalSince1970: 0)
                WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: dateFrom, completionHandler: { [weak self] () -> Void in
                    guard let `self` = self else {
                        return
                    }
                    hasRemoveCache = true
                    self.webView.load(self.urlRequest)
                })
            } else {
                webView.load(urlRequest)
            }
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    
    func popupIfNeed(_ url: String?) {
        if (url == urlRequest.url?.absoluteString) {
            navigationController?.popViewController(animated: false)
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let urlString: String = navigationAction.request.url?.absoluteString else {
            return decisionHandler(.cancel)
        }
        if isiTunesURL(urlString) {
            if let url = URL(string: urlString) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            popupIfNeed(navigationAction.request.url?.absoluteString)
            decisionHandler(.cancel)
            return
        }
        
        if navigationAction.targetFrame == nil {
            if let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
            }
        }
        
        if let url = URL(string: urlString), let host = url.host, let handler = WebViewController.globalHandler {
            if handler(url) {
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
    
    private func isMatch(_ pattern: String, forUrl url: String) -> Bool {
        let error: Error? = nil
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        if error != nil {
            return false
        }
        let res: NSTextCheckingResult? = regex?.firstMatch(in: url, options: [], range: NSRange(location: 0, length: url.count))
        return res != nil
    }
    
    private  func isiTunesURL(_ url: String) -> Bool {
        return isMatch("\\/\\/itunes\\.apple\\.com\\/", forUrl: url) || isMatch("\\/\\/appsto\\.re\\/", forUrl: url)
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleFailureLoadUrl()
    }
    
    func handleFailureLoadUrl() {
        reloadButton.isHidden = false
    }
}

extension WebViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: "提示", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "确认", style: .default) { (_) in
            completionHandler()
        }
        alertController.addAction(action)
        alertController.popoverPresentationController?.sourceView = webView
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }

    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "提示", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确认", style: .default) { (_) in
            completionHandler(true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: . cancel) { (_) in
            completionHandler(false)
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        alertController.popoverPresentationController?.sourceView = webView
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }

    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: prompt, message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        let okAction = UIAlertAction(title: "完成", style: .default) { (_) in
            completionHandler(alertController.textFields?[0].text ?? "")
        }
        alertController.addAction(okAction)
        alertController.popoverPresentationController?.sourceView = webView
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
