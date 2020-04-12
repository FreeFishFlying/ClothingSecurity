//
//  AlbumFolderViewController.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 2017/4/4.
//  Copyright © 2017年 kingxt. All rights reserved.
//

import Foundation
import Result
import SnapKit
import ReactiveSwift
import Core

let AlbumFolderCellIdentifier: String = "AlbumFolderCell"

public class AlbumFolderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var mediaAssetsLibrary: MediaAssetsLibrary?
    private var albums: [MediaAssetGroup] = []
    private let selectionContext: MediaSelectionContext
    private let config: AlbumConfig
    private var hasEnterDefaultRoll = false
    private var actionPhotosChange: Bool = true

    public init(config: AlbumConfig) {
        self.config = config
        selectionContext = config.selectionContext ?? MediaSelectionContext()
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = SLLocalized("Album.title")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: SLLocalized("MediaAssetsPicker.Cancel"), style: .plain, target: self, action: #selector(dismissMyself))
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc fileprivate func dismissMyself() {
        config.cancelCallback()
    }

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .clear
        view.delaysContentTouches = true
        view.canCancelContentTouches = true
        view.delegate = self
        view.dataSource = self
        view.separatorStyle = .none
        view.register(AlbumFolderCell.self, forCellReuseIdentifier: AlbumFolderCellIdentifier)
        return view
    }()

    public override func loadView() {
        super.loadView()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }

    public override func viewDidLoad() {
        view.backgroundColor = .white
        mediaAssetsLibrary = MediaAssetsLibrary(assetType: config.assetType)
        mediaAssetsLibrary?.assetGroups().observe(on: UIScheduler()).take(during: self.reactive.lifetime).startWithResult({ [weak self] (result: Result<[MediaAssetGroup], MediaAssetsLibrary.MediaAssetsLibraryError>) in
            if let strongSelf = self, let value = result.value {
                strongSelf.albums = value
                if strongSelf.config.defautEnterCameraAlbum && !strongSelf.hasEnterDefaultRoll {
                    strongSelf.hasEnterDefaultRoll = true
                    for group in value {
                        if group.isCameraRoll() {
                            let mediaAssetsPickerController = MediaAssetsPickerController(assetGroup: group, config: strongSelf.config, selectionContext: strongSelf.selectionContext)
                            strongSelf.navigationController?.pushViewController(mediaAssetsPickerController, animated: false)
                            break
                        }
                    }
                } else {
                    strongSelf.tableView.reloadData()
                    strongSelf.refreshCurrentGroup()
                }
            }
        })
    }
    
    private func refreshCurrentGroup() {
        if !actionPhotosChange {
            return
        }
        actionPhotosChange = false
        delay(2) { [weak self] in
            self?.actionPhotosChange = true
        }
        if let picker = navigationController?.topViewController as? MediaAssetsPickerController {
            for group in albums {
                if group.title() == picker.assetGroup.title() && group.subtype() == picker.assetGroup.subtype() {
                    picker.refresh(group: group)
                    break
                }
            }
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mediaAssetsPickerController = MediaAssetsPickerController(assetGroup: albums[indexPath.row], config: config, selectionContext: selectionContext)
        navigationController?.pushViewController(mediaAssetsPickerController, animated: true)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AlbumFolderCell = tableView.dequeueReusableCell(withIdentifier: AlbumFolderCellIdentifier) as! AlbumFolderCell
        cell.configure(for: albums[indexPath.row])
        return cell
    }

    public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return albums.count
    }

    public func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 86.0
    }
}
