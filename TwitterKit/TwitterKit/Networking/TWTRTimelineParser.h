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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *The Twitter Search API returns tweets one page at a time. You can receive older tweets by specifying a Tweet ID in the max_id parameter. The documentation (https://dev.twitter.com/rest/reference/get/search/tweets) specifies that the value is *exclusive* but in reality we have found that it is often *inclusive*. This is why we often need to internally decrement this Tweet position, so there is no overlap in the Tweets requested from the Twitter API.
 *
 *  @param tweetPosition (required) The original Tweet position returned from the Twitter API.
 *
 *  @return A new Tweet position that is 1 smaller than the one passed in.
 */
NSString *_Nullable decrementTweetPosition(NSString *tweetPosition);

@interface TWTRTimelineParser : NSObject

/**
 *  Creates an array of TWTRTweet instances from the dictionary of Collection API.
 *
 *  @param dictionary (required) The dictionary received from the collections API.
 *
 *  @return An array of `TWTRTweet` instances or nil.
 */
+ (nullable NSArray *)tweetsFromCollectionAPIResponseDictionary:(NSDictionary *)collection;

/**
 *  Creates and array of Tweet model objects from a dictionary of the server
 *  response from the Twitter Search API.
 *
 *  @param dictionary (required) A dictionary representing the response from the Search API.
 *
 *  @return An array of `TWTRTweet` model objects or nil.
 */
+ (nullable NSArray *)tweetsFromSearchAPIResponseDictionary:(NSDictionary *)dictionary;

/**
 *  Returns the minimum tweet ID returned from the Collection API.
 *
 *  @param dictionary (required) The dictionary received from the collections API.
 *
 *  @return The ID of the oldest tweet returned or nil.
 */
+ (nullable NSString *)minPositionFromCollectionAPIResponseDictionary:(NSDictionary *)collection;

/**
 *  Return ID of the last (by array index) Tweet in the array.
 *
 *  @param tweets Array of TWTRTweet objects
 *
 *  @return A Tweet ID or nil if not found.
 */
+ (nullable NSString *)lastTweetIDFromTweets:(NSArray *)tweets;

@end

NS_ASSUME_NONNULL_END
