//
//  TwitterLoginCollectionViewCell.swift
//  DemoApp
//
//  Created by Rajul Arora on 10/30/17.
//  Copyright © 2017 Twitter. All rights reserved.
//

import UIKit

@objc protocol TwitterLoginCollectionViewCellDelegate {
    func loginCollectionViewCellDidTapAddAccountButton(cell: TwitterLoginCollectionViewCell)
}

class TwitterLoginCollectionViewCell: UICollectionViewCell {

    // MARK: - Private Variables

    private lazy var addAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(addAccount), for: .touchUpInside)
        button.setTitle("Add Account", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Public Variables

    weak var delegate: TwitterLoginCollectionViewCellDelegate?

    // MARK: - Init

    required override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 4.0
        contentView.layer.masksToBounds = true

        contentView.addSubview(addAccountButton)
        setupAddAccountButton()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions

    func addAccount() {
        delegate?.loginCollectionViewCellDidTapAddAccountButton(cell: self)
    }

    // MARK: - Public Methods

    func configure() {

    }

    // MARK: - Private Methods

    private func setupAddAccountButton() {
        addAccountButton.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        addAccountButton.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        addAccountButton.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        addAccountButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}
