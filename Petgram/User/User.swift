//
//  User.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import Foundation
import UIKit
import LeanCloud
import Alamofire
import SwiftyJSON
import FBSDKLoginKit
import FBSDKCoreKit

public struct MyError: Error {
    let msg: String
    
}

extension MyError: LocalizedError {
    public var errorDescription: String? {
        return NSLocalizedString(msg, comment: "")
    }
}

enum LeanCloudApiInfo: String {
    case appId = "PCxTurFECyz1zAW9Wg1jcgtC-MdYXbMMI"
    case appKey = "SyD1iI6XVuqouStLQ9uxgkDj"
    case apiBaseUrl = "https://us-api.leancloud.cn/1.1"
    case jsonHeader = "application/json"
    case objectId = "objectId"
}

@objc protocol UserImageListener {
    func userDidSetProfileImage(_ user: User)
}

protocol UserNeeded {
    var user: User? {get set}
}



extension NSNotification.Name {
    static let userInfoDidUpdated = NSNotification.Name("userInfoDidUpdated")
}


class User: NSObject, NSCoding {
    
    
    // MARK: Signup and Loggin
    
    class func exists(email: String, callback: @escaping (Error?, Bool) ->()) {
        let url = LeanCloudApiInfo.apiBaseUrl.rawValue + "/users"
        
        //        let emailParam = ["where": "{\"email\": \"\(email)\"}"]
        let emailParam = ["email": email]
        
        Alamofire.request(
            url,
            method: .post,
            parameters: emailParam,
            encoding: JSONEncoding.default,
            headers: User.lcHeaders).responseJSON { response in
                switch response.result {
                case .failure(let error):
                    callback(error, false)
                    break
                case .success(let data):
                    //203 represents email has been used in lc
                    //202 represents usernmae has been used in lc
                    let code = JSON(data)["code"]
                    let exist = code == 203 || code == 202
                    callback(nil, exist)
                    break
                }
        }
        
        //        //Query Way
        //        let emailParam = ["where": "{\"email\": \"\(email)\"}"]
        //        Alamofire.request(
        //            url,
        //            method: .get,
        //            parameters: emailParam,
        //            encoding: JSONEncoding.default,
        //            headers: User.lcHeaders).responseJSON { response in
        //                switch response.result {
        //                case .failure(let error):
        //                    callback(error, false)
        //                    break
        //                case .success(let data):
        //                    //203 represents email has been used in lc
        //                    //202 represents usernmae has been used in lc
        //                    let objectId = JSON(data)[LeanCloudApiInfo.objectId.rawValue].string
        //                    if objectId == nil {
        //                        callback(nil, false)
        //                    } else {
        //                        callback(nil, true)
        //                    }
        //                }
        //        }
        
        
    }
    
    //Sign up with email
    class func signUp(email: String, petName: String, password: String, callback: @escaping (Error?, User?) -> ()) {
        
        var params = [String: Any]()
        params[LCUserClassKey.email.rawValue] = email
        params[LCUserClassKey.email.rawValue] = email
        //LeanCloud does not support login with email, so we set email and username same to check login
        params[LCUserClassKey.username.rawValue] = email
        params[LCUserClassKey.password.rawValue] = password
        
        params[LCUserClassKey.petName.rawValue] = petName
        
        //get cur date
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "YYYY-MM-dd"
        params[LCUserClassKey.petAdoptDate.rawValue] = dateFormat.string(from: Date.init())
        
        //        //Default Pet Stats
        //        params["pet_city"] = "Unknown"
        //        params["pet_breed"] = "Unknown"
        //        params["pet_gender"] = "Unknown"
        
        //User Device and Time Zone
        params[LCUserClassKey.deviceId.rawValue] = UIDevice.current.identifierForVendor?.uuidString
        params[LCUserClassKey.timezone.rawValue] = TimeZone.current.secondsFromGMT() / 60 / 60
        
        let url = LeanCloudApiInfo.apiBaseUrl.rawValue + "/users"
        
        Alamofire.request(
            url,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: User.lcHeaders
            ).responseJSON { response in
                switch response.result {
                case .failure(let error):
                    callback(error, nil)
                case .success(let data):
                    let json = JSON(data)
                    let sessionToken = json[LCUserClassKey.sessionToken.rawValue].string
                    let user = User(json: json, token: sessionToken)
                    user?.password = password
                    callback(nil, user)
                    
                    Logger.log("User Sign Up. \n \(JSON(data))", logType: .actionLog)
                }
        }
    }
    
    class func login(email: String, password: String, callback: @escaping(Error?, String?, User?) -> ()) {
        var params = [String: Any]()
        params[LCUserClassKey.username.rawValue] = email
        //        params["username"] = userName
        params[LCUserClassKey.password.rawValue] = password
        
        let url = LeanCloudApiInfo.apiBaseUrl.rawValue + "/login"
        
        Alamofire.request(
            url,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: User.lcHeaders
            ).responseJSON { response in
                switch response.result {
                case .failure(let error):
                    callback(error, nil, nil)
                case .success(let data):
                    let json = JSON(data)
                    if json[LCUserClassKey.objectId.rawValue].string != nil {
                        let sessionToken = json[LCUserClassKey.sessionToken.rawValue].string
                        let user = User(json: json, token: sessionToken)
                        user?.password = password
                        
                        callback(nil, nil, user)
                        Logger.log("User logged in.\n \(json)", logType: .actionLog)
                        
                    }
                    else if json["code"] == 210 {
                        // TODO: Localize String
                        callback(nil, "Username and passwod not matched", nil)
                    }
                    else {
                        callback(nil, json["error"].stringValue, nil)
                    }
                    
                }
        }
    }
    
    class func login(with fbToken: FBSDKAccessToken, callback: @escaping(Error?, User?) ->()) {
        let userId = fbToken.userID
        let tokenString = fbToken.tokenString
        let expirationDate = fbToken.expirationDate
        
        let params: Parameters = [
            "authData": [
                "facebook": [
                    "uid": userId,
                    "access_token": tokenString
                    //                    "expires_in": expirationDate
                ]
            ]
        ]
        
        let url = LeanCloudApiInfo.apiBaseUrl.rawValue + "/users"
        Alamofire.request(
            url,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: User.lcHeaders
            ).responseJSON { (response) in
                switch response.result {
                case .failure(let error):
                    Logger.log("User.signupWith(facebookToken) failed.\n\(error)", logType: .error)
                    callback(error, nil)
                case .success(let data):
                    let json = JSON(data)
                    let code = response.response?.statusCode
                    //201 means new user created
                    if code == 201 {
                        let sessionToken = json[LCUserClassKey.sessionToken.rawValue].string
                        let user = User(json: json, token: sessionToken)
                        user?.setNewUserInfo(with: fbToken)
                    }
                        //200 means user exisited
                    else if code == 200 {
                        let sessionToken = json[LCUserClassKey.sessionToken.rawValue].string
                        let user = User(json: json, token: sessionToken)
                        callback(nil, user)
                    }
                    Logger.log("Status Code Wrong: \(String(describing: code))", logType: .error)
                    callback(NSError(), nil)
                }
        }
    }
    
    func setNewUserInfo(with fbToken: FBSDKAccessToken) {
        let url = "https://graph.facebook.com/me"
        let params: Parameters = [
            "fields": "name,email,picture",
            "access_token": fbToken.tokenString
        ]
        
        Alamofire.request(
            url,
            method: .get,
            parameters: params
            ).responseJSON { (response) in
                switch response.result {
                case .failure(let error):
                    Logger.log("Getting UserInfo from Graph API failed. Error: \n\(error)", logType: .error)
                case .success(let data):
                    let json = JSON(data)
                    print("JSON:    \n\(json)")
                    if let petName = json["name"].string {
                        self.setProfile(key: LCUserClassKey.petName.rawValue, value: petName + "的宠物", completion: { (succeed) in
                            // Currently does not handle error
                        })
                    }
                    if let email = json["email"].string {
                        self.setProfile(key: LCUserClassKey.email.rawValue, value: email, completion: { (succeed) in
                            // Currently does not handle error
                        })
                    }
                    if let avatarUrl = json["picture"]["data"]["url"].string {
                        ImageDownloadManager.shared.downloadImage(from: avatarUrl, completion: { (image, instant) in
                            guard let image = image else {
                                Logger.log("Download Avatar From Facebook Failed. Url: \(avatarUrl)", logType: .error)
                                return
                            }
                            self.set(profileImage: image, completion: { (succeed) in
                                // Currently does not handle error
                            })
                        })
                    }
                    
                    
                }
        }
    }
    
    
    //    func updateInfo(with facebookToken: FBSDKAccessToken, completion: @escaping(Bool)->()) {
    //
    //        let url = "https://graph.facebook.com/me"
    //        let params: Parameters = [
    //            "fields": "name,email,picture",
    //            "access_token": facebookToken.tokenString
    //        ]
    //
    //        Alamofire.request(
    //            url,
    //            method: .get,
    //            parameters: params
    //        ).responseJSON { (response) in
    //            switch response.result {
    //            case .failure(let error):
    //
    //            case .success(let data):
    //                let json = JSON(data)
    //                let name = json["name"]
    //                let email =
    //            }
    //        }
    //
    //        self.authenticatedAFManager.request(
    //            url,
    //            method: .put,
    //            parameters: params,
    //            encoding: JSONEncoding.default).responseJSON{ (response) in
    //                switch response.result {
    //                case .failure(let error):
    //                    Logger.log(error, logType: .error)
    //                    completion(false)
    //                case .success(let data):
    //                    //Leancloud has extra authorization, so we check return result
    //                    //To make sure the data in _User class is updated
    //                    guard JSON(data)[LCUserClassKey.objectId.rawValue].string != nil else {
    //                        completion(false)
    //                        return
    //                    }
    //                    self.getUserInfo(withId: self.id, callback: { (userInfo) in
    //                        guard let userInfo = userInfo else {
    //                            completion(false)
    //                            return
    //                        }
    //                        self.setUpWith(userInfo: userInfo)
    //                        completion(true)
    //                    })
    //                }
    //        }
    //
    //    }
    
    
    
    static let lcHeaders: HTTPHeaders = [
        "X-LC-Id": LeanCloudApiInfo.appId.rawValue,
        "X-LC-Key": LeanCloudApiInfo.appKey.rawValue,
        "Content-Type": LeanCloudApiInfo.jsonHeader.rawValue
    ]
    
    
    class func clearSavedUser() {
        UserDefaults.standard.set(nil, forKey: userKey)
    }
    
    
    //    //To allow to the access staic member in object c
    //    class func getCurrentUser() -> User? {
    //        return User.current
    //    }
    
    
    
    private(set) var id: String
    private(set) var token: String
    
    private(set) var username: String?
    private(set) var email: String?
    private(set) var password: String?
    private(set) var created: Date?
    

    
    private(set) var petName: String?
    private(set) var petAdoptDate: Date?
    private(set) var petGender: String?
    private(set) var petBreed: String?
    private(set) var petCity: String?
    
    private(set) var followingsCount: Int?
    private(set) var followersCount: Int?
    
    var valid: Bool {
        return self.id != invalidVal && self.token != invalidVal
    }
    
    init?(json: JSON, token: String?) {
        self.id = invalidVal
        self.token = invalidVal
        super.init()
        
        // wrapping this in a closure will cause didset to be called
        ({
            self.token = token ?? invalidVal
            self.setUpWith(userJson: json)
        })()
        
        if !self.valid {
            return nil
        }
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        // NSCoding
        self.id = invalidVal
        self.token = invalidSession
        
        super.init()
        
        // wrapping this in a closure will cause didSet to be called
        ({
            self.id = aDecoder.decodeObject(forKey: idKey) as? String ?? invalidVal
            self.token = aDecoder.decodeObject(forKey: tokenKey) as? String ?? invalidSession
            
            self.email = aDecoder.decodeObject(forKey: emailKey) as? String
            self.petName = aDecoder.decodeObject(forKey: petNameKey) as? String
            
            //            self.profileImage = aDecoder.decodeObject(forKey: profileImageKey) as? UIImage
            
        })()
        
    }
    
    //MARK: Saving and Loaing User
    class func loadUser() -> User? {
        let userDefaults = UserDefaults.standard
        if let encodedUser = userDefaults.object(forKey: userKey) as? Data {
            let user = NSKeyedUnarchiver.unarchiveObject(with: encodedUser) as? User
            if let user = user, user.valid == true {
                user.refresh()
                return user
            }
        }
        
        return nil
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: idKey)
        aCoder.encode(self.token, forKey: tokenKey)
        
        aCoder.encode(self.username, forKey: userNameKey)
        aCoder.encode(self.password, forKey: passwordKey)
        
        //        aCoder.encode(self.profileImage, forKey: profileImageKey)
    }
    
    func refresh(completion: (() -> ())? = nil) {
        
        //        //        let url = LeanCloudApiInfo.apiBaseUrl.rawValue + "/users" + "/\(self.id)"
        //
        //        guard let username = self.username, let password = self.password else {
        //            // TODO: Require reloggin just in case in the future
        //            return
        //        }
        //
        //        let loginUrl = LeanCloudApiInfo.apiBaseUrl.rawValue + "/login"
        //        let params: [String: Any] = [
        //            LCUserClassKey.username.rawValue: username,
        //            LCUserClassKey.password.rawValue: password]
        //
        //        self.authenticatedAFManager.request(
        //            loginUrl,
        //            method: .post,
        //            parameters: params,
        //            encoding:JSONEncoding.default
        //            ).responseJSON { (response) in
        //                defer {
        //                    completion?()
        //                }
        //                if let data: Any = response.result.value {
        //                    let json = JSON(data)
        //                    self.update(withJSON: json)
        //                    Logger.log("User refresh.\n\(json)", logType: .actionLog)
        //                    if self === PetDateController.shared.user {
        //                        self.saveUser()
        //                    }
        //                }
        //        }
        
        self.getUserInfo(withId: self.id) { (userInfo) in
            guard let userInfo = userInfo else {
                return
            }
            self.setUpWith(userInfo: userInfo)
        }
    }
    
    
    func saveUser() {
        let encodedUser = NSKeyedArchiver.archivedData(withRootObject: self)
        let userDefaults = UserDefaults.standard
        userDefaults.set(encodedUser, forKey: userKey)
    }
    
    func setUpWith(userJson json: JSON) {
        
        let id = json[LCUserClassKey.objectId.rawValue]
        self.id = id.number?.stringValue ?? id.string ?? invalidVal
        
        self.email = json[LCUserClassKey.email.rawValue].string
        self.username = json[LCUserClassKey.username.rawValue].string
        
        
        //Pet Stats
        
        self.petName = json[LCUserClassKey.petName.rawValue].string
        self.petBreed = json[LCUserClassKey.petBreed.rawValue].string
        self.petGender = json[LCUserClassKey.petGender.rawValue].string
        self.petCity = json[LCUserClassKey.petCity.rawValue].string
        self.petAdoptDate = json[LCUserClassKey.petAdoptDate.rawValue].date
        
        if let createdString = json[LCUserClassKey.createdAt.rawValue].string {
            let df = DateFormatter.USDateFormatter()
            df.dateFormat = "YYYY-MM-dd HH:mm:ss"
            self.created = df.date(from: createdString)
        } else {
            self.created = nil
        }
        
        //        let image = json[LCUserClassKey.profileImage.rawValue]
        //        if let imageURL = image["url"].string{
        //            ImageDownloadManager.shared.downloadImage(
        //                from: imageURL,
        //                completion: { image, _ in
        //                    if let image = image {
        //                        self.profileImage = image
        //                    }
        //            })
        //        }
        //        else {
        //            self.profileImage = nil
        //        }
        
        // Notify user info is updated
        
        NotificationCenter.default.post(name: .userInfoDidUpdated, object: nil)
        
    }
    
    func setUpWith(userInfo: UserInfo) {
        
        self.id = userInfo.id
        self.email = userInfo.email
        self.username = userInfo.userName
        
        //Pet Stats
        
        self.petName = userInfo.petName
        self.petBreed = userInfo.petBreed
        self.petGender = userInfo.petGender
        self.petCity = userInfo.petLocation
        self.petAdoptDate = userInfo.petAdopteDate
        
        //        if let createdString = json[LCUserClassKey.createdAt.rawValue].string {
        //            let df = DateFormatter.USDateFormatter()
        //            df.dateFormat = "YYYY-MM-dd HH:mm:ss"
        //            self.created = df.date(from: createdString)
        //        } else {
        //            self.created = nil
        //        }
        
        //        if let profileImageUrl = userInfo.avatarUrl {
        //
        //        }
        //
        //        let image = json[LCUserClassKey.profileImage.rawValue]
        //        if let imageURL = image["url"].string{
        //            ImageDownloadManager.shared.downloadImage(
        //                from: imageURL,
        //                completion: { image, _ in
        //                    if let image = image {
        //                        self.profileImage = image
        //                    }
        //            })
        //        }
        //        else {
        //            self.profileImage = nil
        //        }
        
        // Notify user info is updated
        
        NotificationCenter.default.post(name: .userInfoDidUpdated, object: nil)
        
    }
    
    
    
    
    
    
    
    
    
    // MARK: Alamofire Manager
    private var manager: PetDateAFManager?
    
    var authenticatedAFManager: PetDateAFManager {
        if let man = self.manager {
            return man
        } else {
            let manager = PetDateAFManager.authenticatedManager(withSessionToken: self.token)
            self.manager = manager
            return manager
        }
    }
    
    private var uploadManager: Alamofire.SessionManager?
    
    var authenticatedAFUploadManager: Alamofire.SessionManager {
        if let manager = self.uploadManager {
            return manager
        } else {
            let config = URLSessionConfiguration.default
            config.httpAdditionalHeaders = [
                "X-LC-Id": LeanCloudApiInfo.appId.rawValue,
                "X-LC-Key": LeanCloudApiInfo.appKey.rawValue,
                "Content-Type": "image/png"]
            let manager = Alamofire.SessionManager(configuration: config)
            self.uploadManager = manager
            return manager
        }
    }
    
    
    // MARK: Update _User table with key and new value
    
    func setProfile(key: String, value: Any, completion: @escaping  (Bool) -> ()) {
        
        let url = LeanCloudApiInfo.apiBaseUrl.rawValue + "/users" + "/\(self.id)"
        let params: [String: Any] = [key: value]
        
        self.authenticatedAFManager.request(
            url,
            method: .put,
            parameters: params,
            encoding: JSONEncoding.default).responseJSON{ (response) in
                switch response.result {
                case .failure(let error):
                    Logger.log(error, logType: .error)
                    completion(false)
                case .success(let data):
                    //Leancloud has extra authorization, so we check return result
                    //To make sure the data in _User class is updated
                    guard JSON(data)[LCUserClassKey.objectId.rawValue].string != nil else {
                        completion(false)
                        return
                    }
                    self.getUserInfo(withId: self.id, callback: { (userInfo) in
                        guard let userInfo = userInfo else {
                            completion(false)
                            return
                        }
                        self.setUpWith(userInfo: userInfo)
                        completion(true)
                    })
                }
        }
        
    }
    
    func getUserInfo(withId userId: String, callback: @escaping (UserInfo?) -> ()) {
        let url = LeanCloudApiInfo.apiBaseUrl.rawValue + "/users/" + userId
        self.authenticatedAFManager.request(url).responseJSON { (response) in
            switch response.result {
            case .failure(let error):
                Logger.log("Update User Info failed!\n \(error)", logType: .error)
                callback(nil)
            case .success(let data):
                let userJson = JSON(data)
                guard let id = userJson["objectId"].string else {
                    callback(nil)
                    return
                }
                callback(UserInfo(withId: id, userJson: userJson))
            }
        }
        
    }
    
    
    
    // MARK: Profile Image
    static let defaultProfileImage = #imageLiteral(resourceName: "profile_no_picture")
    
    //    var profileImage: UIImage? {
    //        didSet {
    //            for weakListener in self.imageListeners {
    //                weakListener.value?.userDidSetProfileImage(self)
    //            }
    //        }
    //    }
    
    static let defualtProfileImage = #imageLiteral(resourceName: "profile_no_picture")
    private var imageListeners = [Weak<UserImageListener>]()
    
    func add(imageListener listener: UserImageListener) {
        self.imageListeners.append(Weak(value: listener))
    }
    func remove(imageListener listener: UserImageListener) {
        self.imageListeners = self.imageListeners.filter { $0.value !== listener }
    }
    
    // not sure why but won't upload with authenticatedAFManager
    
    func set(profileImage image: UIImage, completion: @escaping (Bool) -> ()) {
        
        //        let oldImage = self.profileImage
        
        let scaled: UIImage
        if image.size.width > 500 {
            let size = CGSize(width: 250, height: 250)
            UIGraphicsBeginImageContext(size)
            image.draw(in: CGRect(origin: .zero, size: size))
            scaled = UIGraphicsGetImageFromCurrentImageContext()!
        } else {
            scaled = image
        }
        
        //Set profile Image with scaled one, will replace to old profile image if failed to upload
        //        self.profileImage = scaled
        
        //Upload File to Server
        self.uploadFile(image: image) { (imageInfoJson) in
            guard let json = imageInfoJson else {
                //                self.profileImage = oldImage
                Logger.log("Failed to set user Profile Image", logType: .error)
                completion(false)
                return
            }
            
            var fileValues = [String: Any]()
            fileValues["id"] = json[LeanCloudApiInfo.objectId.rawValue].string
            fileValues["__type"] = "File"
            
            //Connect Image File to _User class table in LeanCloud
            self.setProfile(key: LCUserClassKey.profileImage.rawValue, value: fileValues, completion: { (completed) in
                completion(completed)
            })
            
        }
    }
    
    
    func uploadFile(image: UIImage, callback: @escaping(JSON?) -> ()) {
        
        guard let jpg = image.pngData() else {
            callback(false)
            return
        }
        
        let fileName = "\(self.username ?? "")Image.png"
        let url = LeanCloudApiInfo.apiBaseUrl.rawValue + "/files/" + fileName
        
        self.authenticatedAFUploadManager.upload(jpg, to: url).responseJSON { (response) in
            
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                //Make sure we upload the file to LeanCloud successfully
                guard json[LeanCloudApiInfo.objectId.rawValue].string != nil else {
                    Logger.log("Failed to upload Image File to Server\n Returned Json: \(json))", logType: .error)
                    callback(nil)
                    return
                }
                callback(json)
            case .failure(let error):
                Logger.log("Failed to upload Image File to Server\n Error Detail: \(error))", logType: .error)
                callback(nil)
            }
            
        }
    }
    
    
    
    // MARK: Upload Post
    
    func postToFollowers(image: UIImage, message: String?, success: @escaping(Bool) -> ()) {
        self.uploadFile(image: image) { (imageJson) in
            guard let json = imageJson else {
                success(false)
                return
            }
            guard let imageUrl = json["url"].string else {
                Logger.log("No Image Url returned after uploading File. Original Json: \(json)", logType: .error)
                success(false)
                return
            }
            self.postStatusToFollowers(imageUrl: imageUrl, message: message, completion: { (succeedToPostFollowers) in
                guard succeedToPostFollowers else {
                    success(false)
                    return
                }
                self.postStatusToSelf(imageUrl: imageUrl, message: message, completion: { (succeedToPostSelf) in
                    success(succeedToPostSelf)
                })
            })
        }
    }
    
    private func postStatusToFollowers(imageUrl: String, message: String?, completion: @escaping (Bool) -> ()) {
        
        let url = LeanCloudApiInfo.apiBaseUrl.rawValue + "/statuses"
        
        let params: Parameters = [
            "data":  [
                "imageUrl": imageUrl,
                "message": message ?? "",
                
                "owner":
                    ["__type": "Pointer",
                     "className": "_User",
                     "objectId":"\(self.id)"
                ]
            ],
            
            "query": [
                "className": "_Follower",
                "keys": "follower",
                "where": [
                    "user": [
                        "__type": "Pointer",
                        "className": "_User",
                        "objectId": "\(self.id)"
                    ]
                ]
            ]
        ]
        
        self.authenticatedAFManager.request(
            url,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default
            ).responseJSON { (response) in
                switch response.result {
                case .failure(let error):
                    Logger.log("Failed to Post Status. Error Info:\n\(error)", logType: .error)
                    completion(false)
                case .success(let data):
                    let json = JSON(data)
                    if json["objectId"].string == nil {
                        Logger.log("No ObjectId found after posing status. Retuerned Json\n\(json)", logType: .error)
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
        }
        
    }
    
    //Add status to self manually due to lack of corresponding Rest API methods provided by LeanCloud
    private func postStatusToSelf(imageUrl: String, message: String?, completion: @escaping(Bool) -> ()) {
        
        let url = LeanCloudApiInfo.apiBaseUrl.rawValue + "/classes/SelfPost"
        let params: Parameters = [
            "owner":
                ["__type": "Pointer",
                 "className": "_User",
                 "objectId":"\(self.id)"
            ],
            
            "imageUrl": imageUrl,
            "message": message ?? ""
            
        ]
        
        self.authenticatedAFManager.request(
            url,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default
            ).responseJSON { (response) in
                switch response.result {
                case .failure(let error):
                    Logger.log("Failed to Post Status To Self. Error Info:\n\(error)", logType: .error)
                    completion(false)
                case .success(let data):
                    let json = JSON(data)
                    if json["objectId"].string == nil {
                        Logger.log("No ObjectId found after posing status to self. Retuerned Json\n\(json)", logType: .error)
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
        }
    }
    
    
    // MARK: Fetch Posts
    
    func fetchFollowingsHomePosts(callback: @escaping(Error?, [HomePost]?) -> ()) {
        self.getFollowersAndFollowees(of: self.id) { (followersInfo, followeesInfo) in
            guard let followingsInfo = followeesInfo else {
                callback(MyError(msg: "Cannot fetch current user's timeline"), nil)
                return
            }
            
            var ids : [String] = []
            for folloingInfo in followingsInfo {
                ids.append(folloingInfo.id)
            }
            
            let url = LeanCloudApiInfo.apiBaseUrl.rawValue + "/classes/_status"
            
            let params: Parameters = [
                "include": "owner", //to get the data from pointer "owner" in returned json
                "order": "-createdAt"
            ]
            
            
            self.authenticatedAFManager.request(
                url,
                method: .get,
                parameters: params
            ).responseJSON { (response) in
                    switch response.result {
                    case .failure(let error):
                        Logger.log("Failed to fetch user timeline. Error Detail:\n\(error)", logType: .error)
                        
                        callback(error, nil)
                        
                    case .success(let data):
                        guard let resultArrayJson = JSON(data)["results"].array, resultArrayJson.count > 0 else {
                            Logger.log("Timnline (for user id: \(self.id) ) is empty. Returned Json:\n\(JSON(data))", logType: .error)
                            
                            callback(nil, nil)
                            return
                        }
                        
                        Logger.log("fetchTimeLine() Result json: \n\(JSON(data))", logType: .actionLog)
                        
                        var homePosts: [HomePost] = []
                        for postJson in resultArrayJson {
                            guard
                                let postId = postJson["objectId"].string,
                                let userId = postJson["owner"]["objectId"].string else {
                                    continue
                            }
                            
                            //only getting following's posts
                            if !ids.contains(userId) {
                                continue
                            }
                            
                            let post = Post(withId: postId, postJson: postJson)
                            let userInfo = UserInfo(withId: userId, userJson: postJson["owner"])
                            
                            let homePost = HomePost(userInfo: userInfo, post: post)
                            homePosts.append(homePost)
                        }
                        
                        callback(nil, homePosts)
                        
                    }
                    
            }
        }
    }
    
   
    
    func fetchTimeLine(callback: @escaping(Error?, [HomePost]?) -> ()) {
        let url = LeanCloudApiInfo.apiBaseUrl.rawValue + "/subscribe/statuses"
        let params: Parameters = [
            
            "owner": [
                "__type": "Pointer",
                "className": "_User",
                "objectId": "\(self.id)"
            ],
            
            "include": "owner"
        ]
        
        self.authenticatedAFManager.request(
            url,
            method: .get,
            parameters: params
            ).responseJSON { (response) in
                switch response.result {
                case .failure(let error):
                    Logger.log("Failed to fetch user timeline. Error Detail:\n\(error)", logType: .error)
                    
                    callback(error, nil)
                    
                case .success(let data):
                    guard let resultArrayJson = JSON(data)["results"].array, resultArrayJson.count > 0 else {
                        Logger.log("Timnline (for user id: \(self.id) ) is empty. Returned Json:\n\(JSON(data))", logType: .error)
                        
                        callback(nil, nil)
                        return
                    }
                    
                    Logger.log("fetchTimeLine() Result json: \n\(JSON(data))", logType: .actionLog)
                    
                    var homePosts: [HomePost] = []
                    for postJson in resultArrayJson {
                        guard let postId = postJson["objectId"].string,
                            let userId = postJson["owner"]["objectId"].string else {
                                continue
                        }
                        let post = Post(withId: postId, postJson: postJson)
                        let userInfo = UserInfo(withId: userId, userJson: postJson["owner"])
                        
                        let homePost = HomePost(userInfo: userInfo, post: post)
                        homePosts.append(homePost)
                    }
                    
                    callback(nil, homePosts)
                    
                }
                
        }
    }
    
    func fetchPosts(of userId: String, callback: @escaping([Post]?) -> ()) {
        
        let url = LeanCloudApiInfo.apiBaseUrl.rawValue + "/classes/_Status"
        let params: Parameters = [
            "where": [
                "owner": [
                    "__type": "Pointer",
                    "className": "_User",
                    "objectId": "\(userId)"
                ]
            ],
            "order": "-createdAt"
        ]
        
        self.authenticatedAFManager.request(
            url,
            method: .get,
            parameters: params
            ).responseJSON { (response) in
                switch response.result {
                case .failure(let error):
                    Logger.log("Failed to fetch posts of user id \(userId).\nError Detail\n\(error)", logType: .error)
                    
                    callback(nil)
                    
                case .success(let data):
                    guard let resultArray = JSON(data)["results"].array else {
                        Logger.log("Result of self post for user id \(userId) is empty. Returned Json:\n\(JSON(data))", logType: .error)
                        
                        callback(nil)
                        return
                    }
                    //                    Logger.log("fetchPosts() Returned Json: \n\(JSON(data))", logType: .actionLog)
                    var posts: [Post] = []
                    for postJson in resultArray {
                        guard let id = postJson["objectId"].string else {
                            continue
                        }
                        let post = Post(withId: id, postJson: postJson)
                        posts.append(post)
                    }
                    
                    callback(posts)
                    
                }
        }
        
    }
    
    // MARK: Like Or Dislike Status
    func like(post: Post) {
        
        self.getSelfLike(for: post) { (liked, _) in
            guard let liked = liked, !liked else {
                // TODO: Handle Error: no connection
                //User already liked this post, no need to like it again
                return
            }
            
            let url = LeanCloudApiInfo.apiBaseUrl.rawValue + "/classes" + "/Like"
            let params: Parameters = [
                
                "user": [
                    "__type": "Pointer",
                    "className": "_User",
                    "objectId": "\(self.id)"],
                
                "status": [
                    "__type": "Pointer",
                    "className": "_Status",
                    "objectId": "\(post.id)"]
                
            ]
            
            self.authenticatedAFManager.request(
                url,
                method: .post,
                parameters: params,
                encoding: JSONEncoding.default
                ).responseJSON { (response) in
                    switch response.result {
                    case .failure(let error):
                        Logger.log("Like Post Failed. Error: \n\(error)", logType: .error)
                        
                    case .success(let data):
                        Logger.log("Posting To Like Class Result: \n\(JSON(data)).", logType: .actionLog)
                    }
            }
            
        }
        
    }
    
    func dislike(post: Post) {
        
        self.getSelfLike(for: post) { (liked, resultJson) in
            guard let liked = liked, liked else {
                //No like record found, no need to dislike then
                return
            }
            
            guard let objectId = resultJson?.array?.first?["objectId"].string else {
                return
            }
//            self.delete(objectId: objectId, inClass: "Like")
            self.delete(objectId: objectId, inClass: "Like")
        }
        
        
        
    }
    
    
    //Get user's Like Status
    func getSelfLike(for post: Post, callback: @escaping (Bool?, JSON?) -> ()) {
        let url = LeanCloudApiInfo.apiBaseUrl.rawValue + "/classes" + "/Like"
        
        let queryValue = [
            "$and": [
                ["user": ["__type":"Pointer","className":"_User","objectId":"\(self.id)"]],
                ["status": ["__type":"Pointer","className":"_Status","objectId":"\(post.id)"]]
            ]
        ]
        
        
        let params: Parameters = ["where": JSON(queryValue)]
        
        self.authenticatedAFManager.request(
            url,
            method: .get,
            parameters: params
            ).responseJSON { (response) in
                switch response.result {
                case .failure(let error):
                    Logger.log("Get Like Status Failed. Error Detail: \n\(error)", logType: .error)
                    callback(nil, nil)
                case .success(let data):
                    let resultJson = JSON(data)["results"]
                    let liked = resultJson.count != 0
                    //                    Logger.log("resultJson in GetLikeStatus \(resultJson)", logType: .actionLog)
                    callback(liked, resultJson)
                }
        }
    }
    
    //Get Liked User For A Post
    func getLikedUsers(for post: Post, limitCount: Int = 100, callback: @escaping ([UserInfo]?) -> ()) {
        
        let url = LeanCloudApiInfo.apiBaseUrl.rawValue + "/classes" + "/Like"
        
        let params: Parameters = [
            "where": ["status": ["__type":"Pointer","className":"_Status","objectId":"\(post.id)"]],
            "include": "user",
            "keys": "user",
            "limit": "\(limitCount)", //LeanCloud Default Query Limit is 100
            "order": "-createdAt"
        ]
        
        self.authenticatedAFManager.request(
            url,
            method: .get,
            parameters: params
            ).responseJSON { (response) in
                switch response.result {
                case .failure(let error):
                    Logger.log("getLikedUsers() failed: \n\(error)", logType: .error)
                    callback(nil)
                case .success(let data):
                    //                    Logger.log("getLikedUsers() returned Json: \n\(JSON(data))", logType: .actionLog)
                    let resultArray = JSON(data)["results"].array ?? []
                    var usersInfo: [UserInfo] = []
                    for json in resultArray {
                        guard let id = json["user"]["objectId"].string else {
                            continue
                        }
                        let userInfo = UserInfo(withId: id, userJson: json["user"])
                        usersInfo.append(userInfo)
                    }
                    
                    callback(usersInfo)
                }
        }
    }
    
    
    
    // MARK: Delete from Leancloud Table
    func delete(objectId: String, inClass className: String) {
        let url = LeanCloudApiInfo.apiBaseUrl.rawValue + "/classes/" + className + "/" + objectId
        self.authenticatedAFManager.request(
            url,
            method: .delete
            ).responseJSON { (response) in
                switch response.result {
                case .success(_):
                    Logger.log("Delete ObjectId: \(objectId) in class \(className) Successfully!", logType: .actionLog)
                case .failure(let error):
                    Logger.log("Delete ObjectId: \(objectId) in class \(className) Failed! Error Detail: \n\(error)", logType: .error)
                }
        }
    }
    
    
    
    
    // MARK: Users Relationship
    func getFollowersAndFollowees(of userId: String, callback: @escaping (_ followers: [UserInfo]?, _ followees: [UserInfo]?) -> ()) {
        
        //        if let stats = self.stats {
        //            callback(stats, true)
        //            return
        //        }
        
        let url = LeanCloudApiInfo.apiBaseUrl.rawValue + "/users" + "/\(userId)" + "/followersAndFollowees"
        
        self.authenticatedAFManager.request(
            url,
            method: .get
            ).responseJSON { (response) in
                switch response.result {
                case .failure(let error):
                    Logger.log("getFollowersAndFollowees() failed: \n\(error)", logType: .error)
                    callback(nil, nil)
                case .success(let data):
                    let resultJson = JSON(data)
                    
                    let followersJsonArray = resultJson["followers"].array ?? []
                    var followersInfo: [UserInfo] = []
                    for json in followersJsonArray {
                        guard let id = json["follower"]["objectId"].string else {
                            continue
                        }
                        let follower = UserInfo(withId: id, userJson: json["follower"])
                        followersInfo.append(follower)
                    }
                    
                    let followeesJsonArray = resultJson["followees"].array ?? []
                    var followeesInfo: [UserInfo] = []
                    for json in followeesJsonArray {
                        guard let id = json["followee"]["objectId"].string else {
                            continue
                        }
                        let followee = UserInfo(withId: id, userJson: json["followee"])
                        followeesInfo.append(followee)
                    }
                    
                    callback(followersInfo, followeesInfo)
                }
        }
    }
    
    
    func isFollowing(userId: String? = nil, otherUserId: String, callback: @escaping (Bool?) -> ()) {
        
        let userId = userId ?? self.id
        let url = LeanCloudApiInfo.apiBaseUrl.rawValue + "/classes/_Followee"
        
        let queryValue = [
            "$and": [
                ["user": ["__type":"Pointer","className":"_User","objectId":"\(userId)"]],
                ["followee": ["__type":"Pointer","className":"_User","objectId":"\(otherUserId)"]]
            ]
        ]
        
        
        let params: Parameters = ["where": JSON(queryValue)]
        
        self.authenticatedAFManager.request(
            url,
            method: .get,
            parameters: params
            ).responseJSON { (response) in
                switch response.result {
                case .failure(let error):
                    Logger.log("isFollowing() failed. Erro Detail: \n\(error)", logType: .error)
                    callback(nil)
                case .success(let data):
                    let resultJson = JSON(data)["results"]
                    //                    Logger.log("isFollowing Return Json: \n\(resultJson)", logType: .actionLog)
                    print("count: \(resultJson.count)")
                    callback(resultJson.count == 1)
                }
        }
    }
    
    func follow(_ userId: String, _ follow: Bool, completion: @escaping (Bool) -> ()) {
        let url = LeanCloudApiInfo.apiBaseUrl.rawValue + "/users/" + self.id + "/friendship/" + userId
        
        self.authenticatedAFManager.request(
            url,
            method: follow ? .post : .delete
            ).responseJSON { (response) in
                switch response.result {
                case .failure(let error):
                    Logger.log("follow() failed: \(error)", logType: .error)
                    completion(false)
                case .success(let data):
                    guard JSON(data).isEmpty else {
                        Logger.log("follow() failed. Respnse Json\(JSON(data))", logType: .error)
                        completion(false)
                        return
                    }
                    completion(true)
                }
        }
    }
    
    
    
    
    
    
    
    
    //    //Update user all profile with given LCObject
    //    func updateProfile(with profileObject: LCObject) {
    //        //        let userProfile = userObject.get(LCUserClassKey.userProfile.rawValue)
    //
    //
    //        self.petName = profileObject.get(LCUserProfileKey.petName.rawValue)?.stringValue
    //        self.petBreed = profileObject.get(LCUserProfileKey.petBreed.rawValue)?.stringValue
    //        self.petGender = profileObject.get(LCUserProfileKey.petGender.rawValue)?.stringValue
    //        self.petCity = profileObject.get(LCUserProfileKey.petLocation.rawValue)?.stringValue
    //        self.followersCount = profileObject.get(LCUserProfileKey.followersCount.rawValue)?.intValue
    //        self.followingsCount = profileObject.get(LCUserProfileKey.followingsCount.rawValue)?.intValue
    //        self.petAdoptDate = profileObject.get(LCUserProfileKey.petAdoptDate.rawValue)?.dateValue
    //    }
    
    //    func getPetSpentDaysAsString() -> String? {
    //        guard let adoptDate = self.petAdoptDate else {
    //            return nil
    //        }
    //        return Date().interval(ofComponent: .day, fromDate: adoptDate).description
    //    }
    
    
    
    // MARK: UserStats and PetStatss
    private var userStats: UserStats?
    
    func followedOther() {
        self.userStats?.followingsCount += 1
    }
    
    func unFollowedOther() {
        self.userStats?.followingsCount -= 1
    }
    
    
    
    
    
    
    
    // MARK: Other Class Func
    class func requestResetPassword(forEmail email: String, callback: @escaping (Bool) -> ()) {
        let url = LeanCloudApiInfo.apiBaseUrl.rawValue + "/requestPasswordReset"
        let params: [String: Any] = ["email": email]
        
        Alamofire.request(
            url,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: User.lcHeaders
            ).responseJSON { response in
                switch response.result {
                case .failure(let error):
                    Logger.log("Request Reset User Password Failed. \n \(error))", logType: .error)
                    callback(false)
                case .success(_):
                    callback(true)
                    Logger.log("Request Password Reset for user: " + email, logType: .actionLog)
                }
        }
        
    }
    
    // MARK: Facebook Connection
    class func requestFacebookToken(completion: @escaping (Alamofire.Result<FBSDKAccessToken>) -> ()) {
        if let token = FBSDKAccessToken.current() {
            completion(.success(token))
        } else {
            let login = FBSDKLoginManager()
            let permissions = ["public_profile", "email"]
            
            login.logIn(
                withReadPermissions: permissions,
                from: nil
            ) { result, error in
                if let token = FBSDKAccessToken.current() {
                    completion(.success(token))
                } else if let error = error {
                    completion(.failure(error))
                } else {
                    completion(
                        .failure(
                            NSError(
                                domain: NSCocoaErrorDomain,
                                code: NSUserCancelledError,
                                userInfo: nil
                            )
                        )
                    )
                }
            }
        }
    }
    
    
}

struct UserStats {
    var followingsCount: Int
    var followersCount: Int
}

struct UserInfo {
    
    let id: String
    
    let email: String?
    let userName: String?
    
    let avatarUrl: String?
    let petName: String?
    let petBreed: String?
    let petLocation: String?
    let petGender: String?
    let petAdopteDate: Date?
    
    init(withId id: String, userJson: JSON) {
        self.id = id
        
        self.email = userJson[LCUserClassKey.email.rawValue].string
        self.userName = userJson[LCUserClassKey.username.rawValue].string
        
        self.avatarUrl = userJson[LCUserClassKey.profileImage.rawValue]["url"].string
        self.petName = userJson[LCUserClassKey.petName.rawValue].string
        self.petBreed = userJson[LCUserClassKey.petBreed.rawValue].string
        self.petLocation = userJson[LCUserClassKey.petCity.rawValue].string
        self.petGender = userJson[LCUserClassKey.petGender.rawValue].string
        self.petAdopteDate = userJson[LCUserClassKey.petAdoptDate.rawValue].date
        
        
    }
    
}

struct Post {
    
    let id: String
    
    let imageUrl: String?
    let postMessage: String?
    let postDateTime: Date?
    
    init(withId id: String, postJson: JSON) {
        
        self.id = id
        self.imageUrl = postJson["imageUrl"].string
        self.postMessage = postJson["message"].string
        self.postDateTime = postJson["createdAt"].dateTime
        
    }
}




//struct PetStats {
//    var petName: String
//    var petAdoptedDate: String
//    var petGender: String
//    var petBreedName: String
//    var petCity: String
//}

private let invalidVal = "-9999"
private let invalidSession = "sdkjlhasjkhdkjashnbdjkas"

private let invalidEmail = "zzzzzzzzz@zzzzzz.com"
private let invalidPassword = "sdsadsa"

let userKey = "user"

private let idKey = "userID"
private let tokenKey = "userToken"
private let createdKey = "userCreated"

private let userNameKey = "userName"
private let emailKey = "userEmail"
private let passwordKey = "passwordKey"

private let petNameKey = "petNameKey"


private let facebookIDKey = "userFacebookID"
private let facebookFirstNameKey = "userFacebookFirstName"
private let facebookLastNameKey = "userFacebookLastName"


private let profileImageKey = "userProfileImage"
