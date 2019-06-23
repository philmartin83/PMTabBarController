//
//  PMTabBarController.swift
//  PMTabBarController
//
//  Created by Philip Martin on 23/06/2019.
//  Copyright © 2019 Philip Martin. All rights reserved.
//

import Foundation
import UIKit

open class PMTabBarController :UITabBarController{
    fileprivate var willSelectTheTabBarItem = true
    
    open override var selectedViewController: UIViewController? {
        willSet {
            guard willSelectTheTabBarItem,
                let newValue = newValue else {
                    willSelectTheTabBarItem = true
                    return
            }
            guard let tabBar = tabBar as? PMTabBar, let index = viewControllers?.firstIndex(of: newValue) else {
                return
            }
            tabBar.select(itemAt: index, animated: false)
        }
    }
    
}


