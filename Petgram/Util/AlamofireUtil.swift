//
//  AlamofireUtil.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

// for versions <=1.3.0
private let tooOldCode = 403
private let tooOldMessage = "too old"
// for versions >=1.3.1
private enum OttoSubstatusCode: String {
    case tokenInvalid = "TOKEN_EXPIRED"
    case unsupportedVersion = "UNSUPPORTED_VERSION"
}



extension DefaultDataResponse {
    
    var isInvalidToken: Bool {
        guard self.request?.url?.path != "/logout" else {
            return false
        }
        guard let data = self.data else {
            return false
        }
        guard let obj = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return false
        }
        guard let dict = obj as? NSDictionary else {
            return false
        }
        guard let code = dict["code"] as? String else {
            return false
        }
        return code == OttoSubstatusCode.tokenInvalid.rawValue
    }
    
    var isUnsupportedVersion: Bool {
        guard let data = self.data else {
            return false
        }
        guard let obj = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return false
        }
        guard let dict = obj as? NSDictionary else {
            return false
        }
        guard let code = dict["code"] as? String else {
            return false
        }
        return code == OttoSubstatusCode.unsupportedVersion.rawValue
    }
    
}

class PetDateAFManager: Alamofire.SessionManager {
    
    private var endBlockDate: Date?
    private var endBlockTimer: Timer?
    
    
    // normal syntax is broken in compiler
    private var blockingRequests: [Alamofire.Request] = [] {
        didSet {
            self.updateBlocking()
        }
    }
    private var waitingRequests: [Alamofire.Request] = []
    
    
    override init(configuration: URLSessionConfiguration, delegate: SessionDelegate, serverTrustPolicyManager: ServerTrustPolicyManager?) {
        super.init(
            configuration: configuration,
            delegate: delegate,
            serverTrustPolicyManager: serverTrustPolicyManager
        )
        self.startRequestsImmediately = false
    }
    
    init(configuration: URLSessionConfiguration) {
        super.init(configuration: configuration)
        self.startRequestsImmediately = false
    }
    
    static func authenticatedManager(withSessionToken token: String) -> PetDateAFManager {
        let configuration = URLSessionConfiguration.default
        let appId = LeanCloudApiInfo.appId.rawValue
        let appKey = LeanCloudApiInfo.appKey.rawValue
        
        let headers = [
            "X-LC-Id": appId,
            "X-LC-Key": appKey,
            "X-LC-Session": token
        ]
        
        configuration.httpAdditionalHeaders = headers
        configuration.timeoutIntervalForRequest = 15
        return PetDateAFManager(configuration: configuration)
    }
    
    @discardableResult override func request(_ url: URLConvertible, method: HTTPMethod = .get, parameters: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: HTTPHeaders? = nil) -> DataRequest {
        
        let req = self.requestBlockable(
            url,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: headers,
            blockable: false
        )
        
        req.response { response in
            guard PetDateController.shared.user?.authenticatedAFManager === self else {
                return
            }
            
            if response.isInvalidToken {
                Logger.log("invalid token!)\nurl: \(url)\nparams: \(String(describing: parameters))", logType: .error)
                self.handleInvalidToken(response: response)
            }
            
            if response.isUnsupportedVersion {
                self.handleUnsupportedVersion(response: response)
            }
        }
        
        return req
    }
    
    private func handleInvalidToken(response: DefaultDataResponse) {
        
        // TODO: Need to log out before the transition to Connection Page
        
        //        OttoController.shared.logOut(force: true, completion: nil)
        AppDelegate.shared?.transitionToConnection()
        
    }
    
    private func handleUnsupportedVersion(response: DefaultDataResponse) {
        
        var title = "Uh-oh"
        var message = "Your version of PetDate is no longer supported, please update him in the App Store."
        
        if let data = response.data {
            if let obj = try? JSONSerialization.jsonObject(with: data, options: []) {
                if let dict = obj as? NSDictionary {
                    if let overrideTitle = dict["title"] as? String {
                        title = overrideTitle
                    }
                    if let overrideMessage = dict["text"] as? String {
                        message = overrideMessage
                    }
                }
            }
        }
        
        // FIXME: Change to crrect AppStore address after published
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
            UIApplication.shared.openURL(URL(string: "itms://itunes.apple.com/us/app/apple-store/id975745769?mt=8")!)
        }))
        
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            rootVC.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    // different name so not ambigous
    @discardableResult func requestBlockable(_ url: URLConvertible, method: HTTPMethod = .get, parameters: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: HTTPHeaders? = nil, blockable: Bool = false) -> DataRequest {
        
        if blockable {
            PostMaster.shared.attemptRequests()
        }
        
        let req = super.request(
            url,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: headers
        )
        
        if self.currentlyBlocking && blockable {
            self.waitingRequests.append(req)
        } else {
            req.resume()
        }
        
        return req
    }
    
    @discardableResult func requestBlockOthers(forTime time: TimeInterval, url: URLConvertible, method: HTTPMethod = .get, parameters: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: HTTPHeaders? = nil, blockable: Bool = false) -> DataRequest {
        
        if blockable {
            PostMaster.shared.attemptRequests()
        }
        
        let newBlockDate = Date(timeIntervalSinceNow: time)
        if self.endBlockDate == nil || newBlockDate > self.endBlockDate! {
            runOnMainThread {
                self.endBlockDate = newBlockDate
                self.endBlockTimer?.invalidate()
                self.endBlockTimer = Timer.scheduledTimer(
                    timeInterval: time,
                    target: self,
                    selector: #selector(PetDateAFManager.timeoutBlock(sender:)),
                    userInfo: nil,
                    repeats: false
                )
            }
        }
        
        return self.requestBlockable(
            url,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: headers,
            blockable: blockable
        )
    }
    
    @discardableResult func requestBlockUntilResponse(_ url: URLConvertible, method: HTTPMethod = .get, parameters: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: HTTPHeaders? = nil, blockable: Bool = false, delayAfterResponse: TimeInterval = 1.0) -> DataRequest {
        
        if blockable {
            PostMaster.shared.attemptRequests()
        }
        
        let req = self.requestBlockable(
            url,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: headers,
            blockable: blockable
        )
        
        self.blockingRequests.append(req)
        req.response { _ in
            delay(delayAfterResponse) {
                self.blockingRequests = self.blockingRequests.filter { $0 !== req }
            }
        }
        
        return req
    }
    
    @objc private func timeoutBlock(sender: Timer) {
        if sender !== self.endBlockTimer {
            return
        }
        
        self.endBlockTimer?.invalidate()
        self.endBlockTimer = nil
        self.endBlockDate = nil
        
        self.updateBlocking()
    }
    
    var currentlyBlocking: Bool {
        get {
            if let ebd = self.endBlockDate, Date().timeIntervalSince1970 > ebd.timeIntervalSince1970 {
                self.endBlockDate = nil
                self.endBlockTimer?.invalidate()
                self.endBlockTimer = nil
            }
            return !self.blockingRequests.isEmpty || self.endBlockDate != nil
        }
    }
    
    private func updateBlocking() {
        if !self.currentlyBlocking {
            for req in self.waitingRequests {
                req.resume()
            }
            self.waitingRequests.removeAll()
        }
    }
    
}

