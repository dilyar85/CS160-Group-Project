//
//  PostViewController.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import UIKit

class PostViewController: UIViewController, UITextViewDelegate, UserNeeded {
    
    var postImage: UIImage?
    var user: User?
    
    var userDidEnterText: Bool? = false
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        textView.text = ""
        textView.textColor = .black
        self.userDidEnterText = true
        
    }
    
    
    @IBAction func cancelButtonTapped() {
        // TODO: Need to go back to original page. Go back to Home Page for now
        self.setStatusBar(color: .clear)
        AppDelegate.shared?.transitionToMain(user: self.user!)
    }
    
    @IBAction func postButtonTapped() {
        guard let image = self.postImage else {
            return
        }
        guard let user = self.user else {
            WarningOverlayView.warnToSignInAgain()
            return
        }
        
        let messgae = userDidEnterText ?? false ? self.postTextView.text : nil
        
        LoadingShade.add()
        user.postToFollowers(image: image, message: messgae) { (succeed) in
            LoadingShade.remove()
            guard succeed else {
                let overlay = WarningOverlayView(retryWarningWithRetryAction: { (overlay) in
                    overlay.animateOut()
                    self.postButtonTapped()
                }, cancelAction: { (overlay) in
                    overlay.animateOut()
                })
                overlay.animateIn()
                return
            }
            self.showSuccess()
            delay (0.8) {
                self.setStatusBar(color: .clear)
                AppDelegate.shared?.transitionToMain(user: user)
            }
            
        }
    }
    
    
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var successImage: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.setup()
    }
    
    private func setup() {
        guard let postImage = self.postImage, let _ = self.user else {
            let overlay = WarningOverlayView(retryWarningWithRetryAction: { (overlay) in
                overlay.animateOut()
                self.setup()
            }, cancelAction: { (overlay) in
                overlay.animateOut()
                self.cancelButtonTapped()
            })
            overlay.animateIn()
            return
        }
        
        self.imageView.image = postImage
        self.successImage.image = nil
        
        self.postTextView.delegate = self
        self.postTextView.textColor = .ottoDarkText
        self.postTextView.text = "What's in your mind..." //Need localization
        
        self.setStatusBar(color: .ottoBlue)
        
    }
    
    fileprivate func showSuccess() {
        self.successImage.image = #imageLiteral(resourceName: "profile_success")
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
}

