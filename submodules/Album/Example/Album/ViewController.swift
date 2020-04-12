//
//  ViewController.swift
//  Album
//
//  Created by Dylan Wang on 08/07/2017.
//  Copyright (c) 2017 Dylan Wang. All rights reserved.
//

import UIKit
import Album
import ReactiveCocoa
import ReactiveSwift

class ViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        title = "Test"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        if indexPath.row == 0 {
            cell.textLabel?.text = "Album MultiChoose"
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Album Signal"
        } else if indexPath.row == 2 {
            cell.textLabel?.text = "Lock Aspect Ratio"
        }
        return cell
    }
    
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 3
    }
    
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            MediaAssetsLibrary.default.videoGroup(duration: 300).startWithResult { (group) in
                print(group.value!?.assetCount())
            }

            let style: MediaAssetsPickerController.Style = [MediaAssetsPickerController.Style.editEnabled, .multiChoose, .captureImageOnCameraRoll, .originalImage]
            let albumConfig = AlbumConfig(style: style, confirmTitle: "发送", assetType: .any, confirmCallback: { items, _ in
                for item in items {
                    if let asset = item as? MediaAsset {
                        if asset.isVideo() {
                            if let cropper = asset.editorResult?.cropResult {
                                asset.avAssetSignal(allowNetworkAccess: false).startWithResult({ _ in
                                    
                                    let _ = MediaVideoEditAdjustments(trimStartValue: 0,
                                                                                trimEndValue: asset.videoDuration(),
                                                                                cropRect: cropper.cropRect,
                                                                                originalCropRect: cropper.originalCropRect,
                                                                                cropOrientation: cropper.cropOrientation,
                                                                                mirrored: cropper.mirrored,
                                                                                playRate: asset.editorResult?.playRate ?? .normal)
                                    //                                    self.videoConverter.convert(avAsset: result.value!.0!, adjustments: adjustments).startWithResult({ (result: Result<VideoConverter.ConverterResult, NSError>) in
                                    //
                                    //                                    })
                                    
                                })
                                
                            }
                            break
                        }
                    }
                }
                self.navigationController?.dismiss(animated: true, completion: nil)
            }, cancelCallback: {
                self.navigationController?.dismiss(animated: true, completion: nil)
            })
            //            let albumConfig = AlbumConfig(style: style,
            //                                          confirmTitle: "Send"),
            //                                          confirmCallback: { (items, _) in
            //
            //            },
            //                                          cancelCallback: {
            //                                            self.navigationController?.dismiss(animated: true, completion: nil)
            //            })
            
            navigationController?.present(UINavigationController(rootViewController: AlbumFolderViewController(config: albumConfig)), animated: true, completion: nil)
        } else if indexPath.row == 1 {
            let albumConfig = AlbumConfig(style: [MediaAssetsPickerController.Style.single, MediaAssetsPickerController.Style.editEnabled], confirmTitle: "Cofirm",
                                          confirmCallback: { (_: [MediaSelectableItem], _) in
                                              self.navigationController?.dismiss(animated: true, completion: nil)
                                          },
                                          cancelCallback: {
                                              self.navigationController?.dismiss(animated: true, completion: nil)
                                              
            })
            navigationController?.present(UINavigationController(rootViewController: AlbumFolderViewController(config: albumConfig)), animated: true, completion: nil)
        } else if indexPath.row == 2 {
            let albumConfig = AlbumConfig(style: [MediaAssetsPickerController.Style.single, MediaAssetsPickerController.Style.editEnabled], confirmTitle: "Cofirm",
                                          assetType: .photo,
                                          lockAspectRatio: 1,
                                          confirmCallback: { (_: [MediaSelectableItem], _) in
                                            self.navigationController?.dismiss(animated: true, completion: nil)
            },
                                          cancelCallback: { 
                                            self.navigationController?.dismiss(animated: true, completion: nil)
                                            
            })
            navigationController?.present(UINavigationController(rootViewController: AlbumFolderViewController(config: albumConfig)), animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
