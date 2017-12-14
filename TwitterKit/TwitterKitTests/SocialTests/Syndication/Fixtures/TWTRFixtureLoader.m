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

#import "TWTRFixtureLoader.h"
#import <TwitterCore/TWTRAuthenticationConstants.h>
#import <TwitterCore/TWTRGuestSession.h>
#import <TwitterCore/TWTRSession.h>
#import "TWTRTweet.h"
#import "TWTRTweetMediaEntity.h"
#import "TWTRTweetUrlEntity.h"
#import "TWTRUser.h"

@implementation TWTRFixtureLoader

+ (NSDictionary *)dictFromJSONFile:(NSString *)name
{
    NSString *normalized = [name stringByDeletingPathExtension];

    NSBundle *bundle = [NSBundle bundleForClass:[TWTRFixtureLoader class]];
    NSString *filePath = [bundle pathForResource:normalized ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];

    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

+ (NSData *)dataFromFile:(NSString *)name ofType:(NSString *)type
{
    NSString *normalized = [name stringByDeletingPathExtension];

    NSBundle *bundle = [NSBundle bundleForClass:[TWTRFixtureLoader class]];
    NSString *filePath = [bundle pathForResource:normalized ofType:type];

    return [NSData dataWithContentsOfFile:filePath];
}

+ (NSString *)pathForFile:(NSString *)filename
{
    NSBundle *bundle = [NSBundle bundleForClass:[TWTRFixtureLoader class]];
    return [bundle pathForResource:filename ofType:nil];
}

+ (NSArray *)manyTweets
{
    NSData *manyTweetsData = [TWTRFixtureLoader manyTweetsData];
    NSArray *manyTweetsJSON = [NSJSONSerialization JSONObjectWithData:manyTweetsData options:0 error:nil];
    NSArray *manyTweets = [TWTRTweet tweetsWithJSONArray:manyTweetsJSON];

    return manyTweets;
}

+ (NSDictionary *)vineCard
{
    return [self dictFromJSONFile:@"VineCard"];
}

+ (NSDictionary *)collectionAPIResponse
{
    return [self dictFromJSONFile:@"Collection"];
}

+ (NSData *)manyTweetsData
{
    return [NSData dataWithContentsOfFile:[self pathForFile:@"ManyTweetsResponse.json"]];
}

+ (NSData *)singleTweetData
{
    return [NSData dataWithContentsOfFile:[self pathForFile:@"SingleTweetResponse.json"]];
}

+ (NSData *)gatesTweetData
{
    return [NSData dataWithContentsOfFile:[self pathForFile:@"GatesTweet.json"]];
}

+ (NSData *)obamaTweetData
{
    return [NSData dataWithContentsOfFile:[self pathForFile:@"ObamaTweet.json"]];
}

+ (NSData *)retweetTweetData
{
    return [NSData dataWithContentsOfFile:[self pathForFile:@"RetweetTweet.json"]];
}

+ (NSData *)likedTweetData
{
    return [NSData dataWithContentsOfFile:[self pathForFile:@"LikedTweet.json"]];
}

+ (NSData *)alreadyLikedTweetData
{
    return [NSData dataWithContentsOfFile:[self pathForFile:@"AlreadyLiked.json"]];
}

+ (NSData *)userResponseData
{
    return [NSData dataWithContentsOfFile:[self pathForFile:@"UserResponse.json"]];
}

+ (NSData *)userWithEmailResponseData
{
    return [NSData dataWithContentsOfFile:[self pathForFile:@"UserWithEmailResponse.json"]];
}

+ (NSData *)userWithEmptyEmailResponseData
{
    return [NSData dataWithContentsOfFile:[self pathForFile:@"UserWithEmptyEmailResponse.json"]];
}

+ (NSData *)userWithNullEmailResponseData
{
    return [NSData dataWithContentsOfFile:[self pathForFile:@"UserWithNullEmailResponse.json"]];
}

+ (NSData *)blackLivesMatterSearchResultData
{
    return [NSData dataWithContentsOfFile:[self pathForFile:@"BlackLivesMatterSearchResults.json"]];
}

+ (NSData *)jackUserTimelineData
{
    return [NSData dataWithContentsOfFile:[self pathForFile:@"JackDorseyUserTimeline.json"]];
}

+ (NSData *)oauthDancerCollectionData
{
    return [NSData dataWithContentsOfFile:[self pathForFile:@"OAuthDancerCollection.json"]];
}

+ (NSData *)twitterSyndicationTeamListTimelineData
{
    return [NSData dataWithContentsOfFile:[self pathForFile:@"TwitterSyndicationTeamTweets.json"]];
}

+ (NSData *)sendTweetData
{
    return [NSData dataWithContentsOfFile:[self pathForFile:@"SendTweet.json"]];
}

+ (NSData *)videoData
{
    return [NSData dataWithContentsOfFile:[self pathForFile:@"SmallVideo.m4v"]];
}

+ (NSURL *)videoFileURL
{
    return [NSURL fileURLWithPath:[self pathForFile:@"SmallVideo.m4v"]];
}

+ (TWTRUser *)obamaUser
{
    NSDictionary *dict = [TWTRFixtureLoader dictFromJSONFile:@"ObamaUser.json"];
    return [[TWTRUser alloc] initWithJSONDictionary:dict];
}

+ (TWTRTweet *)obamaTweet
{
    return [self tweetWithJSONFile:@"ObamaTweet.json"];
}

+ (TWTRTweet *)googleTweet
{
    return [self tweetWithJSONFile:@"GoogleTweet.json"];
}

+ (TWTRTweet *)gatesTweet
{
    return [self tweetWithJSONFile:@"GatesTweet.json"];
}

+ (TWTRTweet *)retweetTweet
{
    return [self tweetWithJSONFile:@"RetweetTweet.json"];
}

+ (TWTRTweet *)tooShortOn6PlusTweet
{
    return [self tweetWithJSONFile:@"SamSmithTweet.json"];
}

+ (TWTRTweet *)tooShortOn6Tweet
{
    return [self tweetWithJSONFile:@"MidnightPropagandaTweet.json"];
}

+ (TWTRTweet *)videoTweet
{
    return [self tweetWithJSONFile:@"MovieTweet.json"];
}

+ (TWTRTweet *)manyEntitiesTweet
{
    return [self tweetWithJSONFile:@"ManyEntitiesTweet"];
}

+ (TWTRTweet *)cashtagTweet
{
    return [self tweetWithJSONFile:@"CashtagTweet"];
}

+ (TWTRTweet *)vineTweetV13
{
    return [self tweetWithJSONFile:@"VineTweetV13"];
}

+ (TWTRTweet *)extendedTweet
{
    return [self tweetWithJSONFile:@"ExtendedTweet"];
}

+ (TWTRTweet *)quoteTweet
{
    return [self tweetWithJSONFile:@"QuoteTweet"];
}

+ (TWTRTweet *)quoteTweetWithPlayableVideo
{
    return [self tweetWithJSONFile:@"QuoteTweetWithPlayableMedia"];
}

+ (TWTRTweet *)quoteTweetInConversation
{
    return [self tweetWithJSONFile:@"QuoteTweetInConversation"];
}

+ (TWTRTweet *)punyURLTweet
{
    return [self tweetWithJSONFile:@"PunyUrl"];
}

+ (TWTRTweet *)sendTweet
{
    return [self tweetWithJSONFile:@"SendTweet"];
}

+ (TWTRTweetMediaEntity *)obamaTweetMediaEntity
{
    NSDictionary *dict = [TWTRFixtureLoader dictFromJSONFile:@"ObamaMediaEntity.json"];
    return [[TWTRTweetMediaEntity alloc] initWithJSONDictionary:dict];
}

+ (TWTRTweetMediaEntity *)largeTweetMediaEntity
{
    NSDictionary *dict = [TWTRFixtureLoader dictFromJSONFile:@"LargeMediaEntity.json"];
    return [[TWTRTweetMediaEntity alloc] initWithJSONDictionary:dict];
}

+ (TWTRTweet *)tweetWithJSONFile:(NSString *)fileName
{
    static NSMutableDictionary *tweetTable = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        tweetTable = [NSMutableDictionary dictionary];
    });

    TWTRTweet *tweet = tweetTable[fileName];
    if (!tweet) {
        NSDictionary *dict = [TWTRFixtureLoader dictFromJSONFile:fileName];
        tweet = [[TWTRTweet alloc] initWithJSONDictionary:dict];
        //        tweetTable[fileName] = tweet; // Disabled until we turn off all mocking.
    }

    return tweet;
}

#pragma mark - Entities

+ (TWTRTweetUrlEntity *)tweetURLEntity
{
    NSDictionary *JSON = [self dictFromJSONFile:@"Entities.json"];
    NSDictionary *URL = JSON[@"URL"];

    return [[TWTRTweetUrlEntity alloc] initWithJSONDictionary:URL];
}

@end
