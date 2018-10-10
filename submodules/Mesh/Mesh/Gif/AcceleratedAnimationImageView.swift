//
//  AcceleratedAnimationImageView.swift
//  Mesh
//
//  Created by kingxt on 7/27/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import UIKit

public class AcceleratedAnimationImageView: UIImageView {
    
    private lazy var videoView: AcceleratedVideoView = AcceleratedVideoView()
    
    private var path: String?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(videoView)
        videoView.frame = bounds
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open var image: Image? {
        didSet {
            videoView.path = nil
            path = nil
        }
    }
    
    public override var contentMode: UIView.ContentMode {
        didSet {
            videoView.contentMode = contentMode
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        videoView.frame = self.bounds
    }
    
    public override var frame: CGRect {
        didSet {
            videoView.frame = bounds
        }
    }
    
    @discardableResult
    public func setGifImage(with resource: URL?,
                         placeholder: Image? = nil,
                         options: KingfisherOptionsInfo? = nil,
                         progressBlock: DownloadProgressBlock? = nil,
                         completionHandler: CompletionHandler? = nil) -> RetrieveImageTask?
    {
        guard let resource = resource else {
            return nil
        }
        let path = ImageCache.default.cachePath(forKey: resource.absoluteString) + ".mp4"
        if path == self.path {
            return nil
        }
        var options = options
        if options != nil {
            options!.append(.acceleratedGifPlay(true))
        } else {
            options = [.acceleratedGifPlay(true)]
        }
        return self.kf.setImage(with: resource, placeholder: placeholder, options: options, progressBlock: progressBlock) { [weak self] (image, error, cacheType, url) in
            completionHandler?(image, error, cacheType, url)
            self?.play(path: path, data: image?.kf.gifRepresentation())
        }
    }
    
    
    /// Convert gif to mp4 and play
    ///
    /// - Parameters:
    ///   - path: the mp4 presentation of gif path
    ///   - data: the gif data
    public func play(path: String, data: Data?) {
        if path == self.path {
            return
        }
        self.path = path
        videoView.prepareForRecycle()
        if FileManager.default.fileExists(atPath: path) {
            videoView.path = path
        } else if let data = data {
            if let converter = GIF2MP4(data: data) {
                let dest = URL(fileURLWithPath: path)
                converter.convertAndExport(to: dest, completion: { [weak self] (finished) in
                    if finished && FileManager.default.fileExists(atPath: dest.path) {
                        self?.videoView.path = dest.path
                    }
                })
            }
        }
    }
    
    
    /// Prepare recycle for resuse
    public func prepareForRecycle() {
        self.path = nil
        videoView.prepareForRecycle()
    }
}
