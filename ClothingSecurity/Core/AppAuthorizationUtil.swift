//
//  AppAuthorizationUtil.swift
//  Love
//
//  Created by Dylan Wang on 30/07/2017.
//  Copyright © 2017 liao. All rights reserved.
//

import AlertController
import AVFoundation
import Core
import CoreTelephony
import HUD
import Photos
import ReactiveSwift
import Result
import UIKit
import UserNotifications

public enum Authorization: Int {
    case network
    case unkonw
}

class AuthorizationAlertView: UIView {
    let authorization: Authorization
    var bgView: UIView

    public init(type: Authorization) {
        authorization = type
        bgView = UIView()
        super.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
        backgroundColor = UIColorRGBA(0x000000, 0.7)

        configUI(type: type)

        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(hiddenSelf))
        addGestureRecognizer(dismissTap)

        let bgTap = UITapGestureRecognizer(target: self, action: #selector(doNothing))
        bgView.addGestureRecognizer(bgTap)
    }

    func configUI(type: Authorization) {
        let titleLabel = UILabel()
        titleLabel.text = "“BEEDEE”无线数据未开启"
        titleLabel.font = UIFont(name: "PingFangSC-Medium", size: 17)
        bgView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        var imageName: String = ""
        switch type {
        case .network:
            imageName = "authorizatioForNetwork"
        default:
            break
        }
        let imageView = UIImageView()
        imageView.image = UIImage(named: imageName)
        bgView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.right.equalToSuperview()
        }

        let button = UIButton()
        button.setTitle("马上开启", for: .normal)
        button.backgroundColor = UIColor.black
        button.addTarget(self, action: #selector(toAppSystemSetting), for: .touchUpInside)
        bgView.addSubview(button)
        button.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(48)
            make.bottom.equalToSuperview()
        }

        bgView.backgroundColor = .white
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 12
        bgView.alpha = 0.0
        addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    func show() {
        HUD.hide()
        let window = UIApplication.shared.keyWindow
        if let subviews = window?.subviews {
            for subview in subviews {
                if subview.isKind(of: AuthorizationAlertView.self) {
                    subview.removeFromSuperview()
                }
            }
        }
        window?.endEditing(true)
        window?.addSubview(self)

        UIView.animate(withDuration: 0.2) {
            self.bgView.alpha = 1.0
        }
    }

    @objc private func toAppSystemSetting() {
        hiddenSelf()
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }

    @objc private func hiddenSelf() {
        removeFromSuperview()
    }

    @objc private func doNothing() {
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AppAuthorizationUtil {
    public static func checkNetwork(authorized: ((Bool) -> Void)? = nil) {
        if #available(iOS 9.0, *) {
            let cellularData = CTCellularData()
            cellularData.cellularDataRestrictionDidUpdateNotifier = { (_ state: CTCellularDataRestrictedState) -> Void in
                switch state {
                case .notRestricted:
                    authorized?(true)
                default:
                    authorized?(false)
                    DispatchQueue.main.async {
                        let alert = AuthorizationAlertView(type: .network)
                        alert.show()
                    }
                }
            }
        } else {
            authorized?(true)
        }
    }

    public static func checkRecord(_ authorized: @escaping (() -> Void), denied: (() -> Void)? = nil) {
        let permission = AVAudioSession.sharedInstance()
        permission.requestRecordPermission { (result) in
            DispatchQueue.main.async {
                if result {
                    authorized()
                } else {
                    if let denied = denied {
                        denied()
                    } else {
                        showAlert(title: "BEEDEE需要访问您的麦克风", content: "请在设置->隐私->麦克风中允许BEEDEE的访问权限")
                    }
                }
            }
        }
    }

    public static func checkCamera(_ authorized: (() -> Void), denied: (() -> Void)? = nil) {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if status == AVAuthorizationStatus.denied {
            if let denied = denied {
                denied()
            } else {
                showAlert(title: "BEEDEE需要访问您的相机，从而可以拍照", content: "请在设置->隐私->相机中允许NBEEDEE的访问权限")
            }
        } else {
            authorized()
        }
    }

    public static func checkPhoto(_ authorized: (() -> Void), denied: (() -> Void)? = nil) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == PHAuthorizationStatus.denied {
            if let denied = denied {
                denied()
            } else {
                showAlert(title: "BEEDEE需要访问您的相册", content: "请在设置->隐私->照片中允许BEEDEE的访问权限")
            }
        } else {
            authorized()
        }
    }

    public static func checkNotificationEnabled() -> SignalProducer<Bool, NoError> {
        return SignalProducer<Bool, NoError> { observer, _ in
            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
                    if settings.authorizationStatus == UNAuthorizationStatus.authorized {
                        observer.send(value: true)
                    } else if settings.authorizationStatus == UNAuthorizationStatus.denied {
                        observer.send(value: false)
                    }
                    observer.sendCompleted()
                })
            } else {
                if let notificationSettings = UIApplication.shared.currentUserNotificationSettings {
                    if notificationSettings.types == [] {
                        observer.send(value: false)
                    } else {
                        observer.send(value: true)
                    }
                }
                observer.sendCompleted()
            }
        }
    }

    public static func showAlert(title: String?, content: String) {
        let alert = AlertController(title: title, message: content)
        alert.add(title: localizedString("cancel"))
        alert.add(title: "马上设置", style: .preferred) { () -> Void in
            jumpToAppSystemSettings()
        }
        alert.present()
    }

    public static func jumpToAppSystemSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
}
