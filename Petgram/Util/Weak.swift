//
//  Weak.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import Foundation
import UIKit

class Weak<T: AnyObject> {
    weak var value: T?
    init (value: T) {
        self.value = value
    }
}
