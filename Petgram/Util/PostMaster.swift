//
//  PostMaster.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftTryCatch


func ==(lhs: PostRequest, rhs: PostRequest) -> Bool {
    return lhs.urlString == rhs.urlString
        && (lhs.params as NSDictionary).isEqual(to: rhs.params)
        && lhs.blocking == rhs.blocking
}

class PostRequest: NSObject, NSCoding {
    let urlString: String
    let params: Alamofire.Parameters
    let blocking: Bool
    let method: HTTPMethod
    let waitForAppActive: Bool
    let appVersion: String
    var active = false
    
    init(urlString: String, params: Alamofire.Parameters, blocking: Bool, method: HTTPMethod = .post, waitForAppActive: Bool = false) {
        self.urlString = urlString
        self.params = params
        self.blocking = blocking
        self.method = method
        self.waitForAppActive = waitForAppActive
        self.appVersion = UIApplication.shared.versionString
    }
    
    // Coding
    private static let urlStringKey = "urlStringKey"
    private static let paramsKey = "paramsKey"
    private static let blockingKey = "blockingKey"
    private static let methodKey = "methodKey"
    private static let waitForAppActiveKey = "waitForAppActiveKey"
    private static let appVersionKey = "appVersion"
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.urlString, forKey: PostRequest.urlStringKey)
        aCoder.encode(self.params, forKey: PostRequest.paramsKey)
        aCoder.encode(self.blocking, forKey: PostRequest.blockingKey)
        aCoder.encode(self.method.rawValue, forKey: PostRequest.methodKey)
        aCoder.encode(self.waitForAppActive, forKey: PostRequest.waitForAppActiveKey)
        aCoder.encode(self.appVersion, forKey: PostRequest.appVersionKey)
    }
    
    required init?(coder aDecoder: NSCoder) {
        var hasURL = true
        var hasParams = true
        
        if let urlString = aDecoder.decodeObject(forKey: PostRequest.urlStringKey) as? String {
            self.urlString = urlString
        } else {
            self.urlString = ""
            hasURL = false
        }
        
        if let params = aDecoder.decodeObject(forKey: PostRequest.paramsKey) as? Alamofire.Parameters {
            self.params = params
        } else {
            self.params = [:]
            hasParams = false
        }
        
        self.blocking = false // never block from old calls
        
        self.method = HTTPMethod(
            rawValue: aDecoder.decodeObject(
                forKey: PostRequest.methodKey
                ) as? String
                ?? ""
            ) ?? .post
        
        self.waitForAppActive = aDecoder.decodeBool(forKey: PostRequest.waitForAppActiveKey)
        
        guard let appVersion = aDecoder.decodeObject(forKey: PostRequest.appVersionKey) as? String else {
            // if no app version, must be from old app!
            return nil
        }
        
        guard appVersion == UIApplication.shared.versionString else {
            // from old version, API might have changed,
            // just throw away
            return nil
        }
        
        self.appVersion = appVersion
        
        super.init()
        
        if !hasURL || !hasParams {
            return nil
        }
    }
    
    override var hashValue: Int {
        return "\(self.urlString),\(self.params),\(self.blocking)".hashValue
    }
    
}

class PostMaster: NSObject, UserNeeded {
    
    private static let requestsKey = "PostMasterRequestsKey"
    
    override init() {
        self.requests = [:]
        
        super.init()
        
        SwiftTryCatch.try({
            if let data = UserDefaults.standard.object(forKey: PostMaster.requestsKey) as? Data,
                let requests = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: PostRequest] {
                
                self.requests = requests
            }
        }, catch: nil, finally: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(PostMaster.attemptRequests),
            name: .UIApplicationDidBecomeActive,
            object: nil
        )
    }
    
    var user: User? {
        didSet {
            self.attemptRequests()
        }
    }
    
    static let shared = PostMaster()
    
    private var requests: [String: PostRequest] {
        didSet {
            self.archive()
        }
    }
    
    func add(keyedRequests: [String: PostRequest], dontAttempt: Bool = false) {
        self.requests.update(from: keyedRequests)
        
        if !dontAttempt {
            self.attemptRequests()
        }
    }
    
    func add(requests: [PostRequest], dontAttempt: Bool = false) {
        
        var keyed = [String: PostRequest]()
        for req in requests {
            keyed["\(req.hashValue)"] = req
        }
        
        self.requests.update(from: keyed)
        if !dontAttempt {
            self.attemptRequests()
        }
    }
    
    func add(request: PostRequest, key: String? = nil, dontAttempt: Bool = false) {
        if let key = key {
            self.add(keyedRequests: [key: request])
        } else {
            self.add(requests: [request], dontAttempt: dontAttempt)
        }
    }
    
    func attemptRequests() {
        
        guard let manager = self.user?.authenticatedAFManager, self.requests.count > 0 else {
            return
        }
        
        
        
        synchronize(lock: self) {
            for (key, req) in self.requests {
                
                guard !req.active else {
                    continue
                }
                guard !(req.waitForAppActive && UIApplication.shared.applicationState != .active) else {
                    return
                }
                
                req.active = true
                let afReq: Alamofire.DataRequest
                if req.blocking {
                    afReq = manager.requestBlockUntilResponse(
                        req.urlString,
                        method: req.method,
                        parameters: req.params,
                        encoding: JSONEncoding.default
                    )
                } else {
                    afReq = manager.request(
                        req.urlString,
                        method: req.method,
                        parameters: req.params,
                        encoding: JSONEncoding.default
                    )
                }
                
                afReq.response { result in
                    if result.request?.url?.absoluteString.contains("actionlog") ?? false {
                        Logger.log("data: \(JSON(result.request?.httpBody as Any))", logType: .actionLog)
                        //Logger.log("error: \(String(describing: result.error))", logType: .actionLog)
                        //Logger.log("response: \(String(describing: result.data))", logType: .actionLog)
                    }
                    
                    synchronize(lock: self) {
                        if result.error == nil {
                            self.requests.removeValue(forKey: key)
                        }
                        req.active = false
                    }
                }
            }
        }
    }
    
    private func archive() {
        let requestsData = NSKeyedArchiver.archivedData(withRootObject: self.requests)
        UserDefaults.standard.set(requestsData, forKey: PostMaster.requestsKey)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
