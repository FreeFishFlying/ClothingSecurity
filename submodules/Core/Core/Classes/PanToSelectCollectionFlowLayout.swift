//
//  PanToSelectCollectionFlowLayout.swift
//  Components
//
//  Created by kingxt on 2017/6/15.
//  Copyright © 2017年 liao. All rights reserved.
//

import Foundation
import UIKit

private let collectionViewKeyPath = "collectionView"

public class PanToSelectCollectionFlowLayout: UICollectionViewFlowLayout, UIGestureRecognizerDelegate {

    public var panToDeselect: Bool = true
    public var autoSelectRows: Bool = true
    public var autoSelectCellsBetweenTouches: Bool = true
    public var handleCellSelection: ((IndexPath, Bool) -> Void)?

    private var selectedRow: Bool = false
    private var selectRowCancelled: Bool = false
    private var pannedFromFirstColumn: Bool = false
    private var pannedFromLastColumn: Bool = false
    private var isDeselecting: Bool = false

    private var selecting: Bool = false
    private var deselecting: Bool = false
    private var initialSelectedIndexPath: IndexPath?
    private var previousIndexPath: IndexPath?

    public override init() {
        super.init()

        addObserver(self, forKeyPath: collectionViewKeyPath, options: NSKeyValueObservingOptions.new, context: nil)
    }

    deinit {
        removeObserver(self, forKeyPath: collectionViewKeyPath)
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func observeValue(forKeyPath keyPath: String?, of _: Any?, change _: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        if keyPath == collectionViewKeyPath {
            if collectionView != nil {
                setupCollectionView()
            }
        }
    }

    private func setupCollectionView() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture))
        panGestureRecognizer.delegate = self
        collectionView?.addGestureRecognizer(panGestureRecognizer)
    }

    @objc func handlePanGesture(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let velocity: CGPoint = panGestureRecognizer.velocity(in: collectionView)
        let point: CGPoint = panGestureRecognizer.location(in: collectionView)
        if collectionView == nil {
            return
        }
        if !collectionView!.isDecelerating {
            // Handle pan
            if panGestureRecognizer.state == .ended {
                // Reset pan states
                selecting = false
                selectedRow = false
                selectRowCancelled = false
                pannedFromFirstColumn = false
                pannedFromLastColumn = false
                deselecting = false
                previousIndexPath = nil
            } else {
                if fabs(velocity.x) < fabs(velocity.y) + 300 && !selecting {
                    selecting = false
                } else {
                    selecting = true
                    if let indexPath = collectionView?.indexPathForItem(at: point) {
                        let cell: UICollectionViewCell? = collectionView?.cellForItem(at: indexPath)
                        if cell?.isSelected ?? false {
                            if panToDeselect {
                                if nil == previousIndexPath || previousIndexPath != indexPath {
                                    deselecting = true
                                }
                                if deselecting {
                                    deselectCell(at: indexPath)
                                }
                            }
                        } else {
                            if !deselecting {
                                selectCell(at: indexPath)
                                // TODO: if autoSelectRows {
                                //                                    handleAutoSelectingRows(at: indexPath)
                                //                                }
                            }
                        }
                        previousIndexPath = indexPath
                    }
                }
            }
        }
    }

    private func selectCell(at indexPath: IndexPath) {
        handleCellSelection?(indexPath, true)
    }

    private func deselectCell(at indexPath: IndexPath) {
        handleCellSelection?(indexPath, false)
    }

    private func selectAllItems(from initialIndexPath: IndexPath, to finalIndexPath: IndexPath) {
        var initialIndexPath = initialIndexPath
        var finalIndexPath = finalIndexPath
        if initialIndexPath.section == finalIndexPath.section {
            if finalIndexPath.row < initialIndexPath.row {
                // Swap them
                let tempFinalIndex = IndexPath(item: finalIndexPath.row, section: finalIndexPath.section)
                finalIndexPath = initialIndexPath
                initialIndexPath = tempFinalIndex
            }
            var indexPath = initialIndexPath
            for _ in initialIndexPath.row ..< finalIndexPath.row {
                if let cell = collectionView?.cellForItem(at: indexPath) {
                    if !cell.isSelected {
                        selectCell(at: indexPath)
                    }
                }
                indexPath = IndexPath(item: indexPath.row + 1, section: indexPath.section)
            }
        }
    }

    private func handleAutoSelectingRows(at indexPath: IndexPath) {

        guard let cell = collectionView?.cellForItem(at: indexPath) else {
            return
        }
        let nextIndexPath = IndexPath(item: indexPath.row + 1, section: indexPath.section)
        guard let nextCell = collectionView?.cellForItem(at: nextIndexPath) else {
            return
        }

        if previousIndexPath == nil {
            if cell.frame.origin.x < minimumInteritemSpacing {
                pannedFromFirstColumn = true
            } else if nextCell.frame.origin.x < cell.frame.origin.x {
                pannedFromLastColumn = true
            }
        }

        if previousIndexPath?.section != indexPath.section {
            selectedRow = false
        }
        var didSelectAllItems: Bool = false
        if nextCell.frame.origin.x < cell.frame.origin.x {
            if pannedFromFirstColumn {
                didSelectAllItems = didSelectAllItemsInRow(with: indexPath)
            }
        } else if cell.frame.origin.x < minimumInteritemSpacing {
            if pannedFromLastColumn {
                didSelectAllItems = didSelectAllItemsInRow(with: indexPath)
            }
        }

        if previousIndexPath != nil && didSelectAllItems == false && labs(previousIndexPath!.row - indexPath.row) > 1 {
            selectRowCancelled = true
        }
    }

    private func didSelectAllItemsInRow(with indexPath: IndexPath) -> Bool {
        if selectedRow {
            if !selectRowCancelled {
                if pannedFromFirstColumn {
                    selectRowFromLastColumn(with: indexPath)
                } else {
                    selectRowFromFirstColumn(with: indexPath)
                }
                return true
            }
        } else {
            selectedRow = true
        }
        return false
    }

    private func selectRowFromFirstColumn(with indexPath: IndexPath) {
        var rowIndexPath = indexPath
        var cell: UICollectionViewCell?
        var nextCell: UICollectionViewCell?
        var nextIndexPath: IndexPath

        repeat {
            rowIndexPath = IndexPath(item: rowIndexPath.row + 1, section: rowIndexPath.section)
            cell = collectionView?.cellForItem(at: rowIndexPath)
            if cell?.isSelected ?? false {
                selectCell(at: rowIndexPath)
            }
            nextIndexPath = IndexPath(item: rowIndexPath.row + 1, section: rowIndexPath.section)
            nextCell = collectionView?.cellForItem(at: nextIndexPath)
        } while nextCell?.frame.origin.x ?? 0 > cell?.frame.origin.x ?? 0
    }

    private func selectRowFromLastColumn(with indexPath: IndexPath) {
        var rowIndexPath = indexPath
        var cell: UICollectionViewCell?
        repeat {
            rowIndexPath = IndexPath(item: rowIndexPath.row - 1, section: rowIndexPath.section)
            cell = collectionView?.cellForItem(at: rowIndexPath)
            if cell?.isSelected ?? false {
                selectCell(at: rowIndexPath)
            }
        } while cell != nil && cell!.frame.origin.x < minimumInteritemSpacing
    }

    public func gestureRecognizer(_: UIGestureRecognizer, shouldReceive _: UITouch) -> Bool {
        return true
    }

    public func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return !selecting
    }
}
