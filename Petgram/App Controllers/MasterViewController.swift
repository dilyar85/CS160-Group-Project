//
//  MasterViewController.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import UIKit
import CoreLocation
import Apptentive
import AVFoundation
import MediaPlayer


//extension Notification.Name {
//    static let masterViewControllerDidSetGlobalPlayerUp = Notification.Name("masterViewControllerDidSetGlobalPlayerUp")
//}


@objc protocol AppNavigatorNeeded {
    weak var appNavigator: AppNavigator? { get set }
}


class MasterViewController: UIViewController {
    
    // need to hold a reference for when you ask for location permission
    fileprivate var locationManager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(
                MasterViewController.checkApptentiveMessageCount(notification:)
            ),
            name: .UIApplicationDidBecomeActive,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(
                MasterViewController.checkApptentiveMessageCount(notification:)
            ),
            name: .ApptentiveMessageCenterUnreadCountChanged,
            object: nil
        )
        
        
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
            self.locationManager?.requestWhenInUseAuthorization()
            
            NotificationManager.shared.requestNotificationPermissionIfNecessary()
        }
        
    }
    
    
    @IBOutlet weak var bodyView: UIView!
    private(set) var containerViewController: ContainerViewController?
    
    @IBOutlet weak var navigationViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigationView: BottomNavigationView! {
        didSet {
            navigationView.appNavigator = self.containerViewController
            self.containerViewController?.bottomNavBar = navigationView
        }
    }
    
    //    @IBOutlet fileprivate weak var navBarTitleLabel: UILabel!
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "EmbedContainer" {
            guard let container = segue.destination as? ContainerViewController else {
                return
            }
            container.delegate = self
            self.navigationView?.appNavigator = container
            container.bottomNavBar = self.navigationView
            self.containerViewController = container
        }
    }
    
    // MARK: Appentive Messages
    
    private var lastApptentiveMessageCount: UInt = 0
    
    @objc fileprivate func checkApptentiveMessageCount(notification: NSNotification?) {
        guard UIApplication.shared.applicationState == .active else {
            return
        }
        
        let count = (notification?.userInfo?["count"] as? NSNumber)
            ?? (Apptentive.shared.unreadMessageCount as NSNumber)
        
        let uintCount = count as? UInt ?? 0
        if uintCount > self.lastApptentiveMessageCount {
            self.showNewApptentiveMessage(unreadCount: uintCount)
        }
        self.lastApptentiveMessageCount = uintCount
    }
    
    fileprivate var apptentiveMessageView: ApptentiveNewMessageNotificationView?
    private func showNewApptentiveMessage(unreadCount: UInt) {
        if self.apptentiveMessageView != nil {
            return
        }
        
        let message = ApptentiveNewMessageNotificationView(messageCount: unreadCount)
        message.delegate = self
        self.apptentiveMessageView = message
        message.show()
    }
    
    
    fileprivate static let navBarOpenConstant: CGFloat = 0.0
    fileprivate static let navBarClosedConstant: CGFloat = -BottomNavigationView.height
    
    
    
    
    
    private var currentPGR: UIPanGestureRecognizer?
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //    fileprivate var storyLoadingView: StoryLoadingView?
    //    fileprivate var channelLoadingView: ChannelLoadingView?
    //    fileprivate var stationLoadingView: StationLoadingView?
    
    
    fileprivate var statusBarStyle = UIStatusBarStyle.lightContent {
        didSet {
            guard oldValue != statusBarStyle else {
                return
            }
            runOnMainThread {
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    fileprivate var statusBarHidden = false {
        didSet {
            guard oldValue != statusBarHidden else {
                return
            }
            runOnMainThread {
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    fileprivate var radioYouOverlay: UIView?
}

extension MasterViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.containerViewController?.overlayViewController?.preferredStatusBarStyle
            ?? self.statusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        return self.containerViewController?.overlayViewController?.prefersStatusBarHidden
            ?? (self.statusBarHidden)
    }
    
}

extension MasterViewController: ApptentiveNewMessageNotificationViewDelegate {
    
    func apptentiveNewMessageNotificationViewDidClose(_ apptentiveNewMessageNotificationView: ApptentiveNewMessageNotificationView) {
        self.apptentiveMessageView = nil
    }
    
}

extension MasterViewController: ContainerViewControllerDelegate {
    
    func containerViewController(_ containerViewController: ContainerViewController, willOpen section: NavigationSection) {
        self.navigationView?.setHighlighted(section: section)
    }
    
}



extension MasterViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .notDetermined {
            self.locationManager = nil
        }
    }
    
}
