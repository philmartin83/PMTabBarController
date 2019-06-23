//
//  PMTabBar.swift
//  PMTabBarController
//
//  Created by Philip Martin on 23/06/2019.
//  Copyright © 2019 Philip Martin. All rights reserved.
//

import Foundation
import UIKit

open class PMTabBar: UITabBar{
    
    private var arrayOfButtons: [PMTabBarButton] = []
    public var durationOfAnitmation: Double = 0.3
    private var constraintContainerBottom: NSLayoutConstraint!
    private var spaceLayoutGuides:[UILayoutGuide] = []
    
    override open var selectedItem: UITabBarItem?{
        
        willSet{
            
            guard let newValue = newValue else {
                arrayOfButtons.forEach { $0.setSelected(false) }
                return
            }
            guard let index = items?.firstIndex(of: newValue),
                index != NSNotFound else {
                    return
            }
            select(itemAt: index, animated: false)
        }
    }
    
    open override var tintColor: UIColor! {
        didSet {
            arrayOfButtons.forEach { button in
                if (button.item as? PMTabBarItem)?.tintColor == nil {
                    button.tintColor = tintColor
                }
            }
        }
    }
    
    override open var backgroundColor: UIColor? {
        didSet {
            barTintColor = backgroundColor
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupConfig()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupConfig()
    }
    
    var ourContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
   
    
    override open func safeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.safeAreaInsetsDidChange()
            constraintContainerBottom.constant = -safeAreaInsets.bottom
        } else { }
    }
    
    open override var items: [UITabBarItem]? {
        didSet {
            relaodAllSubviews()
        }
    }
    
    open override func setItems(_ items: [UITabBarItem]?, animated: Bool) {
        super.setItems(items, animated: animated)
        relaodAllSubviews()
    }
    //MARL:- Privtae Functions
    //MARK:- Config
    private func setupConfig() {
        backgroundColor = UIColor.white
        isTranslucent = false
        barTintColor = UIColor.white
        tintColor = #colorLiteral(red: 0.1176470588, green: 0.1176470588, blue: 0.431372549, alpha: 1)
        addSubview(ourContainerView)
        ourContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        ourContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        ourContainerView.topAnchor.constraint(equalTo: topAnchor, constant: 1).isActive = true
        let bottomOffset: CGFloat
        if #available(iOS 11.0, *) {
            bottomOffset = safeAreaInsets.bottom
        } else {
            bottomOffset = 0
        }
        constraintContainerBottom = ourContainerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottomOffset)
        constraintContainerBottom.isActive = true
    }
    
    private func relaodAllSubviews() {
        subviews.filter { String(describing: type(of: $0)) == "UITabBarButton" }.forEach { $0.removeFromSuperview() }
        arrayOfButtons.forEach { $0.removeFromSuperview() }
        spaceLayoutGuides.forEach { self.ourContainerView.removeLayoutGuide($0) }
        arrayOfButtons = items?.map { self.button(forItem: $0) } ?? []
        arrayOfButtons.forEach { (button) in
            self.ourContainerView.addSubview(button)
            button.topAnchor.constraint(equalTo: self.ourContainerView.topAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: self.ourContainerView.bottomAnchor).isActive = true
        }
        if #available(iOS 11.0, *) {
            arrayOfButtons.first?.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10.0).isActive = true
            arrayOfButtons.last?.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10.0).isActive = true
        } else {
            arrayOfButtons.first?.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0).isActive = true
            arrayOfButtons.last?.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0).isActive = true
        }
        let viewCount = arrayOfButtons.count - 1
        spaceLayoutGuides = [];
        for i in 0..<viewCount {
            let layoutGuide = UILayoutGuide()
            ourContainerView.addLayoutGuide(layoutGuide)
            spaceLayoutGuides.append(layoutGuide)
            let prevBtn = arrayOfButtons[i]
            let nextBtn = arrayOfButtons[i + 1]
            layoutGuide.leadingAnchor.constraint(equalTo: prevBtn.trailingAnchor).isActive = true
            layoutGuide.trailingAnchor.constraint(equalTo: nextBtn.leadingAnchor).isActive = true
        }
        for layoutGuide in spaceLayoutGuides[1...] {
            layoutGuide.widthAnchor.constraint(equalTo: spaceLayoutGuides[0].widthAnchor, multiplier: 1.0).isActive = true;
        }
        layoutIfNeeded()
    }
    
    private func button(forItem item: UITabBarItem) -> PMTabBarButton {
        let button = PMTabBarButton(item: item)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        if (button.item as? PMTabBarItem)?.tintColor == nil {
            button.tintColor = tintColor
        }
        button.addTarget(self, action: #selector(tabBarButtonWasPressed), for: .touchUpInside)
        if selectedItem != nil && item === selectedItem {
            button.setSelected(true)
        }
        return button
    }
    
    @objc private func tabBarButtonWasPressed(sender: PMTabBarButton) {
        guard let index = arrayOfButtons.firstIndex(of: sender),
            index != NSNotFound,
            let item = items?[index] else {
                return
        }
        arrayOfButtons.forEach { (button) in
            guard button != sender else {
                return
            }
            button.setSelected(false, animationDuration: durationOfAnitmation)
        }
        sender.setSelected(true, animationDuration: durationOfAnitmation)
        UIView.animate(withDuration: durationOfAnitmation) {
            self.ourContainerView.layoutIfNeeded()
        }
        delegate?.tabBar?(self, didSelect: item)
    }
    
    //MARK:- Helpers
    func select(itemAt index: Int, animated: Bool = false) {
        guard index < arrayOfButtons.count else {
            return
        }
        let selectedbutton = arrayOfButtons[index]
        arrayOfButtons.forEach { (button) in
            guard button != selectedbutton else {
                return
            }
            button.setSelected(false, animationDuration: animated ? durationOfAnitmation : 0)
        }
        selectedbutton.setSelected(true, animationDuration: animated ? durationOfAnitmation : 0)
        if animated {
            UIView.animate(withDuration: durationOfAnitmation) {
                self.ourContainerView.layoutIfNeeded()
            }
        } else {
            self.ourContainerView.layoutIfNeeded()
        }
    }
    
}

