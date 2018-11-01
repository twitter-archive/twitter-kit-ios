//
//  TwitterSessionCollectionViewCell.swift
//  DemoApp
//
//  Created by Rajul Arora on 10/30/17.
//  Copyright © 2017 Twitter. All rights reserved.
//

import UIKit

protocol TwitterSessionCollectionViewCellDelegate : class {
    func sessionCollectionViewCell(collectionViewCell: TwitterSessionCollectionViewCell, didTapLogoutFor session: TWTRSession)
}

class TwitterSessionCollectionViewCell: UICollectionViewCell {

    // MARK: - Public Variables

    weak var delegate: TwitterSessionCollectionViewCellDelegate?

    // MARK: - Private Variables

    private lazy var colorSidebar: UIView = {
        let view = UIView()
        view.backgroundColor = .pubplatPurple
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.numberOfLines = 1
        label.textColor = .darkText
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var userIDLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.numberOfLines = 1
        label.textColor = .lightGray
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(logout), for: .touchUpInside)
        return button
    }()

    private var session: TWTRSession?

    // MARK: - Init

    required override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 4.0
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(usernameLabel)
        contentView.addSubview(userIDLabel)
        contentView.addSubview(colorSidebar)
        contentView.addSubview(logoutButton)

        setupUsernameLabel()
        setupUserIDLabel()
        setupColorSidebar()
        setupLogoutButton()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    private func setupUsernameLabel() {
        usernameLabel.rightAnchor.constraint(equalTo: logoutButton.leftAnchor, constant: -10.0).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10.0).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: colorSidebar.rightAnchor, constant: 10.0).isActive = true
        usernameLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
    }

    private func setupUserIDLabel() {
        userIDLabel.rightAnchor.constraint(equalTo: logoutButton.leftAnchor, constant: -10.0).isActive = true
        userIDLabel.leftAnchor.constraint(equalTo: colorSidebar.rightAnchor, constant: 10.0).isActive = true
        userIDLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor).isActive = true
        userIDLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
    }

    private func setupColorSidebar() {
        colorSidebar.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        colorSidebar.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        colorSidebar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        colorSidebar.widthAnchor.constraint(equalToConstant: 10.0).isActive = true
    }

    private func setupLogoutButton() {
        logoutButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10.0).isActive = true
        logoutButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10.0).isActive = true
        logoutButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10.0).isActive = true
        logoutButton.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
    }

    // MARK: - Actions

    @objc func logout() {
        if let session = session {
            delegate?.sessionCollectionViewCell(collectionViewCell: self, didTapLogoutFor: session)
        }
    }

    // MARK: - Public Methods

    func configure(with session: TWTRSession?) {
        self.session = session
        guard let session = session else { return }
        usernameLabel.text = "Username: \(session.userName)"
        userIDLabel.text = "User ID: \(session.userID)"
    }
}
