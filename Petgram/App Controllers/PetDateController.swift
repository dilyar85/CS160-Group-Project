//
//  PetDateController.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import Foundation
import UIKit

class PetDateController {
    
    static let shared = PetDateController()
    
    
    var user: User? {
        didSet {
            PostMaster.shared.user = user
            if let user = self.user {
                user.saveUser()
                // save device info token
                UIApplication.shared.registerForRemoteNotifications()
                
            } else {
                User.clearSavedUser()
                UIApplication.shared.unregisterForRemoteNotifications()
            }
            
            //            // post user status notification
            //            NotificationCenter.default.post(
            //                name: .userStatusDidChange,
            //                object: user
            //            )
            
        }
    }
    
    var masterViewController: MasterViewController?
    
    var containerViewController: ContainerViewController? {
        return self.masterViewController?.containerViewController
    }
    
    
    var topMostViewController: UIViewController? {
        if let vc = self.containerViewController?.currentTopVC {
            return vc
        } else if let vc = UIApplication.shared.keyWindow?.rootViewController {
            if let nvc = vc as? UINavigationController {
                return nvc.viewControllers.last ?? nvc
            } else {
                return vc
            }
        } else {
            return nil
        }
    }
    
    
}

