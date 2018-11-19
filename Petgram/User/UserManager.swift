//
//  UserManager.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import Foundation
import LeanCloud
import SwiftyJSON
import Alamofire

enum UserManagerError {
    case userNotCreatedError
    case defaultError
    case serverError
    case leanCloudError (String)
    
    
    var description: String {
        get {
            switch self {
            case .userNotCreatedError:
                return "User has not been created"
                
            case .defaultError:
                return "UserManager Default Error"
                
            case .serverError:
                return "Server Error"
                
            case .leanCloudError(let detail):
                return "LeanCloud Error" + detail
            }
        }
    }
}

enum LCUserClassKey: String {
    //    case userProfile = "userProfile"
    case sessionToken = "sessionToken"
    case objectId = "objectId"
    case username = "username"
    case email = "email"
    case password = "password"
    case createdAt = "createdAt"
    //    case user = "user"
    case petName = "pet_name"
    case petBreed = "pet_breed"
    case petAdoptDate = "pet_adopt_date"
    case petGender = "pet_gender"
    case petCity = "pet_city"
    //    case followersCount = "followers_count"
    //    case followingsCount = "followings_count"
    case profileImage = "profile_image"
    
    case deviceId = "deviceID"
    case timezone = "timezone"
    
    case undefined = ""
}

enum LCClassName:String {
    case users = "_User"
    case userProfile = "UserProfile"
}
