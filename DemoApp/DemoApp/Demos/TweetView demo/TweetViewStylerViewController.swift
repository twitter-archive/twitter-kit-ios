//
//  TweetViewStylerViewController.swift
//  DemoApp
//
//  Created by Rajul Arora on 11/1/17.
//  Copyright © 2017 Twitter. All rights reserved.
//

import UIKit

enum TweetViewErrors {
    case noAccount
}

extension TweetViewErrors: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noAccount: return "No User Account. Please Sign in to Continue"
        }
    }
}

class TweetViewStylerViewController: UIViewController {

    // MARK: - Private Variables

    private lazy var tweetContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var tweetView: TWTRTweetView?
    private var tweet: TWTRTweet?

    private lazy var optionsView: TweetOptionsView = {
        let view = TweetOptionsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var generateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Generate!", for: .normal)
        button.setTitleColor(.white, for:.normal)
        button.backgroundColor = .pubplatPurple
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(updateTweetView), for: .touchUpInside)
        button.layer.cornerRadius = 4.0
        return button
    }()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Tweet View Generator"
        edgesForExtendedLayout = []

        view.addSubview(tweetContainerView)
        view.addSubview(optionsView)
        view.addSubview(generateButton)

        setupTweetContainerView()
        setupOptionsView()
        setupGenerateButton()

        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
        loadTweet(with: "864977390941814784") { [weak self] (tweet, error) in
            SVProgressHUD.dismiss()
            if let error = error, let weakSelf = self {
                UIAlertController.showAlert(with: error, on: weakSelf)
            } else if let tweet = tweet {
                self?.configureTweetView(with: tweet)
            }
        }
    }

    // MARK: - Actions

    @objc func updateTweetView() {
        if let tweet = tweet {
            configureTweetView(with: tweet)
        }
    }

    // MARK: - Private Methods

    private func loadTweet(with tweetID: String, _ completion: @escaping (TWTRTweet?, Error?) -> Void) {
        guard let session = TWTRTwitter.sharedInstance().sessionStore.session() else {
            completion(nil, TweetViewErrors.noAccount)
            return
        }

        TWTRAPIClient(userID: session.userID).loadTweet(withID: tweetID, completion: completion)
    }

    private func configureTweetView(with tweet: TWTRTweet) {
        self.tweet = tweet

        if let tweetView = tweetView {
            tweetView.removeConstraints(tweetView.constraints)
            tweetView.removeFromSuperview()
            self.tweetView = nil
        }

        let tweetSettings = optionsView.tweetSettings()

        guard let style = tweetSettings[TweetOption.style] as? TWTRTweetViewStyle else {
            debugPrint("Unable to read style")
            return
        }

        guard let theme = tweetSettings[TweetOption.theme] as? TWTRTweetViewTheme else {
            debugPrint("Unable to read theme.")
            return
        }

        let newTweetView = TWTRTweetView(tweet: tweet, style: style)
        newTweetView.showActionButtons = tweetSettings[TweetOption.actions] as? Bool ?? true
        newTweetView.theme = theme
        newTweetView.translatesAutoresizingMaskIntoConstraints = false

        tweetContainerView.addSubview(newTweetView)
        self.tweetView = newTweetView
        setupTweetView()
    }

    private func setupTweetView() {
        if let tweetView = tweetView {
            tweetView.centerXAnchor.constraint(equalTo: tweetContainerView.centerXAnchor).isActive = true
            tweetView.centerYAnchor.constraint(equalTo: tweetContainerView.centerYAnchor).isActive = true

            let size = tweetView.sizeThatFits(tweetContainerView.frame.size)
            tweetView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
            tweetView.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
    }

    private func setupTweetContainerView() {
        tweetContainerView.topAnchor.constraint(equalTo: generateButton.bottomAnchor, constant: 10.0).isActive = true
        tweetContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20.0).isActive = true
        tweetContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10.0).isActive = true
        tweetContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10.0).isActive = true
    }

    private func setupOptionsView() {
        optionsView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        optionsView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        optionsView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        optionsView.heightAnchor.constraint(equalToConstant: 144.0).isActive = true 
    }

    private func setupGenerateButton() {
        generateButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10.0).isActive = true
        generateButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10.0).isActive = true
        generateButton.topAnchor.constraint(equalTo: optionsView.bottomAnchor, constant: 10.0).isActive = true
        generateButton.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
    }
}
