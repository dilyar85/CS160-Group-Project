//
//  LoadingShade.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import Foundation
import UIKit



class LoadingShade: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    private let spinner = UIActivityIndicatorView()
    
    func setup() {
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.2)
        self.spinner.startAnimating()
        
        self.addSubview(self.spinner)
        self.spinner.translatesAutoresizingMaskIntoConstraints = false
        
        let centerX = NSLayoutConstraint(
            item: self.spinner,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0.0
        )
        let centerY = NSLayoutConstraint(
            item: self.spinner,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0
        )
        
        NSLayoutConstraint.activate([centerX, centerY])
    }
    
    private static var currentShade: LoadingShade?
    
    static func add() {
        runOnMainThread {
            guard self.currentShade == nil else {
                return
            }
            
            let shade = LoadingShade()
            self.currentShade = shade
            
            UIApplication.shared.keyWindow?.addSubview(shade)
            shade.frame = UIScreen.main.bounds
            
            shade.alpha = 0.0
            UIView.animate(withDuration: 0.2) {
                shade.alpha = 1.0
            }
        }
    }
    
    static func remove() {
        runOnMainThread {
            guard let shade = self.currentShade else {
                return
            }
            
            self.currentShade = nil
            
            UIView.animate(withDuration: 0.2, animations: {
                shade.alpha = 0.0
            }, completion: { _ in
                shade.removeFromSuperview()
            })
        }
    }
    
}
