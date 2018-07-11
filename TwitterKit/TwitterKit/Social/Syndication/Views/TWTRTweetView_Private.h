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

#import "TWTRTweetViewMetrics.h"

@class TWTRLikeButton;
@class TWTRProfileHeaderView;
@class TWTRShareButton;
@class TWTRTweet;
@class TWTRTweetContentView;
@class TWTRTweetLabel;
@class TWTRTweetMediaView;
@class TWTRTweetPresenter;
@class TWTRUser;

@interface TWTRTweetView ()

@property (nonatomic, strong) TWTRLikeButton *likeButton;
@property (nonatomic) TWTRShareButton *shareButton;
@property (nonatomic) TWTRTweetPresenter *tweetPresenter;
@property (nonatomic, readonly) TWTRTweetContentView *contentView;
@property (nonatomic) TWTRTweetContentView *attachmentContentView;

// When this variable is set, configureWithTweet: won't load any images. Defaults to NO.
@property (nonatomic) BOOL calculationOnly;
@property (nonatomic) BOOL doneInitializing;
@property (nonatomic, readwrite) TWTRTweet *tweet;
@property (nonatomic) TWTRTweetViewMetrics *metrics;
@property (nonatomic) TWTRTweetViewStyle style;
@property (nonatomic) TWTRUser *profileUserToDisplay;

@property (nonatomic) NSLayoutConstraint *imageTopConstraint;
@property (nonatomic) NSLayoutConstraint *imageBottomConstraint;
@property (nonatomic) NSLayoutConstraint *actionsHeightConstraint;
@property (nonatomic) NSLayoutConstraint *actionsBottomConstraint;

- (void)backgroundTapped;
- (void)playVideo;
- (void)pauseVideo;

@end
