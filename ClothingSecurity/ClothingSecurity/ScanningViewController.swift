//
//  ScanningViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/11.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import SnapKit
class ScanningViewController: BaseViewController{
    var config = SLQRCodeCompat()
    private let session = AVCaptureSession()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = SLQRcodeHelper.navigationItemTitle(type: config.scannerType)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        let albumItem = UIBarButtonItem.init(whiteTitle: localizedString("album"), target: self, action: #selector(showAlbum))
        albumItem.tintColor = .black
        navigationItem.rightBarButtonItem = albumItem;
        
        view.addSubview(scannerView)
        
        // 校验相机权限
        SLQRcodeHelper.checkCamera { (granted) in
            if granted {
                DispatchQueue.main.async {
                    self.setupScanner()
                }
            }
        }
    }
    
    private func setupScanner() {
        
        guard let device = AVCaptureDevice.default(for: .video) else {
            return
        }
        if let deviceInput = try? AVCaptureDeviceInput(device: device) {
            let metadataOutput = AVCaptureMetadataOutput()
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            
            if config.scannerArea == .def {
                metadataOutput.rectOfInterest = CGRect(x: scannerView.scanner_y/view.frame.size.height, y: scannerView.scanner_x/view.frame.size.width, width: scannerView.scanner_width/view.frame.size.height, height: scannerView.scanner_width/view.frame.size.width)
            }
            
            let videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.setSampleBufferDelegate(self, queue: .main)
            
            session.canSetSessionPreset(.high)
            if session.canAddInput(deviceInput) { session.addInput(deviceInput) }
            if session.canAddOutput(metadataOutput) { session.addOutput(metadataOutput) }
            if session.canAddOutput(videoDataOutput) { session.addOutput(videoDataOutput) }
            
            metadataOutput.metadataObjectTypes = SLQRcodeHelper.metadataObjectTypes(type: config.scannerType)
            
            let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            videoPreviewLayer.videoGravity = .resizeAspectFill
            videoPreviewLayer.frame = view.layer.bounds
            view.layer.insertSublayer(videoPreviewLayer, at: 0)
            
            session.startRunning()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resumeScanning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 关闭并隐藏手电筒
        scannerView.setFlashlight(on: false)
        scannerView.hideFlashlight(animated: true)
    }
    
    @objc func showAlbum() {
        SLQRcodeHelper.checkAlbum { (granted) in
            if granted {
                self.imagePicker()
            }
        }
    }

    // MARK: - 跳转相册
    private func imagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    /// 从后台进入前台
    @objc func appDidBecomeActive() {
        resumeScanning()
    }
    
    /// 从前台进入后台
    @objc func appWillResignActive() {
        pauseScanning()
    }
    
    lazy var scannerView: SLScannerView = {
        let tempScannerView = SLScannerView(frame: view.bounds, config: config)
        return tempScannerView
    }()
}

// MARK: - 扫一扫Api
extension ScanningViewController {
    
    /// 处理扫一扫结果
    ///
    /// - Parameter value: 扫描结果
    func handle(value: String) {
        print("handle === \(value)")
        PersonCenterFacade.shared.commodity(value).startWithResult { [weak self] result in
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            if value.isSuccess() {
                let controller = ScanResultViewController(value)
                self.navigationController?.pushViewController(controller, animated: true)
            } else {
                let controller = ScanNoResultViewController()
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    /// 相册选取图片无法读取数据
    func didReadFromAlbumFailed() {
        print("didReadFromAlbumFailed")
    }
}

// MARK: - 扫描结果处理
extension ScanningViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count > 0 {
            pauseScanning()
            if let metadataObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if let stringValue = metadataObject.stringValue {
                    handle(value: stringValue)
                }
            }
        }
    }
}

// MARK: - 监听光线亮度
extension ScanningViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let metadataDict = CMCopyDictionaryOfAttachments(allocator: nil, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)
        
        if let metadata = metadataDict as? [AnyHashable: Any] {
            if let exifMetadata = metadata[kCGImagePropertyExifDictionary as String] as? [AnyHashable: Any] {
                if let brightness = exifMetadata[kCGImagePropertyExifBrightnessValue as String] as? NSNumber {
                    // 亮度值
                    let brightnessValue = brightness.floatValue
                    if !scannerView.setFlashlightOn() {
                        if brightnessValue < -4.0 {
                            scannerView.showFlashlight(animated: true)
                        }
                        else {
                            scannerView.hideFlashlight(animated: true)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 识别选择图片
extension ScanningViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if !self.handlePickInfo(info) {
                self.didReadFromAlbumFailed()
            }
        }
    }
    
    /// 识别二维码并返回识别结果
    private func handlePickInfo(_ info: [UIImagePickerController.InfoKey : Any]) -> Bool {
        if let pickImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let ciImage = CIImage(cgImage: pickImage.cgImage!)
            let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
            
            if let features = detector?.features(in: ciImage),
                let firstFeature = features.first as? CIQRCodeFeature{
                if let stringValue = firstFeature.messageString {
                    handle(value: stringValue)
                    return true
                }
                return false
            }
        }
        return false
    }
}

// MARK: - 恢复/暂停扫一扫功能
extension ScanningViewController {
    
    /// 恢复扫一扫功能
    private func resumeScanning() {
        session.startRunning()
        scannerView.addScannerLineAnimation()
    }
    
    /// 暂停扫一扫功能
    private func pauseScanning() {
        session.stopRunning()
        scannerView.pauseScannerLineAnimation()
    }
}
