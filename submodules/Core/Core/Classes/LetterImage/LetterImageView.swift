//
//  LetterImageView.swift
//  Pods
//
//  Created by Dylan on 03/07/2017.
//
//

import UIKit
import Mesh
import ReactiveSwift
import Result

public class LetterImageView: UIImageView {

    private var retrieveTask: RetrieveImageTask?

    public func setLetterImage(with resource: Resource?, name: String, referId: Int = 0, options: KingfisherOptionsInfo? = nil) {
        cancelLetterImageTask()
        var letterSize = bounds.size
        if letterSize == .zero {
            letterSize = CGSize(width: 50, height: 50)
        }
        let letterContactModel = LetterImageContactModel(name: name, referId: referId, size: letterSize)
        if let resource = resource {
            retrieveTask = kf.setImage(with: resource, placeholder: nil, options: [.onlyFromCache, .keepCurrentImageWhileLoading], progressBlock: nil, completionHandler: { [weak self] image, _, _, _ in
                if let strongSelf = self {
                    if let image = image {
                        strongSelf.setSignal(processCircleLetterSignal(image: image))
                    } else {
                        strongSelf.setSignal(generalContactNameAvatar(data: letterContactModel))
                        strongSelf.retrieveTask = strongSelf.kf.setImage(with: resource, placeholder: nil, options: options, progressBlock: nil, completionHandler: { [weak strongSelf] image, _, _, _ in
                            if let strongSelf = strongSelf {
                                if let image = image {
                                    strongSelf.setSignal(processCircleLetterSignal(image: image))
                                } else {
                                    strongSelf.setSignal(generalContactNameAvatar(data: letterContactModel))
                                }
                            }
                        })
                    }
                }
            })
        } else {
            setSignal(generalContactNameAvatar(data: letterContactModel))
        }
    }

    public func cancelLetterImageTask() {
        retrieveTask?.cancel()
        reset()
        retrieveTask = nil
    }
}

private func processCircleLetterSignal(image: UIImage) -> SignalProducer<UIImage?, NoError> {
    return SignalProducer<UIImage?, NoError> { observer, _ in
        DispatchQueue.global().async {
            let resizedImage: UIImage
            if Int(image.size.width) != Int(image.size.height) {
                let width = min(image.size.width, image.size.height)
                resizedImage = image.scaled(to: CGSize(width: width, height: width), scalingMode: .aspectFill)
            } else {
                resizedImage = image
            }
            let result = resizedImage.circled(forRadius: resizedImage.size.width / 2)
            observer.send(value: result)
            observer.sendCompleted()
        }
    }
}

private class LetterImageContactModel: ContactNameAvatar {

    private let letterName: String
    private let letterReferId: Int?
    private let letterSize: CGSize

    init(name: String, referId: Int, size: CGSize) {
        letterName = name
        letterReferId = referId
        letterSize = size
    }

    var name: String {
        return letterName
    }

    var referId: Int? {
        return letterReferId
    }

    var size: CGSize {
        return letterSize
    }
}
