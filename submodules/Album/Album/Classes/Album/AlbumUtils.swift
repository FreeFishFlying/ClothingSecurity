//
//  AlbumUtils.swift
//  Pods
//
//  Created by Dylan Wang on 07/08/2017.
//
//

import UIKit
import ReactiveSwift
import Result
import Core
import AVFoundation

internal func ImageNamed(_ name: String) -> UIImage? {
    var bundle = Bundle(for: AlbumFolderCell.self)
    if let path = bundle.path(forResource: "Album", ofType: "bundle") {
        if let mainBundle = Bundle(path: path) {
            bundle = mainBundle
        }
    }
    return UIImage(named: name, in: bundle, compatibleWith: nil)
}

private var languageBundle: Bundle?

internal func SLLocalized(_ str: String) -> String {
    if languageBundle == nil {
        let frameworkBundle = Bundle(for: AlbumFolderCell.self)
        if let path = frameworkBundle.path(forResource: "Album", ofType: "bundle") {
            guard let resourceBundle = Bundle(path: path) else {
                return str
            }
            var language = Locale.preferredLanguages.first
            if language == "zh-Hans-CN" {
                language = "zh-Hans"
            }
            var path = resourceBundle.path(forResource: language, ofType: "lproj")
            if path == nil {
                path = resourceBundle.path(forResource: "Base", ofType: "lproj")
                languageBundle = Bundle(path: path!)
            }
        }
    }
    return languageBundle?.localizedString(forKey: str, value: nil, table: nil) ?? str
}

public extension UIImageView {

    public func setSignal(_ signal: SignalProducer<(UIImage?, Double?), RequestImageDataError>) {
        let mapSignal = signal.map { (data) -> UIImage? in
            return data.0
        }.mapError { (error) -> AnyError in
            return AnyError(error)
        }
        setSignal(mapSignal)
    }
}

internal class VideoLayerView: UIView {

    init(frame: CGRect, player: AVPlayer) {
        super.init(frame: frame)
        (layer as! AVPlayerLayer).player = player
    }

    func playerLayer() -> AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
