//
//  CollectionTimelineViewController.swift
//  FabricSampleApp
//
//  Created by Steven Hepting on 5/7/15.
//  Copyright (c) 2015 Twitter. All rights reserved.
//

import UIKit

class CollectionTimelineViewController: TWTRTimelineViewController {

    convenience init() {
        let client = TWTRAPIClient()
        let dataSource = TWTRCollectionTimelineDataSource(collectionID: "659110687482839040", apiClient: client)

        self.init(dataSource: dataSource)
        self.hidesBottomBarWhenPushed = true
    }

    func tweetView(tweetView: TWTRTweetView!, didSelectTweet tweet: TWTRTweet!) {
        print("Selected tweet with ID: \(tweet.tweetID)")
    }
}
