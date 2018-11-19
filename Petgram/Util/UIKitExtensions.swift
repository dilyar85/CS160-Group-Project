//
//  UIKitExtensions.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    
    var versionString: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
}

// MARK: UIViewControll Extension

extension UIViewController {
    
    var deepPresentedViewControllers: [UIViewController] {
        var presented = [UIViewController]()
        
        var vc = self.presentedViewController
        while vc != nil {
            presented.append(vc!)
            vc = vc?.presentedViewController
        }
        
        return presented
    }
    
    var deepChildViewControllers: [UIViewController] {
        var children = [UIViewController]()
        addChildren(of: self, to: &children)
        return children
    }
    
    func nuke() {
        for vc in self.deepChildViewControllers {
            if var un = vc as? UserNeeded {
                un.user = nil
            }
        }
        for vc in self.deepChildViewControllers {
            vc.dismiss(animated: false, completion: nil)
            vc.removeFromParent()
            for sv in vc.view.deepSubviews {
                sv.removeFromSuperview()
            }
        }
    }
    
    func setStatusBar(color: UIColor) {
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        
        statusBar.backgroundColor = color 
    }
    
    
}

private func addChildren(of viewController: UIViewController, to children: inout [UIViewController]) {
    children.append(viewController)
    for cvc in viewController.children {
        addChildren(of: cvc, to: &children)
    }
    if let presented = viewController.presentedViewController {
        children.append(presented)
        addChildren(of: presented, to: &children)
    }
}



extension UIView {
    
    func round(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: self.bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(
                width: radius,
                height: radius
            )
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if parentResponder is UIViewController {
                return parentResponder as! UIViewController!
            }
        }
        return nil
    }
    
    var deepSubviews: [UIView] {
        var views = [UIView]()
        addSubviews(of: self, to: &views)
        return views
    }
    
    private func addSubviews(of view: UIView, to views: inout [UIView]) {
        views.append(view)
        for sv in view.subviews {
            addSubviews(of: sv, to: &views)
        }
    }
    
}

extension UITextField{
    
    func setNeutral() {
        self.textColor = .white
        self.attributedPlaceholder = NSAttributedString(
            string: self.placeholder!,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.neturalPlaceHolderColor]
        )
        self.tintColor = .white
    }
    
    func setToPostMessage() {
        self.textColor = .black
        self.attributedPlaceholder = NSAttributedString(
            string: self.placeholder!,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.ottoDarkText]
        )
        self.autocapitalizationType = .sentences
        self.autocorrectionType = .no
        self.spellCheckingType = .yes
        self.keyboardType = .twitter
        self.returnKeyType = .done
        self.isSecureTextEntry = false
    }
    
    
    func setToEmail() {
        self.placeholder = "Email"
        self.autocapitalizationType = .none
        self.autocorrectionType = .no
        self.spellCheckingType = .no
        self.keyboardType = .emailAddress
        self.returnKeyType = .go
        self.isSecureTextEntry = false
        self.setNeutral()
    }
    
    func setToPetName() {
        self.placeholder = "Pet Name"
        self.autocapitalizationType = .words
        self.autocorrectionType = .no
        self.spellCheckingType = .yes
        self.keyboardType = .default
        self.returnKeyType = .next
        self.isSecureTextEntry = false
        self.setNeutral()
    }
    
    func setToPassword(signUp: Bool, text: String? = nil, returnType: UIReturnKeyType = .go) {
        self.placeholder = text ?? (signUp ? "Password (minimum length 5)" : "Password")
        self.autocapitalizationType = .words
        self.autocorrectionType = .no
        self.spellCheckingType = .yes
        self.keyboardType = .default
        self.returnKeyType = returnType
        self.isSecureTextEntry = true
        self.setNeutral()
    }
    
    func setError() {
        self.textColor = .errorText
        self.attributedPlaceholder = NSAttributedString(
            string: self.placeholder!,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.errorText]
        )
        self.tintColor = .white
    }
    
    
}

extension Date {
    
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        
        let currentCalendar = Calendar.current
        
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        
        return end - start
    }
    
    func getString(withFormat format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: self)
    }
    
}



extension UIColor {
    
    convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1.0) {
        let safeR = max(min(r, 255), 0)
        let safeG = max(min(g, 255), 0)
        let safeB = max(min(b, 255), 0)
        
        self.init(
            red:   CGFloat(safeR) / 255.0,
            green: CGFloat(safeG) / 255.0,
            blue:  CGFloat(safeB) / 255.0,
            alpha: a
        )
    }
    
    
    class var errorText: UIColor {
        return UIColor(r: 255, g: 255, b: 50)
    }
    
    class var neturalPlaceHolderColor :UIColor {
        return UIColor(white: 1.0, alpha: 0.4)
    }
    
    
    class var ottoDarkText: UIColor {
        return UIColor(r: 72, g: 83, b: 102)
    }
    class var ottoLightText: UIColor {
        return UIColor(white: 0.0, alpha: 0.5)
    }
    class var ottoGlass: UIColor {
        return UIColor(white: 1.0, alpha: 0.75)
    }
    class var ottoFrostedGlass: UIColor {
        return UIColor(white: 1.0, alpha: 0.95)
    }
    class var ottoErrorText: UIColor {
        return UIColor(r: 255, g: 255, b: 51)
    }
    class var ottoBlue: UIColor {
        return UIColor(r: 64, g: 180, b: 229)
    }
    class var ottoBlueNightMode: UIColor {
        return UIColor(r: 114, g: 190, b: 233)
    }
    class var ottoGreen: UIColor {
        return UIColor(r: 123, g: 213, b: 127)
    }
    class var ottoRed: UIColor {
        return UIColor(r: 222, g: 106, b: 106)
    }
    class var petBackground: UIColor {
        return .ottoBlue
    }
    
}

// MARK: UIFont Extension

enum OttoFontStyle: String {
    case black         = "Avenir-Black"
    case blackOblique  = "Avenir-BlackOblique"
    case book          = "Avenir-Book"
    case bookOblique   = "Avenir-BookOblique"
    case heavy         = "Avenir-Heavy"
    case heavyOblique  = "Avenir-HeavyOblique"
    case light         = "Avenir-Light"
    case lightOblique  = "Avenir-LightOblique"
    case medium        = "Avenir-Medium"
    case mediumOblique = "Avenir-MediumOblique"
    case oblique       = "Avenir-Oblique"
    case roman         = "Avenir-Roman"
}

extension UIFont {
    
    convenience init(ottoStyle: OttoFontStyle, size: CGFloat) {
        self.init(name: ottoStyle.rawValue, size: size)!
    }
    
}

// MARK: UILayoutPriority Extension

extension UILayoutPriority {
    static let veryLow:  UILayoutPriority = UILayoutPriority(rawValue: 1)
    static let low:      UILayoutPriority = UILayoutPriority(rawValue: 250)
    static let medium:   UILayoutPriority = UILayoutPriority(rawValue: 500)
    static let high:     UILayoutPriority = UILayoutPriority(rawValue: 750)
    static let veryHigh: UILayoutPriority = UILayoutPriority(rawValue: 999)
    static let required: UILayoutPriority = UILayoutPriority(rawValue: 1000)
}

// MARK: NSLayoutConstraint Extension

extension NSLayoutConstraint {
    
    convenience init(item firstItem: Any, attribute firstAttribute: NSLayoutConstraint.Attribute, relatedBy relation: NSLayoutConstraint.Relation, toItem secondItem: Any?, attribute secondAttribute: NSLayoutConstraint.Attribute, multiplier: CGFloat, constant: CGFloat, priority: UILayoutPriority) {
        
        self.init(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant
        )
        self.priority = priority
        
    }
    
}

extension UIButton {
    func addBorder(color: UIColor) {
        self.layer.borderWidth = 1
        self.layer.borderColor = color.cgColor
    }
    
    func setFollowState(_ followed: Bool) {
        if followed {
            self.setTitle("Followed", for: .normal)
            self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            self.setTitleColor(UIColor.darkText, for: .normal)
            self.backgroundColor = UIColor.white
            self.addBorder(color: .ottoLightText)
        } else {
            self.setTitle("Follow", for: .normal)
            self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            self.setTitleColor(UIColor.white, for: .normal)
            self.backgroundColor = UIColor.ottoBlue
        }

    }
}
