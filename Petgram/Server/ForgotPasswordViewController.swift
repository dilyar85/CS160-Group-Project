//
//  ForgotPasswordViewController.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import UIKit
import LeanCloud

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {
    
    //style overrice
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func goBack() {
        
        if let navVC = self.navigationController {
            navVC.popViewController(animated: true)
        } else {
            self.presentingViewController?.dismiss(
                animated: true,
                completion: nil
            )
        }
    }
    
    @IBOutlet weak var sendButton: StandardButton!
    @IBOutlet weak var successImage: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    var email: String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let email = self.email {
            self.textField.text = email
        }
        
        self.textField.isUserInteractionEnabled = true
        self.textField.setNeutral()
        self.textField.delegate = self
        self.textField.returnKeyType = .go
        self.textField.tintColor = .white
        self.textField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 0.4)]
        )
        
        self.successImage.alpha = 0.0
        
        self.sendButton.add { [weak self] in
            self?.send()
        }
        
    }
    
    private func send() {
        guard let email = self.textField.text, email.isValidEmail else {
            self.textField.setError()
            return
        }
        LoadingShade.add()
        User.requestResetPassword(forEmail: email) { (succeed) in
            LoadingShade.remove()
            if (succeed) {
                self.view.isUserInteractionEnabled = false
                UIView.animate(withDuration: 0.2) {
                    self.successImage.alpha = 1.0
                }
                delay(1.0, work: self.goBack)
            }
            else {
                let overlay = WarningOverlayView(
                    retryWarningWithRetryAction: { overlay in
                        self.send()
                        overlay.animateOut()
                },
                    cancelAction: { overlay in
                        overlay.animateOut()
                }
                )
                
                overlay.animateIn()
            }
        }
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.send()
        return true
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

