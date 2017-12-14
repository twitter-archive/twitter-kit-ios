//
//  UserFilteredTimelineViewController.swift
//  FabricSampleApp
//
//  Created by Alejandro Crosa on 11/18/16.
//  Copyright © 2016 Twitter. All rights reserved.
//

import UIKit

class UserFilteredTimelineViewController: TWTRTimelineViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let client = TWTRAPIClient.withCurrentUser()
        self.dataSource = TWTRUserTimelineDataSource(screenName: "fabric", apiClient: client)

        // filter the user timeline
        let filter = TWTRTimelineFilter()
        filter.urls = ["fabric.io", "twitter.com", "answers.io"]
        self.dataSource.timelineFilter = filter;

        self.title = "@fabric"
        self.showTweetActions = true
    }

    func tweetView(tweetView: TWTRTweetView, didSelectTweet tweet: TWTRTweet) {
        print("Selected tweet with ID: \(tweet.tweetID)")
    }
}
