//
//  ContainerViewController.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import UIKit
import AVFoundation
import Apptentive


protocol ContainerViewControllerDelegate: class {
    func containerViewController(_ containerViewController: ContainerViewController, willOpen section: NavigationSection)
}


struct SegueDataKeys {
    
    static let openToSettings = "openToSettings"
    static let openToProfile = "openToProfile"
    static let openToEditProfile = "openToEditProfile"
    static let openToConnections = "openToConnections"
    
    static let allowSectionReload = "allowSectionReload"
    
    
    //    static let openToInterests = "openToInterests"
    //    static let openToKeywords = "openToKeywords"
    //    static let openToStories = "openToStories"
    //    static let openToFollowing = "openToFollowing"
    //    static let story = "story"
    static let query = "query"
    //    static let allowSectionReload = "allowSectionReload"
    //    static let openToCreateAStation = "openToCreateAStation"
    static let focusSearchBar = "focusSearchBar"
}


class ContainerViewController: UIViewController {
    
    private static let persistanceTimeout: TimeInterval = 2 * 60 * 60
    
    
    static let homeId = "EmbedHome"
    static let dateId = "EmbedDate"
    static let postId = "EmbedPost"
    static let searchID = "EmbedSearch"
    static let profileId = "EmbedProfile"
    
    // Not sure what LeftDate do here
    fileprivate var homeLeftDate: Date?
    
    fileprivate var homeViewController: UINavigationController?
    
    fileprivate var postViewController: UINavigationController?
    
    //    fileprivate var searchLeftDate: Date?
    fileprivate var searchViewController: UINavigationController?
    
    //    fileprivate var browseLeftDate: Date?
    //    fileprivate var dateViewController: BrowseViewController?
    
    //    fileprivate var libraryLeftDate: Date?
    fileprivate var profileViewController: UINavigationController?
    
    
    weak var delegate: ContainerViewControllerDelegate?
    
    weak var bottomNavBar: BottomNavigationView?
    
    fileprivate var currentIdentifier = ContainerViewController.homeId
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.performSegue(withIdentifier: self.currentIdentifier, sender: self)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ContainerViewController.appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ContainerViewController.appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        
        if identifier == ContainerViewController.homeId {
            let timeAway = abs(self.homeLeftDate?.timeIntervalSinceNow ?? .infinity)
            if let radioVC = self.homeViewController,
                timeAway <= ContainerViewController.persistanceTimeout {
                let segue = EmptySegue(
                    identifier: identifier,
                    source: self,
                    destination: radioVC
                )
                self.prepare(for: segue, sender: sender)
                segue.perform()
                return
            } else {
                self.homeViewController = nil
            }
        }
        
        if identifier == ContainerViewController.postId  {
            if let postVC = self.postViewController {
                let segue = EmptySegue(identifier: identifier, source: self, destination: postVC)
                self.prepare(for: segue, sender: sender)
                segue.perform()
            } else {
                self.postViewController = nil
            }
        }
        
        
        if identifier == ContainerViewController.profileId {
            if let profileVc = self.profileViewController {
                
                let segue = EmptySegue(
                    identifier: identifier,
                    source: self,
                    destination: profileVc
                )
                self.prepare(for: segue, sender: sender)
                segue.perform()
                return
            } else {
                self.profileViewController = nil
            }
        }
        
        
        super.performSegue(withIdentifier: identifier, sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        let newVC = segue.destination
        
        self.setProperties(on: newVC, segue: segue)
        
        if let navRoot = (newVC as? UINavigationController)?.viewControllers.first {
            self.setProperties(on: navRoot, segue: segue)
        }
        self.updatePersistanceProperties(segue: segue)
        
        self.segueData = nil
        
        self.move(to: newVC)
    }
    
    var currentVC: UIViewController? {
        return self.children.last
    }
    
    var currentRootVCNonNav: UIViewController? {
        let vc = self.currentVC
        if let nvc = vc as? UINavigationController {
            return nvc.viewControllers.first
        } else {
            return vc
        }
    }
    var currentTopVC: UIViewController? {
        var vc = self.currentVC
        if let nvc = vc as? UINavigationController {
            vc = nvc.viewControllers.last
        }
        return vc?.presentedViewController ?? vc
    }
    
    private func move(to newVC: UIViewController) {
        
        if let oldVC = self.currentVC {
            self.swap(from: oldVC, to: newVC)
        } else {
            self.addChild(newVC)
            newVC.didMove(toParent: self)
            
            self.view.addSubview(newVC.view)
            newVC.view.translatesAutoresizingMaskIntoConstraints = false
            let views = ["view": newVC.view!]
            let horiz = NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0-[view]-0-|",
                options: [],
                metrics: nil,
                views: views
            )
            let verti = NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[view]-0-|",
                options: [],
                metrics: nil,
                views: views
            )
            NSLayoutConstraint.activate(horiz)
            NSLayoutConstraint.activate(verti)
            
            let section: NavigationSection
            switch self.currentIdentifier {
            case ContainerViewController.homeId:
                section = .home
                //            case ContainerViewController.dateId:
            //                section = .date
            case ContainerViewController.postId:
                section = .post
                //            case ContainerViewController.searchID:
            //                section = .search
            case ContainerViewController.profileId:
                section = .profile
                
            default:
                section = .home
            }
            
            self.delegate?.containerViewController(self, willOpen: section)
        }
    }
    
    private func setProperties(on vc: UIViewController, segue: UIStoryboardSegue) {
        
        if var userneeded = vc as? UserNeeded {
            userneeded.user = PetDateController.shared.user
        }
        if let ann = vc as? AppNavigatorNeeded {
            ann.appNavigator = self
        }
        if let postVC = vc as? PostViewController {
            postVC.postImage = self.segueData?["image"] as? UIImage
        }
        
        if let profileVC = vc as? ProfileViewController {
            profileVC.profileType = ProfileVCType.selfUser
        }
        //        if let rvc = vc as? RadioViewController {
        //            if self.segueData?[SegueDataKeys.openToCreateAStation] as? Bool ?? false {
        //                DispatchQueue.main.async {
        //                    rvc.openCreateAStation()
        //                }
        //            }
        //        }
        //        if let svc = vc as? SearchViewController {
        //            if let query = self.segueData?[SegueDataKeys.query] as? String {
        //                svc.search(query: query)
        //            } else if self.segueData?[SegueDataKeys.focusSearchBar] as? Bool ?? false {
        //                svc.becomeFirstResponderOnLoad = true
        //            }
        //        }
        
        
        
        //        if let lvc = vc as? LibraryViewController {
        //            if self.segueData?[SegueDataKeys.openToSettings] as? Bool ?? false {
        //                lvc.openSettings(animated: false)
        //            } else if self.segueData?[SegueDataKeys.openToProfile] as? Bool ?? false {
        //                lvc.openProfile(animated: false)
        //            } else if self.segueData?[SegueDataKeys.openToEditProfile] as? Bool ?? false {
        //                lvc.openEditProfile(animated: false)
        //            } else if self.segueData?[SegueDataKeys.openToConnections] as? Bool ?? false {
        //                lvc.openConnections(animated: false)
        //            } else if self.segueData?[SegueDataKeys.openToInterests] as? Bool ?? false {
        //                lvc.openCategories(animated: false)
        //            } else if self.segueData?[SegueDataKeys.openToKeywords] as? Bool ?? false {
        //                lvc.openKeywords(animated: false)
        //            } else if self.segueData?[SegueDataKeys.openToUberSettings] as? Bool ?? false {
        //                lvc.openUberSettings(animated: false)
        //            } else if self.segueData?[SegueDataKeys.openToFollowing] as? Bool ?? false {
        //                lvc.openFollowing(animated: false)
        //            }
        //        }
        
    }
    
    private func updatePersistanceProperties(segue: UIStoryboardSegue) {
        
        //        let fromVC = self.currentVC
        //        let fromVCNonNav = self.currentRootVCNonNav
        
        //        if fromVCNonNav is HomeViewController {
        //            self.homeViewController = Date()
        //        }
        ////        if fromVCNonNav is SearchViewController {
        ////            self.searchLeftDate = Date()
        ////        }
        ////        if fromVC is BrowseViewController {
        ////            self.browseLeftDate = Date()
        ////        }
        ////        if fromVCNonNav is LibraryViewController {
        ////            self.libraryLeftDate = Date()
        ////        }
        //
        //        let toVC = segue.destination
        //        let toVCNonNav = (segue.destination as? UINavigationController)?.viewControllers.first
        //
        //        if let navVC = toVC as? UINavigationController, toVCNonNav is RadioViewController {
        //            self.radioViewController = navVC
        //        }
        //        if let navVC = toVC as? UINavigationController, toVCNonNav is SearchViewController {
        //            self.searchViewController = navVC
        //        }
        //        if let browseVC = toVC as? BrowseViewController {
        //            self.browseViewController = browseVC
        //        }
        //        if let navVC = toVC as? UINavigationController, toVCNonNav is LibraryViewController {
        //            self.libraryViewController = navVC
        //        }
        
    }
    
    fileprivate var swapping = false
    
    private func swap(from fromVC: UIViewController, to toVC: UIViewController) {
        self.swapping = true
        
        // do before animation starts, so state is set before new one loads
        fromVC.willMove(toParent: nil)
        
        if toVC.parent !== self {
            self.addChild(toVC)
            toVC.didMove(toParent: self)
        }
        
        if toVC.view.superview !== self.view {
            toVC.view.alpha = 0.0
            toVC.view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(toVC.view)
            let views = ["view": toVC.view!]
            let horiz = NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0-[view]-0-|",
                options: [],
                metrics: nil,
                views: views
            )
            let verti = NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[view]-0-|",
                options: [],
                metrics: nil,
                views: views
            )
            NSLayoutConstraint.activate(horiz)
            NSLayoutConstraint.activate(verti)
        } else {
            toVC.viewWillAppear(true)
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            toVC.view.alpha = 1.0
            fromVC.view.alpha = 0.0
        }, completion: { _ in
            fromVC.view.removeFromSuperview()
            fromVC.removeFromParent()
            self.swapping = false
        })
        
    }
    
    private var segueData: [String: Any?]?
    
    func openVC(with id: String, sender: Any? = nil, data: [String: Any?]? = nil) {
        guard self.currentIdentifier != id || data?[SegueDataKeys.allowSectionReload] as? Bool ?? false else {
            return
        }
        self.currentIdentifier = id
        self.segueData = data
        
        
        self.performSegue(withIdentifier: id, sender: sender ?? self)
        
    }
    
    private var backgroundDate = Date()
    
    @objc private func appDidEnterBackground() {
        self.backgroundDate = Date()
    }
    
    @objc private func appWillEnterForeground() {
        if abs(self.backgroundDate.timeIntervalSinceNow) >= ContainerViewController.persistanceTimeout {
            let data = [SegueDataKeys.allowSectionReload: true]
            self.open(section: .home, data: data, sender: self)
            self.homeViewController = nil
            self.postViewController = nil
            self.searchViewController = nil
            self.profileViewController = nil
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate(set) var overlayViewController: UIViewController?
    fileprivate var overlayHiddenConstraint: NSLayoutConstraint?
    fileprivate var currentSection = NavigationSection.home
}

extension ContainerViewController: AppNavigator {
    
    func open(section: NavigationSection, data: [String: Any]?, sender: Any) {
        guard !self.swapping else {
            return
        }
        
        //        if section == self.currentSection, self.overlayViewController != nil {
        //            self.removeOverlayViewController(animated: true)
        //            return
        //        }
        //
        //        if section != .browse {
        //            PodcastChannelManager.shared.commitUpdates()
        //        }
        
        self.delegate?.containerViewController(self, willOpen: section)
        switch section {
        case .home:
            self.openHome(data: data, sender: sender)
            //        case .search:
        //            self.openSearch(data: data, sender: sender)
        case .post:
            self.openImages(data: data, sender: sender)
        case .profile:
            self.openProfile(data: data, sender: sender)
            //        case .date:
            //            self.openDate(data: data, sender: sender)
        }
        
    }
    
    //    private func openDate(data: [String: Any?]?, sender: Any) {
    //        self.currentSection = .date
    //        self.openVC(with: ContainerViewController.dateId, data: data)
    //    }
    
    private func openImages(data: [String: Any?]?, sender: Any) {
        self.view.endEditing(false)
        OverflowView.addToWindow(context: .postPicture, delegate: self)
    }
    
    private func openProfile(data: [String: Any?]?, sender: Any) {
        guard self.currentIdentifier != ContainerViewController.profileId else {
            return
        }
        
        self.currentSection = .profile
        self.openVC(with: ContainerViewController.profileId, data: data)
        
    }
    
    private func openSearch(data: [String: Any?]?, sender: Any) {
        //        if let nvc = currentVC as? UINavigationController, let svc = nvc.viewControllers.first as? SearchViewController {
        //
        //            if nvc.viewControllers.count > 1 {
        //                nvc.popViewController(animated: true)
        //            }
        //
        //            if let query = data?[SegueDataKeys.query] as? String {
        //                svc.search(query: query)
        //            }
        //
        //            return
        //        }
        //
        //        self.currentSection = .search
        //        self.openVC(with: ContainerViewController.searchID, data: data)
    }
    
    private func openHome(data: [String: Any?]?, sender: Any) {
        //        if let nvc = currentVC as? UINavigationController,
        //            let rvc = nvc.viewControllers.first as? HomeViewController,
        //            data?[SegueDataKeys.allowSectionReload] as? Bool != true {
        //
        //            if nvc.viewControllers.count > 1 {
        //                nvc.popViewController(animated: true)
        //            }
        
        //            if data?[SegueDataKeys.openToCreateAStation] as? Bool ?? false {
        //                rvc.openCreateAStation()
        //            }
        
        //            return
        //        }
        
        self.currentSection = .home
        self.openVC(with: ContainerViewController.homeId, data: data)
    }
    
    private func openLibrary(data: [String: Any?]?, sender: Any) {
        //        let work = {
        //            if let nvc = self.currentVC as? UINavigationController,
        //                let lvc = nvc.viewControllers.first as? LibraryViewController {
        //                if data?[SegueDataKeys.openToSettings] as? Bool ?? false {
        //                    lvc.openSettings(animated: false)
        //                } else if data?[SegueDataKeys.openToProfile] as? Bool ?? false {
        //                    lvc.openProfile(animated: false)
        //                } else if data?[SegueDataKeys.openToEditProfile] as? Bool ?? false {
        //                    lvc.openEditProfile(animated: false)
        //                } else if data?[SegueDataKeys.openToConnections] as? Bool ?? false {
        //                    lvc.openConnections(animated: false)
        //                } else if data?[SegueDataKeys.openToInterests] as? Bool ?? false {
        //                    lvc.openCategories(animated: false)
        //                } else if data?[SegueDataKeys.openToKeywords] as? Bool ?? false {
        //                    lvc.openKeywords(animated: false)
        //                } else if data?[SegueDataKeys.openToUberSettings] as? Bool ?? false {
        //                    lvc.openUberSettings(animated: false)
        //                } else if data?[SegueDataKeys.openToFollowing] as? Bool ?? false {
        //                    lvc.openFollowing(animated: true)
        //                } else if nvc.viewControllers.count > 1 {
        //                    nvc.popViewController(animated: true)
        //                }
        //                return
        //            }
        //            guard self.currentIdentifier != ContainerViewController.libraryID else {
        //                return
        //            }
        //            self.currentSection = .library
        //            self.openVC(with: ContainerViewController.libraryID, data: data)
        //        }
        //
        //        if self.libraryViewController == nil,
        //            let user = OttoController.shared.user,
        //            ABTestingManager.shared.optionalBucket(
        //                for: user,
        //                for: .libraryBottomSection
        //                ) == nil {
        //
        //            var called = false
        //            delay(5.0) {
        //                if !called {
        //                    LoadingShade.remove()
        //                    called = true
        //                    work()
        //                }
        //            }
        //            LoadingShade.add()
        //            ABTestingManager.shared.refresh(experiment: .libraryBottomSection) {
        //                runOnMainThread {
        //                    if !called {
        //                        LoadingShade.remove()
        //                        called = true
        //                        work()
        //                    }
        //                }
        //            }
        //
        //        } else {
        //            work()
        //        }
    }
    
    //    func openPodcastChannelViewController(for channel: PodcastChannel, location: ChannelLocation) {
    //        let channelVC = PodcastChannelMasterViewController(
    //            channel: channel,
    //            location: location
    //        )
    //        channelVC.user = OttoController.shared.user
    //        self.addOverlay(viewController: channelVC, animated: true)
    //        OttoController.shared.masterViewController?
    //            .closeGlobalPlayer(animated: true)
    //    }
    
}

// MARK: Overlays

//extension ContainerViewController {
//
//    func addOverlay(viewController: UIViewController, animated: Bool) {
//        self.removeOverlayViewController(animated: false)
//
//        self.overlayViewController = viewController
//        self.addChildViewController(viewController)
//        viewController.didMove(toParentViewController: self)
//
//        let view = viewController.view!
//        view.translatesAutoresizingMaskIntoConstraints = false
//        self.view.addSubview(view)
//
//        let views = ["view": view]
//        let horiz = NSLayoutConstraint.constraints(
//            withVisualFormat: "H:|-0-[view]-0-|",
//            options: [],
//            metrics: nil,
//            views: views
//        )
//        let hidden = view.topAnchor.constraint(
//            equalTo: self.view.bottomAnchor,
//            priority: animated ? .high : .low
//        )
//        let shown = view.topAnchor.constraint(
//            equalTo: self.view.topAnchor,
//            priority: .medium
//        )
//        let height = view.heightAnchor
//            .constraint(equalTo: self.view.heightAnchor)
//
//        NSLayoutConstraint.activate(horiz)
//        NSLayoutConstraint.activate([hidden, shown, height])
//
//        self.overlayHiddenConstraint = hidden
//
//        if animated {
//            self.view.layoutIfNeeded()
//            hidden.priority = .low
//            UIView.animate(withDuration: 0.3) {
//                self.view.layoutIfNeeded()
//            }
//        }
//
//        self.setNeedsStatusBarAppearanceUpdate()
//    }
//
//    func removeOverlayViewController(animated: Bool) {
//        guard let overlay = self.overlayViewController,
//            let hidden = self.overlayHiddenConstraint else {
//                return
//        }
//        self.overlayViewController = nil
//        self.overlayHiddenConstraint = nil
//
//        let remove = {
//            overlay.view.removeFromSuperview()
//            overlay.willMove(toParentViewController: nil)
//            overlay.removeFromParentViewController()
//            self.setNeedsStatusBarAppearanceUpdate()
//        }
//
//        if animated {
//            self.view.layoutIfNeeded()
//            hidden.priority = .high
//            UIView.animate(withDuration: 0.3, animations: {
//                self.view.layoutIfNeeded()
//            }, completion: { _ in
//                remove()
//            })
//        } else {
//            remove()
//        }
//    }
//
//}

extension ContainerViewController: OverflowViewDelegate {
    
    func overflowView(overflowView: OverflowView, didPress action: OverflowAction) -> Bool {
        switch overflowView.context {
            
        case .postPicture:
            return false //Do not handle action but just set a reference to delegate
            
        case .profilePicture:
            return false
        }
        
        
    }
    
    func overflowViewDidPressCancel(overflowView: OverflowView) -> Bool {
        switch overflowView.context {
            
        case .postPicture:
            return false //Do not handle action but just set a reference to delegate
            
        case .profilePicture:
            return false
        }
    }
    
    
}
