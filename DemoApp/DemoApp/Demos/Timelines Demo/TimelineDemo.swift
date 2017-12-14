//
//  TimelineDemo.swift
//  DemoApp
//
//  Created by Rajul Arora on 10/27/17.
//  Copyright © 2017 Twitter. All rights reserved.
//

import Foundation

struct TimelineDemo: Demo {
    var title: String = "Timelines"
    var description: String = "A collection of demos of the various types of timelines in TwitterKit"
    var viewController: UIViewController {
        let viewController = DemoCollectionViewController(demos: TimelineDemo.demos)
        viewController.title = title
        return viewController
    }

    static let demos: [Demo] = [
        ListTimelineDemo(),
        TweetCollectionViewDemo(),
        VideoTimelineDemo(),
        ESPNTimelineDemo(),
        ListFilteredTimelineDemo(),
        SearchTimelineDemo(),
        UserFilteredTimelineDemo(),
        UserTimelineDemo(),
        FilteredCollectionDemo(),
        CollectionTimelineDemo()
    ]
}

struct ListTimelineDemo: Demo {
    var title: String = "List Timeline"
    var description: String = "List Timeline Demo"
    var viewController: UIViewController {
        let viewController = ListTimelineViewController()
        viewController.title = title
        return viewController
    }
}

struct TweetCollectionViewDemo: Demo {
    var title: String = "Tweet Collection View"
    var description: String = "A Collection of TWTRTweetViews in a UICollectionView. This is particularly useful to stress test the rendering and scrolling performance of many TWTRTweetViews"
    var viewController: UIViewController {
        let viewController = TweetCollectionViewController()
        viewController.title = title
        return viewController
    }
}

struct VideoTimelineDemo: Demo {
    var title: String = "Video Timeline"
    var description: String = "A timeline of video tweets. This can be used to test video playback and monitor video playback state changes."
    var viewController: UIViewController {
        let viewController = VideoCollectionViewController()
        viewController.title = title
        return viewController
    }
}

struct ESPNTimelineDemo: Demo {
    var title: String = "ESPN Timeline"
    var description: String = "Demo outlining showing native ads in a timeline. This serves as a rough example of how to show an add in your tableview."
    var viewController: UIViewController {
        let viewController = ESPNTimelineViewController()
        viewController.title = title
        return viewController
    }
}

struct ListFilteredTimelineDemo: Demo {
    var title: String = "Filtered List Timeline"
    var description: String = "Demo of filtering a timeline with specific twitter handles."
    var viewController: UIViewController = ListFilteredTimelineViewController()
}

// TODO: Fix Crash
struct SearchFilteredTimelineDemo: Demo {
    var title: String = "Filtered Search Timeline"
    var description: String = "Demo of a search timeline filtered using keywords, hashtags, urls and twitter handles."
    var viewController: UIViewController = SearchFilteredTimelineViewController()
}

struct SearchTimelineDemo: Demo {
    var title: String = "Search Timeline"
    var description: String = "Demo of a search timeline filtered using a geocode specifier."
    var viewController: UIViewController = SearchTimelineViewController()
}

// TODO: Fix Crash
struct UserFilteredTimelineDemo: Demo {
    var title: String = "User Filtered Timeline"
    var description: String = "Demo of a timeline filtered with urls"
    var viewController: UIViewController = UserFilteredTimelineViewController()
}

struct UserTimelineDemo: Demo {
    var title: String = "User Timeline"
    var description: String = "Demo of a timeline filtered using only a single twitter handle."
    var viewController: UIViewController = UserTimelineViewController()
}

struct FilteredCollectionDemo: Demo {
    var title: String = "Filtered Collection Timeline"
    var description: String = "Demo of a timeline filtered using a collection identifier as well as filtered by a specific twitter handle."
    var viewController: UIViewController = CollectionFilteredTimelineViewController()
}

struct CollectionTimelineDemo: Demo {
    var title: String = "Collection Timeline"
    var description: String = "Demo of a timeline filtered using only a collection idenfitier."
    var viewController: UIViewController = CollectionTimelineViewController()
}
