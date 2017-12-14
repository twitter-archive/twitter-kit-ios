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

//
//  A view encompassing the profile image, full name,
//  username, and verified badge.
//
//       <>  Retweeted By Jim         ,D>
//  ⌈¯¯¯¯¯⌉
//  |     |  Kanye West (✓)
//  |     |  @kanyewest • 8h
//  ⌊_____⌋
//

#import <UIKit/UIKit.h>
#import "TWTRTweetView.h"

NS_ASSUME_NONNULL_BEGIN

@class TWTRBirdView;
@class TWTRProfileView;
@class TWTRTimestampLabel;
@class TWTRUser;
@protocol TWTRProfileHeaderViewDelegate;

@interface TWTRProfileHeaderView : UIView

// When this variable is set, configureWithTweet: will not load any images.
// Defaults to NO.
@property (nonatomic) BOOL calculationOnly;

@property (nonatomic, weak, nullable) id<TWTRProfileHeaderViewDelegate> delegate;

// Views
@property (nonatomic, readonly) TWTRProfileView *profileThumbnail;
@property (nonatomic, readonly) UILabel *fullname;
@property (nonatomic, readonly) UILabel *userName;
@property (nonatomic, readonly) TWTRTimestampLabel *timestamp;
@property (nonatomic, readonly) TWTRBirdView *twitterLogo;

// Settable color properties
@property (nonatomic) UIColor *primaryTextColor;
@property (nonatomic) UIColor *secondaryTextColor;
@property (nonatomic) UIColor *backgroundColor;  // passes through to subviews

// When showsTimestamp is set NO, configureWithTweet: will remove timestamp label.
@property (nonatomic) BOOL showsTimestamp;
@property (nonatomic) BOOL showsTwitterLogo;
@property (nonatomic) BOOL showProfileThumbnail;

- (instancetype)initWithStyle:(TWTRTweetViewStyle)style;
- (void)configureWithTweet:(nullable TWTRTweet *)tweet;
- (CGSize)sizeThatFits:(CGSize)size;

@end

@protocol TWTRProfileHeaderViewDelegate <NSObject>

@optional

/**
 * Called when the profile view was tapped.
 */
- (void)profileHeaderView:(TWTRProfileHeaderView *)headerView didTapProfileForUser:(TWTRUser *)user;

@end

NS_ASSUME_NONNULL_END
