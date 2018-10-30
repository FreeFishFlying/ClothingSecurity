//
//  UserItem.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/29.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import SwiftyJSON

class LoginState: NSObject {
    @objc public static let shared = LoginState()
    public var hasLogin: Bool = false
}

class UserItem: NSObject, NSCoding {
    
    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(createTime, forKey: "createTime")
        aCoder.encode(updateTime, forKey: "updateTime")
        aCoder.encode(username, forKey: "username")
        aCoder.encode(gender, forKey: "gender")
        aCoder.encode(avatar, forKey: "avatar")
        aCoder.encode(mobile, forKey: "mobile")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(role, forKey: "role")
        aCoder.encode(nickName, forKey: "nickName")
    }
    
    private func chanegeDecodeTypeToString(key: String, aDecode: NSCoder) -> String {
        if let object = aDecode.decodeObject(forKey: key) as? String {
            return object
        }
        return ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        id = chanegeDecodeTypeToString(key: "id", aDecode: aDecoder)
        createTime = aDecoder.decodeDouble(forKey: "createTime")
        updateTime = aDecoder.decodeDouble(forKey: "createTime")
        username = chanegeDecodeTypeToString(key: "username", aDecode: aDecoder)
        gender = chanegeDecodeTypeToString(key: "gender", aDecode: aDecoder)
        avatar = chanegeDecodeTypeToString(key: "avatar", aDecode: aDecoder)
        mobile = chanegeDecodeTypeToString(key: "mobile", aDecode: aDecoder)
        email = chanegeDecodeTypeToString(key: "email", aDecode: aDecoder)
        role = chanegeDecodeTypeToString(key: "role", aDecode: aDecoder)
        nickName = chanegeDecodeTypeToString(key: "nickName", aDecode: aDecoder)
    }
    
    var id: String = ""
    var createTime: Double = 0
    var updateTime: Double = 0
    var username: String = ""
    var gender: String = ""
    var avatar: String = ""
    var mobile: String = ""
    var email: String = ""
    var role: String = ""
    var nickName: String = ""
    
    
    
    class func create(json: JSON) -> UserItem {
        let userItem = UserItem()
        if let id = json["id"].string {
            userItem.id = id
        }
        if let createTime = json["createTime"].double {
            userItem.createTime = createTime
        }
        if let updateTime = json["updateTime"].double {
            userItem.updateTime = updateTime
        }
        if let username = json["username"].string {
            userItem.username = username
        }
        if let nickName = json["nickName"].string {
            userItem.nickName = nickName
        }
        if let gender = json["gender"].string {
            userItem.gender = gender
        }
        if let avatar = json["avatar"].string {
            userItem.avatar = avatar
        }
        if let mobile = json["mobile"].string {
            userItem.mobile = mobile
        }
        if let email = json["email"].string {
            userItem.email = email
        }
        if let role = json["role"].string {
            userItem .role = role
        }
        return userItem
    }
    
    class func current() -> UserItem? {
        if let value = UserDefaults.standard.object(forKey: "CurrentLoginUserItem") as? Data {
            if let user = NSKeyedUnarchiver.unarchiveObject(with: value) as? UserItem {
                if !user.id.isEmpty {
                    return user
                }
            }
        }
        return nil
    }
    
    class func save(_ user: UserItem) {
        let data = NSKeyedArchiver.archivedData(withRootObject: user)
        UserDefaults.standard.set(data, forKey: "CurrentLoginUserItem")
        UserDefaults.standard.synchronize()
    }
    
    class func loginOut() {
        let clearUser = UserItem()
        UserItem.save(clearUser)
    }
}

func authorization() -> String? {
    return UserDefaults.standard.string(forKey: "authorization")
}
