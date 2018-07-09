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

#import "TWTRVideoViewController.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import "TWTRNotificationConstants.h"
#import "TWTRTweet.h"
#import "TWTRTwitter_Private.h"
#import "TWTRUser.h"
#import "TWTRVideoControlsView.h"
#import "TWTRVideoMediaType.h"
#import "TWTRVideoPlaybackConfiguration.h"
#import "TWTRVideoPlaybackRules.h"
#import "TWTRVideoPlayerOutputView.h"
#import "TWTRVideoPlayerView.h"
#import "TWTRVideoViewController_Private.h"
#import "TWTRViewUtil.h"

// TODO: What does this look like on iPad?

NS_ASSUME_NONNULL_BEGIN

@implementation TWTRVideoViewController

- (instancetype)initWithTweet:(TWTRTweet *)tweet playbackConfiguration:(TWTRVideoPlaybackConfiguration *)playbackConfig previewImage:(nullable UIImage *)previewImage playerView:(nullable TWTRVideoPlayerView *)playerView
{
    TWTRParameterAssertOrReturnValue(tweet, nil);
    TWTRParameterAssertOrReturnValue(playbackConfig, nil);

    self = [super init];
    if (self) {
        _tweet = tweet;
        _playbackConfiguration = playbackConfig;
        _thumbnailImage = previewImage;

        if (!playerView) {
            _playerView = [[TWTRVideoPlayerView alloc] initWithTweet:tweet playbackConfiguration:playbackConfig controlsView:[TWTRVideoControlsView fullscreenControls] previewImage:previewImage];
        } else {
            _playerView = playerView;
            _playerView.delegate = self;
            [_playerView updateControls:[TWTRVideoControlsView fullscreenControls]];
            _playerView.aspectRatio = TWTRVideoPlayerAspectRatioAspect;
        }

        _playerView.delegate = self;
        _playerView.shouldPlayVideoMuted = NO;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.view.clipsToBounds = YES;

    [self.view addSubview:self.playerView];
    self.playerView.translatesAutoresizingMaskIntoConstraints = NO;
    [TWTRViewUtil equateAttribute:NSLayoutAttributeTop onView:self.playerView toView:self.view];
    [TWTRViewUtil equateAttribute:NSLayoutAttributeLeading onView:self.playerView toView:self.view];
    [TWTRViewUtil equateAttribute:NSLayoutAttributeWidth onView:self.playerView toView:self.view];
    [TWTRViewUtil equateAttribute:NSLayoutAttributeHeight onView:self.playerView toView:self.view];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if ([self.delegate respondsToSelector:@selector(videoViewControllerViewWillDissapear:)]) {
        [self.delegate videoViewControllerViewWillDissapear:self];
    }
}

#pragma mark - Presentation Code

- (CGRect)mediaContainerTargetFrame
{
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = width / [self aspectRatioForMediaContainer];

    CGFloat originY = (self.view.bounds.size.height - height) / 2.0;

    return CGRectMake(0, originY, width, height);
}

- (CGFloat)aspectRatioForMediaContainer
{
    return self.playbackConfiguration.aspectRatio;
}

#pragma mark - TWTRVideoViewControllableDelegate

- (void)playerView:(TWTRVideoPlayerView *)playerView setChromeVisible:(BOOL)visible animated:(BOOL)animated
{
    if (self.mediaContainer) {
        [self.mediaContainer setChromeVisible:visible animated:animated];
    }
}

#pragma mark - TWTRMediaContainerPresentable

- (void)willShowInMediaContainer
{
    NSDictionary *userInfo = @{TWTRVideoTypeKey: TWTRMediaConstantFromMediaType(self.playbackConfiguration.mediaType)};
    [[NSNotificationCenter defaultCenter] postNotificationName:TWTRWillPresentVideoNotification object:self userInfo:userInfo];
}

- (void)didDismissInMediaContainer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TWTRDidDismissVideoNotification object:self];
}

- (UIImage *)transitionImage
{
    return self.thumbnailImage;
}

- (CGRect)transitionImageTargetFrame
{
    return [self mediaContainerTargetFrame];
}

- (void)transitionWillBegin
{
    self.playerView.bottomBarContainer.alpha = 0.0;
}

- (void)transitionDidComplete
{
    if ([self.playerView isVideoReadyToPlay]) {
        [self.playerView playVideo];
    } else {
        [self.playerView loadVideo];
    }

    void (^animations)(void) = ^{
        self.playerView.bottomBarContainer.alpha = 1.0;
    };

    [UIView animateWithDuration:0.3 animations:animations];
}

- (void)viewDidLoadWithMediaContainer:(TWTRMediaContainerViewController *)mediaContainer
{
    self.mediaContainer = mediaContainer;
}

@end

NS_ASSUME_NONNULL_END
