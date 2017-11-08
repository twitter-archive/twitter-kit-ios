//
//  UIAlertControllerExtensions.swift
//  DemoApp
//
//  Created by Rajul Arora on 10/31/17.
//  Copyright © 2017 Twitter. All rights reserved.
//

import UIKit

extension UIAlertController {
    class func showAlert(with error: Error, on viewController: UIViewController) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
        alertController.addAction(dismissAction)
        viewController.present(alertController, animated: true)
    }
}
