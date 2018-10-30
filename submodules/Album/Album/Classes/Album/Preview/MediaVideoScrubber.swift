//
//  MediaVideoScrubber.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 2017/4/13.
//  Copyright © 2017年 kingxt. All rights reserved.
//

import Foundation
import ReactiveSwift
import SnapKit
import Result
import AVFoundation
import pop

struct MediaVideoScrubberChange {
    let state: UIGestureRecognizer.State
    let position: TimeInterval?
}

let MediaVideoScrubberTummbnailCellKind = "MediaVideoScrubberTummbnailCellKind"
let segementGapToHandler: CGFloat = 12
let videoScrubberMinimumTrimDuration = 3

class MediaVideoScrubberTummbnailCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
}

class MediaVideoScrubber: UIView, UIGestureRecognizerDelegate {

    private let thumbnailHeightLimit: CGFloat = 32
    private let mediaAsset: MediaAsset
    fileprivate var tunmbnailImages: [UIImage] = [UIImage]()
    fileprivate var duration: TimeInterval {
        didSet {
            updateEffectRange()
        }
    }

    private var isDuringPanScrubber: Bool = false
    fileprivate let allowsTrimming: Bool = true

    // used for scrubber video
    public private(set) var effectRange: MutableProperty<Range<TimeInterval>> = MutableProperty(Range(uncheckedBounds: (lower: 0, upper: 0)))
    public private(set) var currentPlayPosition: TimeInterval = 0

    private let stateChangePipe: (output: Signal<MediaVideoScrubberChange, NoError>, input: Signal<MediaVideoScrubberChange, NoError>.Observer) = Signal<MediaVideoScrubberChange, NoError>.pipe()

    public var onLoadCompleted: (() -> Void)?

    init(frame: CGRect, mediaAsset: MediaAsset) {
        self.mediaAsset = mediaAsset
        duration = mediaAsset.videoDuration()
        super.init(frame: frame)
        updateEffectRange()
        loadView()
    }

    func resetMeta(playItem: AVPlayerItem) {
        let duration = CMTimeGetSeconds(playItem.asset.duration)
        if duration != self.duration {
            self.duration = duration
            loadThumbnails()
        }
    }

    private func updateEffectRange() {
        if let videoTrimResult = mediaAsset.editorResult?.videoTrimResult {
            effectRange = MutableProperty(Range(uncheckedBounds: (lower: CMTimeGetSeconds(videoTrimResult.start), upper: CMTimeGetSeconds(videoTrimResult.start) + CMTimeGetSeconds(videoTrimResult.duration))))
        } else {
            effectRange = MutableProperty(Range(uncheckedBounds: (lower: 0, upper: duration)))
        }
    }

    public func resetToTrimStartValue() {
        currentPlayPosition = effectRange.value.lowerBound
        updatePlayProgress(currentTime: currentPlayPosition, animated: false)
    }

    public func playCanReachToTime(_ time: TimeInterval) -> Bool {
        return time <= effectRange.value.upperBound
    }

    public func updatePlayProgress(currentTime: TimeInterval, animated: Bool) {
        currentPlayPosition = currentTime
        scrubberHandle.pop_removeAnimation(forKey: "progress")
        updateTimeLabels(currentPlayPosition: currentTime)
        if !isDuringPanScrubber {
            let fromFrame = scrubberHandle.frame
            let toFrame = CGRect(x: max(trimView.frame.minX + segementGapToHandler, collectionView.frame.size.width * CGFloat(currentTime / duration) + segementGapToHandler), y: fromFrame.origin.y, width: fromFrame.size.width, height: fromFrame.size.height)
            if animated {
                let animation = POPBasicAnimation(propertyNamed: kPOPViewFrame)
                animation?.fromValue = NSValue(cgRect: fromFrame)
                animation?.toValue = NSValue(cgRect: toFrame)
                animation?.duration = 0.2
                animation?.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
                animation?.clampMode = POPAnimationClampFlags.both.rawValue
                animation?.roundingFactor = 0.5
                scrubberHandle.pop_add(animation, forKey: "progress")
            } else {
                scrubberHandle.frame = toFrame
            }
        }
    }

    override var frame: CGRect {
        set {
            super.frame = newValue
            setSubviewsFrame()
        }
        get {
            return super.frame
        }
    }

    fileprivate func setSubviewsFrame() {
        if duration <= 0 {
            return
        }
        collectionView.frame = CGRect(x: 16, y: frame.size.height - thumbnailHeightLimit - 6, width: frame.size.width - 32, height: thumbnailHeightLimit)
        let timeLabelHeight: CGFloat = 15
        currentTimeLabel.frame = CGRect(x: collectionView.frame.minX, y: collectionView.frame.minY - 5 - timeLabelHeight, width: 100, height: timeLabelHeight)
        inverseTimeLabel.frame = CGRect(x: collectionView.frame.maxX - 100, y: collectionView.frame.minY - 5 - timeLabelHeight, width: 100, height: timeLabelHeight)
        wrapperView.frame = collectionView.frame.inset(by: UIEdgeInsets(top: -2, left: -segementGapToHandler, bottom: -2, right: -segementGapToHandler))

        let x = (CGFloat(effectRange.value.lowerBound) * collectionView.frame.size.width) / CGFloat(duration)
        let maxX = (CGFloat(effectRange.value.upperBound) * collectionView.frame.size.width) / CGFloat(duration) + 2 * segementGapToHandler

        trimView.frame = CGRect(x: x, y: 0, width: maxX - x, height: wrapperView.frame.height)
    }

    fileprivate func loadView() {
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(200)
        }
        
        addSubview(self.currentTimeLabel)
        addSubview(self.inverseTimeLabel)
        addSubview(self.collectionView)
        addSubview(self.wrapperView)

        setSubviewsFrame()
        updateTimeLabels()

        wrapperView.addSubview(leftCurtainView)
        wrapperView.addSubview(rightCurtainView)
        wrapperView.addSubview(trimView)

        wrapperView.addSubview(scrubberHandle)

        let pan1: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanWrap))
        addGestureRecognizer(pan1)

        let pan: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        pan.delegate = self
        self.scrubberHandle.addGestureRecognizer(pan)

        layoutIfNeeded()
    }

    public func scrubberStateChanageSignal() -> Signal<MediaVideoScrubberChange, NoError> {
        return self.stateChangePipe.output
    }

    @objc private func didPanWrap() {
        // disable container pan
    }

    @objc private func didPan(gestureRecognizer: UIPanGestureRecognizer) {
        let location = gestureRecognizer.translation(in: self)
        gestureRecognizer.setTranslation(CGPoint.zero, in: self)
        switch gestureRecognizer.state {
        case .began:
            if isDuringPanScrubber {
                return
            }
            isDuringPanScrubber = true
            stateChangePipe.input.send(value: MediaVideoScrubberChange(state: .began, position: nil))
        case .changed:
            let minXPosition: CGFloat = segementGapToHandler
            let maxXPosition = collectionView.frame.size.width + segementGapToHandler
            scrubberHandle.center = CGPoint(x: min(max(scrubberHandle.center.x + location.x, minXPosition), maxXPosition), y: scrubberHandle.center.y)
            let currentTime = seekToPosition(scrubberPosition: scrubberHandle.center)
            currentPlayPosition = currentTime
            stateChangePipe.input.send(value: MediaVideoScrubberChange(state: .changed, position: currentPlayPosition))
        case .cancelled, .ended:
            stateChangePipe.input.send(value: MediaVideoScrubberChange(state: .ended, position: nil))
            isDuringPanScrubber = false
        default: break
        }
    }

    fileprivate func seekToPosition(scrubberPosition: CGPoint) -> TimeInterval {
        let positon = TimeInterval((scrubberPosition.x - scrubberHandle.frame.size.width / 2) / (collectionView.frame.size.width - scrubberHandle.frame.size.width)) * mediaAsset.videoDuration()
        return min(max(0, positon), mediaAsset.videoDuration())
    }

    fileprivate func updateTimeLabels(currentPlayPosition: TimeInterval = 0) {
        currentTimeLabel.text = stringFromSeconds(Int(currentPlayPosition))
        inverseTimeLabel.text = "-\(self.stringFromSeconds(Int(ceil(self.duration) - currentPlayPosition)))"
    }

    public func loadThumbnails() {
        let size = thumbnailImageSize()
        let timestamps = evenlySpacedTimestamps()
        mediaAsset.avAssetSignal(allowNetworkAccess: false).take(during: reactive.lifetime).startWithResult { [weak self] (result: Result<(AVAsset?, Double?), RequestImageDataError>) in
            guard let strongSelf = self else {
                return
            }
            guard let asset: AVAsset = result.value?.0 else {
                return
            }
            strongSelf.mediaAsset.videoThumbnailsSignal(avAsset: asset, size: CGSize(width: size.width * 2, height: size.height * 2), timestamps: timestamps).take(during: strongSelf.reactive.lifetime).observe(on: UIScheduler()).startWithValues({ [weak strongSelf] (images: [UIImage]) in
                guard let sself = strongSelf else {
                    return
                }
                sself.reloadImages(image: images)
                sself.onLoadCompleted?()
            })
        }
    }

    fileprivate func reloadImages(image: [UIImage]) {
        tunmbnailImages = image
        collectionView.reloadData()
    }

    fileprivate func thumbnailImageSize() -> CGSize {
        let size = mediaAsset.dimensions()
        var aspectRatio: CGFloat = 1
        if size != CGSize.zero {
            aspectRatio = size.width / size.height
        }
        return CGSize(width: ceil(thumbnailHeightLimit * aspectRatio), height: thumbnailHeightLimit)
    }

    fileprivate func evenlySpacedTimestamps() -> [TimeInterval] {
        let count = tummbnailCount()
        let interval = mediaAsset.videoDuration() / Double(count)
        var timestamps = [TimeInterval]()
        for i in 0 ..< count {
            timestamps.append(Double(i) * interval)
        }
        return timestamps
    }

    fileprivate func tummbnailCount() -> Int {
        return Int(ceil(collectionView.frame.size.width / thumbnailImageSize().width))
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate lazy var collectionLayout: UICollectionViewFlowLayout = {
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.minimumLineSpacing = 0
        collectionLayout.scrollDirection = .horizontal
        collectionLayout.itemSize = self.thumbnailImageSize()
        collectionLayout.sectionInset = UIEdgeInsets.zero
        collectionLayout.minimumInteritemSpacing = 0
        return collectionLayout
    }()

    fileprivate lazy var collectionView: UICollectionView = {
        let collectionView: UICollectionView = UICollectionView(frame: self.frame, collectionViewLayout: self.collectionLayout)
        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.isScrollEnabled = false
        collectionView.delaysContentTouches = true
        collectionView.canCancelContentTouches = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MediaVideoScrubberTummbnailCell.self, forCellWithReuseIdentifier: MediaVideoScrubberTummbnailCellKind)
        return collectionView
    }()

    fileprivate lazy var currentTimeLabel: UILabel = {
        let currentTimeLabel = UILabel()
        currentTimeLabel.textColor = .white
        currentTimeLabel.font = UIFont.systemFont(ofSize: 12)
        currentTimeLabel.text = "0:00"
        return currentTimeLabel
    }()

    fileprivate lazy var inverseTimeLabel: UILabel = {
        let inverseTimeLabel = UILabel()
        inverseTimeLabel.textColor = .white
        inverseTimeLabel.font = UIFont.systemFont(ofSize: 12)
        inverseTimeLabel.textAlignment = .right
        inverseTimeLabel.text = "-0:00"
        return inverseTimeLabel
    }()

    fileprivate func stringFromSeconds(_ totalSeconds: Int) -> String {
        let hours = Int(totalSeconds) / 3600
        let minutes = Int(totalSeconds / 60) % 60
        let seconds = Int(totalSeconds % 60)
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", Int(hours), Int(minutes), Int(seconds))
        } else {
            return String(format: "%0d:%02d", Int(minutes), Int(seconds))
        }
    }

    public private(set) lazy var scrubberHandle: UIControl = {
        let scrubberHandle = UIControl(frame: CGRect(x: segementGapToHandler, y: -1, width: 8, height: 39))
        scrubberHandle.isHidden = true
        scrubberHandle.hitTestEdgeInsets = UIEdgeInsets(top: -5, left: -10, bottom: -5, right: -10)
        let imageView = UIImageView(frame: scrubberHandle.bounds)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: CGFloat(scrubberHandle.frame.size.width), height: CGFloat(scrubberHandle.frame.size.height)), false, 0.0)
        var context: CGContext? = UIGraphicsGetCurrentContext()
        context?.setShadow(offset: CGSize(width: 0, height: 1.5), blur: 0.5, color: UIColor(white: 0, alpha: 0.35).cgColor)
        context?.setFillColor(UIColor.white.cgColor)
        var path = UIBezierPath(roundedRect: CGRect(x: 0.5, y: 0.5, width: CGFloat(scrubberHandle.frame.size.width - 1), height: CGFloat(scrubberHandle.frame.size.height - 2.5)), cornerRadius: 3)
        path.fill()
        let handleViewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        imageView.image = handleViewImage
        scrubberHandle.addSubview(imageView)
        return scrubberHandle
    }()

    fileprivate lazy var trimView: MediaVideoScrubberTrimView = {
        let trimView = MediaVideoScrubberTrimView(frame: CGRect.zero)
        trimView.isExclusiveTouch = true
        trimView.didBeginEditing = { [weak self] _ in
            self?.stateChangePipe.input.send(value: MediaVideoScrubberChange(state: .began, position: nil))
        }
        trimView.startHandleMoved = { [weak self] translation in
            self?.handleTrimViewStartMoved(translation: translation)
        }
        trimView.endHandleMoved = { [weak self] translation in
            self?.handleTrimViewEndMoved(translation: translation)
        }
        trimView.didEndEditing = { [weak self] in
            self?.handleTrimViewEndEditing()
        }
        return trimView
    }()

    fileprivate lazy var wrapperView: UIView = {
        let wrapView = UIView()
        return wrapView
    }()

    fileprivate lazy var leftCurtainView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        return view
    }()

    fileprivate lazy var rightCurtainView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        return view
    }()
}

extension MediaVideoScrubber {

    fileprivate func handleTrimViewEndEditing() {
        let start = (trimView.frame.origin.x) * (CGFloat(duration) / collectionView.frame.size.width)
        let end = (trimView.frame.maxX - 2 * segementGapToHandler) * (CGFloat(duration) / collectionView.frame.size.width)
        effectRange.value = Range<TimeInterval>(uncheckedBounds: (lower: TimeInterval(start), upper: TimeInterval(end)))
        resetToTrimStartValue()
    }

    fileprivate func handleTrimViewStartMoved(translation: CGPoint) {
        let originX: CGFloat = max(0, trimView.frame.origin.x + translation.x)
        let delta: CGFloat = originX - trimView.frame.origin.x
        let trimViewRect = CGRect(x: originX, y: trimView.frame.origin.y, width: trimView.frame.size.width - delta, height: trimView.frame.size.height)
        let limit = (trimViewRect.maxX - trimViewRect.minX - 2 * segementGapToHandler) * (CGFloat(duration) / collectionView.frame.size.width)
        if limit < CGFloat(videoScrubberMinimumTrimDuration) {
            return
        }
        trimView.frame = trimViewRect
        layoutTrimCurtainViews()
    }

    fileprivate func handleTrimViewEndMoved(translation: CGPoint) {
        let trimViewRect = CGRect(x: trimView.frame.origin.x, y: trimView.frame.origin.y, width: trimView.frame.size.width + translation.x, height: trimView.frame.size.height)
        let limit = (trimViewRect.maxX - trimViewRect.minX - 2 * segementGapToHandler) * (CGFloat(duration) / collectionView.frame.size.width)
        if limit < CGFloat(videoScrubberMinimumTrimDuration) {
            return
        }
        if trimViewRect.maxX > collectionView.frame.size.width + 2 * segementGapToHandler {
            return
        }
        trimView.frame = trimViewRect
        layoutTrimCurtainViews()
    }

    fileprivate func layoutTrimCurtainViews() {
        leftCurtainView.isHidden = !allowsTrimming
        rightCurtainView.isHidden = !allowsTrimming
        if allowsTrimming {
            leftCurtainView.frame = CGRect(x: 0, y: 2, width: trimView.frame.origin.x, height: 32)
            rightCurtainView.frame = CGRect(x: trimView.frame.maxX, y: 2, width: wrapperView.frame.size.width - trimView.frame.maxX, height: 32)
        }
    }
}

extension MediaVideoScrubber: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaVideoScrubberTummbnailCellKind, for: indexPath) as!
            MediaVideoScrubberTummbnailCell
        if indexPath.item < tunmbnailImages.count {
            cell.imageView.image = tunmbnailImages[indexPath.item]
        } else {
            cell.imageView.image = nil
        }
        return cell
    }

    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return tummbnailCount()
    }
}
