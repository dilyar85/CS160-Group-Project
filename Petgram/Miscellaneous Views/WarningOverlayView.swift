//
//  WarningOverlayView.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import UIKit


class WarningOverlayView: UIView {
    
    
    static let defaultWarningTitle  = "Oops, something is not right :("
    static let confrimNetWorkConnectionSubtitle = "Please check your connection"
    
    class func warnToSignInAgain() {
        let overlay = WarningOverlayView(
            title: "Please signin again", subtitle: nil, topButtonTitle: "Go back to signin page",
            topButtonAction: { (overlay) in
            overlay.animateOut()
            AppDelegate.shared?.transitionToConnection()

        }, bottomButtonTitle: nil, bottomButtonAction: nil) { (overlay) in
            overlay.animateOut()
            AppDelegate.shared?.transitionToConnection()
            
        }
        overlay.animateIn()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(retryWarningWithRetryAction retryAction: @escaping (WarningOverlayView) -> (), cancelAction: @escaping (WarningOverlayView) -> ()) {
        
        self.init(
            title: WarningOverlayView.defaultWarningTitle,
            subtitle: nil,
            topButtonTitle: "Try again",
            topButtonAction: retryAction,
            bottomButtonTitle: "Cancle",
            bottomButtonAction: cancelAction,
            outsideAction: cancelAction
        )
    }
    
    
    
//    convenience init(title: String = defaultWarningTitle, subTitle: String, retryWarningWithRetryAction retryAction: @escaping (WarningOverlayView) -> (), cancelAction: @escaping (WarningOverlayView) -> ()) {
//        
//        self.init(
//            title: title,
//            subtitle: subTitle,
//            topButtonTitle: "再试一次",
//            topButtonAction: retryAction,
//            bottomButtonTitle: "取消",
//            bottomButtonAction: cancelAction,
//            outsideAction: cancelAction
//        )
//        
//    }
    
    init(title: String, subtitle: String?, topButtonTitle: String, topButtonAction: @escaping (WarningOverlayView) -> (), bottomButtonTitle: String?, bottomButtonAction: ((WarningOverlayView) -> ())?, outsideAction: @escaping (WarningOverlayView) -> ()) {
        
        self.topButtonAction = topButtonAction
        self.bottomButtonAction = bottomButtonAction
        self.outsideAction = outsideAction
        
        
        super.init(frame: CGRect.zero)
        
        self.setup(
            title: title,
            subtitle: subtitle,
            topButtonTitle: topButtonTitle,
            bottomButtonTitle: bottomButtonTitle
        )
        
    }
    
    
    let topButtonAction: (WarningOverlayView) -> ()
    let bottomButtonAction: ((WarningOverlayView) -> ())?
    let outsideAction: (WarningOverlayView) -> ()
    
    fileprivate let dropDown = UIView()
    private var dropDownBottomConstraint: NSLayoutConstraint!
    
    private func setup(title: String, subtitle: String?, topButtonTitle: String, bottomButtonTitle: String?) {
        
        self.dropDown.backgroundColor = UIColor(white: 1.0, alpha: 0.95)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont(ottoStyle: .heavy, size: 21)
        titleLabel.textColor = .ottoDarkText
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont(ottoStyle: .roman, size: 18)
        subtitleLabel.textColor = .ottoDarkText
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        
        let topButton = StandardButton.button(withStyle: .blue)
        topButton.title = topButtonTitle
        // accessibility
        topButton.isAccessibilityElement = true
        topButton.accessibilityLabel = topButtonTitle
        topButton.accessibilityTraits = UIAccessibilityTraitButton
        topButton.add { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.topButtonAction(strongSelf)
        }
        
        let bottomButton = StandardButton.button(withStyle: .clearBlueText)
        let hasBottom: Bool
        if let bottomText = bottomButtonTitle, let bottomAction = self.bottomButtonAction {
            hasBottom = true
            bottomButton.title = bottomText
            // accessibility
            bottomButton.isAccessibilityElement = true
            bottomButton.accessibilityLabel = bottomText
            bottomButton.accessibilityTraits = UIAccessibilityTraitButton
            bottomButton.add { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                bottomAction(strongSelf)
            }
        } else {
            hasBottom = false
            bottomButton.isHidden = true
        }
        
        self.dropDown.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        topButton.translatesAutoresizingMaskIntoConstraints = false
        bottomButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.dropDown)
        self.dropDown.addSubview(titleLabel)
        if subtitle != nil {
            self.dropDown.addSubview(subtitleLabel)
        }
        self.dropDown.addSubview(topButton)
        if hasBottom {
            self.dropDown.addSubview(bottomButton)
        }
        
        let font = topButton.font
        let attributes = [NSFontAttributeName: font]
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let bounding = CGSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
        
        let topWidth = topButtonTitle.boundingRect(
            with: bounding,
            options: options,
            attributes: attributes,
            context: nil
            ).width
        let bottomWidth = bottomButtonTitle?.boundingRect(
            with: bounding,
            options: options,
            attributes: attributes,
            context: nil
            ).width ?? 0
        let buttonWidth = max(topWidth, bottomWidth) + 60
        
        
        let views = [
            "dd": self.dropDown,
            "title": titleLabel,
            "subtitle": subtitleLabel,
            "top": topButton,
            "bottom": bottomButton
        ]
        let metrics: [String: CGFloat] = [
            "buttonHeight": 50
        ]
        
        var vertiFormat = "V:|-35-[title]-30-"
        if subtitle != nil {
            vertiFormat += "[subtitle]-30-"
        }
        vertiFormat += "[top(==buttonHeight)]"
        if hasBottom {
            vertiFormat += "-10-[bottom(==buttonHeight)]"
        }
        vertiFormat += "-20-|"
        let verti = NSLayoutConstraint.constraints(
            withVisualFormat: vertiFormat,
            options: .alignAllCenterX,
            metrics: metrics,
            views: views
        )
        
        let centerX = NSLayoutConstraint(
            item: titleLabel,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0.0
        )
        
        let topButtonWidth = NSLayoutConstraint(
            item: topButton,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: buttonWidth
        )
        
        let ddHoriz = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[dd]-0-|",
            options: [],
            metrics: nil,
            views: views
        )
        let ddBottom = NSLayoutConstraint(
            item: self.dropDown,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1.0,
            constant: 0.0
        )
        
        NSLayoutConstraint.activate(verti)
        NSLayoutConstraint.activate([centerX, topButtonWidth])
        NSLayoutConstraint.activate(ddHoriz)
        NSLayoutConstraint.activate([ddBottom])
        
        if hasBottom {
            let bottomButtonWidth = NSLayoutConstraint(
                item: bottomButton,
                attribute: .width,
                relatedBy: .equal,
                toItem: topButton,
                attribute: .width,
                multiplier: 1.0,
                constant: 0.0
            )
            
            NSLayoutConstraint.activate([bottomButtonWidth])
        }
        
        self.dropDownBottomConstraint = ddBottom
        
        let tgr = UITapGestureRecognizer(
            target: self,
            action: #selector(WarningOverlayView.tapped)
        )
        tgr.delegate = self
        self.addGestureRecognizer(tgr)
        
    }
    
    @objc private func tapped() {
        self.outsideAction(self)
    }
    
    func animateIn() {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        window.windowLevel = UIWindowLevelStatusBar + 1
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        window.addSubview(self)
        
        let views = ["self": self]
        
        let horiz = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[self]-0-|",
            options: [],
            metrics: nil,
            views: views
        )
        let verti = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[self]-0-|",
            options: [],
            metrics: nil,
            views: views
        )
        NSLayoutConstraint.activate(horiz)
        NSLayoutConstraint.activate(verti)
        
        self.dropDown.layoutIfNeeded()
        self.layoutIfNeeded()
        window.layoutIfNeeded()
        self.dropDownBottomConstraint.constant = self.dropDown.bounds.height
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
            self.backgroundColor = UIColor(white: 0.0, alpha: 0.36)
        }
    }
    
    func animateOut() {
        guard let constraint = self.dropDownBottomConstraint else {
            return
        }
        
        self.layoutIfNeeded()
        constraint.constant = 0
        UIView.animate(withDuration: 0.2, animations: {
            self.layoutIfNeeded()
            self.backgroundColor = .clear
        }, completion: { _ in
            self.removeFromSuperview()
            UIApplication.shared.keyWindow?.windowLevel = UIWindowLevelNormal
        })
    }
    
}

extension WarningOverlayView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !self.dropDown.frame.contains(touch.location(in: self))
    }
    
}
