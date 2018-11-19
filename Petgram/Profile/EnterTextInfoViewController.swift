//
//  EditTextInfoViewController.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import UIKit

enum EnterTextInfoState {
    
    case petName
    case location
    
    case undefined
    
    func getLCUserClassKey() -> LCUserClassKey{
        switch  self {
        case .petName:
            return .petName
        case .location:
            return .petCity
            
        case .undefined:
            return .undefined
        }
    }
    
    var displayTitle:String  {
        get {
            switch self {
            case .petName:
                return "Update pet name"
            case .location:
                return "Update pet location"
                
            case .undefined:
                return "Update info"
                
            }
        }
    }
    
    var displayValue: String? {
        get {
            switch self {
            case .petName:
                return PetDateController.shared.user?.petName
            case .location:
                return PetDateController.shared.user?.petCity
                
            case .undefined:
                return " "
            }
            
        }
    }
}



class EnterTextInfoViewController: UIViewController, UITextFieldDelegate {
    
    var state: EnterTextInfoState?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var currentField: UITextField!
    
    @IBOutlet weak var successImage: UIImageView!
    
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func goBack() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func save() {
        _ = self.textFieldShouldReturn(self.currentField)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .petBackground
        
        self.currentField.becomeFirstResponder()
        self.currentField.delegate = self
        self.errorLabel.isHidden = true
        self.errorLabel.textColor = .ottoErrorText
        self.successImage.image = nil
        
        if let state = self.state {
            self.titleLabel.text = state.displayTitle
            self.currentField.text = state.displayValue
        } else {
            self.titleLabel.text = "Update info"
            self.currentField.text = ""
        }
        
    }
    
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        
        guard let entity = self.state, let value = self.currentField.text, let user = PetDateController.shared.user else {
            return true
        }
        
        let key = entity.getLCUserClassKey().rawValue
        
        LoadingShade.add()
        user.setProfile(key: key, value: value) { (completed) in
            LoadingShade.remove()
            guard completed else {
                let overlay = WarningOverlayView(
                    retryWarningWithRetryAction: { overlay in
                        overlay.animateOut()
                        _ = self.textFieldShouldReturn(self.currentField)
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
                self.navigationController?.popViewController(animated: true)
            }
        }
        return true
    }
    
    fileprivate func showSuccess() {
        self.successImage.image = #imageLiteral(resourceName: "profile_success")
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
}
