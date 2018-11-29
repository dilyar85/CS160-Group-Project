//
//  AppDelegate.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import UIKit
import CoreData
import LeanCloud
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    static var shared: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    
    // TODO: Add analytics stuff in the future
    private func globalSetup(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        //LeanCloud setup
        LCApplication.default.set(
            id:  "PCxTurFECyz1zAW9Wg1jcgtC-MdYXbMMI", /* Your app ID */
            key: "SyD1iI6XVuqouStLQ9uxgkDj" /* Your app key */
        )
        
        
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        
        self.globalSetup(application: application, launchOptions: launchOptions)
        
        let user = User.loadUser()
        
        if user == nil {
            // no saved user
            let connectRootVC = connectStoryboard.instantiateInitialViewController() as! ConnectNavigationViewController
            self.window?.rootViewController = connectRootVC
        } else {
            
            
            PetDateController.shared.user = user
            let masterVC = mainStoryboard.instantiateInitialViewController() as! MasterViewController
            PetDateController.shared.masterViewController = masterVC
            
            self.window?.rootViewController = masterVC
            NotificationManager.shared.requestNotificationPermissionIfNecessary()
        }
        
        
        
        
        self.window?.makeKeyAndVisible()
        
        //Facebook Login
        FBSDKApplicationDelegate.sharedInstance().application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
        let annotation = options[UIApplication.OpenURLOptionsKey.annotation]
        
        
        let handledByFacebook = FBSDKApplicationDelegate.sharedInstance().application(
            app,
            open: url,
            sourceApplication: sourceApplication,
            annotation: annotation
        )
        return handledByFacebook
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        
        PetDateController.shared.user?.saveUser()
        
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "PetDate")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    
    
}

// MARK: - Transition
extension AppDelegate {
    
    func transitionToConnection(registerData: Any? = nil) {
        
        runOnMainThread {
            let connectRootVC = connectStoryboard.instantiateInitialViewController() as! ConnectNavigationViewController
            self.window?.rootViewController = connectRootVC
            
        }
        
    }
    
    
    func transitionToMain(user: User) {
        
        guard let window = self.window else {
            return
        }
        
        PetDateController.shared.user = user
        
        let masterVC = mainStoryboard.instantiateInitialViewController() as! MasterViewController
        
        runOnMainThread {
            window.addSubview(masterVC.view)
            
            UIView.animate(
                withDuration: 0.5,
                delay: 0.0,
                options: .curveLinear,
                animations: {
                    window.rootViewController?.view.alpha = 0.0
                    masterVC.view.alpha = 1.0
            }, completion: { _ in
                window.rootViewController?.nuke()
                
                window.rootViewController = masterVC
                PetDateController.shared.masterViewController = masterVC
                PetDateController.shared.topMostViewController?.viewWillAppear(true)
            }
            )
            
        }
    }
    
    func transitionToUserProfile(user: User) {
        guard let window = self.window else {
            return
        }
        
        PetDateController.shared.user = user
        
        let userProfileVC = mainStoryboard.instantiateViewController(withIdentifier: "ProfileViewController")
        
        runOnMainThread {
            window.addSubview(userProfileVC.view)
            
            UIView.animate(
                withDuration: 0.5,
                delay: 0.0,
                options: .curveLinear,
                animations: {
                    window.rootViewController?.view.alpha = 0.0
                    userProfileVC.view.alpha = 1.0
            }, completion: { _ in
                window.rootViewController?.nuke()
                
                window.rootViewController = userProfileVC
                PetDateController.shared.topMostViewController?.viewWillAppear(true)
            }
            )
            
        }
        
    }
    
    
    func transitionToPost(image: UIImage, user: User) {
        guard let window = self.window else {
            return
        }
        
        
        //        runOnMainThread {
        //
        //            let postVC = mainStoryboard.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        //            postVC.user = user
        //            postVC.postImage = image
        //
        //            let masterVC = mainStoryboard.instantiateInitialViewController() as! MasterViewController
        //
        //            window.rootViewController = postVC
        //            UIView.animate(
        //                withDuration: 0.5,
        //                delay: 0.0,
        //                options: .curveLinear,
        //                animations: {
        //                    window.rootViewController?.view.alpha = 0.0
        //                    postVC.view.alpha = 1.0
        //            }, completion: { _ in
        //                window.rootViewController?.nuke()
        //                window.rootViewController = postVC
        //                PetDateController.shared.masterViewController = masterVC
        //                PetDateController.shared.topMostViewController?.viewWillAppear(true)
        //            }
        //            )
        //
        //        }
        
        runOnMainThread {
            let postVC = mainStoryboard.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
            postVC.user = user
            postVC.postImage = image
            window.rootViewController = postVC
            
        }
    }
    
}
