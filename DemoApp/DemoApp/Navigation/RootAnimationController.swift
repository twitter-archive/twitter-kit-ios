//
//  RootAnimationContext.swift
//  DemoApp
//
//  Created by Rajul Arora on 10/26/17.
//  Copyright © 2017 Twitter. All rights reserved.
//

import UIKit

struct RootAnimationController {

    // MARK: - Public Variables
    var transitionDuration: TimeInterval = 0.2

    // MARK: - Public Methods
    func transition(using transitionContext: RootTransitionContext) {
        let toViewController = transitionContext.toViewController

        transitionContext.contentViewController.addChildViewController(toViewController)
        toViewController.view.frame = transitionContext.contentViewController.view.bounds
        transitionContext.contentViewController.view.addSubview(toViewController.view)
        transitionContext.fromViewController?.willMove(toParentViewController: nil)
        transitionContext.toViewController.willMove(toParentViewController: transitionContext.contentViewController)

        animateTransition(using: transitionContext)
    }

    // MARK: - Private Methods
    private func animateTransition(using transitionContext: RootTransitionContext) {
        transitionContext.toViewController.view.alpha = 0

        UIView.animate(withDuration: transitionDuration, animations: {
            transitionContext.fromViewController?.view.alpha = 0.0
            transitionContext.toViewController.view.alpha = 1.0
        }, completion: { _ in
            transitionContext.completeTransition()
            self.handleAnimationCompletion(using: transitionContext)
        })
    }

    private func handleAnimationCompletion(using transitionContext: RootTransitionContext?) {
        transitionContext?.fromViewController?.view.removeFromSuperview()
        transitionContext?.fromViewController?.removeFromParentViewController()
        if let constraints = transitionContext?.fromViewController?.view.constraints {
            transitionContext?.fromViewController?.view.removeConstraints(constraints)
        }
    }
}
