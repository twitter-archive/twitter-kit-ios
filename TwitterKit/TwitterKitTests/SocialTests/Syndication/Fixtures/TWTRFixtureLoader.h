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

@class TWTRGuestSession;
@class TWTRSession;
@class TWTRTweet;
@class TWTRTweetUrlEntity;
@class TWTRTweetMediaEntity;
@class TWTRUser;

@interface TWTRFixtureLoader : NSObject

+ (TWTRUser *)obamaUser;
+ (TWTRTweet *)obamaTweet;
+ (TWTRTweet *)googleTweet;
+ (TWTRTweet *)gatesTweet;
+ (TWTRTweet *)videoTweet;
+ (TWTRTweet *)tooShortOn6PlusTweet;
+ (TWTRTweet *)tooShortOn6Tweet;
+ (TWTRTweet *)retweetTweet;
+ (TWTRTweet *)manyEntitiesTweet;
+ (TWTRTweet *)cashtagTweet;
+ (TWTRTweet *)vineTweetV13;
+ (TWTRTweet *)extendedTweet;
+ (TWTRTweet *)quoteTweet;
+ (TWTRTweet *)quoteTweetWithPlayableVideo;
+ (TWTRTweet *)quoteTweetInConversation;
+ (TWTRTweet *)punyURLTweet;
+ (TWTRTweet *)sendTweet;
+ (NSArray *)manyTweets;
+ (NSData *)singleTweetData;
+ (NSData *)gatesTweetData;
+ (NSData *)obamaTweetData;
+ (NSData *)retweetTweetData;
+ (NSData *)manyTweetsData;
+ (NSData *)likedTweetData;
+ (NSData *)alreadyLikedTweetData;
+ (NSData *)userResponseData;
+ (NSData *)userWithEmailResponseData;
+ (NSData *)userWithEmptyEmailResponseData;
+ (NSData *)userWithNullEmailResponseData;
+ (NSData *)blackLivesMatterSearchResultData;
+ (NSData *)jackUserTimelineData;
+ (NSData *)oauthDancerCollectionData;
+ (NSData *)twitterSyndicationTeamListTimelineData;
+ (NSData *)sendTweetData;
+ (NSData *)videoData;
+ (TWTRTweetMediaEntity *)obamaTweetMediaEntity;
+ (TWTRTweetMediaEntity *)largeTweetMediaEntity;
+ (NSURL *)videoFileURL;
+ (NSDictionary *)vineCard;
+ (NSDictionary *)collectionAPIResponse;

+ (NSDictionary *)dictFromJSONFile:(NSString *)path;
+ (NSData *)dataFromFile:(NSString *)name ofType:(NSString *)type;

+ (TWTRTweetUrlEntity *)tweetURLEntity;

@end
