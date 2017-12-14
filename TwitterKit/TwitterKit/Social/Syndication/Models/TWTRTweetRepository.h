/*
 * Copyright (C) 2017 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

/**
 This header is private to the Twitter Kit SDK and not exposed for public SDK consumption
 */

#import "TWTRAPIClient.h"

@class TWTRAPIClient;
@class TWTRTweet;

NS_ASSUME_NONNULL_BEGIN

typedef void (^TWTRTweetRepoSingleTweetCompletion)(TWTRTweet *_Nullable tweet, NSError *_Nullable error);

/**
 Private class that encapsulates the business logic of fetching Tweets and caching them
 */
@interface TWTRTweetRepository : NSObject
/**
 *  Shared Tweet repository.
 *
 *  @return The single instance of a TWTRTweetRepository
 */
+ (instancetype)sharedInstance;

#pragma mark - Tweet API Methods

/**
 *  Load a set of Tweets. If they are already cached, the Tweets will be loaded from disk.
 *  Otherwise they will be fetched from the network, added to the on-disk cache, and then
 *  returned to the caller.
 *
 *  @param tweetIDStrings An array of Tweet IDs. e.g. [@"893428", @"28901", @"2309"]
 *  @param client         The API client to use for required network requests.
 *  @param parameters     Additional parameters to append to the request.
 *  @param completion     The completion block to be called with
 */
- (void)loadTweetsWithIDs:(NSArray<NSString *> *)tweetIDStrings APIClient:(TWTRAPIClient *)client additionalParameters:(nullable NSDictionary *)parameters completion:(TWTRLoadTweetsCompletion)completion;

/**
 *  Cache a single Tweet to disk. Uses the .perspectivalUserId of the tweet to store
 *  each Tweet with respect to the user that loaded it.
 *
 *  @param tweet The TWTRTweet model object to cache.
 */
- (void)cacheTweet:(TWTRTweet *)tweet;

/**
 *  Cache a single Tweet to disk from a given perspective.
 *
 *  @param tweet       The TWTRTweet model object to cache.
 *  @param perspective The userID associated with this tweet.
 */
- (void)cacheTweet:(TWTRTweet *)tweet perspective:(NSString *)perspective;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
