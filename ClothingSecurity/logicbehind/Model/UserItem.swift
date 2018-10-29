//
//  UserItem.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/29.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import SwiftyJSON
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as! String
        createTime = aDecoder.decodeDouble(forKey: "createTime")
        updateTime = aDecoder.decodeDouble(forKey: "createTime")
        username = aDecoder.decodeObject(forKey: "username") as! String
        gender = aDecoder.decodeObject(forKey: "gender") as! String
        avatar = aDecoder.decodeObject(forKey: "avatar") as! String
        mobile = aDecoder.decodeObject(forKey: "mobile") as! String
        email = aDecoder.decodeObject(forKey: "email") as! String
        role = aDecoder.decodeObject(forKey: "role") as! String
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
    
    
    
    class func create(json: JSON) -> UserItem{
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
