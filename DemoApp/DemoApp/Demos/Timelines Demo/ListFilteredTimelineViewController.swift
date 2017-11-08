//
//  ListFilteredTimelineViewController.swift
//  FabricSampleApp
//
//  Created by Alejandro Crosa on 11/18/16.
//  Copyright © 2016 Twitter. All rights reserved.
//

import UIKit

class ListFilteredTimelineViewController: TWTRTimelineViewController, TWTRTimelineDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        let client = TWTRAPIClient.withCurrentUser()
        self.dataSource = TWTRListTimelineDataSource(listSlug: "twitter-kit", listOwnerScreenName: "stevenhepting", apiClient: client)
        // Note that the delegate is being set *after* the dataSource.
        // This is enabled by the change to the `setDataSource:` method
        // to load more Tweets on the next runloop
        self.timelineDelegate = self;
        SVProgressHUD.setDefaultStyle(.dark)

        // filter the search timeline
        let filter = TWTRTimelineFilter()
        filter.handles = [ "newyorker", "benward", "mollie" ]
        self.dataSource.timelineFilter = filter

        self.showTweetActions = true
        self.view.backgroundColor = .lightGray
    }

    func timelineDidBeginLoading(_ timeline: TWTRTimelineViewController) {
        print("Began loading Tweets.")
        SVProgressHUD.show(withStatus: "Loading")
    }

    func timeline(_ timeline: TWTRTimelineViewController, didFinishLoadingTweets tweets: [Any]?, error: Error?) {
        if error != nil {
            print("Encountered error \(error!)")
            SVProgressHUD.showError(withStatus: "Error")
            SVProgressHUD.dismiss(withDelay: 1)
        } else {
            print("Finished loading \(tweets!.count)")
            SVProgressHUD.showSuccess(withStatus: "Finished");
            SVProgressHUD.dismiss(withDelay: 1)
        }
    }
}
