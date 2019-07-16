//
//  PMTabBarController.swift
//  PMTabBarController
//
//  Created by Philip Martin on 23/06/2019.
//  Copyright © 2019 Philip Martin. All rights reserved.
//

import Foundation
import UIKit

open class PMTabBarController: UITabBarController{
    
    //MARK:- Properties
    fileprivate var willSelectTheTabBarItem = true
    fileprivate var barHeight_: CGFloat = 84.0
    
    //MARK:- View presentation
    open override func viewDidLoad() {
        super.viewDidLoad()
        let tab = PMTabBar()
        self.setValue(tab, forKey: "tabBar")
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateTabFrame()
    }
    
    open override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.viewSafeAreaInsetsDidChange()
        }
        updateTabFrame()
    }

    //MARK:- Computed Properties
    open var barHeight: CGFloat{
        get{
//            if #available(iOS 11.0, *) {
//                return barHeight_
//            } else {
                // Fallback on earlier versions
                return barHeight_
//            }
        }set{
            barHeight_ = newValue
            updateTabFrame()
        }
    }
    
    open override var selectedViewController: UIViewController? {
        willSet {
            // all that unwrapping good stuff
            guard willSelectTheTabBarItem,
                let newValue = newValue else {
                    willSelectTheTabBarItem = true
                    return
            }
            guard let tabBar = tabBar as? PMTabBar, let index = viewControllers?.firstIndex(of: newValue) else {
                return
            }
            // select out index item
            tabBar.select(itemAt: index, animated: false)
        }
    }
    
    open override var selectedIndex: Int{
        willSet {
            guard willSelectTheTabBarItem else {
                willSelectTheTabBarItem = true
                return
            }
            guard let tabBar = tabBar as? PMTabBar else{
                return
            }
            // select out index item
            tabBar.select(itemAt: selectedIndex, animated: false)
            
        }
    }
    
    
    open override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // unwrap
        guard let indexOf = tabBar.items?.firstIndex(of: item) else{
            return
        }
        // unwrap our view controller based on the index
        if let controller = viewControllers?[indexOf]{
            // toggle our private bool to false
            willSelectTheTabBarItem = false
            // pass through the selected index
            selectedIndex = indexOf
            // call tabbar controller delelgate
            delegate?.tabBarController?(self, didSelect: controller)
        }
    }
    

    //MARK:- Private Fucntions
    private func updateTabFrame(){
        // update the frame of the tab bar when we are switching through
        var tabBarFrame = self.tabBar.frame
        // adjust our frame
        tabBarFrame.size.height = barHeight
        tabBarFrame.origin.y = self.view.frame.size.height - barHeight
        //  set our frame back to the tabbar and update the layout
        self.tabBar.frame = tabBarFrame
        tabBar.setNeedsLayout()
    }
    
}


