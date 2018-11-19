//
//  Setting
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import UIKit
import Foundation
import Apptentive


private let height: CGFloat = 280.0
private let slideTime = 0.2
private let horizontalMargin: CGFloat = 15.0
private let text = "Hey, it’s the guys from Petgram getting back to you :-)"
private let font = UIFont(ottoStyle: .roman, size: 18)


@objc protocol ApptentiveNewMessageNotificationViewDelegate {
    func apptentiveNewMessageNotificationViewDidClose(_ apptentiveNewMessageNotificationView: ApptentiveNewMessageNotificationView)
}

class ApptentiveNewMessageNotificationView: UIWindow {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let body = UIView()
    private let label = UILabel()
    private let closeButton = UIButton()
    
    weak var delegate: ApptentiveNewMessageNotificationViewDelegate?
    
    static func height(with text: String) -> CGFloat {
        let titleWidth = UIScreen.main.bounds.width - 95 // minus margins
        let constrainSize = CGSize(width: titleWidth, height: CGFloat.greatestFiniteMagnitude)
        let attributes = [NSAttributedString.Key.font: font]
        let expectedSize = text.boundingRect(
            with: constrainSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        let titleHeight = ceil(expectedSize.height)
        return titleHeight + 20 + 20
    }
    
    init(messageCount: UInt) {
        let height = ApptentiveNewMessageNotificationView.height(with: text)
        let frame = CGRect(x: horizontalMargin / 2.0, y: 0, width: UIScreen.main.bounds.width - (horizontalMargin * 2.0), height: height)
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        runOnMainThread {

            self.body.frame = self.frame.offsetBy(dx: 0, dy: -height)
            self.body.backgroundColor = UIColor(r: 43, g: 54, b: 73, a: 0.9)
            self.body.round(corners: [.bottomLeft, .bottomRight], radius: 4)
            self.addSubview(self.body)
            
            self.label.text = text
            self.label.textColor = .white
            self.label.font = font
            self.label.numberOfLines = 0
            self.body.addSubview(self.label)
            
//            self.closeButton.addTarget(
//                self,
//                action: #selector(ApptentiveNewMessageNotificationView.hide),
//                for: .touchUpInside
//            )
            self.closeButton.setImage(#imageLiteral(resourceName: "button_x_white"), for: .normal)
            self.closeButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 15, right: 15)
            self.closeButton.alpha = 0.5
            self.body.addSubview(self.closeButton)
            
            self.label.translatesAutoresizingMaskIntoConstraints = false
            self.closeButton.translatesAutoresizingMaskIntoConstraints = false
            
            let views: [String: Any] = [
                "label": self.label,
                "close": self.closeButton
            ]
            
            let horiz = NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-20-[label]-5-[close(40)]-0-|",
                options: [],
                metrics: nil,
                views: views
            )
            let labelVerti = NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-20-[label]-20-|",
                options: [],
                metrics: nil,
                views: views
            )
            let closeHeight = NSLayoutConstraint(
                item: self.closeButton,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1.0,
                constant: 40
            )
            let closeBottom = NSLayoutConstraint(
                item: self,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: self.closeButton,
                attribute: .bottom,
                multiplier: 1.0,
                constant: 0
            )
            
            NSLayoutConstraint.activate(horiz)
            NSLayoutConstraint.activate(labelVerti)
            NSLayoutConstraint.activate([closeHeight, closeBottom])
        }
        
//        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ApptentiveNewMessageNotificationView.tapped)))
        
        self.windowLevel = UIWindow.Level.statusBar + 1
    }
    
    private var open = false
    
    func show() {
        guard !self.open else {
            return
        }
        self.open = true
        
        runOnMainThread {
            self.isHidden = false
            UIView.animate(withDuration: slideTime) {
                self.body.frame = self.frame
            }
        }
        
    }
    
//    func hide() {
//        guard self.open else {
//            return
//        }
//        self.open = false
//
//        runOnMainThread {
//            UIView.animate(
//                withDuration: 0.2,
//                animations: {
//                    self.body.frame = self.frame.offsetBy(dx: 0, dy: -ApptentiveNewMessageNotificationView.height)
//            },
//                completion: { _ in
//                    self.isHidden = true
//                    self.delegate?.apptentiveNewMessageNotificationViewDidClose(self)
//            }
//            )
//        }
//    }
    
//    @objc private func tapped() {
//        if let topVC = UIApplication.shared.keyWindow?.rootViewController {
//            ATConnect.sharedConnection().presentMessageCenter(from: topVC)
//        }
//        self.hide()
//    }
    
}
