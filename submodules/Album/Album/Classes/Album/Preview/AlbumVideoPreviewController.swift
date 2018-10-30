//
//  AlbumVideoPreviewController.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 4/13/17.
//  Copyright © 2017 kingxt. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import AVFoundation
import Core

class AlbumVideoPreviewController: UIViewController, AlbumPreviewItem {

    private let asset: MediaAsset
    private let index: Int
    private let (lifetime, token) = Lifetime.make()

    private var avPlayer: AVPlayer?
    private var videoView: VideoLayerView?
    private var playbackDisposable: Disposable?
    private var playFinishedDisposable: Disposable?
    private var latestIsPlaying = false

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var overlayView: LoadingOverlayView = {
        var overlayView = LoadingOverlayView(frame: CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0))
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapLoadingView))
        overlayView.addGestureRecognizer(tapGestureRecognizer)
        overlayView.setRadius(44)
        return overlayView
    }()

    private lazy var videoScrubber: MediaVideoScrubber = {
        let videoScrubber = MediaVideoScrubber(frame: CGRect(origin: CGPoint(x: 0, y: -60), size: CGSize(width: UIScreen.main.bounds.size.width, height: 64)), mediaAsset: self.asset)
        videoScrubber.alpha = 0
        videoScrubber.onLoadCompleted = { [weak self] in
            if let strongSelf = self {
                strongSelf.slideInVideoScrubber()
            }
        }
        return videoScrubber
    }()

    private lazy var playerWrapperView: UIView = {
        UIView()
    }()

    private lazy var playerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()

    init(asset: MediaAsset, location: Int) {
        self.asset = asset
        index = location
        super.init(nibName: nil, bundle: nil)
    }

    @objc func tapLoadingView() {
        guard let player = self.avPlayer else {
            preparePlayerAndPlay(play: true)
            return
        }
        if player.rate <= Float.ulpOfOne {
            doPlayPlayerItem()
        } else {
            doPausePlayerItem()
        }
    }

    override func loadView() {
        super.loadView()
        view.addSubview(playerWrapperView)
        playerWrapperView.addSubview(playerView)
        playerView.addSubview(imageView)

        view.backgroundColor = .black
        view.addSubview(overlayView)
        view.addSubview(videoScrubber)
    }

    fileprivate func actionMediaVideoScrubberChange(_ change: MediaVideoScrubberChange) {
        guard let player = self.avPlayer else {
            preparePlayerAndPlay(play: false)
            return
        }

        if change.state == .began {
            latestIsPlaying = player.rate > 0
            doPausePlayerItem(hiddenScrubber: false)
        }

        if let position = change.position {
            if Int(position * 10) == Int(CMTimeGetSeconds(player.currentTime()) * 10) {
                return
            }

            if player.status == .readyToPlay {
                let position = Int64(position * 100)
                player.seek(to: CMTime(value: position, timescale: 100), completionHandler: { _ in

                })
            }
        }
        if change.state == .ended {
            if latestIsPlaying {
                doPlayPlayerItem()
            } else {
                doPausePlayerItem()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapLoadingView))
        view.addGestureRecognizer(gesture)
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.videoScrubber.loadThumbnails()
            }
        }

        overlayView.setPlay()
        videoScrubber.scrubberStateChanageSignal().take(during: reactive.lifetime).throttle(0.1, on: QueueScheduler.main).observeValues({ [weak self] (change: MediaVideoScrubberChange) in
            if let strongSelf = self {
                strongSelf.actionMediaVideoScrubberChange(change)
            }
        })

        let size = ImageUtils.fitSize(size: asset.dimensions(), maxSize: UIScreen.main.bounds.size)
        let scale = UIScreen.main.scale * 0.8
        let action: () -> Void = { [weak self] in
            if let strongSelf = self {
                strongSelf.imageView.setSignal(strongSelf.asset.imageSignal(imageType: .fastScreen, size: CGSize(width: size.width * scale, height: size.height * scale),
                                                                            allowNetworkAccess: true, applyEditorPresentation: false))
                strongSelf.layoutPlayerView(containerSize: strongSelf.view.bounds.size, adjustments: strongSelf.asset.editorResult?.cropResult)
            }
        }
        action()
        asset.eidtorChangeSignal.take(during: reactive.lifetime).observeValues { _ in
            action()
        }
        videoScrubber.effectRange.producer.take(during: reactive.lifetime).skip(first: 1).startWithValues { [weak self] (range: Range<TimeInterval>) in
            self?.onEffectRangeChange(range: range)
        }
    }

    private func onEffectRangeChange(range: Range<TimeInterval>) {
        if range.lowerBound != 0 || range.upperBound != asset.videoDuration() {
            if asset.editorResult == nil {
                asset.editorResult = MediaEditorResult()
            }
            let start = CMTimeMake(value: Int64(range.lowerBound * 100), timescale: 100)
            let duration = CMTimeMake(value: Int64((range.upperBound - range.lowerBound) * 100), timescale: 100)
            asset.editorResult?.videoTrimResult = CMTimeRangeMake(start: start, duration: duration)
            guard let _ = self.avPlayer else {
                preparePlayerAndPlay(play: false)
                return
            }
            seekToPosition(position: range.lowerBound, completed: nil)
        }
    }

    func layoutPlayerView(containerSize: CGSize, adjustments: MediaCropResult?) {
        var videoFrameSize: CGSize = asset.dimensions()
        var cropRect = CGRect(origin: CGPoint.zero, size: videoFrameSize)
        var orientation: UIImage.Orientation = .up
        var mirrored = false
        if let adjustments = adjustments {
            cropRect = adjustments.cropRect
            orientation = adjustments.cropOrientation
            mirrored = adjustments.mirrored

            let ratio: CGFloat = asset.dimensions().width / adjustments.originalCropRect.width
            cropRect.origin.x = cropRect.origin.x * ratio
            cropRect.origin.y = cropRect.origin.y * ratio
            cropRect.size.width = cropRect.size.width * ratio
            cropRect.size.height = cropRect.size.height * ratio

            videoFrameSize = cropRect.size
        }

        var transform = CGAffineTransform(rotationAngle: rotationForOrientation(orientation))
        if mirrored {
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        }
        playerView.transform = transform

        if orientation == .left || orientation == .right {
            videoFrameSize = CGSize(width: videoFrameSize.height, height: videoFrameSize.width)
        }
        if videoFrameSize.equalTo(CGSize.zero) {
            return
        }

        let fittedSize: CGSize = ImageUtils.scaleToSize(size: videoFrameSize, maxSize: containerSize)
        playerWrapperView.frame = CGRect(x: (containerSize.width - fittedSize.width) / 2, y: (containerSize.height - fittedSize.height) / 2, width: fittedSize.width, height: fittedSize.height)
        playerView.frame = playerWrapperView.bounds

        let videoDimensions = asset.dimensions()
        let ratio: CGFloat = fittedSize.width / videoFrameSize.width
        imageView.frame = CGRect(x: -cropRect.origin.x * ratio, y: -cropRect.origin.y * ratio, width: videoDimensions.width * ratio, height: videoDimensions.height * ratio)
        videoView?.frame = imageView.frame
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let player = self.avPlayer else {
            return
        }
        if player.rate >= Float.ulpOfOne {
            doPausePlayerItem()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        var marginTop: CGFloat = 0
        if #available(iOS 11.0, *) {
            marginTop = UIApplication.shared.keyWindow!.safeAreaInsets.top
        }
        videoScrubber.frame = CGRect(origin: CGPoint(x: 0, y: marginTop), size: CGSize(width: size.width, height: videoScrubber.frame.size.height))
        videoScrubber.loadThumbnails()
        coordinator.animate(alongsideTransition: { _ in
            self.layoutPlayerView(containerSize: size, adjustments: self.asset.editorResult?.cropResult)
        }, completion: nil)
    }

    fileprivate func slideInVideoScrubber() {
        if videoScrubber.frame.origin.y < 0 && asset.videoDuration() > 0 {
            videoScrubber.alpha = 1
            var marginTop: CGFloat = 0
            if #available(iOS 11.0, *) {
                marginTop = UIApplication.shared.keyWindow!.safeAreaInsets.top
            }
            UIView.animate(withDuration: 0.25, animations: {
                self.videoScrubber.frame = CGRect(origin: CGPoint(x: 0, y: marginTop), size: self.videoScrubber.frame.size)
            })
        }
    }

    func preparePlayerAndPlay(play: Bool) {
        asset.playerItemSignal().take(during: lifetime).observe(on: UIScheduler()).startWithValues { [weak self] (result: (AVPlayerItem?, Double?)) in
            if let strongSelf = self {
                strongSelf.onLoadPlayItemAndPlay(play, data: result)
            }
        }
    }

    private func onLoadPlayItemAndPlay(_ play: Bool, data: (AVPlayerItem?, Double?)) {
        if let playItem = data.0 {
            videoScrubber.resetMeta(playItem: playItem)
            slideInVideoScrubber()
            let avPlayer = AVPlayer(playerItem: playItem)
            avPlayer.actionAtItemEnd = .none
            self.avPlayer = avPlayer

            let videoView = VideoLayerView(frame: imageView.bounds, player: avPlayer)
            videoView.playerLayer().videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoView.playerLayer().isOpaque = false
            videoView.playerLayer().backgroundColor = nil
            self.videoView = videoView
            playerView.addSubview(videoView)
            if play {
                doPlayPlayerItem()
            } else {
                overlayView.setPlay()
            }
        } else if let progress = data.1 {
            overlayView.setProgress(CGFloat(progress), cancelEnabled: false, animated: true)
        }
    }

    fileprivate func doPlayPlayerItem() {
        guard let player = self.avPlayer else {
            return
        }
        if !imageView.isHidden {
            delay(0.2) {
                self.imageView.isHidden = true
            }
        }
        seekToPosition(position: videoScrubber.currentPlayPosition) { () in
            player.play()
            self.playFinishedDisposable?.dispose()
            self.playbackDisposable?.dispose()
            self.videoScrubber.scrubberHandle.isHidden = false
            self.overlayView.setNone()
            self.playbackDisposable = player.reactive.periodicTimeObserver(interval: CMTime(value: 10, timescale: 50)).take(during: player.reactive.lifetime).map({ (time: CMTime) -> TimeInterval in
                CMTimeGetSeconds(time)
            }).startWithValues({ [weak self] (timeInterval: TimeInterval) in
                if let strongSelf = self {
                    if !strongSelf.videoScrubber.playCanReachToTime(timeInterval) {
                        strongSelf.doPausePlayerItem()
                        strongSelf.videoScrubber.resetToTrimStartValue()
                        strongSelf.seekToPosition(position: strongSelf.videoScrubber.currentPlayPosition, completed: nil)
                    } else {
                        strongSelf.videoScrubber.updatePlayProgress(currentTime: timeInterval, animated: true)
                    }
                }
            })
            self.playFinishedDisposable = player.reactive.playFinishedObserver().take(during: self.reactive.lifetime).startWithValues({ [weak self] _ in
                if let strongSelf = self {
                    strongSelf.doPausePlayerItem()
                    strongSelf.videoScrubber.resetToTrimStartValue()
                    strongSelf.seekToPosition(position: strongSelf.videoScrubber.currentPlayPosition, completed: nil)
                }
            })
        }
    }

    private func seekToPosition(position: Double, completed: (() -> Void)?) {
        guard let player = self.avPlayer else {
            return
        }
        let seekToPosition = max(position, 0)
        if CMTimeGetSeconds(player.currentTime()) == seekToPosition {
            completed?()
        } else {
            player.seek(to: CMTime(value: Int64(seekToPosition * 100), timescale: 100), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: { _ in
                completed?()
            })
        }
    }

    deinit {
        playbackDisposable?.dispose()
        playFinishedDisposable?.dispose()
    }

    fileprivate func doPausePlayerItem(hiddenScrubber: Bool = true) {
        playbackDisposable?.dispose()
        playFinishedDisposable?.dispose()
        avPlayer?.pause()
        overlayView.setPlay()
        if hiddenScrubber {
            videoScrubber.scrubberHandle.isHidden = true
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        overlayView.center = view.center
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func willTranslatedOut() {
        guard let player = self.avPlayer else {
            return
        }
        if player.rate >= Float.ulpOfOne {
            player.pause()
        }
    }

    func canPanToDismiss() -> Bool {
        return true
    }

    func location() -> Int {
        return index
    }

    func displayAsset() -> MediaAsset {
        return asset
    }

    func animationOutView() -> UIView? {
        return playerWrapperView
    }

    func editorAnimationTargetView() -> UIImageView? {
        return imageView
    }

    func willTranslatedIn() {
        imageView.alpha = 0
        overlayView.alpha = 0
        view.backgroundColor = .clear
        UIView.animate(withDuration: 0.2) {
            self.overlayView.alpha = 1
        }
    }

    func didTranslatedIn() {
        imageView.alpha = 1
        view.backgroundColor = .black
    }
}
