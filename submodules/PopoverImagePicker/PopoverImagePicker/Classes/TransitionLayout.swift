//
//  TransitionLayout.swift
//  Components-Swift
//
//  Created by Dylan on 16/05/2017.
//  Copyright © 2017 liao. All rights reserved.
//

import UIKit

class AttachmentCarouseCollectionView: UICollectionView {
    
    private var animationDuration: TimeInterval?
    private var animationStartTime: CFTimeInterval?
    private var animationTransitionLayout: UICollectionViewTransitionLayout?
    private var animationLink: CADisplayLink?
    
    public var isTransitionInProgress: Bool {
        get {
            if animationLink != nil {
                return true
            } else {
                return false
            }
        }
    }
    
    func transition(to layout: UICollectionViewLayout, duration: TimeInterval, completion: @escaping UICollectionView.LayoutInteractiveTransitionCompletion) -> UICollectionViewTransitionLayout {
        animationDuration = duration
        animationStartTime = CACurrentMediaTime()
        
        let link = CADisplayLink(target: self, selector: #selector(updateProgress))
        link.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
        
        animationTransitionLayout = startInteractiveTransition(to: layout) {[weak self] (completed, finished) in
            if let strongSelf = self {
                if let transitionLayout = strongSelf.animationTransitionLayout as? TransitionAnimationLayout {
                    transitionLayout.collectionViewDidCompleteTransition(finished: finished)
                }
                strongSelf.clearAnimationData()
                completion(completed, finished)
            }
        }
        animationLink = link
        return animationTransitionLayout!
    }
    
    private func quadraticEaseInOut(progress: CGFloat) -> CGFloat {
        if progress < 0.5 {
            return 2 * progress * progress
        } else {
            return -2 * progress * progress + 4 * progress - 1
        }
    }
    
    @objc func updateProgress(link: CADisplayLink) {
        if self.collectionViewLayout is UICollectionViewTransitionLayout {
            if let startTIem = animationStartTime,
                let duration = animationDuration {
                var progress = duration > 0 ? CGFloat(link.timestamp - startTIem) / CGFloat(duration) : 1.0
                progress = min(1.0, progress)
                progress = max(0.0, progress)
                progress = quadraticEaseInOut(progress: progress)
                self.animationTransitionLayout?.transitionProgress = progress
//                self.animationTransitionLayout?.invalidateLayout()
                
                if progress >= 1.0 {
                    finishTransition(link: link)
                }
            } else {
                finishTransition(link: link)
            }
        } else {
            finishTransition(link: link)
        }
    }
    
    private func finishTransition(link: CADisplayLink) {
        if let transitionLayout = animationTransitionLayout as? TransitionAnimationLayout {
            transitionLayout.collectionViewWillCompleteTransition()
        }
        link.invalidate()
        finishInteractiveTransition()
        clearAnimationData()
    }
    
    public func toContentOffset(layout: UICollectionViewTransitionLayout, at indexPath: IndexPath, to size: CGSize, to contentInset: UIEdgeInsets) -> CGPoint {
        var fromFrame = CGRect.null
        var toFrame = CGRect.null
        if let fromPose = layout.currentLayout.layoutAttributesForItem(at: indexPath),
            let toPose = layout.nextLayout.layoutAttributesForItem(at: indexPath) {
            fromFrame = fromFrame.union(fromPose.frame)
            toFrame = toFrame.union(toPose.frame)
        }
        
        let placementFrame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        let sourcePoint = CGPoint(x: toFrame.midX, y: toFrame.midY)
        let destinationPoint = CGPoint(x: placementFrame.midX, y: placementFrame.midY)
        
        let contentSize = layout.nextLayout.collectionViewContentSize
        var offset = CGPoint(x: sourcePoint.x - destinationPoint.x, y: sourcePoint.y - destinationPoint.y)
        
        let minOffsetX: CGFloat = 0.0
        let minOffsetY = -contentInset.top
        let maxOffsetX = max(contentSize.width - placementFrame.size.width, minOffsetX)
        let maxOffsetY = max(contentSize.height - placementFrame.size.height, minOffsetY)
        
        offset.x = max(minOffsetX, offset.x)
        offset.y = max(minOffsetY, offset.y)
        
        offset.x = min(maxOffsetX, offset.x)
        offset.y = min(maxOffsetY, offset.y)
        return offset
    }
    
    private func clearAnimationData() {
        animationDuration = nil
        animationStartTime = nil
        animationTransitionLayout = nil
        animationLink = nil
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let hitView = super.hitTest(point, with: event) {
            if hitView == self {
                return nil
            } else {
                return hitView
            }
        }
        return nil
    }
}

class TransitionAnimationLayout: UICollectionViewTransitionLayout {
    
    private var fromContentOffset: CGPoint
    private var previousProgress: CGFloat = 0
    private var poses: [IndexPath: UICollectionViewLayoutAttributes] = [IndexPath: UICollectionViewLayoutAttributes]()
    private var targetPoses: [IndexPath: UICollectionViewLayoutAttributes] = [IndexPath: UICollectionViewLayoutAttributes]()
    
    public var toContentOffet: CGPoint? {
        didSet {
            if oldValue != toContentOffet {
                invalidateLayout()
            }
        }
    }
    
    public var progressChanged: ((CGFloat) -> Void)?
    
    override init(currentLayout: UICollectionViewLayout, nextLayout newLayout: UICollectionViewLayout) {
        fromContentOffset = currentLayout.collectionView?.contentOffset ?? CGPoint.zero
        super.init(currentLayout: currentLayout, nextLayout: newLayout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var transitionProgress: CGFloat {
        didSet {
            if oldValue != transitionProgress {
                previousProgress = oldValue
                let progress = min(1.0, transitionProgress)
                if let toContentOffset = toContentOffet {
                    let t = progress
                    let f = 1 - t
                    let offset = CGPoint(x: f * fromContentOffset.x + t * toContentOffset.x, y: f * fromContentOffset.y + t * toContentOffset.y)
                    collectionView?.contentOffset = offset
                }
                if let progressChanged = progressChanged {
                    progressChanged(transitionProgress)
                }
            }
        }
    }
    
    override func prepare() {
        super.prepare()
        
        let remaining = 1 - previousProgress
        let t = remaining == 0 ? transitionProgress : abs(transitionProgress - previousProgress) / remaining
        let f = 1 - t
        
        let numberOfSections = collectionView?.numberOfSections ?? 0
        for section in 0 ..< numberOfSections {
            let numberOfItems = collectionView?.numberOfItems(inSection: section) ?? 0
            for item in 0 ..< numberOfItems {
                let indexPath = IndexPath(item: item, section: section)
                let fromPose: UICollectionViewLayoutAttributes
                if let p = poses[indexPath] {
                    fromPose = p
                } else {
                    fromPose = currentLayout.layoutAttributesForItem(at: indexPath) ?? UICollectionViewLayoutAttributes(forCellWith: indexPath)
                }
                let toPose: UICollectionViewLayoutAttributes
                if let p = targetPoses[indexPath] {
                    toPose = p
                } else {
                    toPose = nextLayout.layoutAttributesForItem(at: indexPath) ?? UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    targetPoses[indexPath] = toPose
                }
                
                let pose: UICollectionViewLayoutAttributes
                if t > CGFloat.ulpOfOne {
                    pose = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    interpolate(pose: pose, fromPose: fromPose, toPose: toPose, fromProgress: f, toProgress: t)
                } else {
                    pose = fromPose
                }
                poses[indexPath] = pose
            }
        }
    }
    
    private func interpolate(pose: UICollectionViewLayoutAttributes, fromPose: UICollectionViewLayoutAttributes, toPose: UICollectionViewLayoutAttributes, fromProgress: CGFloat, toProgress: CGFloat) {
        var bounds = CGRect.zero
        bounds.size.width = fromProgress * fromPose.bounds.size.width + toProgress * toPose.bounds.size.width
        bounds.size.height = fromProgress * fromPose.bounds.size.height + toProgress * toPose.bounds.size.height
        pose.bounds = bounds
        
        var center = CGPoint.zero
        center.x = fromProgress * fromPose.center.x + toProgress * toPose.center.x
        center.y = fromProgress * fromPose.center.y + toProgress * toPose.center.y
        pose.center = center
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var newPoses = [UICollectionViewLayoutAttributes]()
        let numberOfSections = collectionView?.numberOfSections ?? 0
        for section in 0 ..< numberOfSections {
            let numberOfItems = collectionView?.numberOfItems(inSection: section) ?? 0
            for item in 0 ..< numberOfItems {
                let indexPath = IndexPath(item: item, section: section)
                if let pose = poses[indexPath] {
                    if pose.frame.intersects(rect) {
                        newPoses.append(pose)
                    }
                }
            }
        }
        return newPoses
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return poses[indexPath]
    }
    
    public func collectionViewWillCompleteTransition() {
        
    }
    
    public func collectionViewDidCompleteTransition(finished: Bool) {
        if finished {
            if let toContentOffset = toContentOffet {
                collectionView?.contentOffset = toContentOffset
            }
        }
    }
}



