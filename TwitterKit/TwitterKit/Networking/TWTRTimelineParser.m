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

#import "TWTRTimelineParser.h"
#import <TwitterCore/TWTRAPIConstants.h>
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRDictUtil.h>
#import "TWTRAPIConstantsStatus.h"
#import "TWTRTweet.h"
#import "TWTRTweet_Private.h"
#import "TWTRUser.h"

NSString *_Nullable decrementTweetPosition(NSString *tweetPosition)
{
    NSCParameterAssert(tweetPosition);
    long long originalPosition = [tweetPosition longLongValue];

    if (!originalPosition) {
        NSLog(@"[TwitterKit] Attempted to decrement an invalid Tweet position: %@", tweetPosition);
        return nil;
    }

    long long newPosition = originalPosition - 1;
    return [NSString stringWithFormat:@"%lli", newPosition];
}

@implementation TWTRTimelineParser

/// TODO: Need tests for this
+ (nullable NSArray *)tweetsFromCollectionAPIResponseDictionary:(NSDictionary *)dictionary
{
    TWTRParameterAssertOrReturnValue(dictionary, nil);

    NSDictionary *objects = [TWTRDictUtil twtr_dictForKey:@"objects" inDict:dictionary];
    NSDictionary *tweetsDict = [TWTRDictUtil twtr_dictForKey:@"tweets" inDict:objects];
    NSDictionary *usersDict = [TWTRDictUtil twtr_dictForKey:@"users" inDict:objects];
    NSDictionary *response = [TWTRDictUtil twtr_dictForKey:@"response" inDict:dictionary];
    NSArray *tweetsTimelineOrderMetadata = [TWTRDictUtil twtr_arrayForKey:@"timeline" inDict:response];

    // Replace skeleton users with fully hydrated users
    NSMutableArray *unorderedTweetDicts = [NSMutableArray arrayWithCapacity:tweetsDict.count];

    for (NSDictionary *tweet in [tweetsDict allValues]) {
        NSMutableDictionary *hydratedTweet = [self hyrdrateTweet:tweet withUserFromUsers:usersDict];

        if (hydratedTweet) {
            [unorderedTweetDicts addObject:hydratedTweet];
            [self hydrateSubTweetWithKey:TWTRAPIConstantsStatusFieldQuotedStatus forTweet:hydratedTweet withUsers:usersDict];
            [self hydrateSubTweetWithKey:TWTRAPIConstantsStatusFieldRetweetedStatus forTweet:hydratedTweet withUsers:usersDict];
        }
    }

    NSArray *unorderedTweets = [TWTRTweet tweetsWithJSONArray:unorderedTweetDicts];
    NSArray *tweetIDsInTimelineOrder = [TWTRTimelineParser orderedTweetIDsFromCollectionOrderingResponse:tweetsTimelineOrderMetadata];
    return [self orderTweets:unorderedTweets accordingToIDs:tweetIDsInTimelineOrder];
}

+ (nullable NSMutableDictionary *)hyrdrateTweet:(nullable NSDictionary *)dictionary withUserFromUsers:(NSDictionary *)usersDict
{
    if (!dictionary) {
        return nil;
    }

    NSDictionary *strippedUserDetails = [TWTRDictUtil twtr_dictForKey:TWTRAPIConstantsStatusFieldUser inDict:dictionary];
    NSString *authorID = [TWTRDictUtil twtr_stringForKey:TWTRAPIConstantsFieldIDString inDict:strippedUserDetails];

    if (authorID) {
        NSDictionary *fullUserDetails = [TWTRDictUtil twtr_dictForKey:authorID inDict:usersDict];
        NSMutableDictionary *mutableTweet = [dictionary mutableCopy];
        mutableTweet[TWTRAPIConstantsStatusFieldUser] = fullUserDetails;

        return mutableTweet;
    }
    return nil;
}

+ (void)hydrateSubTweetWithKey:(NSString *)key forTweet:(NSMutableDictionary *)tweet withUsers:(NSDictionary *)usersDictionary
{
    NSDictionary *subTweet = [TWTRDictUtil twtr_objectForKey:key inDict:tweet];
    NSDictionary *hydratedTweet = [self hyrdrateTweet:subTweet withUserFromUsers:usersDictionary];

    if (hydratedTweet) {
        tweet[key] = hydratedTweet;
    }
}

/**
 *  Returns a new array of TWTRTweets sorted by the sequence of IDs in tweetIDsInTimelineOrder.
 *
 *  @param unorderedTweets          Array of unordered TWTRTweet objects
 *  @param tweetIDsInTimelineOrder  Array of Tweet ID strings in the order we want to sort by
 */
+ (NSArray *)orderTweets:(NSArray *)unorderedTweets accordingToIDs:(NSArray *)tweetIDsInTimelineOrder
{
    NSDictionary *unorderedTweetsByID = [self tweetsByID:unorderedTweets];
    NSMutableArray *orderedTweets = [NSMutableArray array];
    for (NSString *tweetID in tweetIDsInTimelineOrder) {
        TWTRTweet *tweet = unorderedTweetsByID[tweetID];
        if (tweet) {
            [orderedTweets addObject:tweet];
        }
    }

    return orderedTweets;
}

// Take an array of tweets, and build a dictionary of tweets keyed by tweet id
+ (NSDictionary *)tweetsByID:(NSArray *)tweets
{
    TWTRParameterAssertOrReturnValue(tweets, @{});

    NSMutableDictionary *tweetsByID = [NSMutableDictionary dictionary];
    for (TWTRTweet *tweet in tweets) {
        tweetsByID[tweet.tweetID] = tweet;
    }

    return [tweetsByID copy];
}

+ (nullable NSString *)lastTweetIDFromTweets:(NSArray *)tweets
{
    TWTRTweet *lastTweet = [tweets lastObject];
    NSString *minPosition = lastTweet.tweetID;

    return minPosition;
}

+ (nullable NSArray *)tweetsFromSearchAPIResponseDictionary:(NSDictionary *)dictionary
{
    TWTRParameterAssertOrReturnValue(dictionary, nil);

    NSArray *statusesArray = [TWTRDictUtil twtr_arrayForKey:@"statuses" inDict:dictionary];
    return [TWTRTweet tweetsWithJSONArray:statusesArray];
}

+ (nullable NSString *)minPositionFromCollectionAPIResponseDictionary:(NSDictionary *)collection
{
    TWTRParameterAssertOrReturnValue(collection, nil);

    NSDictionary *responseDict = [TWTRDictUtil twtr_dictForKey:@"response" inDict:collection];
    NSDictionary *positionDict = [TWTRDictUtil twtr_dictForKey:@"position" inDict:responseDict];
    NSString *minPosition = [TWTRDictUtil twtr_stringForKey:@"min_position" inDict:positionDict];

    return minPosition;
}

#pragma mark - Helpers

/**
 *  Returns just the Tweet IDs from the collection timeline ordering JSON response.
 *
 *  @param orderingResponse Parsed JSON array of the metadata for ordering of Tweets as they appear
 *                          going from maxPosition (0) to minPosition (N-1). The Tweet IDs in this array
 *                          is already sorted by the backend.
 *
 *  @return Array of Tweet IDs as they should appear from maxPosition to minPosition.
 */
+ (NSArray *)orderedTweetIDsFromCollectionOrderingResponse:(NSArray *)orderingResponse
{
    NSMutableArray *orderedTweetIDs = [NSMutableArray array];
    for (NSDictionary *tweetOrderingMetadata in orderingResponse) {
        NSDictionary *tweetDetails = [TWTRDictUtil twtr_dictForKey:@"tweet" inDict:tweetOrderingMetadata];
        NSString *tweetID = [TWTRDictUtil twtr_stringForKey:@"id" inDict:tweetDetails];
        if (tweetID) {
            [orderedTweetIDs addObject:tweetID];
        }
    }

    return orderedTweetIDs;
}

@end
