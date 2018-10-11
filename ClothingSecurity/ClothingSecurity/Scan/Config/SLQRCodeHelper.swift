//
//  SLQRCodeHelper.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/11.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import Photos

struct SLQRcodeHelper {
    static func checkCamera(completion: @escaping (_ granted: Bool) -> Void) {
        let videoAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch videoAuthStatus {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted) in
                completion(granted)
            })
        case .denied, .restricted:
            let alter = UIAlertView(title: "请在”设置-隐私-相机”选项中，允许访问你的相机", message: nil, delegate: nil, cancelButtonTitle: "确定")
            alter.show()
            completion(false)
        }
    }
    
    static func checkAlbum(completion: @escaping (_ granted: Bool) -> Void) {
        let photoAuthStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthStatus {
        case .authorized:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                completion(status == .authorized)
            })
        case .denied, .restricted:
            let alter = UIAlertView(title: "请在”设置-隐私-相片”选项中，允许访问你的相册", message: nil, delegate: nil, cancelButtonTitle: "确定")
            alter.show()
            completion(false)
        }
    }
    
    static func metadataObjectTypes(type: SLScannerType) -> [AVMetadataObject.ObjectType] {
        switch type {
        case .qr:
            return [.qr]
        case .bar:
            return [.ean13, .ean8, .upce, .code39, .code39Mod43, .code93, .code128, .pdf417]
        case .both:
            return [.qr, .ean13, .ean8, .upce, .code39, .code39Mod43, .code93, .code128, .pdf417]
        }
    }
    
    static func navigationItemTitle(type: SLScannerType) -> String {
        switch type {
        case .qr:
            return "二维码"
        case .bar:
            return "条码"
        case .both:
            return "二维码/条码"
        }
    }
    
    static func flashLight(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else {
            return
        }
        if device.hasFlash && device.hasTorch {
            try? device.lockForConfiguration()
            device.torchMode = on ? .on:.off
            device.flashMode = on ? .on:.off
            device.unlockForConfiguration()
        }
    }
}
