//
//  UserTimelineViewController.swift
//  FabricSampleApp
//
//  Created by Steven Hepting on 2/2/15.
//  Copyright (c) 2015 Twitter. All rights reserved.
//

import UIKit

class UserTimelineViewController: TWTRTimelineViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let client = TWTRAPIClient.withCurrentUser()
        self.dataSource = TWTRUserTimelineDataSource(screenName: "testbykate", apiClient: client)

        self.title = "@testbykate"
        self.showTweetActions = true
    }

    func tweetView(tweetView: TWTRTweetView, didSelectTweet tweet: TWTRTweet) {
        print("Selected tweet with ID: \(tweet.tweetID)")
    }

}
