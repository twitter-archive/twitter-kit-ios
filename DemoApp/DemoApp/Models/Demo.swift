//
//  Demo.swift
//  DemoApp
//
//  Created by Rajul Arora on 10/27/17.
//  Copyright © 2017 Twitter. All rights reserved.
//

import Foundation

enum PresentationStyle {
    case push
    case modal
}

protocol Demo {
    var title: String { get }
    var description: String { get }
    var viewController: UIViewController { get }
    var presentationStyle: PresentationStyle { get }
}

extension Demo {
    var presentationStyle: PresentationStyle { return .push }
}
