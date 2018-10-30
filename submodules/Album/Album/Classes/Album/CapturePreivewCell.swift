//
//  CaptureVideoCell.swift
//  Album
//
//  Created by kingxt on 2017/12/10.
//

import Foundation
import AVFoundation
import Core

let MediaPickerCapturePreivewCellKind = "MediaPickerCapturePreivewCellKind"

class CapturePreivewCell: UICollectionViewCell {
    
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    var captureDevice: AVCaptureDevice?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        captureSession.sessionPreset = .high
        
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if (device.hasMediaType(.video)) {
                if(device.position == .back) {
                    captureDevice = device
                    break
                }
            }
        }
        backgroundColor = .black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        delay(0.3) {
            self.beginSession()
        }
    }
    
    func beginSession() {
        guard let captureDevice = captureDevice else {
            return
        }
        if captureSession.isRunning {
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
            }
        } catch {
            print("error: \(error.localizedDescription)")
        }
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.masksToBounds = true
        layer.addSublayer(previewLayer)
        previewLayer.frame = layer.bounds
        captureSession.startRunning()
        
        bringSubviewToFront(imageView)
    }
    
    deinit {
        captureSession.stopRunning()
    }
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageNamed("AlbumAdvanceCameraItem")
        return imageView
    }()
}
