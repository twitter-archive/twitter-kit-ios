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
#import "TWTRVideoPlaybackState.h"
@class TWTRVideoPlaybackConfiguration;

NS_ASSUME_NONNULL_BEGIN

@protocol TWTRVideoPlayerOutputViewDelegate;

typedef NS_ENUM(NSUInteger, TWTRVideoPlayerAspectRatio) {
    /**
     * Preserve the aspect ratio; fit within layer bounds.
     */
    TWTRVideoPlayerAspectRatioAspect,
    /**
     * Preserve the aspect ratio; fill layer bounds.
     */
    TWTRVideoPlayerAspectRatioAspectFill,
    /**
     * Stretch to fill layer bounds.
     */
    TWTRVideoPlayerAspectRatioResize
};

// Class wraps AVFoundation AVPlayer class and only outputs a simple video player
@interface TWTRVideoPlayerOutputView : UIView

/**
 * If YES the video will automatically start playing when it loads. Defaults to YES.
 */
@property (nonatomic) BOOL shouldAutoPlay;

/**
 * If YES the video will automatically start playing from the beginning when it reaches the end.
 * Defaults to NO.
 */
@property (nonatomic) BOOL shouldAutoLoop;

/**
 * If YES, the video will play without any volume.
 * Defaults to NO.
 */
@property (nonatomic) BOOL shouldPlayVideoMuted;

/**
 * Maps to AVPlayer's videoGravity property.
 */
@property (nonatomic) TWTRVideoPlayerAspectRatio aspectRatio;

/**
 * The player's delegate.
 */
@property (nonatomic, weak) id<TWTRVideoPlayerOutputViewDelegate> delegate;

/**
 * The state of playback.
 */
@property (nonatomic, readonly) TWTRVideoPlaybackState playbackState;

/**
 * The duration of this video.
 */
@property (nonatomic, readonly) NSTimeInterval videoDuration;

/**
 * The actual rectangle of the displayed video.
 */
@property (nonatomic, readonly) CGRect videoRect;

/**
 * Initializes the receiver with a given video.
 *
 * @param frame the frame of the player
 * @param configuration the video playback configuration to play
 * @param shouldLoadVideo If YES the player will automatically load its video when it is initialized, if set to NO it is the develper's responsibility to call -loadVideo
 */
- (instancetype)initWithFrame:(CGRect)frame videoPlaybackConfiguration:(TWTRVideoPlaybackConfiguration *)configuration previewImage:(nullable UIImage *)previewImage shouldLoadVideo:(BOOL)shouldLoadVideo;

/**
 * Attempts to load the video in the player. This method only needs to be called if shouldAutoLoad is NO.
 */
- (void)loadVideo;

/**
 * Starts video playback. If the player is not ready to play this value will set shouldAutoPlay to YES.
 */
- (void)play;

/**
 * Pauses the video. If the player is not ready to play this does nothing.
 */
- (void)pause;

/**
 * Seeks to the beginning of the video and calls play. If the player is not ready to play this does nothing.
 */
- (void)restart;

/**
 * Calling this method will make the video player proceed to the next
 * playback state. This are
 *   - If paused -> play
 *   - If playing -> pause
 *   - If completed -> restart
 */
- (void)proceedToNextPlaybackState;

/**
 * Returns YES if the AVPlayerItem's status is AVPlayerStatusReadyToPlay
 */
- (BOOL)isVideoReadyToPlay;

- (void)seekToPosition:(NSTimeInterval)position;

- (NSTimeInterval)elapsedTime;

@end

@protocol TWTRVideoPlayerOutputViewDelegate <NSObject>

@optional
- (void)videoPlayer:(TWTRVideoPlayerOutputView *)player didChangePlaybackState:(TWTRVideoPlaybackState)newState;
- (void)videoPlayerDidBecomeReady:(TWTRVideoPlayerOutputView *)player;

@end

NS_ASSUME_NONNULL_END
