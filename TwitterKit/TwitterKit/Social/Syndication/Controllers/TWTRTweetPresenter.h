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
#import <UIKit/UIKit.h>
#import "TWTRTweetView.h"

@class TWTRTweet;
@class TWTRTweetEntity;

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, TWTRTweetEntityDisplayType) {
    TWTRTweetEntityDisplayTypeURL = 1 << 0,
    TWTRTweetEntityDisplayTypeHashtag = 1 << 1,
    TWTRTweetEntityDisplayTypeCashtag = 1 << 2,
    TWTRTweetEntityDisplayTypeUserMention = 1 << 3,

    TWTRTweetEntityDisplayTypeAll = TWTRTweetEntityDisplayTypeURL | TWTRTweetEntityDisplayTypeHashtag | TWTRTweetEntityDisplayTypeCashtag | TWTRTweetEntityDisplayTypeUserMention
};

@interface TWTRTweetEntityRange : NSObject
@property (nonatomic, readonly) TWTRTweetEntity *entity;
@property (nonatomic, readonly) NSRange textRange;
@end

@interface TWTRTweetPresenter : NSObject

@property (nonatomic, readonly) TWTRTweetViewStyle style;

+ (instancetype)presenterForStyle:(TWTRTweetViewStyle)style;

/**
 * Returns a array of TWTRTweetEntityRange describing the
 * location of entities that will be displayed by the presenter. This
 * information is derived from the TWTRTweetEntity ranges but adjusted
 * based on how they are actually displayed.
 */
- (NSArray<TWTRTweetEntityRange *> *)entityRangesForTweet:(TWTRTweet *)tweet types:(TWTRTweetEntityDisplayType)types;

/**
 *  The text for the Tweet.

 *  @param tweet The tweet model object.
 *
 *  @return The text to display in the tweet view.
 */
- (NSString *)textForTweet:(nullable TWTRTweet *)tweet;
- (NSAttributedString *)attributedTextForText:(NSString *)text withEntityRanges:(NSArray<TWTRTweetEntityRange *> *)entityRanges;

/**
 *  Returns the retweeted by attribution text given a retweet.
 *
 *  @param tweet retweet
 *
 *  @return retweeted by attribution text string
 */
- (NSString *)retweetedByTextForRetweet:(nullable TWTRTweet *)retweet;

/**
 * If the tweet displays media, return the aspect ratio for the
 * given media item. This method makes no assumptions about the
 * media that is going to be shown. It could be a collection of
 * images, a video, a single image, etc. The result is the
 * aggregation of all the items.
 *
 * @param tweet the tweet model object.
 */
- (CGFloat)mediaAspectRatioForTweet:(nullable TWTRTweet *)tweet;

@end

NS_ASSUME_NONNULL_END
