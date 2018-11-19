//
//  EditPetProfileViewController.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import UIKit
import DatePickerDialog

class EditPetProfileViewController: UIViewController, UserNeeded {
    
    
    var user: User?
    

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var adoptedDateLabel: UILabel!
    
    @IBOutlet weak var genderLabel: UILabel!
    
    @IBOutlet weak var breedLabel: UILabel!
    
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBAction func goBack() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changePicture() {
        self.view.endEditing(false)
        OverflowView.addToWindow(context: .profilePicture)
    }
    
    
    @IBAction func enterTextButtonTapped(_ sender: UIButton) {
        let state = self.getEnterTextButtonState(from: sender)
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "EnterTextInfoVC") as! EnterTextInfoViewController
        vc.state = state
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func selectionButtonTapped(_ sender: UIButton) {
        let vc = SelectionViewController(state: self.getSelctionButtonState(from: sender))
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func adoptedDateButtonTapped() {
        
        show(_ title: String,
             doneButtonTitle: String = "Done",
             cancelButtonTitle: String = "Cancel",
             defaultDate: Date = Date(),
             minimumDate: Date? = nil, maximumDate: Date? = nil,
             datePickerMode: UIDatePickerMode = .dateAndTime,
             callback: @escaping DatePickerCallback) {
        
        DatePickerDialog().show("Please select adopted date", doneButtonTitle: "Finish", cancelButtonTitle: "Cancel", datePickerMode: .date) { (date) in
            
            guard let date = date else {
                return
            }
            
            //Show error if user selcet a date in the future
            guard Date().interval(ofComponent: .day, fromDate: date) >= 0 else {
                let overlay = WarningOverlayView(title: "Date cannot be earlier than today", subtitle: nil, topButtonTitle: "Select again", topButtonAction: { (overlay) in
                    overlay.animateOut()
                    self.adoptedDateButtonTapped()
                }, bottomButtonTitle: "Cancel", bottomButtonAction: { (overlay) in
                    overlay.animateOut()
                }, outsideAction: { (overlay) in
                    overlay.animateOut()
                })
                overlay.animateIn()
                return
            }
            
            
            LoadingShade.add()
            self.user?.setProfile(
                key: LCUserClassKey.petAdoptDate.rawValue,
                value: date.getString(withFormat: "YYYY-MM-dd"),
                completion: { (success) in
                LoadingShade.remove()
                
                guard success else {
                    let overlay = WarningOverlayView(retryWarningWithRetryAction: { (overlay) in
                        overlay.animateOut()
                        self.adoptedDateButtonTapped()
                    }, cancelAction: { (overlay) in
                        overlay.animateOut()
                    })
                    overlay.animateIn()
                    return
                }
                
                self.adoptedDateLabel.text = self.user?.petAdoptDate?.getString(withFormat: "YYYY-MM-dd")
                
            })
            
        }
    }
    
    // MARK: View Set Up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .petBackground
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector (setUpPetInfoLabels),
            name: .userInfoDidUpdated,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setUpPetInfoLabels()
    }
    
    
    // If profile is not available, won't show their lables, just an arrow >
    @objc private func setUpPetInfoLabels() {
        guard let user = self.user else {
            return
        }
        
        if let petName = user.petName {
            self.nameLabel.text = petName
            self.nameLabel.isHidden = false
        } else {
            self.nameLabel.isHidden = true
            self.nameLabel.text = ""
        }
        
        if let petAdoptedDate = user.petAdoptDate {
            self.adoptedDateLabel.text = petAdoptedDate.getString(withFormat: "MM-dd-YYYY")
            self.adoptedDateLabel.isHidden = false
        } else {
            self.adoptedDateLabel.isEnabled = true
            self.adoptedDateLabel.text = ""
        }
        
        if let gender = user.petGender {
            self.genderLabel.text = gender
            self.genderLabel.isHidden = false
        } else {
            self.genderLabel.isHidden = true
            self.genderLabel.text = ""
        }
        
        if let petBreed = user.petBreed {
            self.breedLabel.text = petBreed
            self.breedLabel.isHidden = false
        } else {
            self.breedLabel.isHidden = true
            self.breedLabel.text = ""
        }
        
        if let petCity = user.petCity {
            self.locationLabel.text = petCity
            self.locationLabel.isHidden = false
        } else {
            self.locationLabel.isHidden = true
            self.locationLabel.text = ""
        }
    }
    
    private func getEnterTextButtonState(from button: UIButton) -> EnterTextInfoState {
        if (button.tag == 0) {
            return .petName
        }
        
        if (button.tag == 4) {
            return .location
        }
        
        return .undefined
    }
    
    private func getSelctionButtonState(from button: UIButton) -> SelectionViewState {
        
        if (button.tag == 2) {
            return .petGender
        }
        if (button.tag == 3) {
            return .petBreed
        }
        return .undefined
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}



