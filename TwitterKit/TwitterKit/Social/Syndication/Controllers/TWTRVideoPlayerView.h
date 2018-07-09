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
#import "TWTRVideoPlayerOutputView.h"

@class TWTRTweet;
@class TWTRVideoPlaybackConfiguration;
@class TWTRVideoControlsView;
@class TWTRVideoPlayerView;

NS_ASSUME_NONNULL_BEGIN

@protocol TWTRVideoPlayerViewDelegate <NSObject>

@optional
- (void)playerView:(TWTRVideoPlayerView *)playerView setChromeVisible:(BOOL)visible animated:(BOOL)animated;
- (void)playerViewDidTapVideo:(TWTRVideoPlayerView *)playerView;
- (void)playerViewDidTapFullscreen:(TWTRVideoPlayerView *)playerView;
- (void)playerViewDidBecomeReady:(TWTRVideoPlayerView *)playerView shouldAutoPlay:(BOOL)shouldAutoPlay;
- (void)playerView:(TWTRVideoPlayerView *)playerView didChangePlaybackState:(TWTRVideoPlaybackState)newState;

@end

@interface TWTRVideoPlayerView : UIView

@property (nonatomic, readonly) UIView *bottomBarContainer;
@property (nonatomic, readonly) UIView *mediaContainer;
@property (nonatomic, weak) id<TWTRVideoPlayerViewDelegate> delegate;
@property (nonatomic) BOOL shouldSetChromeVisible;
@property (nonatomic) BOOL shouldPlayVideoMuted;
@property (nonatomic) TWTRVideoPlayerAspectRatio aspectRatio;
@property (nonatomic) TWTRVideoPlaybackState playbackState;

- (instancetype)initWithTweet:(TWTRTweet *)tweet playbackConfiguration:(TWTRVideoPlaybackConfiguration *)playbackConfiguration controlsView:(nullable TWTRVideoControlsView *)controlsView previewImage:(nullable UIImage *)previewImage;

- (void)loadVideo;
- (void)playVideo;
- (void)pauseVideo;
- (void)proceedToNextPlaybackState;
- (void)updateControls:(TWTRVideoControlsView *)controlsView;
- (BOOL)isVideoReadyToPlay;

@end

NS_ASSUME_NONNULL_END
