//
//  MediaAssetGroup.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 2017/4/4.
//  Copyright © 2017年 kingxt. All rights reserved.
//

import Foundation
import Photos

var backupSource = [String: MediaAsset]()

class CustomPHFetchResult: PHFetchResult<PHAsset> {
    let assets: [PHAsset]

    init(assets: [PHAsset]) {
        self.assets = assets
    }

    override var firstObject: PHAsset? {
        return assets.first
    }

    override var lastObject: PHAsset? {
        return assets.last
    }

    override func object(at index: Int) -> PHAsset {
        return assets[index]
    }

    override var count: Int {
        return assets.count
    }

    override subscript(index: Int) -> PHAsset {
        return assets[index]
    }
}

public class MediaAssetGroup: NSObject, MediaGroup {

    enum MediaAssetGroupSubtype: Int {
        case none = 0
        case cameraRoll
        case myPhotoStream
        case favorites
        case selfPortraits
        case panoramas
        case videos
        case slomo
        case timelapses
        case bursts
        case screenshots
        case regular
    }

    private let collection: PHAssetCollection?
    private var groupSource: PHFetchResult<PHAsset>
    private var latestAssets: [MediaAsset]?
    
    public init(collection: PHAssetCollection, result: PHFetchResult<PHAsset>?, options: PHFetchOptions = PHFetchOptions()) {
        self.collection = collection
        if result != nil {
            groupSource = result!
        } else {
            groupSource = PHAsset.fetchAssets(in: collection, options: options)
        }
    }

    public init(assets: [PHAsset]) {
        collection = nil
        groupSource = CustomPHFetchResult(assets: assets)
    }

    public func assetCount() -> Int {
        return groupSource.count
    }

    public func objectAt(index: Int) -> MediaAsset? {
        if index >= groupSource.count {
            return nil
        }
        let phAsset = groupSource.object(at: index)
        if let item = backupSource[phAsset.localIdentifier] {
            return item
        }
        let asset = MediaAsset(asset: phAsset)
        backupSource[phAsset.localIdentifier] = asset
        return asset
    }

    public func indexFor(asset: MediaAsset) -> Int? {
        return groupSource.index(of: asset.asset)
    }

    public func isCameraRoll() -> Bool {
        return subtype() == PHAssetCollectionSubtype.smartAlbumUserLibrary
    }

    public func subtype() -> PHAssetCollectionSubtype {
        return collection?.assetCollectionSubtype ?? .any
    }

    public func title() -> String? {
        return collection?.localizedTitle ?? ""
    }

    public func fetchLatestAssets() -> [MediaAsset] {
        if latestAssets != nil {
            return latestAssets!
        }
        let count = groupSource.count
        if count == 0 {
            return []
        }
        let requiredCount = min(3, count)
        var assets = [MediaAsset]()
        for i in 0 ..< requiredCount {
            let index = count - i - 1
            let asset = groupSource.object(at: index)
            assets.append(MediaAsset(asset: asset))
        }
        latestAssets = assets
        return assets
    }

    public func getAssetDirection(from: MediaAsset, to: MediaAsset) -> (orderd: MediaAssetOrder, toIndex: Int) {
        if from.uniqueIdentifier() == to.uniqueIdentifier() {
            return (.same, 0)
        }
        var toIndex: Int?
        var orderd: MediaAssetOrder?
        let count = groupSource.count
        for i in 0 ..< count {
            let asset = groupSource.object(at: i)
            if asset.localIdentifier == to.uniqueIdentifier() {
                if toIndex == nil {
                    toIndex = i
                }
                if orderd == nil {
                    orderd = .descending
                }
            } else if asset.localIdentifier == from.uniqueIdentifier() {
                if orderd == nil {
                    orderd = .ascending
                }
            }
            if toIndex != nil && orderd != nil {
                break
            }
        }
        return (orderd ?? .unknown, toIndex ?? (groupSource.count + 1))
    }
}

extension MediaAssetGroup {
    class func from(type: PHAssetCollectionSubtype) -> MediaAssetGroupSubtype {
        switch type {
        case .smartAlbumPanoramas:
            return .panoramas
        case .smartAlbumVideos:
            return .videos
        case .smartAlbumFavorites:
            return .favorites
        case .smartAlbumTimelapses:
            return .timelapses
        case .smartAlbumBursts:
            return .bursts
        case .smartAlbumSlomoVideos:
            return .slomo
        case .smartAlbumUserLibrary:
            return .cameraRoll
        case .smartAlbumScreenshots:
            return .screenshots
        case .smartAlbumSelfPortraits:
            return .selfPortraits
        case .albumMyPhotoStream:
            return .myPhotoStream
        default:
            return .regular
        }
    }

    public class func isSmartAlbumCollectionSubtype(subtype: PHAssetCollectionSubtype, assetType: MediaAssetType) -> Bool {
        switch subtype {
        case .smartAlbumPanoramas:
            switch assetType {
            case .video:
                return false
            default:
                return true
            }
        case .smartAlbumFavorites:
            return true
        case .smartAlbumTimelapses:
            switch assetType {
            case .photo:
                return false
            default:
                return true
            }
        case .smartAlbumVideos:
            switch assetType {
            case .any:
                return true
            default:
                return false
            }
        case .smartAlbumSlomoVideos:
            switch assetType {
            case .photo:
                return false
            default:
                return true
            }
        case .smartAlbumBursts:
            switch assetType {
            case .video:
                return false
            default:
                return true
            }
        case .smartAlbumScreenshots:
            switch assetType {
            case .video:
                return false
            default:
                return true
            }
        case .smartAlbumSelfPortraits:
            switch assetType {
            case .video:
                return false
            default:
                return true
            }
        default:
            return false
        }
    }
}
