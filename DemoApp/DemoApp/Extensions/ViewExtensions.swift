//
//  ViewExtensions.swift
//  FabricSampleApp
//
//  Created by Steven Hepting on 6/25/15.
//  Copyright (c) 2015 Twitter. All rights reserved.
//

import Foundation


extension UIViewController {
    func addVisualConstraints(format: String, views: [String: AnyObject], options: NSLayoutFormatOptions = [], metrics: [String : AnyObject]? = nil) {
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: format, options: options, metrics: metrics, views: views)
        constraints.forEach { $0.isActive = true }
    }

    func visualConstraint(format: String, _ views: [String: AnyObject]) -> NSLayoutConstraint {
        return NSLayoutConstraint.constraints(withVisualFormat: format, options: [], metrics: nil, views: views).first!
    }
}


extension UIView {
    func centerXinSuperview() {
        NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: self.superview!, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
    }
}
