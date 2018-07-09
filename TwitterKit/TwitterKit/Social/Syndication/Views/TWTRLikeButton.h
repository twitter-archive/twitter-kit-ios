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

@class TWTRTweet;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TWTRLikeButtonSize) {
    // Regular size as used in tweet views
    TWTRLikeButtonSizeRegular,

    // Larger size as used in tweet detail views
    TWTRLikeButtonSizeLarge
};

@interface TWTRLikeButton : UIButton

/**
 *  The view controller from which to present the login UIWebView or
 *  account picker sheet.
 */
@property (nonatomic, weak, null_resettable) UIViewController *presenterViewController;

/**
 * Initializes the Like button with a given size.
 */
- (instancetype)initWithLikeButtonSize:(TWTRLikeButtonSize)size;

/**
 * Initializes the Like button with a given frame and size.
 */
- (instancetype)initWithFrame:(CGRect)frame likeButtonSize:(TWTRLikeButtonSize)size;

/**
 *  Configure the Tweet which should be Liked when this button is tapped.
 *
 *  @param tweet The Tweet model object.
 */
- (void)configureWithTweet:(nullable TWTRTweet *)tweet;

+ (instancetype)buttonWithType:(UIButtonType)buttonType NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
