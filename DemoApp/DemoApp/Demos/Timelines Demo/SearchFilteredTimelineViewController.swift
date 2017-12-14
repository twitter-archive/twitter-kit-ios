//
//  SearchFilteredTimelineViewController.swift
//  FabricSampleApp
//
//  Created by Alejandro Crosa on 11/15/16.
//  Copyright © 2016 Twitter. All rights reserved.
//

import UIKit

@objc (SearchFilteredTimelineViewController)
class SearchFilteredTimelineViewController: TWTRTimelineViewController, DZNEmptyDataSetSource {

    convenience init() {
        let client = TWTRAPIClient.withCurrentUser()
        let dataSource = TWTRSearchTimelineDataSource(searchQuery: "twitter", apiClient: client)

        // filter the search timeline
        let filter = TWTRTimelineFilter()
        filter.keywords = [ "book", "phone" ]
        filter.hashtags = [ "#twitter", "#followme" ]
        filter.urls = [ "twitter.com", "fabric.io" ]
        filter.handles = [ "ericfrohnhoefer", "benward", "vam_si", "katejaiheelee", "esacrosa" ]
        dataSource.timelineFilter = filter

        self.init(dataSource: dataSource)
        self.title = dataSource.searchQuery
        self.hidesBottomBarWhenPushed = true
        self.showTweetActions = true

        // To remove our default message
        self.tableView.backgroundView = nil

        // For DZNEmptyDataSet
        self.tableView.emptyDataSetSource = self;
    }
}
