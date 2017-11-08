//
//  TweetCollectionViewCell.swift
//  DemoApp
//
//  Created by Rajul Arora on 7/28/17.
//  Copyright © 2017 Twitter. All rights reserved.
//

import UIKit

class TweetCollectionViewCell: UICollectionViewCell {

    // MARK: - Private Variables

    static var prototypeTweetView: TWTRTweetView = TWTRTweetView(tweet: nil)

    private var tweetView: TWTRTweetView = TWTRTweetView(tweet: nil)

    private var heightConstraint: NSLayoutConstraint?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(tweetView)
        contentView.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tweetView.frame = contentView.frame
    }

    // MARK: - Public Methods

    func configure(with tweet: TWTRTweet) {
        self.tweetView.configure(with: tweet)
    }

    func pauseVideo() {
        self.tweetView.pauseVideo()
    }

    // MARK: - Class Methods

    class func sizeThatFits(for size: CGSize, with tweet: TWTRTweet) -> CGSize {
        prototypeTweetView.configure(with: tweet)
        return prototypeTweetView.sizeThatFits(size)
    }
}
