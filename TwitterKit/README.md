**As of October 31, 2018, Twitter Kit will no longer be supported by Twitter. Please read the [blog post](https://blog.twitter.com/developer/en_us/topics/tools/2018/discontinuing-support-for-twitter-kit-sdk.html) for more information.**

---

Twitter Kit is the easiest way to bring real-time conversational content to your apps. Growing an app’s user base and retaining end users can be a challenge for any developer. To keep users engaged, you need rich, unique content that feels natural to your app’s experience.

To install, add `TwitterKit` to your `Podfile` and run `pod install`. If you already have `TwitterKit` just run `pod update TwitterKit`.

### Show a Single Tweet

To show a single Tweet, you first need to load that Tweet from the network and then create and configure a `TWTRTweetView` with that `TWTRTweet` model object. Then it may be added to the view hierarchy:

```swift
    import TwitterKit

    TWTRAPIClient().loadTweetWithID("20") { tweet, error in
      if let t = tweet {
        let tweetView = TWTRTweetView(tweet: t)
        tweetView.center = view.center
        view.addSubview(tweetView)
      } else {
        print("Failed to load Tweet: \(error)")
      }
    }
```

<img src="https://dev.twitter.com/_images/search_timeline.png" width="250"/>


#### Configuring Tweet View Colors & Themes
To change the colors of a Tweet view you can either set properties directly on the `TWTRTweetView` instances or on the `UIAppearanceProxy` of the `TWTRTweetView`.

```swift
  // Set the theme directly
  tweetView.theme = .Dark

  // Use custom colors
  tweetView.primaryTextColor = .yellowColor()
  tweetView.backgroundColor = .blueColor()
```

<img src="https://dev.twitter.com/_images/show_tweet_themed.png" width="250"/>



Set visual properties using the `UIAppearanceProxy` for `TWTRTweetView`.

```
  // Set all future tweet views to use dark theme using UIAppearanceProxy
  TWTRTweetView.appearance().theme = .Dark
```

### Show a TableView of Tweets

```swift
import TwitterKit

class UserTimelineViewController: TWTRTimelineViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let client = TWTRAPIClient.clientWithCurrentUser()
        self.dataSource = TWTRUserTimelineDataSource(screenName: "twitterdev", APIClient: client)
        self.showTweetActions = true
    }

}
```

<img src="https://dev.twitter.com/_images/user_timeline.png" width="250"/>


### Compose Tweets
To allow users to composer their own Tweets from within your app, simply create a `TWTRComposer` and call `show(from: UIViewController, completion:)` on the instance. This class automatically handles presenting a log in controller if there are no logged in sessions.


```swift

let composer = TWTRComposer()

composer.setText("just setting up my Twitter Kit")
composer.setImage(UIImage(named: "twitterkit"))

// Called from a UIViewController
composer.show(from: self.navigationController!) { (result in
    if (result == .done) {
        print("Successfully composed Tweet")
    } else {
        print("Cancelled composing")
    }
}
```

<img src="https://dev.twitter.com/_images/compose_tweet.png" width="250"/>



## Resources		

 * [Documentation](https://dev.twitter.com/twitterkit/ios/overview)		
 * [Forums](https://twittercommunity.com/c/publisher/twitter)		
 * Follow us on Twitter: [@TwitterDev](https://twitter.com/TwitterDev)		
