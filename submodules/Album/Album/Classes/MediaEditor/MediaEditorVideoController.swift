//
//  AdvanceVideoEditorController.swift
//  Components-Swift
//
//  Created by kingxt on 5/23/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import Result
import pop
import AVFoundation
import Core

public class MediaEditorVideoController: UIViewController, MediaEditor {

    private let editorContext: MediaEditorContext
    private let animationContext: AnimationTranslationContext

    private var avPlayer: AVPlayer?
    private var videoView: VideoLayerView?
    private var playRate: MediaVideoSettings.PlayRate = .normal
    private var disposiable: Disposable?

    public init(editorContext: MediaEditorContext, animationContext: AnimationTranslationContext) {
        self.editorContext = editorContext
        self.animationContext = animationContext
        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        disposiable?.dispose()
        NotificationCenter.default.removeObserver(self)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        animationContext.stateChangeSignal().startWithValues { [weak self] state in
            switch state {
            case .willTranslationOut:
                self?.avPlayer?.pause()
            default: break
            }
        }
        preparePlayerAndPlay(play: true)
    }

    public override func loadView() {
        super.loadView()

        view.addSubview(playerView)
        playerView.addSubview(imageView)

        view.addSubview(rateControlView)
        if let thumbnailSignal = editorContext.thumbnailSignal {
            imageView.setSignal(thumbnailSignal)
        }
        layout(size: view.bounds.size)
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        avPlayer?.pause()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        avPlayer?.play()
    }

    public func fillResult(result: MediaEditorResult) {
        result.playRate = playRate
    }

    func preparePlayerAndPlay(play _: Bool) {
        if let playItemSignal = editorContext.videoPlayItemSignal {
            disposiable?.dispose()
            disposiable = playItemSignal.take(first: 1).observe(on: UIScheduler()).startWithResult({ [weak self] (result: Result<AVAsset?, RequestImageDataError>) in
                if let strongSelf = self, let avAsset = result.value {
                    if let asset = avAsset {
                        strongSelf.onLoadAVAssetAndPlay(true, asset: asset)
                    }
                }
            })
        }
    }

    private func onLoadAVAssetAndPlay(_ play: Bool, asset: AVAsset) {
        let composition = AVMutableComposition()

        guard let videoCompositionTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            return
        }
        try? videoCompositionTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration), of: asset.tracks(withMediaType: AVMediaType.video)[0], at: CMTime.zero)

        videoCompositionTrack.scaleTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration), toDuration: CMTimeMultiplyByFloat64(asset.duration, multiplier: Float64(1 / playRate.rawValue)))

        guard let audioCompositionTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            return
        }
        try? audioCompositionTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration), of: asset.tracks(withMediaType: AVMediaType.audio)[0], at: CMTime.zero)

        audioCompositionTrack.scaleTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration), toDuration: CMTimeMultiplyByFloat64(asset.duration, multiplier: Float64(1 / playRate.rawValue)))

        if let assetVideoTrack = asset.tracks(withMediaType: AVMediaType.video).first {
            if let compositionVideoTrack = composition.tracks(withMediaType: AVMediaType.video).first {
                compositionVideoTrack.preferredTransform = assetVideoTrack.preferredTransform
            }
        }

        let playerItem = AVPlayerItem(asset: composition)
        playerItem.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithm.timeDomain
        let avPlayer = AVPlayer(playerItem: playerItem)
        avPlayer.actionAtItemEnd = .none
        self.avPlayer = avPlayer

        let videoView = VideoLayerView(frame: imageView.bounds, player: avPlayer)
        videoView.playerLayer().videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoView.playerLayer().isOpaque = false
        videoView.playerLayer().backgroundColor = nil
        self.videoView = videoView
        playerView.addSubview(videoView)
        enableAudioTracks(true, in: playerItem)
        if play {
            doPlayPlayerItem()
        }
        enableAudioTracks(true, in: playerItem)
    }

    func enableAudioTracks(_ enable: Bool, in playerItem: AVPlayerItem) {
        for track: AVPlayerItemTrack in playerItem.tracks {
            if track.assetTrack?.mediaType == AVMediaType.audio {
                track.isEnabled = enable
            }
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
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(note:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer?.currentItem)
        player.play()
    }

    @objc private func playerDidFinishPlaying(note: NSNotification) {
        if note.object is AVPlayerItem {
            let avItem = note.object as! AVPlayerItem
            if avItem == avPlayer?.currentItem {
                avPlayer?.seek(to: CMTime.zero)
                avPlayer?.play()
            }
        }
    }

    @objc private func changeRate() {
        if avPlayer?.rate ?? 0 > 0 {
            avPlayer?.pause()
            switch rateControlView.selectedSegmentIndex {
            case 0:
                playRate = MediaVideoSettings.PlayRate.verySlow
            case 1:
                playRate = MediaVideoSettings.PlayRate.slow
            case 2:
                playRate = MediaVideoSettings.PlayRate.normal
            case 3:
                playRate = MediaVideoSettings.PlayRate.fast
            case 4:
                playRate = MediaVideoSettings.PlayRate.veryFast
            default:
                playRate = MediaVideoSettings.PlayRate.normal
            }

            preparePlayerAndPlay(play: true)
        }
    }

    private lazy var playerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()

    private lazy var rateControlView: UISegmentedControl = {
        let titles = [SLLocalized("MediaEditor.PlayRateVerySlow"), SLLocalized("MediaEditor.PlayRateSlow"), SLLocalized("MediaEditor.PlayRateNormal"), SLLocalized("MediaEditor.PlayRateFast"), SLLocalized("MediaEditor.PlayRateVeryFast")]
        let control = UISegmentedControl(items: titles)
        control.selectedSegmentIndex = 2
        control.layer.cornerRadius = 8.0
        control.layer.borderColor = UIColorRGBA(0x000000, 0.8).cgColor
        control.layer.borderWidth = 1.0
        control.layer.masksToBounds = true
        control.addTarget(self, action: #selector(changeRate), for: .valueChanged)
        control.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: self.view.tintColor], for: .selected)
        for (index, _) in titles.enumerated() {
            control.setWidth(50, forSegmentAt: index)
        }
        control.tintColor = .black
        return control
    }()

    public func animationTranslationInView() -> UIView {
        return imageView
    }

    public func animationTranslationOutView(isCancelled _: Bool) -> UIView? {
        return imageView
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.layout(size: size)
        }) { _ in
        }
    }

    public func layout(size: CGSize) {
        playerView.frame = view.bounds
        imageView.frame = playerView.bounds
        rateControlView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 250, height: 40))
        rateControlView.center = CGPoint(x: size.width / 2, y: size.height - 90)
        rateControlView.snp.makeConstraints { (make) in
            make.width.equalTo(250)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            if #available(iOS 11, *) {
                make.bottom.equalTo(view.safeAreaInsets.bottom).offset(-40)
            } else {
                make.bottom.equalTo(-40)
            }
        }
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func tabBarImage() -> UIImage? {
        return MediaEditorImageNamed("PhotoEditorTools")
    }

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
}
