//
//  TweetOptionsView.swift
//  DemoApp
//
//  Created by Rajul Arora on 11/1/17.
//  Copyright © 2017 Twitter. All rights reserved.
//

import UIKit

enum TweetOption {
    case style
    case theme
    case actions
}

class TweetOptionsView: UIView {

    // MARK: - Private Variables

    fileprivate static let cellIdenfitier = "optionCell"

    private lazy var tableView: UITableView = { [unowned self] in
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 48.0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.register(TweetOptionTableViewCell.self, forCellReuseIdentifier: TweetOptionsView.cellIdenfitier)
        return tableView
    }()

    fileprivate var options: [TweetOption] = [.style, .theme, .actions]

    // MARK: - Init

    init() {
        super.init(frame: .zero)
        addSubview(tableView)
        setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods

    private func setupTableView() {
        tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    }

    // MARK: - Public Methods

    func tweetSettings() -> [TweetOption: Any] {
        var dict: [TweetOption: Any] = [:]
        options.forEach { dict[$0] = setting(for: $0) }
        return dict
    }

    private func setting(for option: TweetOption) -> Any? {
        guard let index = options.index(of: option) else { return nil }
        let indexPath = IndexPath(row: index, section: 0)

        if let cell = tableView.cellForRow(at: indexPath) as? TweetOptionTableViewCell {
            return cell.tweetSetting()
        } else {
            return nil
        }
    }
}

// MARK: - UITableViewDataSource

extension TweetOptionsView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: TweetOptionsView.cellIdenfitier, for: indexPath)
    }
}

// MARK: - UITableViewDelegate

extension TweetOptionsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? TweetOptionTableViewCell {
            cell.selectionStyle = .none
            cell.configure(option: options[indexPath.row])
        }
    }
}
