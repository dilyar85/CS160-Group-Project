//
//  CoreGraphicsUtil.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import Foundation
import CoreGraphics

/*
func ==(left: CGPoint, right: CGPoint) -> Bool {
    return left.x == right.x && left.y == right.y
}

func ==(left: CGSize, right: CGSize) -> Bool {
    return left.width == right.width && left.height == right.height
}
 */

func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func +(left: Int, right: CGFloat) -> CGFloat {
    return CGFloat(left) + right
}

func +(left: CGFloat, right: Int) -> CGFloat {
    return left + CGFloat(right)
}

func -(left: Int, right: CGFloat) -> CGFloat {
    return CGFloat(left) - right
}

func -(left: CGFloat, right: Int) -> CGFloat {
    return left - CGFloat(right)
}

func *(left: Int, right: CGFloat) -> CGFloat {
    return CGFloat(left) * right
}

func *(left: CGFloat, right: Int) -> CGFloat {
    return left * CGFloat(right)
}

func /(left: Int, right: CGFloat) -> CGFloat {
    return CGFloat(left) / right
}

func /(left: CGFloat, right: Int) -> CGFloat {
    return left / CGFloat(right)
}

// MARK: CGRect Extension

func == (lhs: CGRect, rhs: CGRect) -> Bool {
    return lhs.origin == rhs.origin && lhs.size == rhs.size
}

extension CGRect {
    
    init(bottomLeft: CGPoint, size: CGSize) {
        self.origin = (CGPoint(x: bottomLeft.x, y: bottomLeft.y - size.height))
        self.size = size
    }
    
    init(topRight: CGPoint, size: CGSize) {
        self.origin = (CGPoint(x: topRight.x + size.width, y: topRight.y))
        self.size = size
    }
    
    init(bottomRight: CGPoint, size: CGSize) {
        self.origin = (CGPoint(x: bottomRight.x - size.width, y: bottomRight.y - size.height))
        self.size = size
    }
    
    init(center: CGPoint, size: CGSize) {
        self.origin = CGPoint(x: center.x - size.width / 2.0, y: center.y - size.height / 2.0)
        self.size = size
    }
    
    init(topMiddle: CGPoint, size: CGSize) {
        self.origin = CGPoint(x: topMiddle.x - size.width / 2.0, y: topMiddle.y)
        self.size = size
    }
    
    init(bottomMiddle: CGPoint, size: CGSize) {
        self.origin = CGPoint(x: bottomMiddle.x - size.width / 2.0, y: bottomMiddle.y - size.height)
        self.size = size
    }
    
    init(leftMiddle: CGPoint, size: CGSize) {
        self.origin = CGPoint(x: leftMiddle.x, y: leftMiddle.y - size.height / 2.0)
        self.size = size
    }
    
    init(rightMiddle: CGPoint, size: CGSize) {
        self.origin = CGPoint(x: rightMiddle.x - size.width, y: rightMiddle.y - size.height / 2.0)
        self.size = size
    }
    
    var center: CGPoint {
        get {
            return CGPoint(x: self.midX, y: self.midY)
        }
        set(newVal) {
            self.origin = CGPoint(x: newVal.x - size.width / 2.0, y: newVal.y - size.height / 2.0)
        }
    }
    
    var topMiddle: CGPoint {
        get {
            return CGPoint(x: self.midX, y: self.minY)
        }
        set(newVal) {
            self.origin = CGPoint(x: newVal.x - size.width / 2.0, y: newVal.y)
        }
    }
    
    var bottomMiddle: CGPoint {
        get {
            return CGPoint(x: self.midX, y: self.maxY)
        }
        set(newVal) {
            self.origin = CGPoint(x: newVal.x - size.width / 2.0, y: newVal.y - size.height)
        }
    }
    
    var leftMiddle: CGPoint {
        get {
            return CGPoint(x: self.minX, y: self.midY)
        }
        set(newVal) {
            self.origin = CGPoint(x: newVal.x, y: newVal.y - size.height / 2.0)
        }
    }
    
    var rightMiddle: CGPoint {
        get {
            return CGPoint(x: self.maxX, y: self.midY)
        }
        set(newVal) {
            self.origin = CGPoint(x: newVal.x - size.width, y: newVal.y - size.height / 2.0)
        }
    }
    
    var topLeft: CGPoint {
        get {
            return self.origin
        }
        set(newVal) {
            self.origin = newVal
        }
    }
    
    var topRight: CGPoint {
        get {
            return CGPoint(x: self.origin.x + self.size.width, y: self.origin.y)
        }
        set(newVal) {
            self.origin = CGPoint(x: newVal.x - self.size.width, y: newVal.y)
        }
    }
    
    var bottomLeft: CGPoint {
        get {
            return CGPoint(x: self.origin.x, y: self.origin.y + self.size.height)
        }
        set(newVal) {
            self.origin = CGPoint(x: newVal.x, y: newVal.y - self.size.height)
        }
    }
    
    var bottomRight: CGPoint {
        get {
            return CGPoint(x: self.origin.x + self.size.width, y: self.origin.y + self.size.height)
        }
        set(newVal) {
            self.origin = CGPoint(x: newVal.x - self.size.width, y: newVal.y - self.size.height)
        }
    }
    
}

// MARK: CGPoint functions

func midpoint(p1: CGPoint, _ p2: CGPoint) -> CGPoint {
    return CGPoint(x: (p1.x + p2.x) / 2.0, y: (p1.y + p2.y) / 2.0)
}

extension CGPoint {
    
    var magnitude: CGFloat {
        return sqrt(self.x * self.x + self.y * self.y)
    }
    
}
