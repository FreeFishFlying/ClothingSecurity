//
//  ClothesMakingVideoModel.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/6.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit

struct VideoViewModel {
    let coverUrl: String
    private let duration: Double
    let playUrl: String
    let name: String
    var playTime: String = ""
    init(coverUrl: String, duration: Double, playUrl: String, name: String) {
        self.coverUrl = coverUrl
        self.playUrl = playUrl
        self.duration = duration
        self.name = name
        playTime = handelWithOriginalTime()
    }
    
    private func handelWithOriginalTime() -> String {
        let seconds = Int(duration / 1000)
        if seconds / 60 >= 1 {
            let min = seconds / 60
            let sec = seconds % 60
            var minString = ""
            var secString = ""
            if min < 10 {
                minString = "0\(min)"
            } else {
                minString = "\(min)"
            }
            if sec < 10{
                secString = "0\(sec)"
            } else {
                secString = "\(sec)"
            }
            return minString + ":" + secString
            
        } else {
            if seconds > 10 {
                return "00:\(seconds)"
            } else {
                return "00:0\(seconds)"
            }
            
        }
    }
}

class ClothesMakingVideoModel: NSObject {
    var height: CGFloat = 0
    var videoModel = [VideoViewModel]()
    let models: [VideoModel]
    init(models: [VideoModel]) {
        self.models = models
        super.init()
        height = (ScreenWidth - 30) / 16 * 9 + 39
        models.forEach { model in
            videoModel.append(VideoViewModel(coverUrl: model.poster, duration: model.duration, playUrl: model.url, name: model.name))
        }
    }
    
    let videoViewSize: CGSize = CGSize(width: ScreenWidth - 30, height: (ScreenWidth - 30) / 16 * 9 + 39)
}
