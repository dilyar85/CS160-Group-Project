//
//  SelectionViewController.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import UIKit

enum SelectionViewState {
    case petGender
    case petBreed
    
    case undefined
    
    func getLCUserClassKey() -> LCUserClassKey {
        switch self {
        case .petGender:
            return LCUserClassKey.petGender
        case .petBreed:
            return LCUserClassKey.petBreed
            
        case .undefined:
            return .undefined
        }

    }
}

class SelectionListView: UIView {
    
    
    let titleLabel = UILabel()
    let backButton = UIButton()
//    let overflowButton = UIButton()
    let tableView = UITableView()
//    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
//    let emptyView = UIView()
//    let emptyLabel = UILabel()
//    let emptyImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        self.backgroundColor = .petBackground
        
        self.titleLabel.font = UIFont(ottoStyle: .roman, size: 22)
        self.titleLabel.textColor = .white
        self.titleLabel.textAlignment = .center
        
        self.backButton.setImage(#imageLiteral(resourceName: "arrow_left_white"), for: .normal)
        self.backButton.adjustsImageWhenHighlighted = false
    
        
        self.tableView.backgroundColor = .petBackground
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorColor = UIColor(white: 1.0, alpha: 0.5)
        self.tableView.separatorInset = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: 0.0,
            right: 0.0
        )
    
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.backButton.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.titleLabel)
        self.addSubview(self.backButton)
        self.addSubview(self.tableView)
        
        let views = [
            "title": self.titleLabel,
            "back": self.backButton,
            "table": self.tableView,
            ]
        
        let headerHoriz = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-10-[back(==50)]-[title]-50-|",
            options: .alignAllCenterY,
            metrics: nil,
            views: views
        )
        let tableHoriz = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[table]-0-|",
            options: [],
            metrics: nil,
            views: views
        )
        let headerVerti = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-50-[title]-20-[table]-0-|",
            options: [],
            metrics: nil,
            views: views
        )
        
        NSLayoutConstraint.activate(headerHoriz)
        NSLayoutConstraint.activate(tableHoriz)
        NSLayoutConstraint.activate(headerVerti)
    }
    
}



class SelectionViewController: UIViewController, UITabBarDelegate, UITableViewDataSource, UITableViewDelegate, UserNeeded {
    
    var user: User?
    
    private var state: SelectionViewState
    
    private var titleLabel: UILabel! {
        didSet {
            self.titleLabel.text = self.getTitleText(from: self.state)
        }
    }
    
    private var backButton: UIButton! {
        didSet {
            backButton.addTarget(
                self,
                action: #selector(SelectionViewController.backPressed),
                for: .touchUpInside
            )
        }
    }
    @objc private func backPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // protected
    private(set) var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    init (state: SelectionViewState) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        let view = SelectionListView()
        self.titleLabel = view.titleLabel
        self.backButton = view.backButton
        self.tableView = view.tableView
        self.view = view
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        self.setUp()
    }
    
    
    
    public func getTitleText(from state: SelectionViewState) -> String {
        switch state {
        case .petGender:
            return "Please select gender"
        case .petBreed:
            return "Please select breed"
            
        case .undefined:
            return ""
        }
    }
    
    
    
    
    let genders: [String] = ["Boy", "Girl"]
    let breeds: [String] = ["Affenpinscher", "Barbet", "Cairn Terrier", "Chihuahua", "Dachshund", "English Foxhound", "Fox Terrier", "Greyhound", "Havanese", "Kuvasz", "Labradoodle", "Yorkipoo", "Robert", "Ishan"]
    
    // MARK: UITableViewDelegate and UITableViewDataSouce
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.state {
        case .petGender:
            return genders.count
        case .petBreed:
            return breeds.count
        
            
        case .undefined:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = UITableViewCell()
        cell.backgroundColor = .petBackground
        cell.textLabel?.textColor = .white
        cell.selectionStyle = .none
        
        if (self.state == .petGender) {
            cell.textLabel?.text = self.genders[indexPath.row]
        }
        else if (self.state == .petBreed) {
            cell.textLabel?.text = self.breeds[indexPath.row]

        }
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        // Get the correct height if the cell is a DatePickerCell.
//        let cell = tableView.cellForRow(at: indexPath)
//        if (cell is DatePickerCell) {
//            return (cell as! DatePickerCell).datePickerHeight()
//        }
//        
//        return self.tableView.rowHeight
//    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let user = PetDateController.shared.user, let value = self.tableView.cellForRow(at: indexPath)?.textLabel?.text else {
            // TODO: Should transition to Connection Page here
            return
        }
        
        let key = self.state.getLCUserClassKey().rawValue
        
        LoadingShade.add()
        user.setProfile(key: key, value: value) { (completed) in
            LoadingShade.remove()
            guard completed else {
                let overlay = WarningOverlayView(
                    retryWarningWithRetryAction: { overlay in
                        overlay.animateOut()
                        self.tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
                },
                    cancelAction: { overlay in
                        overlay.animateOut()
                })
                
                overlay.animateIn()
                return
            }
            self.navigationController?.popViewController(animated: false)
        }
    }
    
}


