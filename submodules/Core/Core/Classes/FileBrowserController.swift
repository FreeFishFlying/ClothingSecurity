//
//  FileBrowserController.swift
//  Components
//
//  Created by 徐涛 on 09/07/2017.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import UIKit
import QuickLook

private class PreviewItem: NSObject, QLPreviewItem {
    let previewItemURL: URL?
    let previewItemTitle: String?

    init(previewItemURL: URL, previewItemTitle: String) {
        self.previewItemURL = previewItemURL
        self.previewItemTitle = previewItemTitle
    }
}

public class FileBrowserController: QLPreviewController {

    public let fileUrl: URL
    public let fileName: String

    fileprivate var symbolLink: URL?

    public init(fileUrl: URL, fileName: String) {
        self.fileUrl = fileUrl
        self.fileName = fileName
        super.init(nibName: nil, bundle: nil)
        delegate = self
        dataSource = self
    }

    fileprivate lazy var previewItem: PreviewItem = {
        var previewItemURL: URL?

        var symbolLink: URL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(self.fileName)
        try? FileManager.default.removeItem(atPath: symbolLink.path)
        do {
            try FileManager.default.linkItem(at: self.fileUrl, to: symbolLink)
            previewItemURL = symbolLink
            self.symbolLink = symbolLink
        } catch {
            previewItemURL = self.fileUrl
        }
        return PreviewItem(previewItemURL: previewItemURL!, previewItemTitle: self.fileName)
    }()

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: animated)
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.navigationBar.isTranslucent = false
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    public override var shouldAutorotate: Bool {
        return true
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FileBrowserController: QLPreviewControllerDelegate, QLPreviewControllerDataSource {

    public func numberOfPreviewItems(in _: QLPreviewController) -> Int {
        return 1
    }

    public func previewController(_: QLPreviewController, previewItemAt _: Int) -> QLPreviewItem {
        return previewItem
    }

    public func previewControllerDidDismiss(_: QLPreviewController) {
        if fileUrl.absoluteString.contains("/Documents/Inbox/") {
            try? FileManager.default.removeItem(at: fileUrl)
        }
        if let symbolLink = symbolLink {
            try? FileManager.default.removeItem(at: symbolLink)
        }
    }
}
