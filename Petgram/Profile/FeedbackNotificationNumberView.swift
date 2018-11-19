//
//  NotificationNumberView.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import UIKit


class FeedbackNotificationNumberView: UIView {
    
    @IBOutlet private weak var label: UILabel? {
        didSet {
            if let num = self.number {
                self.set(number: num)
            }
        }
    }
    
    private var number: UInt?
    
    func set(number: UInt) {
        self.number = number
        runOnMainThread {
            self.label?.text = "\(number) new message(s)"
            self.isHidden = number <= 0
        }
    }
    
}
