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
#import "TWTRMediaContainerViewController.h"

@class TWTRTweet;
@class TWTRVideoPlayerView;
@class TWTRVideoPlaybackConfiguration;
@class TWTRMediaContainerViewController;
@class TWTRVideoViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol TWTRVideoViewControllerDelegate <NSObject>

@optional
/**
 *  Called during view will disappear during the view controller lifecycle.
 */
- (void)videoViewControllerViewWillDissapear:(TWTRVideoViewController *)viewController;

@end

@interface TWTRVideoViewController : UIViewController <TWTRMediaContainerPresentable>

@property (nonatomic, weak, nullable) TWTRMediaContainerViewController *mediaContainer;

@property (nonatomic, weak) id<TWTRVideoViewControllerDelegate> delegate;

/**
 * Initializes the receiver with a given playback configuration and preview image
 */
- (instancetype)initWithTweet:(TWTRTweet *)tweet playbackConfiguration:(TWTRVideoPlaybackConfiguration *)playbackConfig previewImage:(nullable UIImage *)previewImage playerView:(nullable TWTRVideoPlayerView *)playerView;

@end

NS_ASSUME_NONNULL_END
