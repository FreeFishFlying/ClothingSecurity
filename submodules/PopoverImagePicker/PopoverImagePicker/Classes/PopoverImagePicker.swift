//
//  PopoverImagePicker.swift
//  Pods
//
//  Created by kingxt on 8/25/17.
//
//

import Foundation
import UIKit
import AlertController
import Album
import Core
import ReactiveSwift

public class PopoverImagePicker {
    
    public static func choosePhoto(assetType: MediaAssetType = .photo,
                                   actionSheetActions: [AlertAction]? = nil,
                                   onlyCrop: Bool? = nil,
                                   confirmTitle: String? = nil,
                                   lockAspectRatio: CGFloat? = nil,
                                   navigationControllerClass: UINavigationController.Type = UINavigationController.self,
                                   completionHandler: @escaping (UIImage?) -> (Void)
                                   ) {
        let confirmTitle: String = confirmTitle == nil ? SLLocalized("CarouseAttachment.Confirm") : confirmTitle!
        let alert = AlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let window = OverlayControllerWindow(frame: UIScreen.main.bounds)
        let customHeight: CGFloat = 120
        let style: MediaAssetsPickerController.Style = onlyCrop ?? false ? [.single, .editEnabled, .onlyCrop] : [.single, .editEnabled] 
        let carouseView = AttachmentCarouseView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: customHeight), style: style, confirmTitle: SLLocalized("CarouseAttachment.Confirm"), assetType: assetType, lockAspectRatio: lockAspectRatio)
        alert.contentView.backgroundColor = .white
        alert.contentView.addSubview(carouseView)
        alert.visualStyle.contentPadding = UIEdgeInsets.zero
        alert.visualStyle.backgroundColor = .white
        carouseView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(customHeight)
        }
        carouseView.didClickSendSignal.observeValues { (assets, original) in
            if assets.count > 0 {
                retreiveImage(media: assets.first!, completionHandler: completionHandler)
            } else {
                completionHandler(nil)
            }
            window.rootViewController?.dismiss(animated: true, completion: { () in
                window.dismiss()
            })
        }
        carouseView.cameraPickAssetSignal.observeValues { asset in
            retreiveImage(media: asset, completionHandler: completionHandler)
            window.rootViewController?.dismiss(animated: true, completion: { () in
                window.dismiss()
            })
        }
        alert.add(AlertAction(title: SLLocalized("MediaAssetsPicker.Cancel"), style: .preferred, handler: nil))
        
        if let actions = actionSheetActions {
            for action in actions {
                alert.add(action)
            }
        }
        alert.add(AlertAction(title: SLLocalized("MediaAssetsPicker.FromAlbum"), style: .normal, handler: { (_) in
            chooseFromAlbum(confirmTitle: confirmTitle, lockAspectRatio: lockAspectRatio, completionHandler: completionHandler, navigationControllerClass: navigationControllerClass)
        }))
        window.present(controller: alert, animated: true)
    }
    
    static func chooseFromAlbum(confirmTitle: String, lockAspectRatio: CGFloat?, completionHandler: @escaping (UIImage?) -> (Void), navigationControllerClass: UINavigationController.Type) {
        let window = OverlayControllerWindow(frame: UIScreen.main.bounds)
        window.aboveStatusBar = false
        let albumConfig = AlbumConfig(style: [.single, .editEnabled], confirmTitle: confirmTitle, assetType: .photo, lockAspectRatio: lockAspectRatio,
                                 confirmCallback: { assets, original in
                                    if assets.count > 0 {
                                        retreiveImage(media: assets.first!, completionHandler: completionHandler)
                                    } else {
                                        completionHandler(nil)
                                    }
                                    window.rootViewController?.dismiss(animated: true, completion: { () in
                                        window.dismiss()
                                    })
                        
            }, cancelCallback: { () in
                window.rootViewController?.dismiss(animated: true, completion: { () in
                    window.dismiss()
                })
        })
        let navigationController: UINavigationController = navigationControllerClass.init()
        navigationController.viewControllers = [AlbumFolderViewController(config: albumConfig)]
        window.present(controller: navigationController, animated: true)
    }
    
    private static func retreiveImage(media: MediaSelectableItem, completionHandler: @escaping (UIImage?) -> (Void)) {
        if let asset = media as? MediaAsset {
            if let image = asset.editorResult?.editorImage {
                completionHandler(image)
            } else {
                asset.imageSignal(imageType: .screen, size: asset.dimensions(), allowNetworkAccess: true).observe(on: UIScheduler()).startWithResult({ (result) in
                    if let data = result.value, let image = data.0 {
                        if data.1 == nil {
                            completionHandler(image)
                        }
                    }
                })
            }
        }
        if let asset = media as? MediaConcreteItem {
            if let image = asset.image {
                completionHandler(image)
            }
        }
    }

}
