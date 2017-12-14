//
//  UIViewControllerExtensions.swift
//  DemoApp
//
//  Created by Rajul Arora on 10/30/17.
//  Copyright © 2017 Twitter. All rights reserved.
//

import UIKit

// This is a common extension to find the top-most view
// controller that several of our customers use.
extension UIViewController {

    class var topMostViewController: UIViewController {
        let root = UIApplication.shared.keyWindow?.rootViewController
        return self.topMostViewControllerWithRootViewController(root: root!)
    }

    class func topMostViewControllerWithRootViewController(root: UIViewController) -> UIViewController {
        if let tab = root as? UITabBarController {
            return self.topMostViewControllerWithRootViewController(root: tab.selectedViewController!)
        }

        if let nav = root as? UINavigationController {
            return self.topMostViewControllerWithRootViewController(root: nav.visibleViewController!)
        }

        if let presented = root.presentedViewController {
            return self.topMostViewControllerWithRootViewController(root: presented)
        }

        // We are at the root
        return root
    }
}
