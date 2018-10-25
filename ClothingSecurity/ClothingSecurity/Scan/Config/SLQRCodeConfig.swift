//
//  SLQRCodeConfig.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/11.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
/// 扫描器类型
///
/// - qr: 仅支持二维码
/// - bar: 仅支持条码
/// - both: 支持二维码以及条码
enum SLScannerType {
    case qr
    case bar
    case both
}

/// 扫描区域
///
/// - def: 扫描框内
/// - fullscreen: 全屏
enum SLScannerArea {
    case def
    case fullscreen
}

struct SLQRCodeCompat {
    /// 扫描器类型 默认支持二维码以及条码
    var scannerType: SLScannerType = .both
    /// 扫描区域
    var scannerArea: SLScannerArea = .def
    
    /// 棱角颜色 默认RGB色值 r:63 g:187 b:54 a:1.0
    var scannerCornerColor: UIColor = UIColor(hexString: "#FFEF04")
    
    /// 边框颜色 默认白色
    var scannerBorderColor: UIColor = .white
    
    /// 指示器风格
    var indicatorViewStyle: UIActivityIndicatorView.Style = .whiteLarge
}
