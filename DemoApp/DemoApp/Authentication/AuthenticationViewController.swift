//
//  AuthenticationViewController.swift
//  FabricSampleApp
//
//  Created by Steven Hepting on 8/19/15.
//  Copyright (c) 2015 Twitter. All rights reserved.
//

import UIKit

extension CGRect {
    func offset(offsetValue: Int) -> CGRect {
        return self.offsetBy(dx: 0, dy: CGFloat(offsetValue))
    }
}

@objc protocol AuthenticationViewControllerDelegate {
    @objc func authenticationViewControllerDidTapHome(viewController: AuthenticationViewController)
}

class AuthenticationViewController: UIViewController {

    enum Section: Int {
        case users
        case addUser
    }

    // MARK: - Public Variables

    weak var delegate: AuthenticationViewControllerDelegate?

    // MARK: - Private Variables

    fileprivate lazy var collectionView: UICollectionView = { [unowned self] in
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 10.0, right: 0.0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .groupTableViewBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)
        collectionView.register(TwitterSessionCollectionViewCell.self, forCellWithReuseIdentifier: AuthenticationViewController.cellIdentifier)
        collectionView.register(TwitterLoginCollectionViewCell.self, forCellWithReuseIdentifier: AuthenticationViewController.loginCellIdentifier)
        return collectionView
    }()

    fileprivate static let cellIdentifier = "authCell"
    fileprivate static let loginCellIdentifier = "loginCell"
    fileprivate var sessionStore: TWTRSessionStore

    // MARK: - Init

    required init() {
        self.sessionStore = Twitter.sharedInstance().sessionStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Authentication"

        setupCollectionView()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(home))
    }

    // MARK: - Actions

    func home() {
        delegate?.authenticationViewControllerDidTapHome(viewController: self)
    }

    // MARK: - Private Methods

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
}

// MARK: - UICollectionViewDataSource

extension AuthenticationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let section = Section(rawValue: indexPath.section) {
            switch section {
                case .users:
                    return collectionView.dequeueReusableCell(withReuseIdentifier: AuthenticationViewController.cellIdentifier, for: indexPath)
            case .addUser:
                    return collectionView.dequeueReusableCell(withReuseIdentifier: AuthenticationViewController.loginCellIdentifier, for: indexPath)
            }
        } else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: AuthenticationViewController.cellIdentifier, for: indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .users: return sessionStore.existingUserSessions().count
        case .addUser: return 1
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
}

// MARK: - UICollectionViewDelegate

extension AuthenticationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        switch section {
        case .users:
            if let cell = cell as? TwitterSessionCollectionViewCell, let session = sessionStore.existingUserSessions()[indexPath.row] as? TWTRSession {
                cell.delegate = self
                cell.configure(with: session)
            }
        case .addUser:
            if let cell = cell as? TwitterLoginCollectionViewCell {
                cell.delegate = self
                cell.configure()
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AuthenticationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let section = Section(rawValue: indexPath.section) else { return .zero }
        switch section {
        case .users: return CGSize(width: collectionView.frame.width - 20.0, height: 60.0)
        case .addUser: return CGSize(width: collectionView.frame.width - 20.0, height: 48.0)
        }
    }
}

// MARK: - TwitterLoginCollectionViewCellDelegate

extension AuthenticationViewController: TwitterLoginCollectionViewCellDelegate {
    func loginCollectionViewCellDidTapAddAccountButton(cell: TwitterLoginCollectionViewCell) {
        let viewController = LoginViewController()
        viewController.delegate = self
        viewController.modalPresentationStyle = .overCurrentContext
        present(viewController, animated: true, completion: nil)
    }
}

// MARK: - TwitterSessionCollectionViewCellDelegate

extension AuthenticationViewController: TwitterSessionCollectionViewCellDelegate {
    func sessionCollectionViewCell(collectionViewCell: TwitterSessionCollectionViewCell, didTapLogoutFor session: TWTRSession) {
        Twitter.sharedInstance().sessionStore.logOutUserID(session.userID)
        collectionView.reloadData()
    }
}

// MARK: - LoginViewControllerDelegate

extension AuthenticationViewController: LoginViewControllerDelegate {
    func loginViewControllerDidClearAccounts(viewController: LoginViewController) {
        collectionView.reloadData()
    }

    func loginViewController(viewController: LoginViewController, didAuthWith session: TWTRSession) {
        collectionView.reloadData()
    }
}
