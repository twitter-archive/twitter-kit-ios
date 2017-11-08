//
//  ComplexTweetDemo.swift
//  DemoApp
//
//  Created by Rajul Arora on 10/27/17.
//  Copyright © 2017 Twitter. All rights reserved.
//

import Foundation

struct ComplexTweetDemo: Demo {
    var title: String = "Tweet Composer Demos"
    var description: String = "Presents a series of permutations of our share composer and its several interfaces (legacy and current)."
    var viewController: UIViewController {
        let viewController = DemoCollectionViewController(demos: ComplexTweetDemo.demos)
        viewController.title = title
        return viewController
    }

    static let demos: [Demo] = [
        TweetComposerDemo(),
        TweetComposerViewControllerDemo(),
        TweetComposerViewControllerWithMediaDemo(),
        TweetComposerViewControllerWithPhotosFramework()
    ]
}

struct TweetComposerDemo: Demo {
    var title: String = "TWTRComposer (Legacy)"
    var description: String = "Demo of the legacy tweet composer. This is a minimal composer for only tweeting text."
    var presentationStyle: PresentationStyle = .modal
    var viewController: UIViewController {
        let viewController = TweetComposerViewController(composerType: .tweetComposer)
        viewController.modalPresentationStyle = .overCurrentContext
        return viewController
    }
}

struct TweetComposerViewControllerDemo: Demo {
    var title: String = "TWTRComposerViewController"
    var description: String = "Basic demo of TWTRComposerViewController in an empty state."
    var presentationStyle: PresentationStyle = .modal
    var viewController: UIViewController {
        let viewController = TweetComposerViewController(composerType: .tweetViewController)
        viewController.modalPresentationStyle = .overCurrentContext
        return viewController
    }
}

struct TweetComposerViewControllerWithMediaDemo: Demo {
    var title: String = "TWTRComposerViewController with Media"
    var description: String = "Demo of the TWTRComposerViewController with media selection."
    var presentationStyle: PresentationStyle = .modal
    var viewController: UIViewController {
        let viewController = TweetComposerViewController(composerType: .tweetViewControllerWithMedia)
        viewController.modalPresentationStyle = .overCurrentContext
        return viewController
    }
}

struct TweetComposerViewControllerWithPhotosFramework: Demo {
    var title: String = "TWTRComposerViewController with Photos Framework"
    var description: String = "Demo of the TWTRComposerViewController being used with the Apple Photos Framework. This composer takes your last photo when choosing media."
    var presentationStyle: PresentationStyle = .modal
    var viewController: UIViewController {
        let viewController = TweetComposerViewController(composerType: .tweetViewControllerLastPhoto)
        viewController.modalPresentationStyle = .overCurrentContext
        return viewController
    }
}
