//
//  NewCountView.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import UIKit

class NewCountView: UIView {
    
    private class NewCountLabel: UILabel {
        override var alignmentRectInsets: UIEdgeInsets {
            return UIEdgeInsets(
                top: 0.0,
                left: 0.0,
                bottom: 0.0,
                right: (self.text ?? "").contains("+") ? 2.0 : 0.0
            )
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    let labelContainer: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor(r: 255, g: 70, b: 70)
        return container
    }()
    private let label: UILabel = {
        let label = NewCountLabel()
        label.font = UIFont(ottoStyle: .roman, size: 12)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private func setup() {
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(NewCountView.countChanged(notification:)),
//            name: .newEpisodesCountDidLoad,
//            object: nil
//        )
        
        self.backgroundColor = .white
        self.isUserInteractionEnabled = false
        
        self.labelContainer.translatesAutoresizingMaskIntoConstraints = false
        self.label.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.labelContainer)
        self.labelContainer.addSubview(self.label)
        
        let views = ["container": self.labelContainer, "label": self.label]
        
        let containerHoriz = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-1-[container]-1-|",
            options: [],
            metrics: nil,
            views: views
        )
        let containerVerti = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-1-[container]-1-|",
            options: [],
            metrics: nil,
            views: views
        )
        let labelHoriz = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-6-[label]-6-|",
            options: [],
            metrics: nil,
            views: views
        )
        let labelVerti = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-1-[label]-1-|",
            options: [],
            metrics: nil,
            views: views
        )
        
        NSLayoutConstraint.activate(containerHoriz)
        NSLayoutConstraint.activate(containerVerti)
        NSLayoutConstraint.activate(labelHoriz)
        NSLayoutConstraint.activate(labelVerti)
        
        self.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.height / 2.0
        self.labelContainer.layer.cornerRadius = self.bounds.height / 2.0
    }
    
    @objc private func countChanged(notification: Notification) {
        guard let count = notification.object as? Int else {
            return
        }
//        let max = LibraryViewController.newEpisodesPageSize
//        self.count = min(max, count)
//        self.plus = count >= max
    }
    
    private var count: Int {
        get {
            return Int(self.label.text ?? "") ?? 0
        }
        set {
            self.label.text = "\(newValue)"
            self.isHidden = newValue <= 0
        }
    }
    private var plus: Bool {
        get {
            return self.label.text?.characters.last == "+"
        }
        set {
            if newValue && !plus, let text = self.label.text {
                self.label.text = text + "+"
            } else if !newValue && plus, let text = self.label.text {
                self.label.text = text.substring(to: text.index(before: text.endIndex))
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
