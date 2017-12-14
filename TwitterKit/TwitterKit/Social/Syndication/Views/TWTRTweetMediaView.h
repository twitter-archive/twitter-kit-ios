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
#import "TWTRTweetView.h"
#import "TWTRVideoPlayerView.h"
@class TWTRTweet;
@class TWTRTweetMediaEntity;
@class TWTRVideoPlaybackConfiguration;
@protocol TWTRTweetMediaViewDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 * Provides an interface for showing the media contained
 * inside of a tweet.
 */
@interface TWTRTweetMediaView : UIView <TWTRVideoPlayerViewDelegate>

/**
 * The aspect ratio of the view, defaults to 1:1
 */
@property (nonatomic) CGFloat aspectRatio;

/**
 * The style of the view
 */
@property (nonatomic, readonly) TWTRTweetViewStyle style;

/**
 *  The view controller from which to present the login UIWebView or
 *  account picker sheet.
 */
@property (nonatomic, weak, null_resettable) UIViewController *presenterViewController;

/**
 * The media views delegate.
 */
@property (nonatomic, weak) id<TWTRTweetMediaViewDelegate> delegate;

/**
 * If YES, the default, corner radius will be set based on the style of the tweet view.
 * If NO, the corners will never be rounded.
 */
@property (nonatomic) BOOL allowsCornerRadiusRounding;

/**
 * If YES, inline video playback will play muted. This does not affect fullscreen playback.
 * Defaults to NO.
 */
@property (nonatomic) BOOL shouldPlayVideoMuted;

/**
 * The gesture recognizer that handles media taps.
 */
@property (nonatomic, readonly) UITapGestureRecognizer *tapGestureRecognizer;

/**
 * Call this method to update the image view with the given tweet and style.
 * @param tweet the tweet to display
 * @param style the style of the tweet view (used to determine layout)
 */
- (void)configureWithTweet:(nullable TWTRTweet *)tweet style:(TWTRTweetViewStyle)style;

/**
 *  Update the background color of subviews based on the computed
 *  background color passed in.
 *
 *  @param color The background color of the parent Tweet view
 */
- (void)updateBackgroundWithComputedColor:(UIColor *)color;

/**
 * This method allows the caller to programatically present the detailed media view.
 * The media view will call this method internally when it is tapped so it is not
 * common that this method will need to be called.
 *
 * @returns Returns YES if the detailed view has been presented, returns
 *          NO if there is no media or if the delegate blocks presentation.
 */
- (BOOL)presentDetailedMediaViewForMediaEntity:(TWTRTweetMediaEntity *)mediaEntity;

/**
 * Returns an image that matches the given media entity
 */
- (nullable UIImage *)imageForMediaEntity:(TWTRTweetMediaEntity *)mediaEntity;

- (CGSize)sizeThatFits:(CGSize)size;

- (void)playVideo;
- (void)pauseVideo;

@end

@protocol TWTRTweetMediaViewDelegate <NSObject>

@optional

/**
 * Provides the delegate the ability to stop the media view from showing the detailed media display.
 * This method can be implemented to provide your own handling of the media view tap.
 * This method is only called for images, for videos see tweetMediaView:shouldPresentVideo:
 */
- (BOOL)tweetMediaView:(TWTRTweetMediaView *)mediaView shouldPresentImageForMediaEntity:(TWTRTweetMediaEntity *)mediaEntity;

/**
 * Provides the delegate the ability to stop the media view from showing the video player.
 * This method can be implemented to provide your own handling of the video tap.
 */
- (BOOL)tweetMediaView:(TWTRTweetMediaView *)mediaView shouldPresentVideoForConfiguration:(TWTRVideoPlaybackConfiguration *)videoConfiguration;

/**
 * Allows the delegate to supply a view controller to present the detailed media. Can return nil to use the root view controller of the window.
 */
- (nullable UIViewController *)viewControllerToPresentFromTweetMediaView:(TWTRTweetMediaView *)mediaView;

/**
 * Called when user taps a video tweet and the tweet has the embeddable parameter set to NO.
 */
- (void)mediaViewDidSelectNonEmbeddableVideo:(TWTRTweetMediaView *)mediaView;

/**
 * Called when the image viewer is presented.
 */
- (void)tweetMediaView:(TWTRTweetMediaView *)mediaView didPresentImageViewerForMediaEntity:(TWTRTweetMediaEntity *)mediaEntity;

/**
 * Called when the video player is presented.
 */
- (void)tweetMediaView:(TWTRTweetMediaView *)mediaView didPresentVideoPlayerForMediaEntity:(TWTRTweetMediaEntity *)mediaEntity;

- (void)tweetMediaView:(TWTRTweetMediaView *)mediaView didChangePlaybackState:(TWTRVideoPlaybackState)newState;

@end

NS_ASSUME_NONNULL_END
