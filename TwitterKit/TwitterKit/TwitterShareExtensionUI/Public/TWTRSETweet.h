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

@import Foundation;

@protocol TWTRSETweetAttachment;
@protocol TWTRSEGeoPlace;

NS_ASSUME_NONNULL_BEGIN

@class TwitterTextEntity;

@protocol TwitterTextProtocol

+ (NSInteger)remainingCharacterCount:(NSString *)text;
+ (NSArray<TwitterTextEntity *> *)entitiesInText:(NSString *)text;
+ (NSArray<TwitterTextEntity *> *)URLsInText:(NSString *)text;
+ (NSArray<TwitterTextEntity *> *)mentionedScreenNamesInText:(NSString *)text;
+ (NSArray<TwitterTextEntity *> *)hashtagsInText:(NSString *)text checkingURLOverlap:(BOOL)checkingURLOverlap;

@end

@interface TWTRSETweet : NSObject <NSCopying>

+ (void)setTwitterText:(id<TwitterTextProtocol>)twitterText;
+ (Class<TwitterTextProtocol>)twitterText;

@property (nonatomic, nullable, copy) NSNumber *inReplyToTweetID;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, nullable) id<TWTRSETweetAttachment> attachment;
@property (nonatomic, nullable) id<TWTRSEGeoPlace> place;

/**
 @param inReplyToTweetID (Optional) The tweet ID this tweet is a reply of.
 @param text The text contents of the tweet, not counting prefixing screennames or hashtags.
 @param attachment (Optional): See specific implementations of the `TWTRSETweetAttachment` protocol.
 @param place (Optional): The place where this tweet is geo-tagged.
 @param usernames (Optional): An array of usernames without leading "@" that are mentioned in this tweet.
 @param hashtags (Optional): An array of hashtags without leading "#" that are included in this tweet.
 */
- (instancetype)initWithInReplyToTweetID:(nullable NSNumber *)inReplyToTweetID text:(nullable NSString *)text attachment:(nullable id<TWTRSETweetAttachment>)attachment place:(nullable id<TWTRSEGeoPlace>)place usernames:(nullable NSArray<NSString *> *)usernames hashtags:(nullable NSArray<NSString *> *)hashtags NS_DESIGNATED_INITIALIZER;

+ (TWTRSETweet *)emptyTweet;

- (instancetype)init NS_UNAVAILABLE;

/**
 This will be a negative number if the tweet is over the limit
 @see -isWithinCharacterLimit
 */
- (NSInteger)remainingCharacters;

- (BOOL)isNearOrOverCharacterLimit;
- (BOOL)isWithinCharacterLimit;

@end

NS_ASSUME_NONNULL_END
