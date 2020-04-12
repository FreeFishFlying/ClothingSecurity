//
//  MediaAssetsLibrary.swift
//  VideoPlayer-Swift
//
//  Created by kingxt on 2017/4/4.
//  Copyright © 2017年 kingxt. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result
import Photos
import Core
import XCGLogger

private var latestPHAuthorizationStatus: PHAuthorizationStatus?

private extension URL {
    var attributes: [FileAttributeKey : Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }

    var fileSize: UInt64 {
        return attributes?[.size] as? UInt64 ?? UInt64(0)
    }

    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
}

public class MediaAssetsLibrary: NSObject {

    public static let `default` = MediaAssetsLibrary(assetType: .any)

    public enum MediaAssetsLibraryError: Error {
        case nothing
        case noPriority
    }

    private let assetType: MediaAssetType
    fileprivate var libraryChangePipe: (output: Signal<PHChange, NoError>, input: Signal<PHChange, NoError>.Observer)

    public init(assetType: MediaAssetType) {
        self.assetType = assetType
        libraryChangePipe = Signal<PHChange, NoError>.pipe()
        super.init()
        PHPhotoLibrary.shared().register(self)
    }

    public func saveVideo(atFileURL url: URL, completion: ((Bool) -> Void)? = nil) {
        PHPhotoLibrary.shared().performChanges({ () -> Void in
            let createAssetRequest: PHAssetChangeRequest? = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            createAssetRequest?.creationDate = Date()
        }) { (success, _) -> Void in
            DispatchQueue.main.async {
                completion?(success)
            }
        }
    }

    public func saveImage(image: UIImage, completion: ((Bool) -> Void)? = nil) {
        PHPhotoLibrary.shared().performChanges({ () -> Void in
            if let data = image.kf.gifRepresentation() {
                do {
                    if #available(iOS 9.0, *) {
                        let request = PHAssetCreationRequest.forAsset()
                        request.creationDate = Date()
                        request.addResource(with: .photo, data: data, options: PHAssetResourceCreationOptions())
                    } else {
                        let url = randomTemporaryURL()
                        try data.write(to: url)
                        let createAssetRequest: PHAssetChangeRequest? = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
                        createAssetRequest?.creationDate = Date()
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion?(false)
                    }
                }
            } else {
                let createAssetRequest: PHAssetChangeRequest? = PHAssetChangeRequest.creationRequestForAsset(from: image)
                createAssetRequest?.creationDate = Date()
            }
        }) { (success, _) -> Void in
            DispatchQueue.main.async {
                completion?(success)
            }
        }
    }
    
    public func videoGroup(duration: TimeInterval? = nil, sizeLimit: UInt64? = nil) -> SignalProducer<MediaAssetGroup?, MediaAssetsLibraryError> {
        return SignalProducer<MediaAssetGroup?, MediaAssetsLibraryError>{ (observer, _) in
            self.requestAuthorization().startWithResult({ (statues: Result<PHAuthorizationStatus, NoError>) in
                if statues.value != PHAuthorizationStatus.authorized {
                    observer.send(error: MediaAssetsLibrary.MediaAssetsLibraryError.noPriority)
                    XCGLogger.default.info("没有相册权限...")
                    return
                }
                
                let assetResults = PHAsset.fetchAssets(with: .video, options: nil)
                XCGLogger.default.info("videoAssetResultsCount:\(assetResults.count)")
                var result = [PHAsset]()
                for i in 0..<assetResults.count {
                    result.append(assetResults[i])
                }
                observer.send(value: MediaAssetGroup(assets: result.sorted(by: { (left, right) -> Bool in
                    guard let leftDate = left.creationDate, let rightDate = right.creationDate else {
                        return true
                    }
                    return leftDate < rightDate
                })))
                observer.sendCompleted()
            })
        }
    }

    public func assetGroups() -> SignalProducer<[MediaAssetGroup], MediaAssetsLibraryError> {
        let groupsSignal: () -> (SignalProducer<[MediaAssetGroup], MediaAssetsLibraryError>) = { () in

            self.cameraRollGroup().map { (assetGroup: MediaAssetGroup) -> [MediaAssetGroup] in
                var groups = [MediaAssetGroup]()
                groups.append(assetGroup)
                let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
                for i in 0 ..< albums.count {
                    if albums.object(at: i).estimatedAssetCount > 0 {
                        groups.append(MediaAssetGroup(collection: albums.object(at: i), result: nil))
                    }
                }
                let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
                for i in 0 ..< smartAlbums.count {
                    let collection: PHAssetCollection = smartAlbums.object(at: i)
                    if MediaAssetGroup.isSmartAlbumCollectionSubtype(subtype: collection.assetCollectionSubtype, assetType: self.assetType) {
                        let group = MediaAssetGroup(collection: collection, result: nil)
                        if group.assetCount() > 0 {
                            groups.append(group)
                        }
                    }
                }
                groups.sort(by: { (group1, group2) -> Bool in
                    MediaAssetGroup.from(type: group1.subtype()).rawValue < MediaAssetGroup.from(type: group2.subtype()).rawValue
                })
                return groups
            }
        }

        let updateSignal = libraryChangePipe.output.map { (_) -> SignalProducer<[MediaAssetGroup], MediaAssetsLibraryError> in
            return groupsSignal()
        }

        let returnValue = SignalProducer<[MediaAssetGroup], MediaAssetsLibraryError> { (sink: Signal<[MediaAssetGroup], MediaAssetsLibraryError>.Observer, _: Lifetime) in
            self.requestAuthorization().startWithResult({ (statues: Result<PHAuthorizationStatus, NoError>) in
                if statues.value != PHAuthorizationStatus.authorized {
                    return sink.send(error: .nothing)
                }
                groupsSignal().startWithResult({ (result: Result<[MediaAssetGroup], MediaAssetsLibrary.MediaAssetsLibraryError>) in
                    if let value = result.value {
                        sink.send(value: value)
                    }
                })
                updateSignal.flatten(.latest).observeResult({ (result: Result<[MediaAssetGroup], MediaAssetsLibrary.MediaAssetsLibraryError>) in
                    if let value = result.value {
                        sink.send(value: value)
                    }
                })
            })
        }

        return returnValue
    }

    public func requestAuthorization() -> SignalProducer<PHAuthorizationStatus, NoError> {
        return SignalProducer<PHAuthorizationStatus, NoError> { (observer: Signal<PHAuthorizationStatus, NoError>.Observer, _: Lifetime) in
            if let latestPHAuthorizationStatus = latestPHAuthorizationStatus {
                observer.send(value: latestPHAuthorizationStatus)
                observer.sendCompleted()
            }
            PHPhotoLibrary.requestAuthorization({ status in
                latestPHAuthorizationStatus = status
                observer.send(value: status)
                observer.sendCompleted()
            })
        }
    }

    public func fetchAsset(phAssetLocalIdentifier: String) -> SignalProducer<PHAsset?, MediaAssetsLibraryError> {
        return SignalProducer<PHAsset?, MediaAssetsLibraryError> { observer, _ in
            self.requestAuthorization().startWithValues { status in
                if status != PHAuthorizationStatus.authorized {
                    observer.send(error: .noPriority)
                } else {
                    let assetItem = PHAsset.fetchAssets(withLocalIdentifiers: [phAssetLocalIdentifier], options: nil).firstObject
                    observer.send(value: assetItem)
                    observer.sendCompleted()
                }
            }
        }
    }

    public func cameraRollGroup() -> SignalProducer<MediaAssetGroup, MediaAssetsLibraryError> {
        return SignalProducer<MediaAssetGroup, MediaAssetsLibraryError> { (observer: Signal.Observer, _: Lifetime) in
            self.requestAuthorization().startWithValues { status in
                if status != PHAuthorizationStatus.authorized {
                    observer.send(error: .noPriority)
                } else {
                    let options: PHFetchOptions = PHFetchOptions()
                    let fetchResult: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.smartAlbumUserLibrary, options: options)
                    let assetCollection: PHAssetCollection? = fetchResult.firstObject
                    if let assetCollection = assetCollection {
                        if self.assetType != .any {
                            options.predicate = NSPredicate(format: "mediaType = %i", argumentArray: [assetMediaType(for: self.assetType).rawValue])
                        }
                        let assetsFetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(in: assetCollection, options: options)
                        observer.send(value: MediaAssetGroup(collection: assetCollection, result: assetsFetchResult))
                        observer.sendCompleted()
                    } else {
                        observer.send(error: MediaAssetsLibraryError.nothing)
                    }
                }
            }
        }
    }
}

extension MediaAssetsLibrary: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        libraryChangePipe.input.send(value: changeInstance)
    }
}
