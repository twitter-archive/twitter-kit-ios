//
//  LoginViewController.swift
//  DemoApp
//
//  Created by Rajul Arora on 10/30/17.
//  Copyright © 2017 Twitter. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate : class {
    func loginViewController(viewController: LoginViewController, didAuthWith session: TWTRSession)
    func loginViewControllerDidClearAccounts(viewController: LoginViewController)
}

class LoginViewController: UIViewController {

    // MARK: - Public Variables

    weak var delegate: LoginViewControllerDelegate?

    // MARK: - Private Variables

    private lazy var loginView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var backgroundView: UIView = { [unowned self] in
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tapGesture)
        return view
    }()

    private lazy var loginButton: TWTRLogInButton = { [weak self] in
        let button = TWTRLogInButton() { (session, error) in
            guard let weakSelf = self else { return }
            if let error = error {
                UIAlertController.showAlert(with: error, on: weakSelf)
            } else if let session = session {
                weakSelf.dismiss(animated: true) {
                    weakSelf.delegate?.loginViewController(viewController: weakSelf, didAuthWith: session)
                }
            }
        }

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var customLoginButton: UIButton = { [unowned self] in
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Log In with a Custom Button", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .pubplatPurple
        button.layer.cornerRadius = 4.0
        button.addTarget(self, action: #selector(login), for: .touchUpInside)
        return button
    }()

    private lazy var clearAccountsButton: UIButton = { [unowned self] in
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Clear All Accounts", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .pubplatPurple
        button.layer.cornerRadius = 4.0
        button.addTarget(self, action: #selector(clearAccounts), for: .touchUpInside)
        return button
    }()

    private lazy var cancelButton: UIButton = { [unowned self] in
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(backgroundTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .darkText
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.text = "Select a Login Method"
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        view.addSubview(loginView)
        view.addSubview(backgroundView)

        loginView.addSubview(loginButton)
        loginView.addSubview(cancelButton)
        loginView.addSubview(titleLabel)
        loginView.addSubview(customLoginButton)
        loginView.addSubview(clearAccountsButton)

        setupLoginView()
        setupBackgroundView()
        setupLoginButton()
        setupCancelButton()
        setupTitleLabel()
        setupCustomLoginButton()
        setupClearAccountsButton()
    }

    // MARK: - Actions

    @objc func backgroundTap() {
        dismiss(animated: true, completion: nil)
    }

    @objc func login() {
        TWTRTwitter.sharedInstance().logIn(with: self) { (session, error) in
            if let session = session {
                self.dismiss(animated: true) {
                    self.delegate?.loginViewController(viewController: self, didAuthWith: session)
                }
            } else if let error = error {
                UIAlertController.showAlert(with: error, on: self)
            }
        }
    }

    @objc func clearAccounts() {
        for session in TWTRTwitter.sharedInstance().sessionStore.existingUserSessions() {
            if let session = session as? TWTRSession {
                TWTRTwitter.sharedInstance().sessionStore.logOutUserID(session.userID)
            }
        }

        dismiss(animated: true) {
            self.delegate?.loginViewControllerDidClearAccounts(viewController: self)
        }
    }

    // MARK: - Private Methods

    private func setupLoginView() {
        loginView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        loginView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        loginView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        loginView.heightAnchor.constraint(equalToConstant: 224.0).isActive = true

        loginView.layer.shadowRadius = 4.0
        loginView.layer.shadowColor = UIColor.lightGray.cgColor
        loginView.layer.shadowOpacity = 0.2
        loginView.layer.masksToBounds = false
    }

    private func setupBackgroundView() {
        backgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: loginView.topAnchor).isActive = true
        backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }

    private func setupLoginButton() {
        loginButton.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 10.0).isActive = true
        loginButton.rightAnchor.constraint(equalTo: loginView.rightAnchor, constant: -10.0).isActive = true
        loginButton.leftAnchor.constraint(equalTo: loginView.leftAnchor, constant: 10.0).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
    }

    private func setupCustomLoginButton() {
        customLoginButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 10.0).isActive = true
        customLoginButton.rightAnchor.constraint(equalTo: loginButton.rightAnchor).isActive = true
        customLoginButton.leftAnchor.constraint(equalTo: loginButton.leftAnchor).isActive = true
        customLoginButton.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
    }

    private func setupClearAccountsButton() {
        clearAccountsButton.topAnchor.constraint(equalTo: customLoginButton.bottomAnchor, constant: 10.0).isActive = true
        clearAccountsButton.rightAnchor.constraint(equalTo: customLoginButton.rightAnchor).isActive = true
        clearAccountsButton.leftAnchor.constraint(equalTo: customLoginButton.leftAnchor).isActive = true
        clearAccountsButton.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
    }

    private func setupCancelButton() {
        cancelButton.leftAnchor.constraint(equalTo: loginView.leftAnchor, constant: 10.0).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 60.0).isActive = true
        cancelButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
    }

    private func setupTitleLabel() {
        titleLabel.topAnchor.constraint(equalTo: loginView.topAnchor, constant: 10.0).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: loginView.centerXAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 30.0)
        titleLabel.widthAnchor.constraint(equalToConstant: 100.0)
    }
}
