//
//  LanguageHelper.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2019/7/20.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation

var languageBundle: Bundle? = getLanguageBundle()

// MARK: - 国际化直接调用此方法
func localizedString(_ key: String) -> String {
    return languageBundle?.localizedString(forKey: key, value: nil, table: nil) ?? key
}
// MARK: - 国际化含参调用
func localizedString(_ key: String, _ arguments: CVarArg...) -> String {
    return String(format: localizedString(key), arguments: arguments)
}

class LocalizableHelper: NSObject {
    @objc class func localizedString(_ key: String) -> String {
        return languageBundle?.localizedString(forKey: key, value: nil, table: nil) ?? key
    }
}

func getLanguageBundle(language: String? = "zh-Hans") -> Bundle? {
    var currentLanuage = "zh-Hans"
    if let la = language {
        currentLanuage = la
    } else if let firstLanguage = getFirstLanuage() {
        currentLanuage = firstLanguage
    }
    let bundle = Bundle.main
    guard let path = bundle.path(forResource: currentLanuage, ofType: "lproj") else {
        return nil
    }
    return Bundle(path: path)
}

func setLanguageBundle() {
    if let language = getFirstLanuage() {
        languageBundle = getLanguageBundle(language: language)
    }
}

func getFirstLanuage() -> String? {
    let key = "AppleLanguages"
    let languages = UserDefaults.standard.object(forKey: key) as? [String]
    return languages?.first
}

func setFirstLanguage(language: String = "zh-Hans") {
    let key = "AppleLanguages"
    UserDefaults.standard.set(language, forKey: key)
    UserDefaults.standard.synchronize()

    setLanguageBundle()
}
//
//var bundle: Bundle?
//
//func initUserLanguage() {
//    let def = UserDefaults.standard
//    var languageValue = def.value(forKey: "userLanguage") as? String
//    if languageValue?.length == 0 || languageValue == nil  {
//        let languages = def.object(forKey: "AppleLanguages") as? NSArray
//        if let languages = languages, languages.count > 0 {
//            if let current = languages[0] as? String {
//                languageValue = current
//                def.setValue(current, forKey: "userLanguage")
//                def.synchronize()
//            }
//        }
//    }
//    if let path = Bundle.main.path(forResource: languageValue, ofType: "lproj") {
//        bundle = Bundle(path: path)
//    }
//}
//
//func setLanguage( _ language: String) {
//    if let path = Bundle.main.path(forResource: language, ofType: "lproj") {
//        bundle = Bundle(path: path)
//    }
//    UserDefaults.standard.setValue(language, forKey: "userLanguage")
//    UserDefaults.standard.synchronize()
//}
//
//
//func localizedString(_ key: String) -> String {
//    return bundle?.localizedString(forKey: key, value: nil, table: nil) ?? ""
//}
