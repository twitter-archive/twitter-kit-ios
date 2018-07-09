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

#import "TWTRTweetView.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRColorUtil.h>
#import <TwitterCore/TWTRDateUtil.h>
#import <TwitterCore/TWTRUtils.h>
#import "TWTRCardEntity.h"
#import "TWTRConstants_Private.h"
#import "TWTRFontUtil.h"
#import "TWTRImageLoader.h"
#import "TWTRImageViewController.h"
#import "TWTRImages.h"
#import "TWTRLikeButton.h"
#import "TWTRNotificationCenter.h"
#import "TWTRNotificationConstants.h"
#import "TWTRProfileHeaderView.h"
#import "TWTRProfileView.h"
#import "TWTRShareButton.h"
#import "TWTRStore.h"
#import "TWTRSubscriber.h"
#import "TWTRTranslationsUtil.h"
#import "TWTRTweetDelegationHelper.h"
#import "TWTRTweetLabel.h"
#import "TWTRTweetMediaEntity.h"
#import "TWTRTweetMediaView.h"
#import "TWTRTweetPresenter.h"
#import "TWTRTweetRepository.h"
#import "TWTRTweetUrlEntity.h"
#import "TWTRTweetViewMetrics.h"
#import "TWTRTweetView_Private.h"
#import "TWTRTweet_Private.h"
#import "TWTRTwitter_Private.h"
#import "TWTRUser.h"
#import "TWTRVideoMetaData.h"
#import "TWTRVideoPlaybackConfiguration.h"
#import "TWTRVideoPlaybackState.h"
#import "TWTRVideoViewController.h"
#import "TWTRViewUtil.h"

#import "TWTRTweetContentView+Layout.h"
#import "TWTRTweetContentView.h"
#import "TWTRTweetContentViewLayoutFactory.h"

@interface TWTRTweetView () <TWTRAttributedLabelDelegate, TWTRProfileHeaderViewDelegate, TWTRTweetMediaViewDelegate, UIGestureRecognizerDelegate, UITextViewDelegate, TWTRSubscriber>

/**
 * Represents an area that can display other content like Quote Tweets or poll cards.
 */
@property (nonatomic, readonly) UIView *attachmentContainer;
@property (nonatomic, readonly) NSLayoutConstraint *attachmentTopMarginConstraint;
@property (nonatomic, readonly) NSLayoutConstraint *attachmentBottomMarginConstraint;

/**
 * Represents an area at the bottom of the view which can hold an action bar.
 */
@property (nonatomic, readonly) UIView *actionContainer;

@end

@implementation TWTRTweetView

static CGFloat const TWTRTweetViewBorderWidth = 0.5;
static CGFloat const TWTRTweetViewCornerRadius = 4.0;
static TWTRTweetViewTheme const TWTRTweetViewDefaultTheme = TWTRTweetViewThemeLight;

#pragma mark - Initialization

+ (void)initialize
{
    if (self == [TWTRTweetView class]) {
        [[self appearance] setTheme:TWTRTweetViewDefaultTheme];
    }
}

+ (id<TWTRTweetContentViewLayout>)layoutForTweetViewStyle:(TWTRTweetViewStyle)style metrics:(TWTRTweetViewMetrics *)metrics
{
    switch (style) {
        case TWTRTweetViewStyleRegular:
            return [TWTRTweetContentViewLayoutFactory regularTweetViewLayoutWithMetrics:metrics];
        case TWTRTweetViewStyleCompact:
            return [TWTRTweetContentViewLayoutFactory compactTweetViewLayoutWithMetrics:metrics];
    }
}

- (instancetype)init
{
    return [self initWithTweet:nil];
}

- (instancetype)initWithTweet:(TWTRTweet *)tweet
{
    return [self initWithTweet:tweet style:TWTRTweetViewStyleCompact];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    return [self initWithTweet:nil style:TWTRTweetViewStyleCompact];
}

- (instancetype)initWithTweet:(TWTRTweet *)tweet style:(TWTRTweetViewStyle)style
{
    self = [super init];

    if (self) {
        // Setup self
        _tweet = tweet;
        _profileUserToDisplay = tweet.author;
        _style = style;
        _metrics = [[TWTRTweetViewMetrics alloc] init];
        _calculationOnly = NO;
        _tweetPresenter = [TWTRTweetPresenter presenterForStyle:style];
        _presenterViewController = [TWTRUtils topViewController];

        // Content View
        id<TWTRTweetContentViewLayout> layout = [[self class] layoutForTweetViewStyle:style metrics:_metrics];
        _contentView = [[TWTRTweetContentView alloc] initWithLayout:layout];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_contentView];

        _contentView.mediaViewDelegate = self;
        _contentView.profileHeaderDelegate = self;
        _contentView.tweetLabelDelegate = self;

        // Attachment Container
        _attachmentContainer = [[UIView alloc] init];
        _attachmentContainer.clipsToBounds = YES;
        _attachmentContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_attachmentContainer];

        // Action Container
        _actionContainer = [[UIView alloc] init];
        _actionContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_actionContainer];

        // Share Button
        _shareButton = [[TWTRShareButton alloc] initWithShareButtonSize:TWTRShareButtonSizeRegular];
        _shareButton.hidden = (style == TWTRTweetViewStyleCompact);
        _shareButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_actionContainer addSubview:_shareButton];

        // Like Button
        _likeButton = [[TWTRLikeButton alloc] initWithLikeButtonSize:TWTRLikeButtonSizeRegular];
        _likeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_actionContainer addSubview:_likeButton];

        _shouldPlayVideoMuted = NO;

        [self setShowBorder:YES];
        [self setupConstraints];
        [self setupGestureRecognizers];
        [self configureWithTweet:tweet];
        [self setShowActionButtons:NO];

        // We need a way to size ourselves before the developer does or the frame
        // will be 0 in cases where the host app doesn't use Auto Layout
        CGPoint origin = self.frame.origin;
        CGSize desiredSize = [self sizeThatFits:CGSizeMake(self.metrics.defaultWidth, CGFLOAT_MAX)];
        self.frame = TWTRRectPixelIntegral(CGRectMake(origin.x, origin.y, desiredSize.width, desiredSize.height));

        _doneInitializing = YES;
    }

    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize constrainedSize = CGSizeMake(MAX(size.width, TWTRTweetViewMinWidth), size.height);  // Clamp Minimum value to 200px wide
    CGSize finalSize = [self.contentView sizeThatFits:constrainedSize];

    if (self.attachmentContentView) {
        if (self.style == TWTRTweetViewStyleRegular) {
            constrainedSize.width -= 2.0 * self.metrics.regularMargin + self.metrics.profileImageSize + self.metrics.profileMarginRight;
        } else {
            constrainedSize.width -= self.metrics.profileMarginLeft + self.metrics.profileImageSize + self.metrics.profileMarginRight + self.metrics.defaultMargin;
        }

        finalSize.height += self.metrics.marginTop;
        finalSize.height += [self.attachmentContentView sizeThatFits:constrainedSize].height;
        finalSize.height += self.metrics.marginBottom;
    }

    if (self.showActionButtons) {
        finalSize.height += self.metrics.actionsHeight;
        finalSize.height += self.metrics.actionsBottomMargin;
    } else {
        finalSize.height += self.metrics.marginBottom;
    }

    return finalSize;
}

#pragma mark - Theme Methods

+ (UIColor *)backgroundColorForTheme:(TWTRTweetViewTheme)theme
{
    switch (theme) {
        case TWTRTweetViewThemeDark:
            return [TWTRColorUtil textColor];
        case TWTRTweetViewThemeLight:
            return [TWTRColorUtil whiteColor];
    }
}

+ (UIColor *)primaryTextColorForTheme:(TWTRTweetViewTheme)theme
{
    switch (theme) {
        case TWTRTweetViewThemeDark:
            return [TWTRColorUtil faintGrayColor];
        case TWTRTweetViewThemeLight:
            return [TWTRColorUtil textColor];
    }
}

+ (UIColor *)linkTextColorForTheme:(TWTRTweetViewTheme)theme
{
    switch (theme) {
        case TWTRTweetViewThemeDark:
            return [TWTRColorUtil lightBlueColor];
        case TWTRTweetViewThemeLight:
            return [TWTRColorUtil blueColor];
    }
}

+ (UIColor *)borderColorForTheme:(TWTRTweetViewTheme)theme
{
    switch (theme) {
        case TWTRTweetViewThemeDark:
            return [TWTRColorUtil darkBorderGrayColor];
        case TWTRTweetViewThemeLight:
            return [TWTRColorUtil borderGrayColor];
    }
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<%@: %p; %@ @%@>", NSStringFromClass([self class]), self, self.tweet.author.name, self.tweet.author.screenName];
}

- (void)setupGestureRecognizers
{
    // Background taps
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped)];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
}

// UIAppearance watches the instance variables to see when they have been
// set directly. Therefore, we only set them directly after init has finished
// to keep from have UIAppearance thinking that we have directly edited
// every single tweet view. http://petersteinberger.com/blog/2013/uiappearance-for-custom-views/
- (void)setTheme:(TWTRTweetViewTheme)theme
{
    theme = (theme == TWTRTweetViewThemeDark) ? theme : TWTRTweetViewDefaultTheme;

    if (self.doneInitializing) {
        _theme = theme;
    }

    self.backgroundColor = [[self class] backgroundColorForTheme:theme];
    self.primaryTextColor = [[self class] primaryTextColorForTheme:theme];
    self.linkTextColor = [[self class] linkTextColorForTheme:theme];
    [self updateBorder];
}

- (void)setBackgroundColor:(UIColor *)color
{
    if (self.doneInitializing) {
        _backgroundColor = color;
    }

    [super setBackgroundColor:color];

    const BOOL colorIsOpaque = [TWTRColorUtil isOpaqueColor:color];

    // Avoid seeing the background of the subviews if the user sets a semi-transparent background color.
    UIColor *backgroundColorForSubviews = colorIsOpaque ? color : [UIColor clearColor];

    self.contentView.backgroundColor = backgroundColorForSubviews;
    self.attachmentContainer.backgroundColor = backgroundColorForSubviews;

    [self setNeedsComputedColorsUpdate];
}

- (void)setPrimaryTextColor:(UIColor *)color
{
    if (self.doneInitializing) {
        _primaryTextColor = color;
    }

    [self.contentView setPrimaryTextColor:color];
    self.attachmentContentView.primaryTextColor = color;
    [self setNeedsComputedColorsUpdate];
}

- (void)setLinkTextColor:(UIColor *)linkTextColor
{
    if (self.doneInitializing) {
        _linkTextColor = linkTextColor;
    }

    [self.contentView setLinkTextColor:linkTextColor];
    [self.contentView updateTweetTextWithTweet:[self tweetToDisplay]];

    self.attachmentContentView.linkTextColor = linkTextColor;
    // TODO: We need a better way of udating the coloring of a tweet label.
    [self.attachmentContentView updateTweetTextWithTweet:[self tweetToDisplay].quotedTweet];
}

- (void)setShowBorder:(BOOL)showBorder
{
    _showBorder = showBorder;

    [self updateBorder];
}

- (void)updateBorder
{
    UIColor *borderColor = [[self class] borderColorForTheme:self.theme];

    self.layer.borderColor = borderColor.CGColor;
    self.layer.borderWidth = self.showBorder ? TWTRTweetViewBorderWidth : 0.0;
    self.layer.cornerRadius = self.showBorder ? TWTRTweetViewCornerRadius : 0.0;
    self.clipsToBounds = YES;

    self.attachmentContainer.layer.borderColor = borderColor.CGColor;
    self.attachmentContainer.layer.borderWidth = (2 * TWTRTweetViewBorderWidth);
    self.attachmentContainer.layer.cornerRadius = TWTRTweetViewCornerRadius;
}

- (void)setShowActionButtons:(BOOL)showActionButtons
{
    if (self.doneInitializing && (showActionButtons == _showActionButtons)) {
        return;
    }

    _showActionButtons = showActionButtons;

    self.likeButton.hidden = !showActionButtons;
    self.shareButton.hidden = !showActionButtons;
    [self setNeedsUpdateConstraints];
    if (self.doneInitializing) {
        [self sizeToFit];
    }
}

- (void)setDoneInitializing:(BOOL)doneInitializing
{
    if (_doneInitializing != doneInitializing) {
        _doneInitializing = doneInitializing;
        [self setNeedsComputedColorsUpdate];
    }
}

/**
 * Configures computed colors based on existing user-defined colors.
 * This method should always be called internally after setting user-defined colors.
 */
- (void)setNeedsComputedColorsUpdate
{
    [self updateComputedColorsForContentView:self.contentView];
}

- (void)updateComputedColorsForContentView:(TWTRTweetContentView *)contentView
{
    // This is a bit hacky; unfortunately we can't use TWTRTweetView's .primaryTextColor and .backgroundColor
    // properties, since their iVars don't actually get set (see previous comments regarding
    // UIAppearance).
    UIColor *primaryColor = self.contentView.primaryTextColor;
    UIColor *backgroundColor = self.contentView.backgroundColor;

    if (primaryColor && backgroundColor) {
        UIColor *secondaryTextColor = [TWTRColorUtil secondaryTextColorFromPrimaryTextColor:primaryColor backgroundColor:backgroundColor];
        self.contentView.secondaryTextColor = secondaryTextColor;
        self.attachmentContentView.secondaryTextColor = secondaryTextColor;
    }

    if (backgroundColor) {
        [self.contentView updateForComputedBackgroundColor:backgroundColor];
    }
}

#pragma mark - TWTRTweetSubscriber

- (void)objectUpdated:(id)object
{
    [self configureWithTweet:(TWTRTweet *)object];
}

#pragma mark - Configuration

- (TWTRTweet *)tweetToDisplay
{
    return self.tweet.isRetweet ? self.tweet.retweetedTweet : self.tweet;
}

- (void)configureWithTweet:(TWTRTweet *)tweet
{
    TWTRTweet *previousTweet = self.tweet;

    self.tweet = tweet;
    [self.likeButton configureWithTweet:tweet];
    [self.shareButton configureWithTweet:tweet];

    // If this is a retweet, show the original Tweet's text instead
    TWTRTweet *tweetToDisplay = [self tweetToDisplay];
    self.profileUserToDisplay = tweetToDisplay.author;

    [self.contentView updateTweetTextWithTweet:tweetToDisplay];
    [self.contentView updateProfileHeaderWithTweet:tweet];

    BOOL isSameTweetAsBefore = [tweet.tweetID isEqualToString:previousTweet.tweetID];

    // If this tweet is being configured with the same tweet as before,
    // we would like to avoid flickering images by avoiding duplicate loads
    if (isSameTweetAsBefore && self.doneInitializing) {
        return;
    }

    [[TWTRStore sharedInstance] unsubscribeSubscriber:self fromClass:[TWTRTweet class] objectID:previousTweet.tweetID];
    [[TWTRStore sharedInstance] subscribeSubscriber:self toClass:[TWTRTweet class] objectID:tweet.tweetID];

    CGFloat aspectRatio = [self.tweetPresenter mediaAspectRatioForTweet:tweetToDisplay];
    [self.contentView updateMediaWithTweet:tweetToDisplay aspectRatio:aspectRatio];

    [self updateAttachmentViewWithTweet:tweetToDisplay];

    [self invalidateIntrinsicContentSize];
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

- (void)updateAttachmentViewWithTweet:(TWTRTweet *)tweet
{
    for (UIView *subview in self.attachmentContainer.subviews) {
        [subview removeFromSuperview];
    }

    // Currently only show a quote tweet as an attachment
    // If content view already has media, does not show a quote tweet attachment
    if (tweet.isQuoteTweet && !tweet.hasMedia) {
        id<TWTRTweetContentViewLayout> layout = [TWTRTweetContentViewLayoutFactory quoteTweetViewLayoutWithMetrics:self.metrics];
        TWTRTweetContentView *contentView = [[TWTRTweetContentView alloc] initWithLayout:layout];
        [self.attachmentContainer addSubview:contentView];

        contentView.mediaViewDelegate = self;
        contentView.tweetLabelDelegate = self;

        contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [TWTRViewUtil addVisualConstraints:@"H:|[contentView]|" views:NSDictionaryOfVariableBindings(contentView)];
        [TWTRViewUtil addVisualConstraints:@"V:|[contentView]|" views:NSDictionaryOfVariableBindings(contentView)];

        contentView.primaryTextColor = self.primaryTextColor;
        [self updateComputedColorsForContentView:contentView];
        contentView.linkTextColor = self.linkTextColor;
        contentView.presenterViewController = self.presenterViewController;
        contentView.secondaryTextColor = [TWTRColorUtil secondaryTextColorFromPrimaryTextColor:self.primaryTextColor backgroundColor:self.backgroundColor];

        [contentView updateTweetTextWithTweet:tweet.quotedTweet];
        [contentView updateProfileHeaderWithTweet:tweet.quotedTweet];
        [contentView updateMediaWithTweet:tweet.quotedTweet aspectRatio:(16.0 / 10.0)];
        self.attachmentTopMarginConstraint.constant = self.metrics.marginTop;
        self.attachmentBottomMarginConstraint.constant = self.metrics.marginBottom;

        // Add a tap gesture
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(quoteTweetTapped)];
        tapGesture.delegate = self;
        [contentView addGestureRecognizer:tapGesture];

        self.attachmentContentView = contentView;
    } else {
        self.attachmentContentView = nil;
        self.attachmentTopMarginConstraint.constant = 0;
        self.attachmentBottomMarginConstraint.constant = 0;
    }
}

#pragma mark - Auto Layout
- (void)setupConstraints
{
    [TWTRViewUtil addVisualConstraints:@"[self(defaultWidth@750)]" metrics:self.metrics.metricsDictionary views:@{@"self": self}];

    [self setupContainerViewConstraints];
    [self setupActionBarConstraints];

    [TWTRViewUtil equateAttribute:NSLayoutAttributeLeft onView:[self.contentView alignmentLayoutGuide] toView:self.likeButton.imageView];

    // These constraints will have their constant updated every time configureWithTweet: is called
    NSArray *modifiableConstraints = @[self.actionsHeightConstraint, self.actionsBottomConstraint];
    [TWTRViewUtil setConstraints:modifiableConstraints active:YES];

    [self setNeedsUpdateConstraints];
}

- (void)setupContainerViewConstraints
{
    NSDictionary *views = @{@"content": self.contentView, @"attach": self.attachmentContainer, @"action": self.actionContainer};

    [TWTRViewUtil addVisualConstraints:@"H:|[content]|" views:views];

    [TWTRViewUtil equateAttribute:NSLayoutAttributeLeading onView:self.contentView.profileHeaderView.fullname toView:self.attachmentContainer];
    [TWTRViewUtil equateAttribute:NSLayoutAttributeTrailing onView:(UIView *)self.contentView.profileHeaderView.twitterLogo toView:self.attachmentContainer];

    _attachmentTopMarginConstraint = [TWTRViewUtil marginConstraintBetweenTopView:self.contentView bottomView:self.attachmentContainer];
    _attachmentBottomMarginConstraint = [TWTRViewUtil marginConstraintBetweenTopView:self.attachmentContainer bottomView:self.actionContainer];

    _attachmentTopMarginConstraint.active = YES;
    _attachmentBottomMarginConstraint.active = YES;

    [TWTRViewUtil addVisualConstraints:@"H:|[action]|" views:views];

    [TWTRViewUtil addVisualConstraints:@"V:|[content]" views:views];

    self.actionsBottomConstraint = [TWTRViewUtil constraintToBottomOfSuperview:self.actionContainer];
    self.actionsBottomConstraint.priority = UILayoutPriorityDefaultLow;  // This should be the constraint to break first
}

- (void)setupActionBarConstraints
{
    NSDictionary *views = @{@"like": self.likeButton, @"share": self.shareButton};

    [TWTRViewUtil addVisualConstraints:@"H:[like(40)]-30-[share(40)]" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom views:views];
    [TWTRViewUtil addVisualConstraints:@"V:[like]|" views:views];

    self.actionsHeightConstraint = [TWTRViewUtil constraintForAttribute:NSLayoutAttributeHeight onView:self.actionContainer value:0.0];
}

- (void)updateConstraints
{
    [super updateConstraints];
    [self updateConstraintConstants];
}

- (void)updateConstraintConstants
{
    BOOL show = self.showActionButtons;
    self.actionsHeightConstraint.constant = show ? self.metrics.actionsHeight : 0;
    self.actionsBottomConstraint.constant = show ? self.metrics.actionsBottomMargin : self.metrics.marginBottom;
}

- (void)playVideo
{
    if ([self.tweet isQuoteTweet] && [self.tweet.quotedTweet hasPlayableVideo]) {
        self.attachmentContentView.shouldPlayVideoMuted = self.shouldPlayVideoMuted;
        [self.attachmentContentView playVideo];
    } else if ([self.tweet hasPlayableVideo]) {
        self.contentView.shouldPlayVideoMuted = self.shouldPlayVideoMuted;
        [self.contentView playVideo];
    }
}

- (void)pauseVideo
{
    if ([self.tweet isQuoteTweet] && [self.tweet.quotedTweet hasPlayableVideo]) {
        [self.attachmentContentView pauseVideo];
    } else if ([self.tweet hasPlayableVideo]) {
        [self.contentView pauseVideo];
    }
}

#pragma mark - Button Handlers

- (void)backgroundTapped
{
    if (self.tweet) {
        [self handleTappingTweet:self.tweet];
    }
}

- (void)quoteTweetTapped
{
    if ([self tweetToDisplay].quotedTweet) {
        [self handleTappingTweet:[self tweetToDisplay].quotedTweet];
    }
}

- (void)handleTappingTweet:(TWTRTweet *)tweet
{
    if ([self.delegate respondsToSelector:@selector(tweetView:didTapTweet:)]) {
        [self.delegate tweetView:self didTapTweet:tweet];
    } else {
        [TWTRTweetDelegationHelper performDefaultActionForTappingTweet:tweet];
    }
    [TWTRNotificationCenter postNotificationName:TWTRDidSelectTweetNotification tweet:tweet userInfo:nil];
}

- (TWTRVideoMetaData *)videoMetaData
{
    return [self tweetToDisplay].videoMetaData;
}

#pragma mark - TWTRTweetLabelDelegate Methods

- (void)attributedLabel:(TWTRAttributedLabel *)label didTapTweetURLEntity:(TWTRTweetUrlEntity *)URLEntity
{
    NSURL *URL = [NSURL URLWithString:URLEntity.url];
    if ([self.delegate respondsToSelector:@selector(tweetView:didTapURL:)]) {
        [self.delegate tweetView:self didTapURL:URL];
    } else {
        [TWTRTweetDelegationHelper performDefaultActionForTappingURL:URL];
    }
}

- (void)attributedLabel:(TWTRAttributedLabel *)label didTapTweetHashtagEntity:(TWTRTweetHashtagEntity *)hashtagEntity
{
    [TWTRTweetDelegationHelper performDefaultActionForTappingHashtag:hashtagEntity];
}

- (void)attributedLabel:(TWTRAttributedLabel *)label didTapTweetCashtagEntity:(TWTRTweetCashtagEntity *)cashtagEntity
{
    [TWTRTweetDelegationHelper performDefaultActionForTappingCashtag:cashtagEntity];
}

- (void)attributedLabel:(TWTRAttributedLabel *)label didTapTweetUserMentionEntity:(TWTRTweetUserMentionEntity *)userMentionEntity
{
    [TWTRTweetDelegationHelper performDefaultActionForTappingUserMention:userMentionEntity];
}

#pragma mark - TWTRProfileHeaderViewDelegate

- (void)profileHeaderView:(TWTRProfileHeaderView *)headerView didTapProfileForUser:(TWTRUser *)user
{
    if ([self.delegate respondsToSelector:@selector(tweetView:didTapProfileImageForUser:)]) {
        [self.delegate tweetView:self didTapProfileImageForUser:user];
    } else {
        [TWTRTweetDelegationHelper performDefaultActionForTappingProfileForUser:user];
    }
}

- (void)setPresenterViewController:(UIViewController *)presenterViewController
{
    _presenterViewController = presenterViewController ?: [TWTRUtils topViewController];
    self.likeButton.presenterViewController = self.presenterViewController;
    self.shareButton.presenterViewController = self.presenterViewController;
    self.contentView.presenterViewController = self.presenterViewController;
}

#pragma mark - Media View Delegate

- (void)mediaViewDidSelectNonEmbeddableVideo:(TWTRTweetMediaView *)mediaView
{
    [TWTRTweetDelegationHelper performDefaultActionForTappingTweet:self.tweet];
}

- (BOOL)tweetMediaView:(TWTRTweetMediaView *)mediaView shouldPresentImageForMediaEntity:(TWTRTweetMediaEntity *)mediaEntity
{
    if ([self shouldAllowDelegateToHandlePresentationOfImageMediaEntity]) {
        [self allowDelegateToHandlePresentationOfImageMediaEntity:mediaEntity];
        return NO;
    }
    return YES;
}

- (BOOL)tweetMediaView:(TWTRTweetMediaView *)mediaView shouldPresentVideoForConfiguration:(TWTRVideoPlaybackConfiguration *)videoConfiguration
{
    if ([self shouldAllowDelegateToHandlePresentationOfVideo]) {
        [self allowDelegateToHandlePresentationOfVideo:videoConfiguration];
        return NO;
    }

    return YES;
}

- (void)tweetMediaView:(TWTRTweetMediaView *)mediaView didChangePlaybackState:(TWTRVideoPlaybackState)newState
{
    if ([self.delegate respondsToSelector:@selector(tweetView:didChangePlaybackState:)]) {
        [self.delegate tweetView:self didChangePlaybackState:newState];
    }
}

- (BOOL)shouldAllowDelegateToHandlePresentationOfImageMediaEntity
{
    return [self.delegate respondsToSelector:@selector(tweetView:didTapImage:withURL:)];
}

- (void)allowDelegateToHandlePresentationOfImageMediaEntity:(TWTRTweetMediaEntity *)mediaEntity
{
    NSURL *imageURL = [NSURL URLWithString:mediaEntity.mediaUrl];
    UIImage *image;

    // If the image we desire isn't from parent tweet, fetch image of its attachment contentView (its quote Tweet)
    if (self.tweet.isQuoteTweet && !self.tweet.hasMedia) {
        image = [self.attachmentContentView imageForMediaEntity:mediaEntity];
    } else {
        image = [self.contentView imageForMediaEntity:mediaEntity];
    }
    if (imageURL) {
        [self.delegate tweetView:self didTapImage:image withURL:imageURL];
    }
}

- (BOOL)shouldAllowDelegateToHandlePresentationOfVideo
{
    return [self.delegate respondsToSelector:@selector(tweetView:didTapVideoWithURL:)];
}

- (void)allowDelegateToHandlePresentationOfVideo:(TWTRVideoPlaybackConfiguration *)playbackConfig
{
    [self.delegate tweetView:self didTapVideoWithURL:playbackConfig.videoURL];
}

- (UIViewController *)viewControllerToPresentFromTweetMediaView:(TWTRTweetMediaView *)mediaView
{
    return self.presenterViewController;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return ![self.contentView didGestureRecognizerInteractWithEntity:gestureRecognizer] && ![self.attachmentContentView didGestureRecognizerInteractWithEntity:gestureRecognizer];
}

#pragma mark - Cleanup

- (void)dealloc
{
    [[TWTRStore sharedInstance] unsubscribeSubscriber:self fromClass:[TWTRTweet class] objectID:self.tweet.tweetID];
}

@end
