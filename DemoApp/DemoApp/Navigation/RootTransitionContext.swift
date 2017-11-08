//
//  RootTransitionContext.swift
//  DemoApp
//
//  Created by Rajul Arora on 10/26/17.
//  Copyright © 2017 Twitter. All rights reserved.
//

import UIKit

struct RootTransitionContext {

    // MARK: - Public Variables
    var animationCompletion:(() -> ())?

    var toViewController: UIViewController
    var fromViewController: UIViewController?
    var contentViewController: UIViewController

    // MARK: - Init
    init(from fromViewController: UIViewController?, to toViewController: UIViewController, in contentViewController: UIViewController) {
        self.toViewController = toViewController
        self.fromViewController = fromViewController
        self.contentViewController = contentViewController
    }

    func completeTransition() {
        animationCompletion?()
    }
}
