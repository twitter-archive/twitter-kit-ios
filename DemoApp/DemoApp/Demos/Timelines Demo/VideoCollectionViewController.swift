//
//  VideoCollectionViewController.swift
//  FabricSampleApp
//
//  Created by Chase Latta on 12/15/15.
//  Copyright © 2015 Twitter. All rights reserved.
//

import UIKit

class VideoCollectionViewController: TWTRTimelineViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let client = TWTRAPIClient()
        self.dataSource = TWTRCollectionTimelineDataSource(collectionID: "676964973252317184", apiClient: client)
        
        self.title = "Videos"
        self.showTweetActions = true
        
        // Uncomment to handle the video taps yourself
//        self.tweetViewDelegate = self

        setupNotificationObservers()
    }

    func setupNotificationObservers() {
        let _ = NotificationCenter.default.addObserver(forName: NSNotification.Name.TWTRVideoPlaybackStateChanged, object: nil, queue: OperationQueue.main) { (notification) in
            print("Video state changed: \(notification.userInfo![TWTRVideoPlaybackStateKey]!)")
        }
        let _ = NotificationCenter.default.addObserver(forName: NSNotification.Name.TWTRWillPresentVideo, object: nil, queue: OperationQueue.main) { (notification) in
            print("Will present: \(notification.name)")
        }
        let _ = NotificationCenter.default.addObserver(forName: NSNotification.Name.TWTRDidDismissVideo, object: nil, queue: OperationQueue.main) { (notification) in
            print("Did dismiss: \(notification.name)")
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let tweetTableCell = cell as? TWTRTweetTableViewCell {
            tweetTableCell.tweetView.presenterViewController = self
        }

        return cell
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension VideoCollectionViewController: TWTRTweetViewDelegate {
    func tweetView(_ tweetView: TWTRTweetView, didTapVideoWith videoURL: URL) {
        print("TAPPED VIDEO ", videoURL)
    }
}
