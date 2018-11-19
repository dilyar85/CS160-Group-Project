//
//  ConnectWithEmailViewController.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import UIKit
import LeanCloud

//private let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"


//extension String {
//
//    var isValidEmail: Bool {
//        return self.range(of: emailRegex, options: .regularExpression) != nil
//    }
//}


private enum ConnectEmialState {
    case emailEntry
    case signUp
    case logIn
}


class ConnectWithEmailViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    fileprivate var state = ConnectEmialState.emailEntry
    
    @IBOutlet weak var backButton: UIButton!
    @IBAction func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet var textFields: [UITextField]!
    
    @IBOutlet var dividers: [UIView]!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var forgotButton: UIButton!
    
    @IBOutlet weak var successImage: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.successImage.image = nil
        
        for field in self.textFields {
            field.delegate = self //To enable calling method after user clicking Go on keyboard
            field.setNeutral()
        }
        self.errorLabel.isHidden = true
        self.errorLabel.textColor = .errorText
        
        self.set(state: .emailEntry)
        
        
    }
    
    //We need theses methods while waiting result from LeanCloud
    fileprivate func enable() {
        for field in self.textFields {
            field.isUserInteractionEnabled = true
        }
        self.backButton.isUserInteractionEnabled = true
    }
    
    fileprivate func disable() {
        self.view.endEditing(true)
        for field in self.textFields {
            field.isUserInteractionEnabled = false
        }
        self.backButton.isUserInteractionEnabled = false
    }
    
    
    //Set Controller state
    fileprivate func set(state: ConnectEmialState) {
        self.state = state
        switch state {
        case .emailEntry:
            self.textFields[0].setToEmail()
            
            for i in 1..<self.textFields.count {
                let field = self.textFields[i]
                field.isHidden = true
                field.text = nil
                let divider = self.dividers[i]
                divider.isHidden = true
            }
            
            self.scrollView.isScrollEnabled = false
            self.textFields[0].becomeFirstResponder()
            self.forgotButton.isHidden = true
            
        case .signUp:
            self.textFields[1].setToPetName()
            self.textFields[2].setToPassword(signUp: true)
            
            self.textFields[1].isHidden = false
            self.textFields[2].isHidden = false
            self.dividers[1].isHidden = false
            self.dividers[2].isHidden = false
            
            self.textFields[0].setNeutral()
            self.textFields[1].setNeutral()
            self.textFields[2].setNeutral()
            
            self.errorLabel.isHidden = true
            self.errorLabel.text = ""
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
            
            self.scrollView.isScrollEnabled = true
            self.enable()
            self.textFields[1].becomeFirstResponder()
            
            self.forgotButton.isHidden = true
            
        case .logIn:
            self.textFields[1].setToPassword(signUp: false)
            self.textFields[1].isHidden = false
            self.dividers[1].isHidden = false
            self.scrollView.isScrollEnabled = true
            
            self.enable()
            self.textFields[1].becomeFirstResponder()
            
            self.forgotButton.isHidden = false
        }
    }
    
    fileprivate func checkEmail() {
        
        guard let email = self.textFields[0].text?.strip(), email.isValidEmail else {
            self.setEmailInvalid()
            return
        }
        
        self.errorLabel.isHidden = true
        self.errorLabel.text = ""
        
        self.disable()
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        
        //Check if email account is already existed
        LoadingShade.add()
        User.exists(email: email) { (error, exist) in
            LoadingShade.remove()
            guard error == nil else {
                let overlay = WarningOverlayView(
                    retryWarningWithRetryAction: { overlay in
                        overlay.animateOut()
                        self.checkEmail()
                },
                    cancelAction: { overlay in
                        overlay.animateOut()
                }
                )
                overlay.animateIn()
                return
            }
            
            if exist {
                self.set(state: .logIn)
            } else {
                self.set(state: .signUp)
            }
        }
        
    }
    
    fileprivate func setEmailInvalid() {
        
        self.textFields[0].setError()
        self.errorLabel.text = "Please enter valid email address"
        self.errorLabel.isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func go() {
        let email: String
        let password: String
        let userName: String
        
        switch self.state {
        case .emailEntry:
            return
            
            
        case .logIn:
            email = self.textFields[0].text?.strip() ?? ""
            password = self.textFields[1].text ?? ""
            
            self.disable()
            self.textFields[0].setNeutral()
            self.textFields[1].setNeutral()
            self.errorLabel.isHidden = true
            self.errorLabel.text = ""
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
            
            
            LoadingShade.add()
            User.login(email: email, password: password, callback: { (serverError, errorMessage, user) in
                LoadingShade.remove()
                
                guard serverError == nil else {
                    let overlay = WarningOverlayView(
                        retryWarningWithRetryAction: { overlay in
                            overlay.animateOut()
                            self.checkEmail()
                    },
                        cancelAction: { overlay in
                            overlay.animateOut()
                    }
                    )
                    overlay.animateIn()
                    return
                }
                
                if let message = errorMessage {
                    self.errorLabel.text = message
                    self.errorLabel.isHidden = false
                    UIView.animate(withDuration: 0.2) {
                        self.view.layoutIfNeeded()
                    }
                    self.enable()
                } else {
                    self.showSuccess()
                    delay(0.8) {
                        AppDelegate.shared?.transitionToMain(user: user!)
                    }
                }
                
            })
            
            
            
        case .signUp:
            //check length of password
            guard self.textFields[2].text?.characters.count ?? 0 >= 5 else {
                self.textFields[0].setNeutral()
                self.textFields[1].setNeutral()
                self.textFields[2].setError()
                
                self.errorLabel.text = "Password must have more than 5 characters"
                self.errorLabel.isHidden = false
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                }
                self.enable()
                self.textFields[2].becomeFirstResponder()
                return
            }
            
            //check length of user name
            guard self.textFields[1].text?.characters.count ?? 0 >= 1 else {
                self.textFields[0].setNeutral()
                self.textFields[1].setError()
                self.textFields[2].setNeutral()
                
                self.errorLabel.text = "Please enter username"
                self.errorLabel.isHidden = false
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                }
                self.enable()
                self.textFields[1].becomeFirstResponder()
                
                return
            }
            
            email = self.textFields[0].text?.strip() ?? ""
            userName = self.textFields[1].text?.strip() ?? ""
            password = self.textFields[2].text ?? ""
            
            self.disable()
            self.textFields[0].setNeutral()
            self.textFields[1].setNeutral()
            self.textFields[2].setNeutral()
            self.errorLabel.isHidden = true
            self.errorLabel.text = ""
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
            
            LoadingShade.add()
            User.signUp(email: email, petName: userName, password: password, callback: { (error, user) in
                LoadingShade.remove()
                
                guard error == nil, let user = user else {
                    let overlay = WarningOverlayView(
                        retryWarningWithRetryAction: { overlay in
                            overlay.animateOut()
                            self.checkEmail()
                    },
                        cancelAction: { overlay in
                            overlay.animateOut()
                    }
                    )
                    overlay.animateIn()
                    return
                }
                
                self.showSuccess()
                delay(0.8) {
                    AppDelegate.shared?.transitionToMain(user: user)
                }
            })
            
        }
        
    }
    
    fileprivate func showSuccess() {
        self.successImage.image = #imageLiteral(resourceName: "profile_success")
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    // Segue: Forgot Password
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let fpvc = segue.destination as? ForgotPasswordViewController {
            fpvc.email = self.textFields[0].text
        }
    }
    
    
    
}
// MARK: - TextField Delegate

extension ConnectWithEmailViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField === self.textFields[0] {
            self.set(state: .emailEntry)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case self.textFields[0]:
            self.checkEmail()
            
        case self.textFields[1]:
            if self.state == .logIn {
                self.go()
            }
            else if self.state == .signUp {
                self.textFields[2].becomeFirstResponder()
            }
            
        case self.textFields[2]:
            self.go()
            
        default:
            break
        }
        
        return true
    }
    
}

