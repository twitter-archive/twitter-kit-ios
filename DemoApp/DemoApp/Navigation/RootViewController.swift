//
//  RootViewController.swift
//  DemoApp
//
//  Created by Rajul Arora on 10/26/17.
//  Copyright © 2017 Twitter. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    // MARK: - Private Variables

    private var currentViewController: UIViewController?
    private var animationController: RootAnimationController = RootAnimationController()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        navigateToHome()
    }

    // MARK: - Private Methods

    fileprivate func navigateToHome() {
        let homeViewController = HomeViewController()
        homeViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: homeViewController)
        setCurrentViewController(with: navigationController)
    }

    fileprivate func navigateToAuthentication() {
        let authenticationViewController = AuthenticationViewController()
        authenticationViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: authenticationViewController)
        setCurrentViewController(with: navigationController)
    }

    private func setCurrentViewController(with viewController: UIViewController) {
        var transitionContext = RootTransitionContext(from: currentViewController, to: viewController, in: self)
        transitionContext.animationCompletion = { [weak self] in
            self?.currentViewController = viewController
            self?.setupConstraints()
        }

        animationController.transition(using: transitionContext)
    }

    private func setupConstraints() {
        guard let viewController = currentViewController else { return }
        viewController.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        viewController.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        viewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

// MARK: - HomeViewControllerDelegate

extension RootViewController: HomeViewControllerDelegate {
    func homeViewControllerDidTapProfileButton(viewController: HomeViewController) {
        navigateToAuthentication()
    }
}

// MARK: - AuthenticationViewControllerDelegate

extension RootViewController: AuthenticationViewControllerDelegate {
    func authenticationViewControllerDidTapHome(viewController: AuthenticationViewController) {
        navigateToHome()
    }
}
