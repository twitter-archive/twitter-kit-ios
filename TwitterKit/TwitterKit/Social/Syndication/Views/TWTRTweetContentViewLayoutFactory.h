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
#import "TWTRTweetView.h"

@class TWTRTweetMediaView;
@class TWTRProfileHeaderView;
@class TWTRTweetLabel;
@class TWTRTweetViewMetrics;
@class TWTRTweetContentView;

NS_ASSUME_NONNULL_BEGIN

/**
 * A protocol for objects that define the layout of views in a TWTRTweetContentView
 */
@protocol TWTRTweetContentViewLayout <NSObject>

@required

/**
 * Returns the font that should be used for the tweet label.
 */
- (UIFont *)fontForTweetLabel;

/**
 * Method which is called when constraints need to be added to the content view.
 */
- (void)applyConstraintsForContentView:(TWTRTweetContentView *)contentView;

/**
 * Called if the content view should show or not show media.
 */
- (void)setShowingMedia:(BOOL)showingMedia;

/**
 * Returns the style associated with this Tweet view.
 */
- (TWTRTweetViewStyle)tweetViewStyle;

/**
 * Whether or not media corners should be rounded.
 */
- (BOOL)allowsMediaCornerRounding;

/*
 * Calculate the size to fit within the desired space for the provided content view.
 */
- (CGSize)sizeThatFits:(CGSize)size forContentView:(TWTRTweetContentView *)contentView;

@end

@interface TWTRTweetContentViewLayoutFactory : NSObject

+ (id<TWTRTweetContentViewLayout>)compactTweetViewLayoutWithMetrics:(TWTRTweetViewMetrics *)metrics;
+ (id<TWTRTweetContentViewLayout>)regularTweetViewLayoutWithMetrics:(TWTRTweetViewMetrics *)metrics;
+ (id<TWTRTweetContentViewLayout>)quoteTweetViewLayoutWithMetrics:(TWTRTweetViewMetrics *)metrics;

@end

NS_ASSUME_NONNULL_END
