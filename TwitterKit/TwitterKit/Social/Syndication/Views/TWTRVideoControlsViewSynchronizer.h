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
#import "TWTRVideoControlsView.h"
#import "TWTRVideoPlayerOutputView.h"

@class TWTRVideoControlsViewSynchronizer;

NS_ASSUME_NONNULL_BEGIN

@protocol TWTRVideoControlsViewSynchronizerDelegate <NSObject>

@optional
- (void)controlsViewSynchronizerDidTapFullscreen:(TWTRVideoControlsViewSynchronizer *)synchronizer;
- (void)controlsViewSynchronizer:(TWTRVideoControlsViewSynchronizer *)synchronizer didChangePlaybackState:(TWTRVideoPlaybackState)state;
- (void)controlsViewSynchronizerVideoPlayerDidBecomeReady:(TWTRVideoControlsViewSynchronizer *)synchronizer;
@end

@interface TWTRVideoControlsViewSynchronizer : NSObject <TWTRVideoPlayerOutputViewDelegate, TWTRVideoControlsViewDelegate>

@property (nonatomic, weak) TWTRVideoControlsView *controlsView;
@property (nonatomic, weak, readonly) TWTRVideoPlayerOutputView *videoPlayerView;
@property (nonatomic, weak) id<TWTRVideoControlsViewSynchronizerDelegate> delegate;

/**
 * If set to YES, the synchronizer will hide the video controls until the player states that it is ready. Defaults to YES.
 * @note this value should not be set after the video player has become ready.
 */
@property (nonatomic) BOOL presentsVideoControlsOnReady;

- (instancetype)initWithVideoPlayer:(TWTRVideoPlayerOutputView *)player controls:(TWTRVideoControlsView *)controls;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
