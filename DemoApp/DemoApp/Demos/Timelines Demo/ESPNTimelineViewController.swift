//
//  ESPNTimelineViewController.swift
//  FabricSampleApp
//
//  Created by Steven Hepting on 2/25/15.
//  Copyright (c) 2015 Twitter. All rights reserved.
//
//  Rough example of how to show an ad in your tableview.
//

import UIKit

func offset(indexPath: IndexPath) -> IndexPath {
    let newIndexPath = IndexPath(row: indexPath.row - 1, section: 0)
    return newIndexPath
}

@objc(ESPNTimelineViewController)
class ESPNTimelineViewController: TWTRTimelineViewController {

    let numberOfAds = 1
    let adIndex = 2

    convenience init() {
        self.init(dataSource: TWTRSearchTimelineDataSource(searchQuery: "ESPN", apiClient: TWTRAPIClient()))
    }

    // Insert extra cells at some row indexes
    // otherwise, offset the indexPath and call super
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row < adIndex) { // Regular cell, no offset
            return super.tableView(tableView, cellForRowAt: indexPath)
        } else if (indexPath.row == adIndex) { // Ad cell, create custom
            // Create first ad view here
            let cell = UITableViewCell()
            cell.textLabel?.text = "Demo Ad Unit"
            cell.backgroundColor = .lightGray
            return cell
        } else { // Regular cell, offset indexPath
            return super.tableView(tableView, cellForRowAt: offset(indexPath: indexPath))
        }
    }

    @available(iOS 8.0, *)
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let moreRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "More", handler:{action, indexpath in
            print("More Action")
            })
        moreRowAction.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);

        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler:{action, indexpath in
            print("Delete Action")
        });

        return [deleteRowAction, moreRowAction]
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

    }

    // Check if this is our cell, return the correct height
    // otherwise, offset the indexPath and call super
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row < adIndex) { // Regular cell, no offset
            return super.tableView(tableView, heightForRowAt: indexPath)
        } else if (indexPath.row == adIndex) { // Ad cell, custom height
            return 60
        } else { // Regular cell, offset index
            return super.tableView(tableView, heightForRowAt: offset(indexPath: indexPath))
        }
    }

    // Make sure we've offset by the number of extra rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSuper = super.tableView(tableView, numberOfRowsInSection: section)
        if (numberOfRowsInSuper > adIndex) { // If super has enough rows to show ad
            return numberOfRowsInSuper + numberOfAds
        } else {
            return 0
        }
    }

    func tweetView(tweetView: TWTRTweetView!, didSelectTweet tweet: TWTRTweet!) {
        print("Selected tweet with ID: \(tweet.tweetID)")
    }
}
