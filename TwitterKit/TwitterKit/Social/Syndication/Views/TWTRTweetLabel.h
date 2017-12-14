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

#import <UIKit/UIKit.h>
#import "TWTRAttributedLabel.h"
#import "TWTRTweetPresenter.h"

@class TWTRTweet;

NS_ASSUME_NONNULL_BEGIN

@interface TWTRTweetLabel : TWTRAttributedLabel

/**
 *  Sets the link color for URLs in tweet text
 */
@property (nonatomic, nullable) UIColor *linkColor;

/**
 * Which entities should be linkified.
 * Defaults to TWTRTweetEntityDisplayTypeURL
 */
@property (nonatomic) TWTRTweetEntityDisplayType entityDisplayTypes;

/**
 *  Set text of tweet text label.
 *
 *  Also strips last media link (since it's shown as an image), strips whitespace from beginning & end, replaces t.co URLs with display URLs, and adds tappable links.
 *
 *  @param tweet The tweet model object holding the text, media info, and URL info
 */
- (void)setTextFromTweet:(TWTRTweet *)tweet;

/**
 * Returns YES if one of the enabled entities exists at the given point.
 */
- (BOOL)entityExistsAtPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
