//
//  TweetViewDemo.swift
//  DemoApp
//
//  Created by Rajul Arora on 11/1/17.
//  Copyright © 2017 Twitter. All rights reserved.
//

import Foundation

struct TweetViewDemo: Demo {
    var title: String = "Tweet View Demos"
    var description: String = "Demos for TWTRTweetView"
    var viewController: UIViewController {
        let viewController = DemoCollectionViewController(demos: TweetViewDemo.demos)
        viewController.title = title
        return viewController
    }

    static let demos: [Demo] = [
        TweetViewGeneratorDemo()
    ]
}

struct TweetViewGeneratorDemo: Demo {
    var title: String = "Tweet View Generator"
    var description: String = "Generator for a TWTRTweetView given your own custom parameters"
    var viewController: UIViewController = TweetViewStylerViewController()
}
