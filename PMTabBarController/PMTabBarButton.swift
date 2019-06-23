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
        return [constraintUnfoldedLblLeading, constraintFoldedLblLeading]
    }
    
    private var unfoldedConstraints: [NSLayoutConstraint] {
        return [constraintUnfoldedLblLeading, constraintFoldedLblLeading]
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
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
         configSubViews()
    }
    //MARK:- Initaliser
    
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
        
        self.addSubview(tabBarBackground)
        self.addSubview(tabBarLabel)
        self.addSubview(tabBarImage)
        
        tabBarBackground.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tabBarBackground.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        tabBarBackground.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tabBarBackground.heightAnchor.constraint(equalToConstant: backgroundHeight).isActive = true
        
        
        tabBarImage.leadingAnchor.constraint(equalTo: tabBarBackground.leadingAnchor, constant: backgroundHeight/2.0).isActive = true
        tabBarImage.centerYAnchor.constraint(equalTo: tabBarBackground.centerYAnchor).isActive = true
        tabBarLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        constraintFoldedLblLeading = tabBarLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
        constraintUnfoldedLblLeading = tabBarLabel.leadingAnchor.constraint(equalTo: tabBarImage.trailingAnchor, constant: backgroundHeight/4.0)
        constraintFoldedBackgroundTrailing = tabBarImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -backgroundHeight/2.0)
        constraintUnfoldedBackgroundTrailing = tabBarLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -backgroundHeight/2.0)
        foldButton()
        setNeedsLayout()
    }
    
    func unFoldButton(durationOfAnimation duration: Double = 0.0){
        foldedConstraints.forEach{ $0.isActive = false }
        unfoldedConstraints.forEach{ $0.isActive = true }
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
        unfoldedConstraints.forEach{ $0.isActive = false }
        foldedConstraints.forEach{ $0.isActive = true }
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

