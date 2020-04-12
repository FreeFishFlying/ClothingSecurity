//
//  MeshFileLogger.swift
//  Mesh
//
//  Created by kingxt on 6/21/17.
//  Copyright © 2017 liao. All rights reserved.
//

import Foundation
import XCGLogger

public protocol LogFormatter {

    func formatMessage(_ msg: String) -> String
}

class DefaultFormatter: LogFormatter {

    let dateFormatter = DateFormatter()

    init() {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    }

    func formatMessage(_ msg: String) -> String {
        return "\(dateFormatter.string(from: Date())) " + msg
    }
}

public class MeshFileLogger: MeshLogger {

    let log = XCGLogger(identifier: "com.xhb.mesh", includeDefaultDestinations: false)

    public init(fileName: String) {
        let fileDestination = AutoRotatingFileDestination(writeToFile: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.path + "/Logs/" + fileName, shouldAppend: true, maxFileSize: 2 * 1024 * 1024, maxTimeInterval: 60 * 60 * 24 * 30)
        fileDestination.targetMaxLogFiles = 2
        fileDestination.outputLevel = .info
        fileDestination.showFunctionName = false
        fileDestination.showFileName = false
        fileDestination.showDate = true
        fileDestination.logQueue = XCGLogger.logQueue
        log.add(destination: fileDestination)
    }

    public func log(info: String) {
        log.info(info)
    }
}
