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

#import "TWTRVideoPlayerView.h"

#import <TwitterCore/TWTRAssertionMacros.h>

#import "TWTRTweet.h"
#import "TWTRTwitter_Private.h"
#import "TWTRUser.h"
#import "TWTRVideoCTAView.h"
#import "TWTRVideoControlsView.h"
#import "TWTRVideoControlsViewSynchronizer.h"
#import "TWTRVideoDeeplinkConfiguration.h"
#import "TWTRVideoPlaybackConfiguration.h"
#import "TWTRVideoPlaybackRules.h"
#import "TWTRVideoPlayerOutputView.h"
#import "TWTRVideoPlayerView_Private.h"
#import "TWTRViewUtil.h"

NS_ASSUME_NONNULL_BEGIN

@implementation TWTRVideoPlayerView

#pragma mark - Init

- (instancetype)initWithTweet:(TWTRTweet *)tweet playbackConfiguration:(TWTRVideoPlaybackConfiguration *)playbackConfiguration controlsView:(nullable TWTRVideoControlsView *)controlsView previewImage:(nullable UIImage *)previewImage
{
    TWTRParameterAssertOrReturnValue(tweet, nil);
    TWTRParameterAssertOrReturnValue(playbackConfiguration, nil);

    if (self = [super init]) {
        _tweet = tweet;
        _playbackConfiguration = playbackConfiguration;
        _controlsView = controlsView;
        _previewImage = previewImage;
        _shouldSetChromeVisible = YES;
        _aspectRatio = TWTRVideoPlayerAspectRatioAspect;

        [self prepareSubviews];
        [self installGestureRecognizers];
        [self prepareVideoSynchronizer];
    }

    return self;
}

#pragma mark - Private Methods

- (void)prepareSubviews
{
    [self prepareMediaContainer];  // Needs to be first so that it sits below other content
    [self prepareBottomBar];
    [self prepareCallToActionView];
}

- (void)prepareBottomBar
{
    UIView *bottomBar = [[UIView alloc] init];
    bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
    bottomBar.backgroundColor = [UIColor clearColor];
    [self addSubview:bottomBar];

    NSDictionary *views = NSDictionaryOfVariableBindings(bottomBar);

    [TWTRViewUtil addVisualConstraints:@"H:|[bottomBar]|" views:views];
    [TWTRViewUtil addVisualConstraints:@"V:[bottomBar(60)]" views:views];

    if (@available(iOS 11, *)) {
        [bottomBar.bottomAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.bottomAnchor].active = YES;
    } else {
        [TWTRViewUtil constraintToBottomOfSuperview:bottomBar].active = YES;
    }

    _bottomBarContainer = bottomBar;

    if ([TWTRVideoPlaybackRules shouldShowVideoControlsForType:self.playbackConfiguration.mediaType]) {
        [self addVideoControlsToBottomBar:bottomBar];
    }
}

- (void)prepareCallToActionView
{
    if (self.playbackConfiguration.deeplinkConfiguration) {
        UIView *cta = [self makeCTAViewWithConfiguration:self.playbackConfiguration.deeplinkConfiguration];
        [self addSubview:cta];
        [TWTRViewUtil centerViewHorizontallyInSuperview:cta];
        _CTATopConstraint = [TWTRViewUtil constraintToTopOfSuperview:cta constant:20];
        _CTABottomConstraint = [NSLayoutConstraint constraintWithItem:cta attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];

        _CTATopConstraint.active = YES;
        _CTABottomConstraint.active = NO;

        _CTAView = cta;
    }
}

- (void)addVideoControlsToBottomBar:(UIView *)bottomBar
{
    self.controlsView.tintColor = [UIColor whiteColor];
    self.controlsView.translatesAutoresizingMaskIntoConstraints = NO;
    [bottomBar addSubview:self.controlsView];

    NSDictionary *views = @{ @"controls": self.controlsView };

    [TWTRViewUtil addVisualConstraints:@"H:|[controls]|" views:views];
    [TWTRViewUtil addVisualConstraints:@"V:[controls]|" views:views];
}

- (void)prepareMediaContainer
{
    UIView *container = [[UIView alloc] init];
    container.backgroundColor = [UIColor whiteColor];
    [self addSubview:container];

    container.frame = self.frame;
    container.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    _playerView = [[TWTRVideoPlayerOutputView alloc] initWithFrame:container.bounds videoPlaybackConfiguration:self.playbackConfiguration previewImage:self.previewImage shouldLoadVideo:NO];
    _playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [container addSubview:_playerView];
    _playerView.shouldAutoLoop = [TWTRVideoPlaybackRules shouldAutoLoopForConfiguration:self.playbackConfiguration];

    _mediaContainer = container;
}

- (UIView *)makeCTAViewWithConfiguration:(TWTRVideoDeeplinkConfiguration *)configuration
{
    TWTRVideoCTAView *cta = [[TWTRVideoCTAView alloc] initWithFrame:CGRectZero deeplinkConfiguration:configuration];
    cta.translatesAutoresizingMaskIntoConstraints = NO;
    cta.delegate = self;

    return cta;
}

- (void)installGestureRecognizers
{
    UITapGestureRecognizer *backgroundTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackgroundTap)];
    backgroundTap.delegate = self;
    [self addGestureRecognizer:backgroundTap];

    /// If we are not showing controls we need some way to start/stop the video
    if (![TWTRVideoPlaybackRules shouldShowVideoControlsForType:self.playbackConfiguration.mediaType]) {
        UITapGestureRecognizer *videoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleVideoTap)];
        videoTap.delegate = self;
        [self.mediaContainer addGestureRecognizer:videoTap];
        _videoTapGestureRecognizer = videoTap;
    }

    _backgroundTapGestureRecognizer = backgroundTap;
}

- (void)prepareVideoSynchronizer
{
    if (self.playerView && self.controlsView) {
        _synchronizer = [[TWTRVideoControlsViewSynchronizer alloc] initWithVideoPlayer:self.playerView controls:self.controlsView];
        _synchronizer.delegate = self;
    }
}

- (BOOL)isChromeVisible
{
    return CGAffineTransformIsIdentity(self.bottomBarContainer.transform);
}

- (void)setChromeVisible:(BOOL)visible animated:(BOOL)animated
{
    CGAffineTransform bottomTransform = visible ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0.0, self.bottomBarContainer.bounds.size.height / 2.0);
    CGFloat alpha = visible ? 1.0 : 0.0;

    void (^animations)(void) = ^{
        self.bottomBarContainer.transform = bottomTransform;
        self.bottomBarContainer.alpha = alpha;
        self.CTAView.alpha = alpha;

        self.CTATopConstraint.active = visible;
        self.CTABottomConstraint.active = !visible;
        [self layoutIfNeeded];
    };

    if (animated) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:animations completion:nil];
    } else {
        animations();
    }

    if ([self.delegate respondsToSelector:@selector(playerView:setChromeVisible:animated:)]) {
        [self.delegate playerView:self setChromeVisible:visible animated:animated];
    }
}

- (void)setAspectRatio:(TWTRVideoPlayerAspectRatio)aspectRatio
{
    _aspectRatio = aspectRatio;
    self.playerView.aspectRatio = aspectRatio;
}

#pragma mark - Public Methods

- (void)loadVideo
{
    self.playerView.shouldPlayVideoMuted = self.shouldPlayVideoMuted;
    [self.playerView loadVideo];
}

- (void)playVideo
{
    self.playerView.shouldPlayVideoMuted = self.shouldPlayVideoMuted;
    [self.playerView play];
}

- (void)pauseVideo
{
    [self.playerView pause];
}

- (void)proceedToNextPlaybackState
{
    [self.playerView proceedToNextPlaybackState];
}

- (void)updateControls:(TWTRVideoControlsView *)controlsView
{
    [self.controlsView removeFromSuperview];
    [self.bottomBarContainer removeFromSuperview];

    self.controlsView = controlsView;
    self.synchronizer.controlsView = controlsView;

    [self prepareBottomBar];
}

- (BOOL)isVideoReadyToPlay
{
    return [self.playerView isVideoReadyToPlay];
}

#pragma mark - Actions

- (void)handleBackgroundTap
{
    if (self.shouldSetChromeVisible) {
        [self setChromeVisible:![self isChromeVisible] animated:YES];
    }

    if ([self.delegate respondsToSelector:@selector(playerViewDidTapVideo:)]) {
        [self.delegate playerViewDidTapVideo:self];
    }
}

- (void)handleVideoTap
{
    [self.playerView proceedToNextPlaybackState];
}

#pragma mark - TWTRVideoCTAViewDelegate

- (void)videoCTAView:(TWTRVideoCTAView *)CTAView willDeeplinkToTargetURL:(NSURL *)targetURL
{
    [self.playerView pause];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.backgroundTapGestureRecognizer) {
        return [self backgroundGestureRecognizerShouldBegin:gestureRecognizer];
    } else if (gestureRecognizer == self.videoTapGestureRecognizer) {
        return [self videoGestureRecognizerShouldBegin:gestureRecognizer];
    }
    return YES;
}

- (BOOL)videoGestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self.playerView];

    return CGRectContainsPoint(self.playerView.videoRect, location);
}

- (BOOL)backgroundGestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (![self isChromeVisible]) {
        return YES;
    }

    CGRect ignoredFrame = [self.controlsView convertRect:self.controlsView.bounds toView:gestureRecognizer.view];
    CGPoint location = [gestureRecognizer locationInView:self];

    return !CGRectContainsPoint(ignoredFrame, location);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == self.backgroundTapGestureRecognizer && otherGestureRecognizer == self.videoTapGestureRecognizer) {
        return YES;
    }
    return NO;
}

#pragma mark - TWTRVideoControlsViewSynchronizerDelegate

- (void)controlsViewSynchronizerDidTapFullscreen:(TWTRVideoControlsViewSynchronizer *)synchronizer
{
    if ([self.delegate respondsToSelector:@selector(playerViewDidTapFullscreen:)]) {
        [self.delegate playerViewDidTapFullscreen:self];
    }
}

- (void)controlsViewSynchronizer:(TWTRVideoControlsViewSynchronizer *)synchronizer didChangePlaybackState:(TWTRVideoPlaybackState)state
{
    self.playbackState = state;
    if ([self.delegate respondsToSelector:@selector(playerView:didChangePlaybackState:)]) {
        [self.delegate playerView:self didChangePlaybackState:state];
    }
}

- (void)controlsViewSynchronizerVideoPlayerDidBecomeReady:(TWTRVideoControlsViewSynchronizer *)synchronizer
{
    if ([self.delegate respondsToSelector:@selector(playerViewDidBecomeReady:shouldAutoPlay:)]) {
        [self.delegate playerViewDidBecomeReady:self shouldAutoPlay:self.playerView.shouldAutoPlay];
    }
}

@end

NS_ASSUME_NONNULL_END
