//
//  OverflowView.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import UIKit

enum OverflowViewContext {
    
    case profilePicture
    
    case postPicture
    
}

protocol OverflowViewDelegate: class {
    // return true if handled
    func overflowView(overflowView: OverflowView, didPress action: OverflowAction) -> Bool
    func overflowViewDidPressCancel(overflowView: OverflowView) -> Bool
}

private protocol OptionsViewDelegate: class {
    func optionsView(optionsView: OptionsView, didPress action: OverflowAction)
    func optionsViewDidPressCancel(optionsView: OptionsView)
}

enum OverflowAction {
    
    // Image
    
    case takeAPicture
    case chooseAPicture
    
    func displayName(in context: OverflowViewContext) -> String {
        switch self {
        case .chooseAPicture:
            return "Open Photos"
        case .takeAPicture:
            return "Take Picture"
            
        }
    }
    
    var image: UIImage {
        switch self {
        case .takeAPicture:
            return #imageLiteral(resourceName: "overflow_camera")
        case .chooseAPicture:
            return #imageLiteral(resourceName: "overflow_frame")
        }
    }
    
}

private class OptionButton: UIButton {
    
    static let height: CGFloat = 60
    
    var action: OverflowAction {
        didSet {
            self.actionImageView.image = action.image
            self.label.text = action.displayName(in: self.context)
        }
    }
    
    var context: OverflowViewContext
    
    private let actionImageView = UIImageView()
    private let label = UILabel()
    
    init(action: OverflowAction, context: OverflowViewContext) {
        self.action = action
        self.context = context
        super.init(frame: .zero)
        self.setup()
        
        defer {
            // call didSet
            self.action = action
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.actionImageView.contentMode = .center
        
        self.label.font = UIFont(ottoStyle: .roman, size: 15)
        self.label.textColor = .ottoDarkText
        
        self.actionImageView.translatesAutoresizingMaskIntoConstraints = false
        self.label.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.actionImageView)
        self.addSubview(self.label)
        
        let views = ["image": self.actionImageView, "label": self.label]
        let contentHoriz = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-5-[image(==50)]-10-[label]-10-|",
            options: [.alignAllCenterY],
            metrics: nil,
            views: views
        )
        let contentCenterY = NSLayoutConstraint(
            item: self.actionImageView,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0.0
        )
        
        NSLayoutConstraint.activate(contentHoriz)
        NSLayoutConstraint.activate([contentCenterY])
        
        self.isAccessibilityElement = true
        self.accessibilityLabel = action.displayName(in: context)
        self.accessibilityTraits = UIAccessibilityTraitButton
    }
    
}


private class OptionsView: UIView {
    
    weak var delegate: OptionsViewDelegate?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(context: OverflowViewContext, delegate: OptionsViewDelegate?) {
        var actions = [OverflowAction]()
        
        switch context {
            
        case .profilePicture, .postPicture:
            actions.append(.takeAPicture)
            actions.append(.chooseAPicture)
            //          if OttoController.shared.user?.profileImage != nil { actions.append(.deletePicture)}
            
            
        }
        
        self.init(actions: actions, context: context, delegate: delegate)
        // To select the fist item when overflow menu open
        
    }
    
    private init(actions: [OverflowAction], context: OverflowViewContext, delegate: OptionsViewDelegate?) {
        super.init(frame: .zero)
        
        self.delegate = delegate
        
        self.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        
        for action in actions {
            let (actionView, height) = self.actionView(for: action, in: context)
            
            actionView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(actionView)
            
            var views = ["actionView": actionView]
            let metrics = ["height": height]
            
            let horiz = NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0-[actionView]-0-|",
                options: [],
                metrics: nil,
                views: views
            )
            
            let verti: [NSLayoutConstraint]
            if let previous = self.actionViews.last {
                views["previous"] = previous
                verti = NSLayoutConstraint.constraints(
                    withVisualFormat: "V:[previous]-0-[actionView(==height)]",
                    options: [],
                    metrics: metrics,
                    views: views
                )
            } else {
                verti = NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|-0-[actionView(==height)]",
                    options: [],
                    metrics: metrics,
                    views: views
                )
            }
            
            NSLayoutConstraint.activate(horiz)
            NSLayoutConstraint.activate(verti)
            
            self.actionViews.append(actionView)
        }
        
        let divider = UIView()
        divider.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        divider.translatesAutoresizingMaskIntoConstraints = false
        
        let cancelButton = UIButton()
        cancelButton.addTarget(
            self,
            action: #selector(OptionsView.cancelButtonPress(button:)),
            for: .touchUpInside
        )
        
        let cancelLabel = UILabel()
        // MARK: Multipe Language
        cancelLabel.text = "关闭"
        cancelLabel.font = UIFont(ottoStyle: .roman, size: 15)
        cancelLabel.textColor = .ottoRed
        
        divider.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(divider)
        self.addSubview(cancelButton)
        cancelButton.addSubview(cancelLabel)
        cancelButton.accessibilityLabel = "Cancel"
        
        
        var views = [
            "divider": divider,
            "button": cancelButton,
            "label": cancelLabel
        ]
        let metrics = ["height": OptionButton.height]
        
        let verti: [NSLayoutConstraint]
        if let previous = self.actionViews.last {
            views["previous"] = previous
            verti = NSLayoutConstraint.constraints(
                withVisualFormat: "V:[previous]-0-[divider(==1)]-0-[button(==height)]-0-|",
                options: [.alignAllLeading, .alignAllTrailing],
                metrics: metrics,
                views: views
            )
        } else {
            verti = NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[divider(==1)]-0-[button(==height)]-0-|",
                options: [.alignAllLeading, .alignAllTrailing],
                metrics: metrics,
                views: views
            )
        }
        let horiz = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[divider]-0-|",
            options: [],
            metrics: nil,
            views: views
        )
        let labelCenterX = NSLayoutConstraint(
            item: cancelLabel,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: cancelButton,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0.0
        )
        let labelCenterY = NSLayoutConstraint(
            item: cancelLabel,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: cancelButton,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0.0
        )
        
        NSLayoutConstraint.activate(verti)
        NSLayoutConstraint.activate(horiz)
        NSLayoutConstraint.activate([labelCenterX, labelCenterY])
    }
    
    
    fileprivate var actionViews = [UIView]()
    
    // returns view and height
    private func actionView(for action: OverflowAction, in context: OverflowViewContext) -> (UIView, CGFloat) {
        
        let button = OptionButton(action: action, context: context)
        button.addTarget(
            self,
            action: #selector(OptionsView.actionButtonPress(button:)),
            for: .touchUpInside
        )
        return (button, OptionButton.height)
        
    }
    
    
    @objc private func actionButtonPress(button: UIButton) {
        guard let action = (button as? OptionButton)?.action else {
            return
        }
        self.delegate?.optionsView(optionsView: self, didPress: action)
    }
    
    @objc private func cancelButtonPress(button: UIButton) {
        self.delegate?.optionsViewDidPressCancel(optionsView: self)
    }
    
}

class OverflowView: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    static func addToWindow(context: OverflowViewContext, delegate: OverflowViewDelegate? = nil) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        runOnMainThread {
            let view = OverflowView(
                context: context,
                delegate: delegate
            )
            
            view.translatesAutoresizingMaskIntoConstraints = false
            window.addSubview(view)
            let views = ["overflow": view]
            let horiz = NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0-[overflow]-0-|",
                options: [],
                metrics: nil,
                views: views
            )
            let verti = NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[overflow]-0-|",
                options: [],
                metrics: nil,
                views: views
            )
            NSLayoutConstraint.activate(horiz)
            NSLayoutConstraint.activate(verti)
            view.animateIn()
        }
    }
    
    // MARK: Variables
    weak var delegate: OverflowViewDelegate?
    var context: OverflowViewContext
    
    private let optionsView: OptionsView
    private var visibleConstraint: NSLayoutConstraint!
    
    fileprivate var removeTimer: Timer?
    
    // need to keep a reference so delegate methods get called
    fileprivate static var imageOverflowView: OverflowView?
    
    
    init(context: OverflowViewContext, delegate: OverflowViewDelegate? = nil) {
        
        self.context = context
        
        self.optionsView = OptionsView(
            context: context,
            delegate: nil
        )
        self.delegate = delegate
        
        super.init(frame: UIScreen.main.bounds)
        optionsView.delegate = self
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setup() {
        self.backgroundColor = .clear
        
        self.optionsView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.optionsView)
        
        let views = ["options": self.optionsView]
        
        let horiz = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[options]-0-|",
            options: [],
            metrics: nil,
            views: views
        )
        let hidden = NSLayoutConstraint(
            item: self.optionsView,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0.0,
            priority: .medium
        )
        let visible = NSLayoutConstraint(
            item: self.optionsView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0.0,
            priority: .low
        )
        
        NSLayoutConstraint.activate(horiz)
        NSLayoutConstraint.activate([hidden, visible])
        
        self.visibleConstraint = visible
        
        self.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(OverflowView.tapped)
            )
        )
        
        
    }
    
    //Return when tap outside area of the OverflowView
    @objc private func tapped() {
        let handledByDelegate = self.delegate?.overflowViewDidPressCancel(overflowView: self) ?? false
        guard !handledByDelegate else {
            return
        }
        self.remove()
    }
    
    func animateIn() {
        self.isHidden = false
        self.layoutIfNeeded()
        self.visibleConstraint.priority = .high
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
            self.layoutIfNeeded()
        }
    }
    
    func remove() {
        self.removeTimer?.invalidate()
        self.removeTimer = nil
        self.layoutIfNeeded()
        self.visibleConstraint.priority = .low
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundColor = .clear
            self.layoutIfNeeded()
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
    
    fileprivate func handle(action: OverflowAction) -> TimeInterval {
        
        let delayTime = 0.0
        
        switch action {
            
            // Photot
            
        case .takeAPicture:
            let camera = UIImagePickerController()
            camera.sourceType = .camera
            camera.cameraDevice = .front
            camera.allowsEditing = true
            camera.delegate = self
            PetDateController.shared.masterViewController?.present(
                camera,
                animated: true,
                completion: nil
            )
            OverflowView.imageOverflowView = self
            
        case .chooseAPicture:
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            picker.delegate = self
            PetDateController.shared.masterViewController?.present(
                picker,
                animated: true,
                completion: nil
            )
            OverflowView.imageOverflowView = self
            
        }
        
        return delayTime
    }
    
    
    
}

extension OverflowView: OptionsViewDelegate {
    
    fileprivate func optionsViewDidPressCancel(optionsView: OptionsView) {
        let handledByDelegate = self.delegate?.overflowViewDidPressCancel(overflowView: self) ?? false
        guard !handledByDelegate else {
            return
        }
        self.remove()
    }
    
    fileprivate func optionsView(optionsView: OptionsView, didPress action: OverflowAction) {
        
        let handledByDelegate = self.delegate?.overflowView(
            overflowView: self,
            didPress: action
            ) ?? false
        
        guard !handledByDelegate else {
            return
        }
        
        let delayTime = self.handle(action: action)
        if delayTime > 0 {
            self.removeTimer?.invalidate()
            self.removeTimer = Timer.scheduledTimer(
                timeInterval: delayTime,
                target: self,
                selector: #selector(OverflowView.remove),
                userInfo: nil,
                repeats: false
            )
        } else {
            self.remove()
        }
    }
    
}

extension OverflowView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        PetDateController.shared.masterViewController?.dismiss(
            animated: true,
            completion: nil
        )
        OverflowView.imageOverflowView = nil
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        PetDateController.shared.masterViewController?.dismiss(
            animated: true,
            completion: nil
        )
        OverflowView.imageOverflowView = nil
        
        guard
            let image = info[UIImagePickerControllerEditedImage] as? UIImage,
            let user = PetDateController.shared.user else {
                return
        }
        
        self.go(for: self.context, image: image, user: user)
        
        
    }
    
    func go(for context: OverflowViewContext, image: UIImage, user: User) {
        
        switch context {
            
        case .postPicture:
            guard let containerViewControllerDelegate = self.delegate as? ContainerViewController else {
                return
            }
            let data: [String: Any] = ["image": image]
            containerViewControllerDelegate.openVC(with: ContainerViewController.postId, data: data)
            
        case .profilePicture:
            LoadingShade.add()
            user.set(profileImage: image) { (succeed) in
                LoadingShade.remove()
                guard succeed else {
                    let overlay = WarningOverlayView(
                        retryWarningWithRetryAction: { overlay in
                            overlay.animateOut()
                            self.go(for: context, image: image, user: user)
                    },
                        cancelAction: { overlay in
                            overlay.animateOut()
                    }
                    )
                    overlay.animateIn()
                    return
                }
                
            }
            
            
        }
    }
    
    
}

