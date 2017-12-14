//
//  CollectionFilteredTimelineViewController.swift
//  FabricSampleApp
//
//  Created by Alejandro Crosa on 11/18/16.
//  Copyright © 2016 Twitter. All rights reserved.
//

import UIKit

class CollectionFilteredTimelineViewController: TWTRTimelineViewController {

    convenience init() {
        let client = TWTRAPIClient()
        let dataSource = TWTRCollectionTimelineDataSource(collectionID: "659110687482839040", apiClient: client)

        // filter the search timeline
        let filter = TWTRTimelineFilter()
        filter.handles = [ "nasa" ]

        dataSource.timelineFilter = filter

        self.init(dataSource: dataSource)
        self.hidesBottomBarWhenPushed = true
    }

    func tweetView(tweetView: TWTRTweetView!, didSelectTweet tweet: TWTRTweet!) {
        print("Selected tweet with ID: \(tweet.tweetID)")
    }
}
