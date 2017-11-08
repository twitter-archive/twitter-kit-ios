//
//  DemoCollectionViewCell.swift
//  DemoApp
//
//  Created by Rajul Arora on 10/26/17.
//  Copyright © 2017 Twitter. All rights reserved.
//

import UIKit

class DemoCollectionViewCell: UICollectionViewCell {

    // MARK: - Private Variables

    private var demo: Demo?

    private lazy var colorSidebar: UIView = {
        let view = UIView()
        view.backgroundColor = .pubplatPurple
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.textColor = .darkText
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    required override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(colorSidebar)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)

        setupColorSidebar()
        setupTitleLabel()
        setupDescriptionLabel()

        contentView.backgroundColor = .white

        contentView.layer.cornerRadius = 4.0
        contentView.layer.masksToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    private func setupColorSidebar() {
        colorSidebar.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        colorSidebar.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        colorSidebar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        colorSidebar.widthAnchor.constraint(equalToConstant: 10.0).isActive = true
    }

    private func setupTitleLabel() {
        titleLabel.leftAnchor.constraint(equalTo: colorSidebar.rightAnchor, constant: 10.0).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10.0).isActive = true
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10.0).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor).isActive = true
    }

    private func setupDescriptionLabel() {
        descriptionLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        descriptionLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10.0).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10.0).isActive = true
    }

    // MARK: - Public Methods

    func configure(with demo: Demo) {
        self.demo = demo
        titleLabel.text = demo.title
        descriptionLabel.text = demo.description
    }

    private static let prototypeCell: DemoCollectionViewCell = DemoCollectionViewCell(frame: .zero)

    static func sizeThatFits(_ size: CGSize, for demo: Demo) -> CGSize {
        prototypeCell.configure(with: demo)
        let constrainedWidth = size.width - 10.0 - 20.0
        let titleSize = prototypeCell.titleLabel.sizeThatFits(CGSize(width: constrainedWidth, height: CGFloat.greatestFiniteMagnitude))
        let descriptionSize = prototypeCell.descriptionLabel.sizeThatFits(CGSize(width: constrainedWidth, height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: size.width, height:titleSize.height + descriptionSize.height + 20.0)
    }
}
