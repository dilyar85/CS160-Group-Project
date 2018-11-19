//
//  ProfileViewController.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

enum PostViewMode {
    case picture
    case record
    case tag
}

enum ProfileVCType {
    case selfUser
    case otherUser(_: UserInfo)
    
}

enum UserRelationship {
    case follow
    case unfollow
}



class ProfileViewController: UIViewController, UserNeeded {
    
    var user: User?
    
    var profileType: ProfileVCType?
    
    var posts: [Post]? {
        didSet{
            self.postTableView.reloadData()
        }
    }
    
    var followers: [UserInfo]? {
        didSet {
            guard let followers = self.followers else {
                self.follwersCountLaebl.text = "..."
                return
            }
            self.follwersCountLaebl.text = "\(followers.count)"
        }
    }
    
    var followees: [UserInfo]? {
        didSet {
            guard let followees = self.followees else {
                self.follwingCountLabel.text = "..."
                return
            }
            self.follwingCountLabel.text = "\(followees.count)"
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: CircleImageView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var statsView: UIView!
    
    @IBOutlet weak var petBreedLabel: UILabel!
    @IBOutlet weak var follwersCountLaebl: UILabel!
    @IBOutlet weak var follwingCountLabel: UILabel!
    
    @IBOutlet weak var petSpentDaysLaebl: UILabel!
    
    
    
    
    @IBOutlet weak var postTableView: UITableView! {
        didSet {
            self.postTableView.dataSource = self
            self.postTableView.delegate = self
        }
    }
    
    @IBAction func openFollowingButtonTapped() {
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "UsersDisplayVC") as! UsersDisplayViewController
        vc.displayType = .followings
        vc.usersInfo = self.followees
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func openFollowersButtonTapped() {
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "UsersDisplayVC") as! UsersDisplayViewController
        vc.displayType = .followers
        vc.usersInfo = self.followers
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.view.backgroundColor = .petBackground
        self.setStatusBar(color: .petBackground)
        
        self.setupViewsWithType()
        
        self.updateStatsCountView()
        
        
        self.fetchPosts()
        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(setUpPetInfoLabels),
//            name: .userInfoDidUpdated,
//            object: nil)
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Because self user can update its info after viewDidLoad() called
        //We updatePetInfoLables() here
        self.setUpPetInfoLabels()
    }
    
    func setupViewsWithType() {
        guard let type = self.profileType else {
            return
        }
        
        switch type {
        case .selfUser:
            
            self.titleLabel.text = "Profile"
            
            // FIXME: Enable Constraints
            
            let settingButton = UIButton(frame: CGRect(x: 300, y: 200, width: 50, height: 45))
            settingButton.addTarget(
                self,
                action: #selector(ProfileViewController.buttonTapped(_:)),
                for: .touchUpInside
            )
            
            let settingImaggView = UIImageView(frame: CGRect(x: 300, y: 200, width: 25, height: 25))
            settingImaggView.image = #imageLiteral(resourceName: "button_gear_black")
            
            self.view.addSubview(settingButton)
            self.view.addSubview(settingImaggView)

            
            
//            let width = NSLayoutConstraint (
//                item: settingButton,
//                attribute: .width,
//                relatedBy: .equal,
//                toItem: nil,
//                attribute: .notAnAttribute,
//                multiplier: 1.0,
//                constant: 50
//            )
//            
//            let height = NSLayoutConstraint(
//                item: settingButton,
//                attribute: .height,
//                relatedBy: .equal,
//                toItem: nil,
//                attribute: .notAnAttribute,
//                multiplier: 1.0,
//                constant: 50
//            )
//            
//            let trailing = NSLayoutConstraint(
//                item: settingButton,
//                attribute: .trailing,
//                relatedBy: .equal,
//                toItem: self.view,
//                attribute: .trailing,
//                multiplier: 1.0,
//                constant: 0.0
//            )
//            
//            let top = NSLayoutConstraint(
//                item: settingButton,
//                attribute: .top,
//                relatedBy: .equal,
//                toItem: self.view,
//                attribute: .top,
//                multiplier: 1.0,
//                constant: 0.0
//            )
//            
//            let centerX = NSLayoutConstraint(
//                item: settingButton,
//                attribute: .centerX,
//                relatedBy: .equal,
//                toItem: self.view,
//                attribute: .centerX,
//                multiplier: 1.0,
//                constant: 0.0
//            )
//            
//            let centerY = NSLayoutConstraint(
//                item: settingButton,
//                attribute: .centerY,
//                relatedBy: .equal,
//                toItem: self.view,
//                attribute: .centerY,
//                multiplier: 1.0,
//                constant: 0.0
//            )

//            NSLayoutConstraint.activate([width, height, top, trailing])
            
            
            
            
        case .otherUser(let userInfo):
            guard let user = self.user else {
                return
            }
            self.titleLabel.text = userInfo.petName
            
            let backButton = UIButton(frame: CGRect(x: 0, y: 15, width: 50, height: 50))
            backButton.setImage(#imageLiteral(resourceName: "back_button"), for: .normal)
            backButton.addTarget(self, action: #selector (ProfileViewController.backButtonTapped), for: .touchUpInside)
            
            
            self.view.addSubview(backButton)
            
            
            
            let followButton = UIButton(frame: CGRect(x: 305, y: 172, width: 100, height: 30))
            followButton.isHidden = true
            followButton.isUserInteractionEnabled = false
            self.view.addSubview(followButton)
            
            user.isFollowing(otherUserId: userInfo.id, callback: { (followed) in
                guard let followed = followed else {
                    return
                }
                // TODO: Maybe this is not a good way to restore following state
                followButton.tag = followed ? 1 : 0
                followButton.setFollowState(followed)
                followButton.isHidden = false
                followButton.isUserInteractionEnabled = true
                
                followButton.addTarget(self, action: #selector(ProfileViewController.buttonTapped(_:)), for: .touchUpInside)
            })
            
        }
        
    }
    
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        
        guard let type = self.profileType else {
            Logger.log("Trying to call settingButtonTapped() with nil profileType", logType: .error)
            return
        }
        switch type {
        case .selfUser:
            let vc = mainStoryboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
            self.navigationController?.pushViewController(vc, animated: true)
            
            
        case .otherUser(let userInfo):
            guard let user = PetDateController.shared.user else {
                return
            }
            let spinner = UIActivityIndicatorView(style: .white)
            spinner.center = sender.center
            sender.addSubview(spinner)
            spinner.startAnimating()
            
            let followed = sender.tag == 1
            
            user.follow(userInfo.id, !followed, completion: { (succeed) in
                guard succeed else {
                    let overlay = WarningOverlayView(title: "Action failed", subtitle: "Please check your connection", topButtonTitle: "", topButtonAction: { (overlay) in
                        overlay.animateOut()
                        self.buttonTapped(sender)
                    }, bottomButtonTitle: "", bottomButtonAction: { (overlay) in
                        overlay.animateOut()
                    }, outsideAction: { (overlay) in
                        overlay.animateOut()
                    })
                    overlay.animateIn()
                    return
                }
                
                spinner.isHidden = true
                spinner.stopAnimating()
                sender.setFollowState(!followed)
            })
        }
    }
    
//    @objc private func followButtonTapped() {
//        guard let type = self.profileType else {
//            Logger.log("Trying to call settingButtonTapped() with nil profileType", logType: .error)
//            return
//        }
//        switch type {
//        case .selfUser:
//            let vc = mainStoryboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
//            self.navigationController?.pushViewController(vc, animated: true)
//        default:
//            Logger.log("Trying to call settingButtonTapped() with other type: \(type)", logType: .error)
//        }
//
//    }
    
    private func updateStatsCountView() {
        guard let user = self.user, let type = self.profileType else {
            return
        }
        
        self.spinner.startAnimating()
        self.spinner.alpha = 1.0
        
        let userId: String
        switch type {
        case .selfUser:
            userId = user.id
        case .otherUser(let userInfo):
            userId = userInfo.id
        }
        user.getFollowersAndFollowees(of: userId) { (followersInfo, followeesInfo) in
            self.spinner.alpha = 0.0
            self.spinner.stopAnimating()
            
            self.followers = followersInfo
            self.followees = followeesInfo
        }
        
    }
    
    
    func setUpPetInfoLabels() {
        guard let user = self.user, let type = self.profileType else {
            return
        }
        
        switch type {
        case .selfUser:
            self.nameLabel.text = user.petName
            self.petSpentDaysLaebl.text =
                Date().interval(ofComponent: .day, fromDate: user.petAdoptDate ?? Date()).description + " days"
            self.petBreedLabel.text = user.petBreed
        case .otherUser(let userInfo):
            self.nameLabel.text = userInfo.petName
            self.petSpentDaysLaebl.text =
                Date().interval(ofComponent: .day, fromDate: userInfo.petAdopteDate ?? Date()).description + " days"
            self.petBreedLabel.text = userInfo.petBreed
        }
        
    }
    
    func fetchPosts() {
        guard let user = self.user, let type = self.profileType else {
            self.posts = nil
            return
        }
        let userId: String
        switch type {
        case .selfUser:
            userId = user.id
        case .otherUser(let userInfo):
            userId = userInfo.id
        }
        
        user.fetchPosts(of: userId) { (posts) in
            guard let posts = posts else {
                let overlay = WarningOverlayView(title: "Failed to fetch posts :(", subtitle: "Please check your connection", topButtonTitle: "Try again", topButtonAction: { (overlay) in
                    overlay.animateOut()
                    self.fetchPosts()
                }, bottomButtonTitle: "Cancel", bottomButtonAction: { (overlay) in
                    overlay.animateOut()
                }, outsideAction: { (overlay) in
                    overlay.animateOut()
                })
                overlay.animateIn()
                return
            }
            self.posts = posts
        }
    }
    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
    
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell
        
        cell.post = self.posts?[indexPath.row]

        return cell
    }
    
    
    
    // MARK: Table View Delegate
    
    

}

class PostTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postMessageView: UILabel!
    
    
    var post: Post? {
        didSet {
            
            guard let post = self.post else {
                return
            }
            
            self.postDateLabel.text = post.postDateTime?.getString(withFormat: "MMM dd")
            self.postMessageView.text = post.postMessage
            
            if let url = post.imageUrl {
                self.postImageView.kf.indicatorType = .activity
                self.postImageView.kf.setImage(with: URL(string: url))
            } else {
                self.postImageView.image = #imageLiteral(resourceName: "empty_post")
            }
            
        }
    }
    
}




private extension Int {
    var roundedString: String {
        switch self {
        case let i where i >= 1_000_000:
            return String(format:  "%.1fm", Double(self) / 1_000_000)
        case let i where i >= 1000:
            return String(format:  "%.1fk", Double(self) / 1000)
        default:
            return "\(self)"
        }
    }
    
}

private extension Double {
    var roundedString: String {
        return Int((self).rounded()).roundedString
    }
    
}

