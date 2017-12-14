//
//  StubTweetRepository.m
//  TwitterKit
//
//  Created by Steven Hepting on 12/16/14.
//  Copyright (c) 2014 Twitter. All rights reserved.
//

#import "TWTRStubTweetCache.h"
#import <TwitterKit/TWTRKit.h>

@implementation TWTRStubTweetCache

- (NSMutableDictionary *)cachedTweets
{
    if (!_cachedTweets) {
        _cachedTweets = [[NSMutableDictionary alloc] init];
    }

    return _cachedTweets;
}

- (void)cacheTweets:(NSArray *)tweets
{
    for (TWTRTweet *tweet in tweets) {
        self.cachedTweets[tweet.tweetID] = tweet;
    }

    if (!tweets) {
        _cachedTweets = nil;
    }
}

- (TWTRTweet *)tweetWithID:(NSString *)tweetIDString perspective:(NSString *)userIDString
{
    self.lastRequestedID = tweetIDString;
    return self.cachedTweets[tweetIDString];
}

- (BOOL)storeTweet:(TWTRTweet *)tweet perspective:(NSString *)userIDString
{
    self.cachedTweets[tweet.tweetID] = tweet;

    return YES;
}

@end
