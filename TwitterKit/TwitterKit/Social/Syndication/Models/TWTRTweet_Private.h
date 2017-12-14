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
#import "TWTRTweet.h"
#import "TWTRVersionedCacheable.h"

@class TWTRCardEntity;
@class TWTRTweetMediaEntity;
@class TWTRVideoMetaData;
@class TWTRTweetRepository;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const TWTRCompactTweetExpandedURLString;
FOUNDATION_EXTERN NSString *const TWTRTweetPerspectivalUserID;

@interface TWTRTweet () <TWTRVersionedCacheable>

@property (nonatomic, readonly) TWTRTweetRepository *tweetRepo;

#pragma mark - Private Properties

@property (nonatomic, copy, readonly, nullable) NSArray *hashtags;
@property (nonatomic, copy, readonly, nullable) NSArray *cashtags;
@property (nonatomic, copy, readonly, nullable) NSArray<TWTRTweetMediaEntity *> *media;
@property (nonatomic, copy, readonly, nullable) NSArray *urls;
@property (nonatomic, copy, readonly, nullable) NSArray *userMentions;

@property (nonatomic, readonly, nullable) TWTRCardEntity *cardEntity;

@property (nonatomic, readonly, nullable) TWTRVideoMetaData *videoMetaData;

#pragma mark - Getters and Setters

/**
 * Returns true if the Tweet has media entities.
 */
- (BOOL)hasMedia;

/**
 * Returns true if the Tweet has a media entity which has associated video or
 * the card entity contains playable media.
 */
- (BOOL)hasPlayableVideo;

/**
 *  Returns true if the Tweet has a card entity attached
 *  which is a Vine card.
 */
- (BOOL)hasVineCard;

/**
 *  Returns a new Tweet with the perspectival user ID set. This data is only available when fetching
 *  Tweets with `TWTRAPIClient` since the REST API does not include the authenticated user making
 *  the request.
 *
 *  @param userID ID of the Twitter user who fetched this Tweet. Nil means logged-out user.
 *
 *  @return Copy of the Tweet with the `perspectivalUserID` set to the given ID.
 */
- (TWTRTweet *)tweetWithPerspectivalUserID:(nullable NSString *)userID;

@end

NS_ASSUME_NONNULL_END
