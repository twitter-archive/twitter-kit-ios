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

#import "TWTRVideoCTAView.h"
#import "TWTRVideoControlsViewSynchronizer.h"
#import "TWTRVideoPlayerOutputView.h"
#import "TWTRVideoPlayerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TWTRVideoPlayerView () <TWTRVideoPlayerOutputViewDelegate, UIGestureRecognizerDelegate, TWTRVideoCTAViewDelegate, TWTRVideoControlsViewSynchronizerDelegate>

@property (nonatomic, readonly) TWTRTweet *tweet;
@property (nonatomic, readonly) TWTRVideoPlaybackConfiguration *playbackConfiguration;
@property (nonatomic, readonly) TWTRVideoPlayerOutputView *playerView;

@property (nonatomic, nullable) TWTRVideoControlsView *controlsView;
@property (nonatomic, readonly, nullable) TWTRVideoControlsViewSynchronizer *synchronizer;
@property (nonatomic, nullable) UIImage *previewImage;
@property (nonatomic, readonly) UIView *CTAView;

@property (nonatomic, readonly) UITapGestureRecognizer *backgroundTapGestureRecognizer;
@property (nonatomic, readonly) UITapGestureRecognizer *videoTapGestureRecognizer;
@property (nonatomic, readonly) NSLayoutConstraint *CTATopConstraint;
@property (nonatomic, readonly) NSLayoutConstraint *CTABottomConstraint;

@end

NS_ASSUME_NONNULL_END
