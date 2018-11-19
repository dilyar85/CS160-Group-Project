//
//  SettingsViewController.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import Foundation
import Apptentive



protocol UpdateableCell {
    func update()
}


class SettingsViewController: UIViewController {
    
    //    var user: User?
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.dataSource = self
            self.tableView.delegate = self
            self.tableView.tableHeaderView = UIView(
                frame: CGRect(
                    x: 0,
                    y: 0,
                    width: self.tableView.bounds.width,
                    height: CGFloat.leastNormalMagnitude
                )
            )
        }
    }
    
    @IBAction func backPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .petBackground
        //        NotificationCenter.default.addObserver(
        //            self,
        //            selector: #selector(SettingsViewController.unreadMessageCountChanged(notification:)),
        //            name: .ApptentiveMessageCenterUnreadCountChanged,
        //            object: nil
        //        )
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // don't allow scrolling if content fits in view
        self.tableView.isScrollEnabled = self.tableView.frame.origin.y + self.tableView.contentSize.height > self.view.bounds.height
    }
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        super.prepare(for: segue, sender: sender)
    //
    //        let toVC = segue.destination
    //
    //        if let un = toVC as? UserNeeded {
    //            un.user = self.user
    //        }
    //    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //    @objc private func unreadMessageCountChanged(notification: NSNotification) {
    //        for cell in self.tableView.visibleCells {
    //            if let feedback = cell as? FeedbackCell {
    //                feedback.update()
    //            }
    //        }
    //    }
    
    // MARK: deep linking
    
    //    func openYourInterests(animated: Bool, forceToCategories: Bool = false, forceToKeywords: Bool = false) {
    //
    //        let yivc = YourInterestsViewController()
    //        yivc.user = self.user
    //
    //        if forceToCategories {
    //            yivc.openTab(index: 0, animated: false)
    //        } else if forceToKeywords {
    //            yivc.openTab(index: 1, animated: false)
    //        }
    //
    //        self.navigationController?.pushViewController(yivc, animated: animated)
    //    }
    
    
    //
    //    func openPetProfile(animated: Bool) {
    //        let pvc = self.createPetProfileVC()
    //        self.navigationController?.pushViewController(pvc, animated: animated)
    //    }
    
    
    
    //    func openConnections(animated: Bool) {
    //        // never animate this, all pushing
    //        // needs to be done synchronously
    //        let pvc = self.createProfileVC()
    //        self.navigationController?.pushViewController(pvc, animated: false)
    //        pvc.openConnections(animated: false)
    //    }
    //
    //    func openUberSettings(animated: Bool) {
    //        // never animate this, all pushing
    //        // needs to be done synchronously
    //        let pvc = self.createProfileVC()
    //        self.navigationController?.pushViewController(pvc, animated: false)
    //        pvc.openUberSettings(animated: false)
    //    }
    
    
    //    private func createEditPetProfileVC() -> EditPetProfileViewController {
    //        let vc = mainStoryboard.instantiateViewController(withIdentifier: "EditPetProfileVC") as! EditPetProfileViewController
    //        //        pvc.user = self.user
    //        return vc
    //    }
    //
    //
    
    func openEditPetProfileView(animated: Bool) {
        // never animate this, all pushing
        // needs to be done synchronously
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "EditPetProfileVC") as! EditPetProfileViewController
        vc.user = PetDateController.shared.user
        self.navigationController?.pushViewController(vc, animated: animated)
    }
    
    
    
    func openLegal(animated: Bool) {
        let lvc = LegalViewController()
        self.navigationController?.pushViewController(lvc, animated: animated)
    }
    
    // MARK: deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func logOut() {
        PetDateController.shared.user = nil 
        User.clearSavedUser()
        AppDelegate.shared?.transitionToConnection()
    }
    
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 2
        case 2:
            return 3
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //        return section > 0 ? 40 : CGFloat.leastNormalMagnitude
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 25.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier: String
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            identifier = PetProfileCell.identifier
        case (0, 1):
            identifier = AppSettingsCell.identifier
        case (1, 0):
            identifier = FeedbackCell.identifier
        case (1, 1):
            identifier = RateCell.identifier
        case (2, 0):
            identifier = LegalCell.identifier
        case (2, 1):
            identifier = VersionCell.identifier
        case (2, 2):
            identifier = SignoutCell.identifier
            
        default:
            identifier = ""
        }
        
        return tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: tableView.bounds.width,
                height: self.tableView(
                    self.tableView,
                    heightForHeaderInSection: section
                )
            )
        )
        header.backgroundColor = .petBackground
        
        let label = UILabel()
        switch section {
        case 0:
            label.text = "Legal"
        case 1:
            label.text = "Feedback"
        case 2:
            label.text = "About"
        default:
            break
        }
        label.font = UIFont(ottoStyle: .black, size: 18)
        label.textColor = .white
        label.sizeToFit()
        label.frame.leftMiddle = CGPoint(x: 13, y: header.bounds.height / 2.0)
        header.addSubview(label)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            // Pet Profile
            self.openEditPetProfileView(animated: true)
            break
            
        case (0, 1):
            // TODO: App Settings
            break
            //            self.openAppSettings(
            //                animated: true,
            //                forceToCategories: false,
            //                forceToKeywords: false
            //            )
            
        // feedback
        case (1, 0):
            
            ATConnect.sharedConnection().presentMessageCenter(from: self)
            
        // rate or share
        case (1, 1):
            
            UIApplication.shared.openURL(
                URL(
                    string: "itms-apps://itunes.apple.com/us/app/instagram/id389801252?mt=8&v0=WWW-NAUS-ITSTOP100-FREEAPPS&l=en&ign-mpt=uo%3D4"
                    )!
            )
            
        // Legal
        case (2, 0):
            self.openLegal(animated: true)
            
        //Signout:
        case (2, 2):
            self.logOut()
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .petBackground
        if let uc = cell as? UpdateableCell {
            uc.update()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
}

class PetProfileCell: UITableViewCell {
    static let identifier = "PetProfileCell"
    
}

class AppSettingsCell: UITableViewCell {
    static let identifier = "AppSettingsCell"
}

class FeedbackCell: UITableViewCell {
    static let identifier = "FeedbackCell"
    
    @IBOutlet weak var countView: FeedbackNotificationNumberView! {
        didSet {
            self.update()
        }
    }
    
    func update() {
        self.countView.set(number: Apptentive.shared.unreadMessageCount)
    }
}

class RateCell: UITableViewCell {
    static let identifier = "RateCell"
}

class LegalCell: UITableViewCell {
    static let identifier = "LegalCell"
}

class VersionCell: UITableViewCell, UpdateableCell {
    static let identifier = "VersionCell"
    
    @IBOutlet private weak var label: UILabel!
    
    func update() {
        self.label.text = "Version number: \(UIApplication.shared.versionString)"
    }
}

class SignoutCell: UITableViewCell {
    static let identifier = "LogOutCell"
}
