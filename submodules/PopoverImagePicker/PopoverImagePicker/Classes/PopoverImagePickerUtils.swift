//
//  PopoverImagePickerUtils.swift
//  Pods
//
//  Created by Dylan Wang on 07/08/2017.
//
//

import UIKit

internal func ImageNamed(_ name: String) -> UIImage? {
    var bundle = Bundle(for: AttachmentAssetCell.self)
    if let path = bundle.path(forResource: "PopoverImagePicker", ofType: "bundle") {
        if let mainBundle = Bundle(path: path) {
            bundle = mainBundle
        }
    }
    return UIImage(named: name, in: bundle, compatibleWith: nil)
}

private var languageBundle: Bundle?

internal func SLLocalized(_ str: String) -> String {
    if languageBundle == nil {
        let frameworkBundle = Bundle(for: AttachmentAssetCell.self)
        if let path = frameworkBundle.path(forResource: "PopoverImagePicker", ofType: "bundle") {
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
