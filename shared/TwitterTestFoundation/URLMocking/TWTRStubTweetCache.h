//
//  StubTweetRepository.h
//  TwitterKit
//
//  Created by Steven Hepting on 12/16/14.
//  Copyright (c) 2014 Twitter. All rights reserved.
//

#import "TWTRTweetCache.h"

/*
 *  Provide a stub implementation of TWTRTweetCache to more thoroughly test any classes that depend heavily the way that tweets are loaded from disk.
 *
 *  To use, call any of the TWTRTweetCache methods to add Tweets to this faux cache.
 */
@interface TWTRStubTweetCache : NSObject <TWTRTweetCache>

@property (nonatomic, strong) NSMutableDictionary *cachedTweets;
@property (nonatomic, strong) NSString *lastRequestedID;

- (void)cacheTweets:(NSArray *)cachedTweets;

#pragma mark - TWTRTweetCache Protocol Methods

- (TWTRTweet *)tweetWithID:(NSString *)tweetIDString perspective:(NSString *)userIDString;
- (BOOL)storeTweet:(TWTRTweet *)tweet perspective:(NSString *)userIDString;

@end
