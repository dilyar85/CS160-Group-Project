//
//  BottomNavigationView.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import Foundation
import UIKit
//import SwiftyJSON


@objc enum NavigationSection: Int {
    case home
    //    case search
    case post
    //    case date
    case profile
    
    static var all: [NavigationSection] {
        //        return [.home, .search, .camera, .date, .profile]
        return [.home, .post, .profile]
    }
    
    var image: UIImage {
        switch self {
        case .home:
            return #imageLiteral(resourceName: "nav_bar_library")
            //        case .search:
        //            return #imageLiteral(resourceName: "nav_bar_search")
        case .post:
            return #imageLiteral(resourceName: "nav_bar_browse")
            //        case .date:
        //            return #imageLiteral(resourceName: "nav_bar_date")
        case .profile:
            return #imageLiteral(resourceName: "nav_bar_me")
        }
    }
    
    var selectedImage: UIImage {
        switch self {
        case .home:
            return #imageLiteral(resourceName: "nav_bar_library_selected")
            //        case .search:
        //            return
        case .post:
            return #imageLiteral(resourceName: "nav_bar_browse_selected")
            //        case .date:
        //            return #imageLiteral(resourceName: "nav_bar_date_selected")
        case .profile:
            return #imageLiteral(resourceName: "nav_bar_me_selected")
        }
        
    }
    
    var name: String {
        switch self {
        case .home:
            return "Home"
            //        case .search:
        //            return "Search"
        case .post:
            return "Post"
            //        case .date:
        //            return "Date"
        case .profile:
            return "Mine"
        }
    }
    
    var keyForAnalytics: String {
        return self.name
    }
    
}

@objc protocol AppNavigator: class {
    func open(section: NavigationSection, data: [String: Any]?, sender: Any)
}

@objc protocol BottomNavigationViewDelegate {
    func bottomNavigationViewDidTap(_ bottomNavigationView: BottomNavigationView)
}

extension NSNotification.Name {
    static let navBarDidSelectSection = NSNotification.Name("navBarDidSelectSection")
}



class BottomNavigationView: UIView, AppNavigatorNeeded {
    
    static let sectionRawValueKey = "sectionRawValue"
    
    weak var delegate: BottomNavigationViewDelegate?
    
    private static let highlightedColor = UIColor.white
    private static let unhighlightedColor = UIColor(white: 0.3, alpha: 1.0)
    
    static let height: CGFloat = 50
    
    weak var appNavigator: AppNavigator?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    private let images: [UIImageView] = {
        return NavigationSection.all.map {
            UIImageView(image: $0.image) //cool
        }
    }()
    
    private let labels: [UILabel] = NavigationSection.all
        .map { $0.name }
        .map { text -> UILabel in
            let label = UILabel()
            label.text = text
//            label.font = UIFont(ottoStyle: .roman, size: 12)
            label.textColor = BottomNavigationView.unhighlightedColor
            return label
    }
    
    // if use repeated value initializer,
    // all elements === each other
    private let buttons = (0..<3).map { _ in UIButton() } // TODO: Change back to 5 future
    
    private var libraryButton: UIButton?
    
    private let newCountView: NewCountView = {
        let view = NewCountView()
        view.backgroundColor = .clear
        return view
    }()
    
    private func setup() {
        
        //        NotificationCenter.default.addObserver(
        //            self,
        //            selector: #selector(BottomNavigationView.updateNewCountView),
        //            name: .UIApplicationDidBecomeActive,
        //            object: nil
        //        )
        
        
        // if use repeated value initializer,
        // all elements === each other
        
        for index in 0..<self.images.count {
            let image = self.images[index]
            let label = self.labels[index]
            
            image.translatesAutoresizingMaskIntoConstraints = false
            label.translatesAutoresizingMaskIntoConstraints = false
            
            let button = self.buttons[index]
            button.addSubview(image)
            button.addSubview(label)
            
            let imageCenterX = NSLayoutConstraint(
                item: image,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: button,
                attribute: .centerX,
                multiplier: 1.0,
                constant: 0.0
            )
            let imageCenterY = NSLayoutConstraint(
                item: image,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: button,
                attribute: .centerY,
                multiplier: 0.8,
                constant: 0.0
            )
            let labelCenterX = NSLayoutConstraint(
                item: label,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: button,
                attribute: .centerX,
                multiplier: 1.0,
                constant: 0.0
            )
            let labelBottom = NSLayoutConstraint(
                item: label,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: button,
                attribute: .bottom,
                multiplier: 0.9,
                constant: 0.0
            )
            
            
            NSLayoutConstraint.activate([
                imageCenterX,
                imageCenterY,
                labelCenterX,
                labelBottom
                ])
        }
        
        for (index, button) in buttons.enumerated() {
            
            button.tag = index
            button.addTarget(
                self,
                action: #selector(BottomNavigationView.sectionTapped(button:)),
                for: .touchUpInside
            )
            
            
            button.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(button)
            
            //first button
            if index == 0 {
                
                let left = NSLayoutConstraint(
                    item: button,
                    attribute: .leading,
                    relatedBy: .equal,
                    toItem: self,
                    attribute: .leading,
                    multiplier: 1.0,
                    constant: 0.0
                )
                NSLayoutConstraint.activate([left])
            }
                //middle buttons
            else {
                let lastButton = buttons[index - 1]
                
                let left = NSLayoutConstraint(
                    item: button,
                    attribute: .leading,
                    relatedBy: .equal,
                    toItem: lastButton,
                    attribute: .trailing,
                    multiplier: 1.0,
                    constant: 0.0
                )
                let equalWidth = NSLayoutConstraint(
                    item: button,
                    attribute: .width,
                    relatedBy: .equal,
                    toItem: lastButton,
                    attribute: .width,
                    multiplier: 1.0,
                    constant: 0.0
                )
                NSLayoutConstraint.activate([left, equalWidth])
            }
            //last button
            if index == buttons.count - 1 {
                let right = NSLayoutConstraint(
                    item: button,
                    attribute: .trailing,
                    relatedBy: .equal,
                    toItem: self,
                    attribute: .trailing,
                    multiplier: 1.0,
                    constant: 0.0
                )
                NSLayoutConstraint.activate([right])
            }
            
            
            let top = NSLayoutConstraint(
                item: button,
                attribute: .top,
                relatedBy: .equal,
                toItem: self,
                attribute: .top,
                multiplier: 1.0,
                constant: 0.0
            )
            let bottom = NSLayoutConstraint(
                item: button,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: self,
                attribute: .bottom,
                multiplier: 0.8,
                constant: 0.0
            )
            
            NSLayoutConstraint.activate([top, bottom])
        }
        
        //        self.newCountView.translatesAutoresizingMaskIntoConstraints = false
        //        self.buttons[1].addSubview(self.newCountView)
        
        //        let views = ["new": self.newCountView]
        //
        //        let verti = NSLayoutConstraint.constraints(
        //            withVisualFormat: "V:|-6-[new(==18)]",
        //            options: [],
        //            metrics: nil,
        //            views: views
        //        )
        //        let centerX = NSLayoutConstraint(
        //            item: self.newCountView,
        //            attribute: .centerX,
        //            relatedBy: .equal,
        //            toItem: self.buttons.last,
        //            attribute: .centerX,
        //            multiplier: 1.4,
        //            constant: 0.0
        //        )
        //
        //        NSLayoutConstraint.activate(verti)
        //        NSLayoutConstraint.activate([centerX])
        //
        //        self.updateNewCountView()
    }
    
    @objc private func sectionTapped(button: UIButton) {
        
        self.delegate?.bottomNavigationViewDidTap(self)
        
        guard let section = NavigationSection(rawValue: button.tag) else {
            return
        }
        
        NotificationCenter.default.post(
            name: .navBarDidSelectSection,
            object: self,
            userInfo: [BottomNavigationView.sectionRawValueKey: section.rawValue]
        )
        
        self.appNavigator?.open(section: section, data: nil, sender: self)
        
        
    }
    
    
    private(set) var currentSection: NavigationSection = .home
    
    func setHighlighted(section: NavigationSection) {
        for sec in NavigationSection.all {
            let index = sec.rawValue
            self.images[index].image = section == sec
                ? sec.selectedImage
                : sec.image
            self.labels[index].textColor = section == sec
                ? BottomNavigationView.highlightedColor
                : BottomNavigationView.unhighlightedColor
        }
        
        self.currentSection = section
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

