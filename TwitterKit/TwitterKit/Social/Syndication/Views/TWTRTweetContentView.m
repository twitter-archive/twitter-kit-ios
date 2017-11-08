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

#import "TWTRTweetContentView.h"
#import "TWTRFontUtil.h"
#import "TWTRTweetContentView+Layout.h"
#import "TWTRTweet_Private.h"
#import "TWTRViewUtil.h"

@interface TWTRTweetContentView ()

@property (nonatomic, readonly) id<TWTRTweetContentViewLayout> layout;

@property (nonatomic, readonly) NSLayoutConstraint *imageTopConstraint;
@property (nonatomic, readonly) NSLayoutConstraint *imageBottomConstraint;

@end

@implementation TWTRTweetContentView

- (instancetype)initWithLayout:(id<TWTRTweetContentViewLayout>)layout
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _layout = layout;
        [self setupSubviews];
        _shouldPlayVideoMuted = NO;
    }
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.tweetLabel.backgroundColor = backgroundColor;
    self.profileHeaderView.backgroundColor = backgroundColor;
}

- (void)setPrimaryTextColor:(UIColor *)color
{
    if (_primaryTextColor != color) {
        _primaryTextColor = color;
        self.profileHeaderView.fullname.textColor = color;
        self.tweetLabel.textColor = color;
    }
}

- (void)setSecondaryTextColor:(UIColor *)color
{
    if (_secondaryTextColor != color) {
        _secondaryTextColor = color;
        self.profileHeaderView.secondaryTextColor = color;
    }
}

- (void)setLinkTextColor:(UIColor *)color
{
    if (_linkTextColor != color) {
        _linkTextColor = color;
    }
    self.tweetLabel.linkColor = color;
}

- (void)setMediaViewDelegate:(id<TWTRTweetMediaViewDelegate>)mediaViewDelegate
{
    self.mediaView.delegate = mediaViewDelegate;
}

- (id<TWTRTweetMediaViewDelegate>)mediaViewDelegate
{
    return self.mediaView.delegate;
}

- (void)setProfileHeaderDelegate:(id<TWTRProfileHeaderViewDelegate>)profileHeaderDelegate
{
    self.profileHeaderView.delegate = profileHeaderDelegate;
}

- (id<TWTRProfileHeaderViewDelegate>)profileHeaderDelegate
{
    return self.profileHeaderView.delegate;
}

- (void)setTweetLabelDelegate:(id<TWTRAttributedLabelDelegate>)tweetLabelDelegate
{
    self.tweetLabel.delegate = tweetLabelDelegate;
}

- (id<TWTRAttributedLabelDelegate>)tweetLabelDelegate
{
    return self.tweetLabel.delegate;
}

- (void)updateForComputedBackgroundColor:(UIColor *)color
{
    [self.mediaView updateBackgroundWithComputedColor:color];
    self.profileHeaderView.backgroundColor = color;
    [self bringSubviewToFront:self.tweetLabel];
}

- (UIView *)alignmentLayoutGuide
{
    return self.tweetLabel;
}

- (void)setPresenterViewController:(UIViewController *)controller
{
    self.mediaView.presenterViewController = controller;
}

- (UIViewController *)presenterViewController
{
    return self.mediaView.presenterViewController;
}

- (nullable UIImage *)imageForMediaEntity:(TWTRTweetMediaEntity *)mediaEntity
{
    return [self.mediaView imageForMediaEntity:mediaEntity];
}

- (BOOL)didGestureRecognizerInteractWithEntity:(UIGestureRecognizer *)gesture
{
    CGPoint tapPoint = [gesture locationInView:self.tweetLabel];

    return [self.tweetLabel entityExistsAtPoint:tapPoint];
}

- (void)setupSubviews
{
    _mediaView = [[TWTRTweetMediaView alloc] init];
    _profileHeaderView = [[TWTRProfileHeaderView alloc] initWithStyle:[self.layout tweetViewStyle]];

    _tweetLabel = [[TWTRTweetLabel alloc] init];
    _tweetLabel.font = [self.layout fontForTweetLabel];
    _tweetLabel.minimumLineHeight = [TWTRFontUtil minimumLineHeightForFont:_tweetLabel.font traitCollection:self.traitCollection];
    _tweetLabel.entityDisplayTypes = TWTRTweetEntityDisplayTypeAll;

    for (UIView *view in @[_mediaView, _profileHeaderView, _tweetLabel]) {
        [self addSubview:view];
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }

    [self.layout applyConstraintsForContentView:self];

    _mediaView.allowsCornerRadiusRounding = [self.layout allowsMediaCornerRounding];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return [self.layout sizeThatFits:size forContentView:self];
}

- (void)updateTweetTextWithTweet:(TWTRTweet *)tweet
{
    [self.tweetLabel setTextFromTweet:tweet];
}

- (void)updateProfileHeaderWithTweet:(TWTRTweet *)tweet
{
    [self.profileHeaderView configureWithTweet:tweet];
}

- (void)updateMediaWithTweet:(TWTRTweet *)tweet aspectRatio:(CGFloat)aspectRatio
{
    [self.mediaView configureWithTweet:tweet style:TWTRTweetViewStyleCompact];
    self.mediaView.aspectRatio = aspectRatio;
    [self.layout setShowingMedia:tweet.hasMedia];
}

- (void)playVideo
{
    self.mediaView.shouldPlayVideoMuted = self.shouldPlayVideoMuted;
    [self.mediaView playVideo];
}

- (void)pauseVideo
{
    [self.mediaView pauseVideo];
}

@end
