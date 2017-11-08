//
//  TweetOptionTableViewCell.swift
//  DemoApp
//
//  Created by Rajul Arora on 11/1/17.
//  Copyright © 2017 Twitter. All rights reserved.
//

import UIKit

class TweetOptionTableViewCell: UITableViewCell {

    // MARK: - Private Variables

    private var option: TweetOption?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkText
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.tintColor = .pubplatPurple
        return control
    }()

    // MARK: - Init

    required override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(titleLabel)
        contentView.addSubview(segmentedControl)

        configureTitleLabel()
        configureSegmentedControl()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func configure(option: TweetOption) {
        self.option = option

        switch option {
        case .actions:
            titleLabel.text = "Actions"
            segmentedControl.insertSegment(withTitle: "No Actions", at: 0, animated: false)
            segmentedControl.insertSegment(withTitle: "Actions", at: 0, animated: false)
        case .style:
            titleLabel.text = "Style"
            segmentedControl.insertSegment(withTitle: "Compact", at: 0, animated: false)
            segmentedControl.insertSegment(withTitle: "Regular", at: 0, animated: false)
        case .theme:
            titleLabel.text = "Theme"
            segmentedControl.insertSegment(withTitle: "Dark", at: 0, animated: false)
            segmentedControl.insertSegment(withTitle: "Light", at: 0, animated: false)
        }

        segmentedControl.selectedSegmentIndex = 0
    }

    func tweetSetting() -> Any? {
        guard let option = option else { return nil }
        switch option {
        case .actions:
            return segmentedControl.selectedSegmentIndex == 0
        case .style:
            return (segmentedControl.selectedSegmentIndex == 0) ? TWTRTweetViewStyle.regular : TWTRTweetViewStyle.compact
        case .theme:
            return (segmentedControl.selectedSegmentIndex == 0) ? TWTRTweetViewTheme.light : TWTRTweetViewTheme.dark
        }
    }

    // MARK: - Private Methods

    private func configureTitleLabel() {
        titleLabel.widthAnchor.constraint(equalToConstant: 80.0).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10.0).isActive = true
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }

    private func configureSegmentedControl() {
        segmentedControl.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 10.0).isActive = true
        segmentedControl.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10.0).isActive = true
        segmentedControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10.0).isActive = true
        segmentedControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10.0).isActive = true
    }
}
