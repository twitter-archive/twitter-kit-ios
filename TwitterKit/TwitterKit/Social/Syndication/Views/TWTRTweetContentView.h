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
#import "TWTRProfileHeaderView.h"
#import "TWTRTweetContentViewLayoutFactory.h"
#import "TWTRTweetLabel.h"
#import "TWTRTweetMediaView.h"
@class TWTRTweet;
@class TWTRTweetMediaEntity;
@class TWTRTweetMediaView;
@class TWTRProfileHeaderView;
@class TWTRTweetLabel;

NS_ASSUME_NONNULL_BEGIN

@interface TWTRTweetContentView : UIView

@property (nonatomic, weak) id<TWTRTweetMediaViewDelegate> mediaViewDelegate;
@property (nonatomic, weak) id<TWTRProfileHeaderViewDelegate> profileHeaderDelegate;
@property (nonatomic, weak) id<TWTRAttributedLabelDelegate> tweetLabelDelegate;

@property (nonatomic) UIColor *primaryTextColor;
@property (nonatomic) UIColor *secondaryTextColor;
@property (nonatomic) UIColor *linkTextColor;
@property (nonatomic) BOOL shouldPlayVideoMuted;

@property (nonatomic) UIViewController *presenterViewController;

- (instancetype)initWithLayout:(id<TWTRTweetContentViewLayout>)layout;

- (void)updateTweetTextWithTweet:(TWTRTweet *)tweet;
- (void)updateProfileHeaderWithTweet:(TWTRTweet *)tweet;
- (void)updateMediaWithTweet:(TWTRTweet *)tweet aspectRatio:(CGFloat)aspectRatio;

- (void)updateForComputedBackgroundColor:(UIColor *)color;

- (void)playVideo;
- (void)pauseVideo;

// This is just a stand in until we can use UILayoutGuides when we drop iOS 8.
- (UIView *)alignmentLayoutGuide;

- (CGSize)sizeThatFits:(CGSize)size;

- (nullable UIImage *)imageForMediaEntity:(TWTRTweetMediaEntity *)mediaEntity;

- (BOOL)didGestureRecognizerInteractWithEntity:(UIGestureRecognizer *)gesture;

@end

NS_ASSUME_NONNULL_END
