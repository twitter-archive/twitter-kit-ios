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

#import "TWTRTweetMediaView.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRColorUtil.h>
#import <TwitterCore/TWTRResourcesUtil.h>
#import <TwitterCore/TWTRUtils.h>
#import "TWTRImageViewController.h"
#import "TWTRMediaEntityDisplayConfiguration.h"
#import "TWTRMultiImageViewController.h"
#import "TWTRMultiPhotoLayout.h"
#import "TWTRPlayIcon.h"
#import "TWTRPlayerCardEntity.h"
#import "TWTRTranslationsUtil.h"
#import "TWTRTweet.h"
#import "TWTRTweetImageView.h"
#import "TWTRTweetMediaEntity.h"
#import "TWTRTweet_Private.h"
#import "TWTRTwitter_Private.h"
#import "TWTRVideoControlsView.h"
#import "TWTRVideoMetaData.h"
#import "TWTRVideoPlaybackConfiguration.h"
#import "TWTRVideoPlayerView.h"
#import "TWTRVideoViewController.h"
#import "TWTRViewUtil.h"

NS_ASSUME_NONNULL_BEGIN

@interface TWTRTweetMediaView () <TWTRVideoViewControllerDelegate>

@property (nonatomic, readonly, nullable) TWTRTweet *tweet;
@property (nonatomic) NSMutableArray<TWTRTweetImageView *> *imageViews;
@property (nonatomic, nullable) TWTRVideoPlayerView *inlinePlayerView;
@property (nonatomic, readonly) NSLayoutConstraint *aspectRatioConstraint;

@end

static const CGFloat TWTRImageCornerRadius = 4.0;

@implementation TWTRTweetMediaView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _style = TWTRTweetViewStyleRegular;
        _aspectRatio = 1;
        _allowsCornerRadiusRounding = YES;
        _shouldPlayVideoMuted = NO;

        self.isAccessibilityElement = YES;
        self.clipsToBounds = YES;
        self.presenterViewController = [TWTRUtils topViewController];
        self.imageViews = [NSMutableArray array];

        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentDetailedMediaForGesture:)];
        [self addGestureRecognizer:_tapGestureRecognizer];
    }
    return self;
}

- (void)prepareImageViewsForTweet:(TWTRTweet *)tweet
{
    // Inefficiently remove image views
    for (UIImageView *imageView in self.imageViews) {
        [imageView removeFromSuperview];
    }

    NSMutableArray *imageViews = [NSMutableArray array];

    for (TWTRMediaEntityDisplayConfiguration *config in [self mediaDisplayConfigurations]) {
        TWTRTweetImageView *imageView = [[TWTRTweetImageView alloc] init];
        [imageView configureWithMediaEntityConfiguration:config style:self.style];
        [self addSubview:imageView];
        [imageViews addObject:imageView];
    }

    if (imageViews.count > 0) {
        [TWTRMultiPhotoLayout layoutViews:imageViews];
    }

    self.imageViews = imageViews;
}

- (void)prepareInlinePlayerForTweet:(nullable TWTRTweet *)tweet
{
    if ([tweet hasPlayableVideo]) {
        if ([self.subviews containsObject:self.inlinePlayerView]) {
            [self.inlinePlayerView removeFromSuperview];
        }

        self.inlinePlayerView = [[TWTRVideoPlayerView alloc] initWithTweet:tweet playbackConfiguration:[self videoPlaybackConfiguration] controlsView:[TWTRVideoControlsView inlineControls] previewImage:[self videoThumbnail].image];
        self.inlinePlayerView.shouldSetChromeVisible = NO;
        self.inlinePlayerView.delegate = self;
        self.inlinePlayerView.aspectRatio = TWTRVideoPlayerAspectRatioAspectFill;
        self.inlinePlayerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self insertSubview:self.inlinePlayerView belowSubview:[self videoThumbnail]];
    } else {
        [self.inlinePlayerView removeFromSuperview];
        self.inlinePlayerView = nil;
    }
}

- (void)layoutInlinePlayerView
{
    self.inlinePlayerView.translatesAutoresizingMaskIntoConstraints = NO;
    [TWTRViewUtil centerView:self.inlinePlayerView inView:self];
    [TWTRViewUtil equateAttribute:NSLayoutAttributeWidth onView:self.inlinePlayerView toView:self];
    [TWTRViewUtil equateAttribute:NSLayoutAttributeHeight onView:self.inlinePlayerView toView:self];
}

- (NSArray *)mediaDisplayConfigurations
{
    NSMutableArray *mediaConfigurations = [NSMutableArray array];
    if ([self.tweet hasVineCard]) {
        [mediaConfigurations addObject:[TWTRMediaEntityDisplayConfiguration mediaEntityDisplayConfigurationWithCardEntity:self.tweet.cardEntity]];
    } else if ([self.tweet hasMedia]) {
        for (TWTRTweetMediaEntity *entity in self.tweet.media) {
            [mediaConfigurations addObject:[[TWTRMediaEntityDisplayConfiguration alloc] initWithMediaEntity:entity targetWidth:[self desiredWidth]]];
        }
    }

    return mediaConfigurations;
}

- (CGFloat)desiredWidth
{
    CGFloat desiredWidth = [TWTRResourcesUtil screenScale] * self.frame.size.width;
    if ([self.tweet.media count] > 1) {
        desiredWidth = desiredWidth / 2;
    }
    return desiredWidth;
}

- (void)addAspectRatioConstraint
{
    if ([self isShowingMedia]) {
        _aspectRatioConstraint = [TWTRViewUtil constraintForAspectRatio:self.aspectRatio onView:self];
    } else {
        _aspectRatioConstraint = [TWTRViewUtil constraintForAttribute:NSLayoutAttributeHeight onView:self value:0];
    }

    self.aspectRatioConstraint.active = YES;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(size.width, (self.tweet.hasMedia) ? floor(size.width / self.aspectRatio) : 0.0);
}

#pragma mark - constraints
- (void)updateConstraints
{
    if (self.aspectRatioConstraint == nil) {
        [self addAspectRatioConstraint];
    }
    [super updateConstraints];
}

- (void)setAspectRatioConstraintNeedsUpdate
{
    if (self.aspectRatioConstraint) {
        self.aspectRatioConstraint.active = NO;
        [self setNeedsUpdateConstraints];
    }
    _aspectRatioConstraint = nil;
}

#pragma mark - Configuration

- (void)setAspectRatio:(CGFloat)aspectRatio
{
    const BOOL aspectRatioHasChanged = ABS(aspectRatio - _aspectRatio) > __FLT_EPSILON__;
    if (aspectRatioHasChanged) {
        _aspectRatio = aspectRatio;
        [self setAspectRatioConstraintNeedsUpdate];
    }
}

- (nullable TWTRTweetImageView *)videoThumbnail
{
    return [self.imageViews firstObject];
}

- (TWTRTweetMediaEntity *)firstMediaEntity
{
    return self.tweet.media.firstObject;
}

- (void)configureWithTweet:(nullable TWTRTweet *)tweet style:(TWTRTweetViewStyle)style
{
    _tweet = tweet;
    _style = style;

    [self prepareImageViewsForTweet:tweet];
    [self prepareInlinePlayerForTweet:tweet];
    [self addPlayIconIfNeeded];
    [self roundCornersIfNeeded];
    [self setAspectRatioConstraintNeedsUpdate];
}

- (void)addPlayIconIfNeeded
{
    if ([self shouldShowPlayButtonForEmbeddableVideo] || [self isShowingVideoThumbnail]) {
        TWTRPlayIcon *playIcon = [[TWTRPlayIcon alloc] init];
        [self.videoThumbnail addSubview:playIcon];
        [TWTRViewUtil centerViewInSuperview:playIcon];
    }
}

- (void)roundCornersIfNeeded
{
    if (self.allowsCornerRadiusRounding && self.style == TWTRTweetViewStyleCompact) {
        self.layer.cornerRadius = TWTRImageCornerRadius;
    } else {
        self.layer.cornerRadius = 0.0;
    }
}

- (BOOL)isShowingVideoThumbnail
{
    return [self.tweet hasPlayableVideo];
}

- (BOOL)shouldShowPlayButtonForEmbeddableVideo
{
    if ([self.tweet hasMedia]) {
        TWTRTweetMediaEntity *mediaEntity = [self.tweet.media firstObject];
        if ([mediaEntity isEmbeddableDefined] && ![mediaEntity embeddable]) {
            return YES;
        }
    }

    return NO;
}

- (BOOL)isShowingMedia
{
    return [self.tweet hasMedia];
}

- (void)playVideo
{
    if ([self.tweet hasPlayableVideo] && self.inlinePlayerView != nil) {
        [self videoThumbnail].hidden = YES;
        self.inlinePlayerView.shouldPlayVideoMuted = self.shouldPlayVideoMuted;
        [self.inlinePlayerView loadVideo];
        [self layoutInlinePlayerView];
    }
}

- (void)pauseVideo
{
    if ([self.tweet hasPlayableVideo] && self.inlinePlayerView != nil) {
        [self.inlinePlayerView pauseVideo];
    }
}

- (BOOL)presentDetailedMediaViewForMediaEntity:(TWTRTweetMediaEntity *)mediaEntity
{
    /// Don't present if no media
    if (![self isShowingMedia]) {
        return NO;
    } else {
        NSInteger index = [self.tweet.media indexOfObject:mediaEntity];
        if (index != NSNotFound) {
            return [self presentDetailedViewForMediaEntityAtIndex:index];
        } else {
            return NO;
        }
    }
}

- (BOOL)presentDetailedViewForMediaEntityAtIndex:(NSInteger)idx
{
    if ([self.tweet hasPlayableVideo]) {
        [self playVideo];
        return YES;
    } else if ([self shouldShowPlayButtonForEmbeddableVideo]) {
        return [self callDelegateToOpenTweet];
    } else {
        return [self presentDetailedImageViewWithMediaEntityAtIndex:idx];
    }
}

- (void)presentDetailedMediaForGesture:(UITapGestureRecognizer *)tapGesture
{
    CGPoint tapPoint = [tapGesture locationInView:self];
    NSInteger idx = [self indexOfMediaEntityForTapPoint:tapPoint];

    if (idx != NSNotFound) {
        [self presentDetailedViewForMediaEntityAtIndex:idx];
    }
}

- (BOOL)callDelegateToOpenTweet
{
    if ([self.delegate respondsToSelector:@selector(mediaViewDidSelectNonEmbeddableVideo:)]) {
        [self.delegate mediaViewDidSelectNonEmbeddableVideo:self];
        return YES;
    } else {
        return NO;
    }
}

// Pick the media entity that represents the thumbnail tapped
- (NSInteger)indexOfMediaEntityForTapPoint:(CGPoint)tapPoint
{
    NSUInteger imageIndex = [self.imageViews indexOfObjectPassingTest:^BOOL(TWTRTweetImageView *imageView, NSUInteger idx, BOOL *stop) {
        return CGRectContainsPoint(imageView.frame, tapPoint);
    }];

    if (imageIndex != NSNotFound) {
        return imageIndex;
    } else {
        NSLog(@"[TwitterKit] No media entity found at tap location.");
        return NSNotFound;
    }
}

- (nullable UIImage *)imageForMediaEntity:(TWTRTweetMediaEntity *)mediaEntity
{
    NSUInteger index = [self.tweet.media indexOfObject:mediaEntity];
    return [self imageAtIndex:index];
}

- (nullable UIImage *)imageAtIndex:(NSInteger)index
{
    if (index >= 0 && index < self.imageViews.count) {
        return self.imageViews[index].image;
    } else {
        return nil;
    }
}

- (BOOL)presentDetailedVideoView
{
    TWTRVideoPlaybackConfiguration *videoConfig = [self videoPlaybackConfiguration];

    if (![self shouldPresentVideo:videoConfig]) {
        return NO;
    }

    [self.inlinePlayerView pauseVideo];
    UIViewController *presentingViewController = [self viewControllerForPresenting];
    [self presentVideo:videoConfig fromViewController:presentingViewController];
    return YES;
}

- (BOOL)presentDetailedImageViewWithMediaEntityAtIndex:(NSInteger)idx
{
    TWTRTweetMediaEntity *mediaEntity = self.tweet.media[idx];
    if (![self shouldPresentMediaEntity:mediaEntity]) {
        return NO;
    }

    [self presentMediaEntity:mediaEntity forImageAtIndex:idx];
    return YES;
}

- (void)presentMediaEntity:(TWTRTweetMediaEntity *)mediaEntity forImageAtIndex:(NSInteger)idx
{
    NSMutableArray<TWTRImagePresentationContext *> *contexts = [NSMutableArray array];

    NSString *parentTweetID = self.tweet.tweetID;

    [self.tweet.media enumerateObjectsUsingBlock:^(TWTRTweetMediaEntity *_Nonnull entity, NSUInteger blockIdx, BOOL *_Nonnull stop) {
        TWTRImagePresentationContext *ctx = [TWTRImagePresentationContext contextWithImage:self.imageViews[blockIdx].image mediaEntity:entity parentTweetID:parentTweetID];

        // If the image is missing, don't show in viewer
        if (ctx.image != nil) {
            [contexts addObject:ctx];
        }
    }];

    // If there are no images for viewer, don't attempt to present
    if ([contexts count] == 0) {
        return;
    }

    TWTRMultiImageViewController *mediaVC = [[TWTRMultiImageViewController alloc] initWithImagePresentationContexts:contexts initialContextIndex:idx];

    [self presentMediaViewController:mediaVC fromView:self.imageViews[idx] presentingViewController:[self viewControllerForPresenting]];

    if ([self.delegate respondsToSelector:@selector(tweetMediaView:didPresentImageViewerForMediaEntity:)]) {
        [self.delegate tweetMediaView:self didPresentImageViewerForMediaEntity:mediaEntity];
    }
}

- (void)presentVideo:(TWTRVideoPlaybackConfiguration *)videoConfig fromViewController:(UIViewController *)presentingViewController
{
    TWTRVideoViewController *viewController = [[TWTRVideoViewController alloc] initWithTweet:self.tweet playbackConfiguration:videoConfig previewImage:[self imageAtIndex:0] playerView:self.inlinePlayerView];
    viewController.delegate = self;

    [self presentMediaViewController:viewController fromView:self presentingViewController:presentingViewController];

    if ([self.delegate respondsToSelector:@selector(tweetMediaView:didPresentVideoPlayerForMediaEntity:)]) {
        [self.delegate tweetMediaView:self didPresentVideoPlayerForMediaEntity:self.firstMediaEntity];
    }
}

- (void)presentMediaViewController:(UIViewController<TWTRMediaContainerPresentable> *)mediaViewController fromView:(UIView *)view presentingViewController:(UIViewController *)presentingViewController
{
    TWTRMediaContainerViewController *mediaContainer = [[TWTRMediaContainerViewController alloc] initWithMediaViewController:mediaViewController];

    // Delay this for a short moment to avoid flickering when showing the view.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        view.alpha = 0.0;
    });

    [mediaContainer showFromView:view
                inViewController:presentingViewController
                      completion:^{
                          view.alpha = 1.0;
                      }];
}

- (TWTRVideoPlaybackConfiguration *)videoPlaybackConfiguration
{
    TWTRTweetMediaEntity *mediaEntity = self.firstMediaEntity;
    if (mediaEntity) {
        return [TWTRVideoPlaybackConfiguration playbackConfigurationForTweetMediaEntity:mediaEntity];
    } else {
        return [TWTRVideoPlaybackConfiguration playbackConfigurationForCardEntity:self.tweet.cardEntity URLEntities:self.tweet.urls];
    }
}

- (void)updateBackgroundWithComputedColor:(UIColor *)backgroundColor
{
    UIColor *color = [TWTRColorUtil mediaBackgroundColorFromBackgroundColor:backgroundColor];
    self.backgroundColor = color;
}

- (BOOL)shouldPresentMediaEntity:(TWTRTweetMediaEntity *)mediaEntity
{
    if ([self.delegate respondsToSelector:@selector(tweetMediaView:shouldPresentImageForMediaEntity:)]) {
        return [self.delegate tweetMediaView:self shouldPresentImageForMediaEntity:mediaEntity];
    }
    return YES;
}

- (BOOL)shouldPresentVideo:(TWTRVideoPlaybackConfiguration *)playbackConfig
{
    if ([self.delegate respondsToSelector:@selector(tweetMediaView:shouldPresentVideoForConfiguration:)]) {
        return [self.delegate tweetMediaView:self shouldPresentVideoForConfiguration:playbackConfig];
    }
    return YES;
}

- (UIViewController *)viewControllerForPresenting
{
    UIViewController *viewController;
    if ([self.delegate respondsToSelector:@selector(viewControllerToPresentFromTweetMediaView:)]) {
        viewController = [self.delegate viewControllerToPresentFromTweetMediaView:self];
    }

    return viewController ?: self.presenterViewController;
}

- (void)setPresenterViewController:(nullable UIViewController *)presenterViewController
{
    _presenterViewController = presenterViewController ?: [TWTRUtils topViewController];
}

#pragma mark - TWTRVideoViewControllerDelegate

- (void)videoViewControllerViewWillDissapear:(TWTRVideoViewController *)viewController
{
    [self.inlinePlayerView removeFromSuperview];

    self.inlinePlayerView.shouldSetChromeVisible = NO;
    self.inlinePlayerView.delegate = self;
    self.inlinePlayerView.aspectRatio = TWTRVideoPlayerAspectRatioAspectFill;

    [self.inlinePlayerView updateControls:[TWTRVideoControlsView inlineControls]];
    [self insertSubview:self.inlinePlayerView belowSubview:[self videoThumbnail]];
    [self layoutInlinePlayerView];
    [self.inlinePlayerView playVideo];
}

#pragma mark - TWTRVideoPlayerViewDelegate

- (void)playerViewDidTapVideo:(TWTRVideoPlayerView *)playerView
{
    [self videoThumbnail].hidden = self.inlinePlayerView.playbackState = TWTRVideoPlaybackStatePlaying;
    [self.inlinePlayerView proceedToNextPlaybackState];
}

- (void)playerViewDidTapFullscreen:(TWTRVideoPlayerView *)playerView
{
    [self presentDetailedVideoView];
}

- (void)playerView:(TWTRVideoPlayerView *)playerView didChangePlaybackState:(TWTRVideoPlaybackState)newState
{
    if ([self.delegate respondsToSelector:@selector(tweetMediaView:didChangePlaybackState:)]) {
        [self.delegate tweetMediaView:self didChangePlaybackState:newState];
    }
}

#pragma mark - Accessibility

- (nullable NSString *)accessibilityLabel
{
    if (![self isShowingMedia]) {
        return @"";
    }

    if ([self isShowingVideoThumbnail]) {
        return TWTRLocalizedString(@"tw__video_thumbnail");
    } else {
        return TWTRLocalizedString(@"tw__single_image");
    }
}

@end

NS_ASSUME_NONNULL_END
