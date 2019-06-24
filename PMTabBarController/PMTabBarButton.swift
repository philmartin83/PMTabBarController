//
//  PMTabBarButton.swift
//  PMTabBarController
//
//  Created by Philip Martin on 23/06/2019.
//  Copyright © 2019 Philip Martin. All rights reserved.
//

import Foundation
import UIKit

public class PMTabBarItem: UITabBarItem{
    @IBInspectable public var tintColor : UIColor?
}

public class PMTabBarButton: UIControl{
    
    //MARK:- Private Propterties
    private var isSelected_: Bool = false
    private var tabBarImage = UIImageView()
    private var tabBarLabel = UILabel()
    private var tabBarBackground = UIView()
    
    private let backgroundHeight: CGFloat = 42.0
    
    // Trailing Folded
    private var constraintFoldedBackgroundTrailing: NSLayoutConstraint!
    // Trailing Unfolded
    private var constraintUnfoldedBackgroundTrailing: NSLayoutConstraint!
    
    // Leading Folded
    private var constraintFoldedLblLeading: NSLayoutConstraint!
    
    // Leading Unfolded
    private var constraintUnfoldedLblLeading: NSLayoutConstraint!
    
    
    private var foldedConstraints: [NSLayoutConstraint] {
        return [constraintFoldedLblLeading, constraintFoldedBackgroundTrailing]
    }
    
    private var unfoldedConstraints: [NSLayoutConstraint] {
        return [constraintUnfoldedLblLeading, constraintUnfoldedBackgroundTrailing]
    }
    
    //MARK:- Overrides
    override public var isSelected: Bool{
        
        get {
            return isSelected_
        }
        set {
            guard newValue != isSelected_ else {
                return
            }
            if newValue {
                unFoldButton()
            } else {
                foldButton()
            }
        }
    }
    
    override public var tintColor: UIColor! {
        didSet {
            if isSelected_ {
                tabBarImage.tintColor = tintColor
            }
            tabBarLabel.textColor = tintColor
            tabBarBackground.backgroundColor = tintColor.withAlphaComponent(0.2)
        }
    }
    
    //MARK:- Initaliser
    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
         configSubViews()
    }

    init(item: UITabBarItem) {
        super.init(frame: .zero)
        tabBarImage = UIImageView(image: item.image)
        defer {
            self.item = item
            configSubViews()
        }
    }
    
    var item: UITabBarItem? {
        didSet {
            tabBarImage.image = item?.image?.withRenderingMode(.alwaysTemplate)
            tabBarLabel.text = item?.title
            if let tabItem = item as? PMTabBarItem,
                let color = tabItem.tintColor {
                tintColor = color
            }
        }
    }
    
    //MARK:- Helpers
    func configSubViews(){
        // configure the layout using contraints and setting up TAMC and all that good stuff
        tabBarImage.contentMode = .center
        tabBarImage.translatesAutoresizingMaskIntoConstraints = false
        tabBarLabel.translatesAutoresizingMaskIntoConstraints = false
        tabBarLabel.font = UIFont.systemFont(ofSize: 14)
        tabBarLabel.adjustsFontSizeToFitWidth = true
        tabBarBackground.translatesAutoresizingMaskIntoConstraints = false
        tabBarBackground.isUserInteractionEnabled = false
        tabBarImage.setContentHuggingPriority(.required, for: .horizontal)
        tabBarImage.setContentHuggingPriority(.required, for: .vertical)
        tabBarImage.setContentCompressionResistancePriority(.required, for: .horizontal)
        tabBarImage.setContentCompressionResistancePriority(.required, for: .vertical)
        
        // add to the subview
        self.addSubview(tabBarBackground)
        self.addSubview(tabBarLabel)
        self.addSubview(tabBarImage)
        
        // set our backgrounds
        tabBarBackground.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tabBarBackground.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        tabBarBackground.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tabBarBackground.heightAnchor.constraint(equalToConstant: backgroundHeight).isActive = true
        
        // apply the tab bar icon
        tabBarImage.leadingAnchor.constraint(equalTo: tabBarBackground.leadingAnchor, constant: backgroundHeight/2.0).isActive = true
        tabBarImage.centerYAnchor.constraint(equalTo: tabBarBackground.centerYAnchor).isActive = true
        tabBarLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        // more constraint work
        constraintFoldedLblLeading = tabBarLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
        constraintUnfoldedLblLeading = tabBarLabel.leadingAnchor.constraint(equalTo: tabBarImage.trailingAnchor, constant: backgroundHeight/4.0)
        constraintFoldedBackgroundTrailing = tabBarImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -backgroundHeight/2.0)
        constraintUnfoldedBackgroundTrailing = tabBarLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -backgroundHeight/2.0)
        
        // refresh the view
        foldButton()
        setNeedsLayout()
    }
    
    func unFoldButton(durationOfAnimation duration: Double = 0.0){
        
        // expand the tab bar button based the selected button
        foldedConstraints.forEach{ $0.isActive = false }
        unfoldedConstraints.forEach{ $0.isActive = true }
        
        // Animation the buttons
        UIView.animate(withDuration: duration) {
            self.tabBarBackground.alpha = 1.0
        }
        UIView.animate(withDuration: duration * 0.5, delay: duration * 0.5, options: [], animations: {
            self.tabBarLabel.alpha = 1.0
        }, completion: nil)
        UIView.transition(with: tabBarImage, duration: duration, options: [.transitionCrossDissolve], animations: {
            self.tabBarImage.tintColor = self.tintColor
        }, completion: nil)
    }
    
    func foldButton(durationOfAnimation duration: Double = 0.0){
        
        // collapse the button based the selected
        unfoldedConstraints.forEach{ $0.isActive = false }
        foldedConstraints.forEach{ $0.isActive = true }
        
        // more good animation stuff
        UIView.animate(withDuration: duration) {
            self.tabBarBackground.alpha = 0.0
        }
        UIView.animate(withDuration: duration * 0.4) {
            self.tabBarLabel.alpha = 0.0
        }
        UIView.transition(with: tabBarImage, duration: duration, options: [.transitionCrossDissolve], animations: {
            self.tabBarImage.tintColor = .black
        }, completion: nil)
    }
    
    public func setSelected(_ selected: Bool, animationDuration duration: Double = 0.0) {
        
        // set our selected buttons index
        isSelected_ = selected
        if selected {
            unFoldButton(durationOfAnimation: duration)
        } else {
            foldButton(durationOfAnimation: duration)
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        tabBarBackground.layer.cornerRadius = tabBarBackground.bounds.height / 2.0
    }
    
}

