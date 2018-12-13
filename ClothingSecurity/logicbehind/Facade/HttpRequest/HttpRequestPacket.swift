//
//  HttpRequestPacket.swift
//  blackboard
//
//  Created by kingxt on 2017/10/15.
//  Copyright © 2017年 xkb. All rights reserved.
//

import Foundation
import Mesh
import ReactiveSwift
import Result
import SwiftyJSON
import XCGLogger

let httpRootUrl = "https://api.beedeemade.com"
//"https://api.beedee.yituizhineng.top"

enum DeltaDataType: String {
    case add = "ADD"
    case delete = "DELETE"
    case update = "UPDATE"
    case setting = "SETTING"
    case unknow
}

open class HttpResponseData: NSObject {
    public let json: JSON?
    public required init(json: JSON?) {
        self.json = json
    }
    
    public func tipMesage() -> String? {
        return json?["message"].string
    }
    
    public func isSuccess() -> Bool {
        if let code = json?["code"], code >= 200, code < 300 {
            return true
        }
        return false
    }
}

let logger = XCGLogger.default


public protocol HttpResponseErrorHandler {
    func handle(data: HttpResponseData)
    func handle(error: NSError)
}
private let internalErrorDomain = "com.xhb.httpresponse"
public let commonResponseError: NSError = NSError(domain: internalErrorDomain, code: -1, userInfo: nil)
public var httpResponseErrorGloablHandler: HttpResponseErrorHandler? = nil

private let appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
private let sysVersion: String = UIDevice.current.systemVersion

open class HttpRequestPacket<T: HttpResponseData> {
    
    var httpResponseErrorHandler: HttpResponseErrorHandler? = httpResponseErrorGloablHandler

    private(set) var request: DataRequest?

    required public init() {
    }
    
    open func requestUrl() -> URL {
        fatalError("mush override this method!  test test")
    }
    
    var rootUrl: String {
        return httpRootUrl
    }

    open func requestParameter() -> [String: Any]? {
        return nil
    }

    open func httpMethod() -> HTTPMethod {
        return .post
    }

    open func parameterEncoding() -> ParameterEncoding {
        return URLEncoding.default
    }

    fileprivate func constructRequest() -> DataRequest? {
        // TODO: config base server url
        var systemInfo = utsname()
        uname(&systemInfo)
        var headers: [String: String] = ["X-App-Version": "BeeDee/\(appVersion)" + " " + "iOS/\(sysVersion)"]
        if let authorization = authorization() {
            headers["authorization"] = authorization
        }
        print("url = \(requestUrl().absoluteString)")
        request = Mesh.request(URL(string: rootUrl + requestUrl().absoluteString)!,
                               method: httpMethod(),
                               parameters: requestParameter(),
                               encoding: parameterEncoding(),
                               headers: headers)
        let manager = Mesh.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        return request
    }

    open func send() -> SignalProducer<T, NSError> {
        return SignalProducer<T, NSError> { observer, lifetime in
            guard let request = self.constructRequest() else {
                observer.send(error: commonResponseError)
                return
            }
            logger.info("[Http][Out] " + (request.request?.url?.absoluteString ?? "") + " \(String(describing: self.requestParameter()))")
            request.responseData(queue: DispatchQueue.main, completionHandler: { response in
                if let error = response.error as NSError? {
                    if let statusCode = response.response?.statusCode {
                        observer.send(error: NSError(domain: error.domain, code: statusCode, userInfo: error.userInfo))
                    } else {
                        observer.send(error: error)
                    }
                } else if let data = response.data {
                    do {
                        let json = try JSON(data: data)
                        logger.info("[Http][In] \((request.request?.url?.absoluteString ?? "")) " + (json.rawString(options: []) ?? ""))
                        if let code = response.response?.statusCode, code == 401 {
                            LoginAndRegisterFacade.shared.changeLoginState(value: true)
                            UserItem.loginOut()
                        }
                        if response.response?.statusCode ?? 200 >= 400 {
                            observer.send(error: NSError(domain: internalErrorDomain, code: json["code"].intValue, userInfo: ["message" : json["message"].stringValue]))
                        } else {
                            if let allHeader = response.response?.allHeaderFields {
                                if let authorization: String = allHeader["Authorization"] as? String {
                                    UserDefaults.standard.set(authorization, forKey: "authorization")
                                }
                            }
                            observer.send(value: T(json: json))
                            observer.sendCompleted()
                        }
                    } catch {
                        logger.error(String(data: data, encoding: .utf8))
                        observer.send(error: commonResponseError)
                    }
                } else {
                    observer.send(error: commonResponseError)
                }
            })
            lifetime.observeEnded {
                request.cancel()
            }
            }.on(failed: { (error) in
                self.httpResponseErrorHandler?.handle(error: error)
            }, value: { (responseData) in
                self.httpResponseErrorHandler?.handle(data: responseData)
            })
    }

    open func sendImmediately() {
        send().start()
    }
}

class StatusHttpRequestPacket<T: HttpResponseData>: HttpRequestPacket<T> {
    override func send() -> SignalProducer<T, NSError> {
        return SignalProducer<T, NSError> { observer, lifetime in
            guard let request = self.constructRequest() else {
                observer.send(error: commonResponseError)
                return
            }
            logger.info("[Http][Out] " + (request.request?.url?.absoluteString ?? "") + " \(String(describing: self.requestParameter()))")
            request.responseData(queue: DispatchQueue.main, completionHandler: { response in
                if let data = response.data {
                    do {
                        let json = try JSON(data: data)
                        logger.info("[Http][In] \((request.request?.url?.absoluteString ?? "")) " + (json.rawString(options: []) ?? ""))
                        let statusString = json["status"].stringValue
                        if statusString != "1" {
                            observer.send(error: NSError(domain: internalErrorDomain, code: -1, userInfo: ["message" : json["msg"].stringValue]))
                        } else {
                            observer.send(value: T(json: json))
                            observer.sendCompleted()
                        }
                    } catch {
                        logger.error(String(data: data, encoding: .utf8))
                        observer.send(error: commonResponseError)
                    }
                } else if let error = response.error as NSError? {
                    observer.send(error: error)
                } else {
                    observer.send(error: commonResponseError)
                }
            })
            lifetime.observeEnded {
                request.cancel()
            }
            }.on(failed: { (error) in
                self.httpResponseErrorHandler?.handle(error: error)
            }, value: { (responseData) in
                self.httpResponseErrorHandler?.handle(data: responseData)
            })
    }
}

