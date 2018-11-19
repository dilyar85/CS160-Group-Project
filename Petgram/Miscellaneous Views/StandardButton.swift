//
//  StandardButton.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import UIKit


func ==(lhs: StandardButtonStyle, rhs: StandardButtonStyle) -> Bool {
    return lhs.colors == rhs.colors
}


func ==(lhs: StandardButtonColors, rhs: StandardButtonColors) -> Bool {
    return lhs.background == rhs.background
        && lhs.border     == rhs.border
        && lhs.title      == rhs.title
}

struct StandardButtonColors: Equatable {
    let background: UIColor
    let border: UIColor
    let title: UIColor
    
}

enum StandardButtonStyle: Equatable {
    case primaryLightText
    case primaryDarkText
    case secondary
    case clearWhiteText
    case clearBlueText
    case blue
    case generic(StandardButtonColors)
    
    init(i: Int) {
        switch i {
        case 0:
            self = .primaryLightText
        case 1:
            self = .primaryDarkText
        case 2:
            self = .secondary
        case 3:
            self = .clearWhiteText
        case 4:
            self = .clearBlueText
        case 5:
            self = .blue
        default:
            self = .primaryLightText
        }
    }
    
    var colors: StandardButtonColors {
        let background: UIColor
        let border: UIColor
        let title: UIColor
        switch self {
        case .primaryLightText:
            background = .white
            border = .clear
            title = UIColor(r: 82, g: 153, b: 192)
        case .primaryDarkText:
            background = .white
            border = .clear
            title = UIColor(r: 4, g: 34, b: 64)
        case .secondary:
            background = .clear
            border = .white
            title = .white
        case .clearWhiteText:
            background = .clear
            border = .clear
            title = .white
        case .clearBlueText:
            background = .clear
            border = .clear
            title = .ottoBlue
        case .blue:
            background = .ottoBlue
            border = .clear
            title = .white
        case .generic(let colors):
            return colors
        }
        
        return StandardButtonColors(
            background: background,
            border: border,
            title: title
        )
    }
    
    
}


class StandardButton: UIView {
    
    
    @IBInspectable var styleRawValue: Int = 0 {
        didSet {
            self.style = StandardButtonStyle(i: styleRawValue)
        }
    }
    
    var style = StandardButtonStyle.primaryLightText {
        didSet {
            self.setupStyle()
        }
    }
    
    static func button(withStyle style: StandardButtonStyle) -> StandardButton {
        let button = StandardButton()
        button.style = style
        return button
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    private func setup() {
        self.backgroundColor = .clear
        self.layer.insertSublayer(self.bodyLayer, at: 0)
        self.bodyLayer.lineWidth = 1
        
        self.isAccessibilityElement = true
        self.accessibilityTraits = UIAccessibilityTraits.button
    }
    
    
    private let bodyLayer = CAShapeLayer()
    
    private func setupStyle() {
        
        let colors = self.style.colors
        
        self.bodyLayer.fillColor = colors.background.cgColor
        self.bodyLayer.strokeColor = colors.border.cgColor
        
        if let path = (self.layer.mask as? CAShapeLayer)?.path {
            self.set(path: UIBezierPath(cgPath: path))
        }
        
        if let label = self.contents as? UILabel {
            label.textColor = colors.title
        }
    }
    
    private(set) var pressed = false
    
    func setPressed() {
        self.pressed = true
    }
    
    func setNotPressed() {
        self.pressed = false
    }
    
    @IBInspectable var shouldRoundCorners: Bool = true {
        didSet {
            if !shouldRoundCorners {
                self.layer.mask = nil
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if shouldRoundCorners {
            let radius = self.bounds.height / 2.0
            let path = UIBezierPath(
                roundedRect: self.bounds,
                byRoundingCorners: .allCorners,
                cornerRadii: CGSize(width: radius, height: radius)
            )
            self.set(path: path)
        }
    }
    
    func set(path: UIBezierPath) {
        self.bodyLayer.path = path.cgPath
    }
    
    private var tapHandles = Array<() -> ()>()
    
    func add(action: @escaping () -> ()) {
        self.tapHandles.append(action)
    }
    
    func removeAllTapActions() {
        self.tapHandles.removeAll()
    }
    
    func simulateTap() {
        self.tapped()
    }
    
    
    private func tapped() {
        for handle in self.tapHandles {
            handle()
        }
    }
    
    // don't call super on touch events
    // don't want to forward touches!
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.pressed {
            self.setPressed()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        if self.pressed {
            self.setNotPressed()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.pressed {
            self.setNotPressed()
        }
        
        if let touch = touches.first, self.bounds.contains(touch.location(in: self)) {
            self.tapped()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self)
            if self.bounds.contains(point) {
                if !self.pressed {
                    self.setPressed()
                }
            } else {
                if self.pressed {
                    self.setNotPressed()
                }
            }
        }
    }
    
    var contents: UIView? {
        willSet {
            self.contents?.removeFromSuperview()
        }
        didSet {
            guard let contents = self.contents else {
                return
            }
            
            contents.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(contents)
            let centerX = NSLayoutConstraint(
                item: contents,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerX,
                multiplier: 1.0,
                constant: self.contentsXOffset
            )
            let centerY = NSLayoutConstraint(
                item: contents,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerY,
                multiplier: 1.0,
                constant: self.contentsYOffset
            )
            NSLayoutConstraint.activate([centerX, centerY])
            self.contents = contents
            self.contentsXConstraint = centerX
            self.contentsYConstraint = centerY
            
            self.updateWithContents()
        }
    }
    
    fileprivate func updateWithContents() {
        // override me
    }
    
    private var contentsXConstraint: NSLayoutConstraint?
    private var contentsYConstraint: NSLayoutConstraint?
    var contentsXOffset: CGFloat = 0 {
        didSet {
            self.contentsXConstraint?.constant = contentsXOffset
        }
    }
    var contentsYOffset: CGFloat = 0 {
        didSet {
            self.contentsYConstraint?.constant = contentsXOffset
        }
    }
    
    private func set(title: String, font: UIFont? = nil) {
        if let label = self.contents as? UILabel {
            label.text = title
            if let font = font {
                label.font = font
            }
            return
        }
        let label = UILabel()
        label.text = title
        label.font = font ?? UIFont(ottoStyle: .roman, size: self.fontSize)
        
        label.textColor = self.style.colors.title
        
        self.contents = label
    }
    
    @IBInspectable var title: String? {
        didSet {
            if let title = self.title  {
                var font: UIFont?
                if self.fontSize > 0 {
                    font = UIFont(ottoStyle: .roman, size: self.fontSize)
                }
                self.set(title: title, font: font)
            }
            self.accessibilityValue = title
        }
    }
    @IBInspectable var fontSize: CGFloat = 18 {
        didSet {
            if let title = self.title  {
                var font: UIFont?
                if self.fontSize > 0 {
                    font = UIFont(ottoStyle: .roman, size: self.fontSize)
                }
                self.set(title: title, font: font)
            }
        }
    }
    var font: UIFont {
        get {
            return (self.contents as? UILabel)?.font ?? UIFont(ottoStyle: .roman, size: self.fontSize)
        }
    }
    
}


class AutoSizingStandardButton: StandardButton {
    
    var insets = UIEdgeInsets.zero {
        didSet {
            self.superview?.setNeedsLayout()
            self.superview?.layoutIfNeeded()
        }
    }
    
    override func updateWithContents() {
        self.superview?.setNeedsLayout()
        self.superview?.layoutIfNeeded()
    }
    
    override var intrinsicContentSize: CGSize {
        guard let contents = self.contents else {
            return super.intrinsicContentSize
        }
        
        return CGSize(
            width: contents.bounds.width + insets.left + insets.right,
            height: contents.bounds.height + insets.top + insets.bottom
        )
    }
    
}
