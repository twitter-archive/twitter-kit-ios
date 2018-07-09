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

#import "TWTRTweetViewDelegate.h"

@class TWTRTweet;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TWTRShareButtonSize) {
    // Regular size as used in tweet views
    TWTRShareButtonSizeRegular,

    // Larger size as used in tweet detail views
    TWTRShareButtonSizeLarge
};

@interface TWTRShareButton : UIButton

/**
 *  The view controller from which to present the Share Sheet and
 *  popover controller.
 */
@property (nonatomic, weak, null_resettable) UIViewController *presenterViewController;

/**
 * Initializes the Share button with a given size.
 */
- (instancetype)initWithShareButtonSize:(TWTRShareButtonSize)size;

/**
 * Initializes the Share button with a given frame and size.
 */
- (instancetype)initWithFrame:(CGRect)frame shareButtonSize:(TWTRShareButtonSize)size;

/**
 *  Set up this view to be associated with a given Tweet.
 *
 *  @param tweet The Tweet which should be shared when the icon has been tapped.
 */
- (void)configureWithTweet:(nullable TWTRTweet *)tweet;

+ (instancetype)buttonWithType:(UIButtonType)buttonType NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
