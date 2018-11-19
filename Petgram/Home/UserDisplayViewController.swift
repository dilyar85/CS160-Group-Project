//
//  UserDisplayViewController.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import UIKit

enum UserDisplayType {
    case followers
    case followings
    case likes
    
    // TODO: Localize Strings
    var title: String {
        get {
            switch self {
            case .followers:
                return "Followers"
            case .followings:
                return "Followings"
            case .likes:
                return "Likes"
            }
        }
    }
    
}


class UsersDisplayViewController: UIViewController {
    
    @IBAction func backButtonTapped() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var usersTableView: UITableView! {
        didSet {
            usersTableView.dataSource = self
            //            usersTableView.delegate = self
        }
    }
    
    var displayType: UserDisplayType?
    
    var usersInfo: [UserInfo]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let type = self.displayType else {
            return
        }
        self.titleLabel.text = type.title
        
    }
    
}

extension UsersDisplayViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usersInfo?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UsersDisplayCell", for: indexPath) as! UsersDisplayCell
        //Set up the cell's property
        cell.userInfo = self.usersInfo?[indexPath.row]
        
        
        cell.followButton.addTarget(
            self,
            action: #selector(UsersDisplayViewController.followButtonTapped),
            for: .touchUpInside
        )
        
        return cell
    }
    
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        print("didSelectRowAt: \(indexPath)")
    //    }
    
    @objc func followButtonTapped() {
        print("followButtonTapped() called!")
    }
    
}


class UsersDisplayCell: UITableViewCell {
    
    @objc func followButtonTapped() {
        print("followButtonTapped() called!")
    }
    
    @IBOutlet weak var avatarImageView: CircleImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    
    
    
    //    @IBAction func followButtonTapped() {
    //        Logger.log("followButtonTapped() called!", logType: .actionLog)
    //        guard let state = self.followButton.currentTitle, let user = PetDateController.shared.user, let userInfo = self.userInfo else {
    //            return
    //        }
    //        self.indicator.startAnimating()
    //        self.indicator.isHidden = false
    //
    //        let followed = state == "关注"
    //        user.follow(userInfo.id, followed, completion: { (success) in
    //            guard success else {
    //                let overlay = WarningOverlayView(retryWarningWithRetryAction: { (overlay) in
    //                    overlay.animateOut()
    //                    self.followButtonTapped()
    //                }, cancelAction: { (overlay) in
    //                    overlay.animateOut()
    //                })
    //                overlay.animateIn()
    //                return
    //            }
    //            self.indicator.isHidden = true
    //            self.indicator.stopAnimating()
    //            self.followButton.setFollowState(!followed)
    //
    //        })
    //
    //    }
    
    
    var userInfo: UserInfo? {
        didSet {
            guard let userInfo = self.userInfo else {
                return
            }
            
            self.nameLabel.text = userInfo.petName
            if let avatarUrl = userInfo.avatarUrl {
                self.avatarImageView.kf.indicatorType = .activity
                self.avatarImageView.kf.setImage(with: URL(string: avatarUrl))
            }
            else {
                self.avatarImageView.image = User.defaultProfileImage
            }
            
            
            self.setupFollowButton(with: userInfo)
            
        }
    }
    
    private func setupFollowButton(with userInfo: UserInfo) {
        
        self.followButton.isUserInteractionEnabled = false
        self.followButton.isHidden = true
        
        self.indicator.startAnimating()
        self.indicator.isHidden = false
        
        guard let user = PetDateController.shared.user else {
            return
        }
        
        user.isFollowing(otherUserId: userInfo.id) { (followed) in
            guard let followed = followed else {
                return
            }
            self.followButton.setFollowState(followed)
            
            self.indicator.isHidden = true
            self.indicator.stopAnimating()
            
            self.followButton.isEnabled = true
            self.followButton.isHidden = false
        }
    }
    
}
