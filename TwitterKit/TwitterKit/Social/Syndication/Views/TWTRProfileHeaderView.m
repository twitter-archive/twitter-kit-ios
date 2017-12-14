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

#import "TWTRProfileHeaderView.h"
#import <TwitterCore/TWTRColorUtil.h>
#import "TWTRBirdView.h"
#import "TWTRFontUtil.h"
#import "TWTRProfileView.h"
#import "TWTRRetweetView.h"
#import "TWTRTimestampLabel.h"
#import "TWTRTweet.h"
#import "TWTRTweetPresenter.h"
#import "TWTRTweetViewMetrics.h"
#import "TWTRTwitter_Private.h"
#import "TWTRUser.h"
#import "TWTRVerifiedView.h"
#import "TWTRViewUtil.h"

@interface TWTRProfileHeaderView ()

@property (nonatomic) TWTRTweet *tweet;
@property (nonatomic) TWTRTweet *tweetToDisplay;
@property (nonatomic) TWTRUser *user;
@property (nonatomic) TWTRTweetViewStyle style;
@property (nonatomic) TWTRTweetViewMetrics *metrics;
@property (nonatomic) TWTRTweetPresenter *tweetPresenter;

@property (nonatomic) TWTRBirdView *twitterLogo;
@property (nonatomic) TWTRRetweetView *retweetView;
@property (nonatomic) TWTRVerifiedView *verified;
@property (nonatomic) UILabel *userName;

@property (nonatomic) NSLayoutConstraint *retweetHeightConstraint;
@property (nonatomic) NSLayoutConstraint *retweetBottomConstraint;

/**
 * Constraints which define the distance from the edge of the view to the name view.
 */
@property (nonatomic) NSLayoutConstraint *displayThumbnailEdgeConstraint;
@property (nonatomic) NSLayoutConstraint *hideThumbnailEdgeConstraint;
@end

@implementation TWTRProfileHeaderView

- (instancetype)initWithStyle:(TWTRTweetViewStyle)style
{
    if (self = [super init]) {
        _metrics = [[TWTRTweetViewMetrics alloc] init];
        _style = style;
        _tweetPresenter = [TWTRTweetPresenter presenterForStyle:style];
        _calculationOnly = NO;

        _showsTwitterLogo = YES;
        _showsTimestamp = YES;
        _showProfileThumbnail = YES;

        // Custom Views
        _verified = [[TWTRVerifiedView alloc] init];
        _profileThumbnail = [[TWTRProfileView alloc] init];
        _profileThumbnail.userInteractionEnabled = YES;
        _retweetView = [[TWTRRetweetView alloc] init];
        _twitterLogo = [TWTRBirdView smallBird];
        _timestamp = [[TWTRTimestampLabel alloc] init];
        _timestamp.font = [TWTRFontUtil timestampFontForStyle:style];

        // Username
        _userName = [[UILabel alloc] init];
        _userName.font = [TWTRFontUtil usernameFontForStyle:style];
        [_userName setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [_userName setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

        // Fullname
        _fullname = [[UILabel alloc] init];
        _fullname.font = [TWTRFontUtil fullnameFont];
        [_fullname setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [_fullname setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

        [self bringSubviewToFront:self.twitterLogo];
        [self configureWithTweet:nil];
        self.backgroundColor = [UIColor clearColor];

        [self setupConstraints];
        [self setupGestureRecognizers];
    }
    return self;
}

- (void)setupGestureRecognizers
{
    UITapGestureRecognizer *profileTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTapped)];
    [self.profileThumbnail addGestureRecognizer:profileTapGesture];
}

- (void)configureWithTweet:(TWTRTweet *)tweet
{
    // Developers sometimes call configure again just to update the timestamp
    self.timestamp.date = tweet.createdAt;

    // Don't bother updating views a second time for the same Tweet
    if ([tweet isEqual:_tweet]) {
        return;
    }

    self.tweet = tweet;
    self.tweetToDisplay = tweet.isRetweet ? tweet.retweetedTweet : tweet;
    self.user = self.tweetToDisplay.author;

    // Subviews
    if (self.user) {
        self.fullname.text = self.tweetToDisplay.author.name;
        self.userName.text = [NSString stringWithFormat:@"@%@", self.tweetToDisplay.author.screenName];
    } else {
        self.fullname.text = @"";
        self.userName.text = @"";
    }
    self.verified.hidden = ![self shouldDisplayVerifiedBadge];
    self.retweetView.textLabel.text = [self.tweetPresenter retweetedByTextForRetweet:tweet];
    self.retweetView.hidden = !self.tweet.isRetweet;

    [self updateConstraintConstants];
    [self loadProfileThumbnail];

    self.timestamp.hidden = !self.showsTimestamp;
    self.twitterLogo.hidden = !self.showsTwitterLogo;
    if (!self.showsTimestamp) {
        [self.timestamp removeFromSuperview];
    }
}

- (BOOL)shouldDisplayVerifiedBadge
{
    BOOL isVerified = self.user.isVerified;
    BOOL isRegular = (self.style == TWTRTweetViewStyleRegular);

    return (isVerified && isRegular);
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat height = 0.0;

    if (self.style == TWTRTweetViewStyleCompact) {
        CGFloat width = size.width - self.metrics.profileMarginLeft - self.metrics.defaultMargin - self.metrics.profileImageSize - self.metrics.profileMarginRight;

        height += [self.fullname sizeThatFits:CGSizeMake(width, height)].height;
        height += self.metrics.fullnameMarginBottom;
    } else {
        height += self.metrics.profileImageSize + self.metrics.profileHeaderMarginBottom;
    }

    if (self.tweet.isRetweet) {
        height += [self.retweetView.textLabel sizeThatFits:size].height;
        height += self.metrics.retweetMargin;
    }

    return CGSizeMake(size.width, height);
}

#pragma mark - Constraints

- (NSDictionary *)autoLayoutViews
{
    return @{
        @"fullname": self.fullname,
        @"username": self.userName,
        @"verified": self.verified,
        @"thumbnail": self.profileThumbnail,
        @"timestamp": self.timestamp,
        @"bird": self.twitterLogo,
        @"retweet": self.retweetView,
    };
}

- (void)setupConstraints
{
    NSDictionary *views = [self autoLayoutViews];

    // Add subviews
    for (UIView *view in [views allValues]) {
        [self addSubview:view];
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    }

    // Horizontal
    [TWTRViewUtil equateAttribute:NSLayoutAttributeLeading onView:self.retweetView.textLabel toView:self.fullname];

    _displayThumbnailEdgeConstraint = [NSLayoutConstraint constraintWithItem:self.profileThumbnail attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];

    _hideThumbnailEdgeConstraint = [NSLayoutConstraint constraintWithItem:self.profileThumbnail attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];

    _displayThumbnailEdgeConstraint.active = YES;

    // Vertical
    self.retweetHeightConstraint = [TWTRViewUtil constraintForAttribute:NSLayoutAttributeHeight onView:self.retweetView value:0];
    self.retweetHeightConstraint.active = YES;
    self.retweetBottomConstraint = [TWTRViewUtil marginConstraintBetweenTopView:self.retweetView bottomView:self.fullname];
    self.retweetBottomConstraint.active = YES;

    if (self.style == TWTRTweetViewStyleRegular) {
        [self setupRegularConstraints];
    } else {
        [self setupCompactConstraints];
    }
}

- (void)setupCompactConstraints
{
    NSDictionary *views = [self autoLayoutViews];
    NSDictionary *metrics = self.metrics.metricsDictionary;

    // Horizontal
    [TWTRViewUtil addVisualConstraints:@"H:[thumbnail]-profileMarginRight-[fullname]-4-[username][timestamp]" metrics:metrics views:views];
    [TWTRViewUtil addVisualConstraints:@"H:[timestamp]-(>=8)-[bird]|" metrics:metrics views:views];
    [TWTRViewUtil addVisualConstraints:@"H:[username]-(>=0)-|" metrics:metrics views:views];

    // Vertical
    [TWTRViewUtil equateAttribute:NSLayoutAttributeTop onView:self.profileThumbnail toView:self.fullname];
    [TWTRViewUtil equateAttribute:NSLayoutAttributeBaseline onView:self.fullname toView:self.userName];
    [TWTRViewUtil equateAttribute:NSLayoutAttributeBaseline onView:self.fullname toView:self.timestamp];
    [TWTRViewUtil addVisualConstraints:@"V:|[retweet]" views:views];
    [TWTRViewUtil addVisualConstraints:@"V:[thumbnail]|" views:views];
    [TWTRViewUtil addVisualConstraints:@"V:|[bird]" views:views];
}

- (void)setupRegularConstraints
{
    NSDictionary *views = [self autoLayoutViews];
    NSDictionary *metrics = self.metrics.metricsDictionary;

    // Horizontal
    [TWTRViewUtil addVisualConstraints:@"H:[thumbnail]-profileMarginRight-[fullname]" metrics:metrics views:views];
    [TWTRViewUtil addVisualConstraints:@"H:[fullname]-(>=4)-[bird]-regularMargin-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views];  // Top tweet meta info + logo
    [TWTRViewUtil addVisualConstraints:@"H:[username][timestamp]-(>=20)-|" options:NSLayoutFormatAlignAllCenterY views:views];                           // Second tweet meta info

    // Vertical
    [TWTRViewUtil addVisualConstraints:@"V:[fullname][username]|" options:NSLayoutFormatAlignAllLeading metrics:metrics views:views];
    [TWTRViewUtil addVisualConstraints:@"V:|[retweet]" views:views];
    // Align bottom of fullname to middle of profile
    [NSLayoutConstraint constraintWithItem:self.fullname attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.profileThumbnail attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;

    [TWTRViewUtil addVisualConstraints:@"H:[fullname][verified]" options:NSLayoutFormatAlignAllCenterY views:views];
}

- (void)updateConstraintConstants
{
    BOOL isRetweet = self.tweet.isRetweet;
    CGFloat retweetHeight = [self.retweetView.textLabel intrinsicContentSize].height;
    self.retweetHeightConstraint.constant = isRetweet ? retweetHeight : 0;
    self.retweetBottomConstraint.constant = isRetweet ? self.metrics.retweetMargin : 0;
}

#pragma mark - Colors

- (void)setPrimaryTextColor:(UIColor *)primaryTextColor
{
    self.fullname.textColor = primaryTextColor;
}

- (void)setSecondaryTextColor:(UIColor *)color
{
    self.userName.textColor = color;
    self.retweetView.textLabel.textColor = color;
    self.timestamp.textColor = color;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];

    self.fullname.backgroundColor = backgroundColor;
    self.userName.backgroundColor = backgroundColor;
    self.timestamp.backgroundColor = backgroundColor;
    self.retweetView.backgroundColor = backgroundColor;
    self.twitterLogo.birdColor = [TWTRColorUtil logoColorFromBackgroundColor:backgroundColor];
}

- (void)setShowProfileThumbnail:(BOOL)showProfileThumbnail
{
    if (showProfileThumbnail == _showProfileThumbnail) {
        return;
    }

    _showProfileThumbnail = showProfileThumbnail;

    self.displayThumbnailEdgeConstraint.active = showProfileThumbnail;
    self.hideThumbnailEdgeConstraint.active = !showProfileThumbnail;
    self.profileThumbnail.hidden = !showProfileThumbnail;
}

- (void)prepareForReuse
{
    // Cancel profile image load
}

- (void)loadProfileThumbnail
{
    self.profileThumbnail.image = nil;
    self.profileThumbnail.alpha = 0.5;
    BOOL missingUser = (self.user == nil);
    if (missingUser || self.calculationOnly) {
        return;
    }

    NSString *userID = [self.user.userID copy];
    if (self.user.profileImageLargeURL) {
        NSURL *profileImageURL = [NSURL URLWithString:self.user.profileImageLargeURL];
        @weakify(self);
        [[[TWTRTwitter sharedInstance] imageLoader] fetchImageWithURL:profileImageURL
                                                           completion:^(UIImage *image, NSError *error) {
                                                               @strongify(self);

                                                               if (error) {
                                                                   NSLog(@"[TwitterKit] Could not load image: %@", error);
                                                               }

                                                               const BOOL sameAuthorAsRequested = [userID isEqualToString:self.user.userID];

                                                               if (self && sameAuthorAsRequested && image) {
                                                                   self.profileThumbnail.image = image;
                                                                   self.profileThumbnail.alpha = 1.0;
                                                               }
                                                           }];
    }
}

- (void)profileTapped
{
    if ([self.delegate respondsToSelector:@selector(profileHeaderView:didTapProfileForUser:)]) {
        [self.delegate profileHeaderView:self didTapProfileForUser:self.user];
    }
}

@end
