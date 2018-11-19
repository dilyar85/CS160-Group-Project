//
//  CircleImageView.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import Foundation
import UIKit


class CircleImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let circle = UIBezierPath(ovalIn: self.bounds)
        let mask = CAShapeLayer()
        mask.path = circle.cgPath
        self.layer.mask = mask
    }
    
}
