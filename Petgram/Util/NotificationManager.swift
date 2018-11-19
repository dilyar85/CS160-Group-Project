//
//  NotificationManager.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import Localytics


class NotificationManager {
    
    static let shared = NotificationManager()
    
    static var notificationPermissionGranted: Bool {
        guard let settings = UIApplication.shared.currentUserNotificationSettings else {
            return false
        }
        return !settings.types.isEmpty
    }
    
    func requestNotificationPermissionIfNecessary() {
        
        if #available(iOS 10, *) {
            let options: UNAuthorizationOptions = [.badge, .alert, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
                Localytics.didRequestUserNotificationAuthorization(
                    withOptions: options.rawValue,
                    granted: granted
                )
            }
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            let types: UIUserNotificationType = [.sound, .alert, .badge]
            let settings = UIUserNotificationSettings(types: types, categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        
    }
    
}
