//
//  HomePostViewController.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

struct HomePost {
    
    let userInfo: UserInfo
    let post: Post
    
    init(userInfo: UserInfo, post: Post) {
        self.userInfo = userInfo
        self.post = post
    }
    
}



class HomePostViewController: UIViewController, UserNeeded {
    
    var user: User?
    
    var homePosts: [HomePost]? {
        didSet{
            Logger.log("HomePost Didset", logType: .actionLog)
            runOnMainThread {
                self.postTableView.reloadData()
            }
        }
    }
    
    @IBOutlet weak var postTableView: UITableView! {
        didSet {
            self.postTableView.dataSource = self
            self.postTableView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBar(color: .petBackground)
        self.fetchTimeLine()
        
    }
    
    
    func fetchTimeLine() {
        guard let user = self.user else {
            return
        }
        
        
        user.fetchFollowingsHomePosts { (error, homePosts) in
            guard error == nil else {
                let overlay = WarningOverlayView(title: "Load posts failed :(", subtitle: "Please check your connection", topButtonTitle: "Try again", topButtonAction: { (overlay) in
                    overlay.animateOut()
                    self.fetchTimeLine()
                }, bottomButtonTitle: "Cancel", bottomButtonAction: { (overlay) in
                    overlay.animateOut()
                }, outsideAction: { (overlay) in
                    overlay.animateOut()
                })
                overlay.animateIn()
                return
            }
            
            // TODO: Handle when time line is empty
            self.homePosts = homePosts
        }
    }
    
    
}

extension HomePostViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.homePosts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomePostTableViewCell", for: indexPath) as! HomePostTableViewCell
        //Set up the cell's property
        
        cell.homePost = self.homePosts?[indexPath.row]
        cell.navController = self.navigationController
        
        return cell
    }
    
}


class HomePostTableViewCell: UITableViewCell {
    
    static let maxUserLikesDisplay: Int = 8
    
    var navController: UINavigationController?
    
    @IBOutlet weak var avatarImageView: CircleImageView!
    
    @IBAction func avatarButtonTapped() {
        guard let navController = self.navController, let homePost = self.homePost else {
            return
        }
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.user = PetDateController.shared.user
        vc.profileType = ProfileVCType.otherUser(homePost.userInfo)
        navController.pushViewController(vc, animated: true)
        
    }
    
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var petBreedLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    
    @IBOutlet weak var followButtonSpinner: UIActivityIndicatorView!
    
    @IBAction func followButtonTapped(_ sender: UIButton) {
        guard let user = PetDateController.shared.user, let userInfo = self.homePost?.userInfo else {
            return
        }
        
        self.followButtonSpinner.startAnimating()
        self.followButtonSpinner.isHidden = false
        
        sender.isUserInteractionEnabled = false
        
        let followed = sender.tag == 1
        
        user.follow(userInfo.id, !followed) { (succeed) in
            guard succeed else {
                
                // TODO: Handle error
                
                return
            }
            
            sender.setFollowState(!followed)
            sender.isUserInteractionEnabled = true
            
            self.followButtonSpinner.isHidden = true
            self.followButtonSpinner.stopAnimating()
            
            
        }
        
        
    }
    
    @IBOutlet weak var petLocationLabel: UILabel!
    
    @IBOutlet weak var postMessageLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var likedImage: UIImageView!
    
    
//    @IBOutlet var likedUserImageViews: [UIImageView]!
//    @IBOutlet weak var likedCountButton: UIButton!
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        guard let user = PetDateController.shared.user, let homePost = self.homePost, let liked = self.likedStatus else {
            return
        }
        
        if (liked) {
//            user.dislike(post: homePost.post, done: )
            user.dislike(post: homePost.post)
            self.likedStatus = false
        }
        else {
            user.like(post: homePost.post)
            self.likedStatus = true
        }
    }
    
    
    
    @IBAction func likedCountButtonTapped() {
        guard let navController = self.navController else {
            Logger.log("HomePostTableViewCell's navController is nil!", logType: .error)
            let overlay = WarningOverlayView(retryWarningWithRetryAction: { (overlay) in
                overlay.animateOut()
                self.likedCountButtonTapped()
            }, cancelAction: { (overlay) in
                overlay.animateOut()
            })
            overlay.animateIn()
            return
        }
        
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "UsersDisplayVC") as! UsersDisplayViewController
        vc.displayType = .likes
//        vc.usersInfo = self.likedUsersInfo
        navController.pushViewController(vc, animated: true)
    }
    
    
    
    
    var homePost: HomePost? {
        
        didSet {
            updateHomePostView()
        }
    }
    
    func updateHomePostView() {
        guard let homePost = self.homePost else {
            return
        }
        
        let userInfo = homePost.userInfo
        let post = homePost.post
        
        //Set follow button
        self.setupFollowButton(with: userInfo)
        
        //Set Pet Location Label
        self.setupPetLocation(with: userInfo)
        
        //Set Like Button
        self.setupLikedStatus(for: post)
        
        //Setup Liked User
//        self.getLikedUser(for: post)
        
        self.petNameLabel.text = userInfo.petName
        self.petBreedLabel.text = userInfo.petBreed
        self.petLocationLabel.text = userInfo.petLocation
        
        self.postMessageLabel.text = post.postMessage
        self.postTimeLabel.text = post.postDateTime?.getString(withFormat: "MMM dd")
        
        
        
        // Set Images
        if let avatarUrl = userInfo.avatarUrl {
            self.avatarImageView.kf.indicatorType = .activity
            self.avatarImageView.kf.setImage(with: URL(string: avatarUrl))
        } else {
            self.postImageView.image = User.defaultProfileImage
        }
        
        if let postImageUrl = post.imageUrl {
            self.postImageView.kf.indicatorType = .activity
            self.postImageView.kf.setImage(with: URL(string: postImageUrl))
        } else {
            self.postImageView.image = #imageLiteral(resourceName: "empty_post")
        }
    }
    
    private func setupPetLocation(with userInfo: UserInfo) {
        self.petLocationLabel.text = userInfo.petLocation
    }
    
    private func setupFollowButton(with userInfo: UserInfo) {
        
        self.followButton.isUserInteractionEnabled = false
        self.followButton.isHidden = true
        self.followButton.tag = 0
        
        
        self.followButtonSpinner.startAnimating()
        self.followButtonSpinner.isHidden = false
        
        guard let user = PetDateController.shared.user else {
            return
        }
        
        user.isFollowing(otherUserId: userInfo.id) { (followed) in
            guard let followed = followed else {
                return
            }
            self.followButton.setFollowState(followed)
            self.followButton.tag = followed ? 1 : 0
            
            self.followButtonSpinner.isHidden = true
            self.followButtonSpinner.stopAnimating()
            
            self.followButton.isEnabled = true
            self.followButton.isHidden = false
        }
        
    }
    
    var likedStatus: Bool? {
        
        didSet {
            guard let liked = self.likedStatus else {
                self.likedImage.isHidden = true
                return
            }
            self.likedImage.image = liked ? #imageLiteral(resourceName: "button_heart_full") : UIImage(imageLiteralResourceName: "overflow_heart")
            self.likedImage.isHidden = false
        }
    }
    
//    var likedUsersInfo: [UserInfo]? {
//        didSet {
//            guard let usersInfo = self.likedUsersInfo else {
//                self.likedCountButton.isUserInteractionEnabled = false
//                self.likedCountButton.isHidden = true
//                for imageView in self.likedUserImageViews {
//                    imageView.isHidden = true
//                }
//                return
//            }
//
//            let likedCount = usersInfo.count
//            self.likedCountButton.setTitle("\(likedCount)", for: UIControl.State.normal)
//            self.likedCountButton.isUserInteractionEnabled = true
//            self.likedCountButton.isHidden = false
//
//            for (index, imageView) in self.likedUserImageViews.enumerated() {
//                guard let userInfo = usersInfo.safeGet(index: index) else {
//                    continue
//                }
//
//                if let avatarUrl = userInfo.avatarUrl {
//                    imageView.kf.indicatorType = .activity
//                    imageView.kf.setImage(with: URL(string: avatarUrl))
//                } else {
//                    imageView.image = User.defaultProfileImage
//                }
//
//                imageView.isHidden = false
//            }
//        }
//    }
    
    private func setupLikedStatus(for post: Post) {
        guard let user = PetDateController.shared.user else {
            self.likedStatus = nil
            return
        }
        user.getSelfLike(for: post) { (liked, _) in
            self.likedStatus = liked
        }
    }
    
//    private func getLikedUser(for post: Post) {
//
//        guard let user = PetDateController.shared.user else {
//            self.likedUsersInfo = nil
//            return
//        }
//
//        user.getLikedUsers(for: post, limitCount: HomePostTableViewCell.maxUserLikesDisplay) { (usersInfo) in
//            self.likedUsersInfo = usersInfo
//        }
//
//    }
}
