//
//  Constants.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import Foundation
import UIKit


let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)

let onboardingStoryboard = UIStoryboard(name: "Onboarding", bundle: Bundle.main)
let connectStoryboard = UIStoryboard(name: "Connect", bundle: Bundle.main)

var deviceID: String? {
    return UIDevice.current.identifierForVendor?.uuidString
}

let navBarHeight: CGFloat = 75

let validListenedDuration: TimeInterval = 1.0
