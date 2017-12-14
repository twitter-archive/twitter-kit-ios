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

#import "TWTRTweetContentViewLayoutFactory.h"
#import "TWTRFontUtil.h"
#import "TWTRProfileHeaderView.h"
#import "TWTRTweetContentView+Layout.h"
#import "TWTRTweetContentView.h"
#import "TWTRTweetLabel.h"
#import "TWTRTweetMediaView.h"
#import "TWTRTweetViewMetrics.h"
#import "TWTRViewUtil.h"

@interface TWTRTweetContentViewLayoutCompact : NSObject <TWTRTweetContentViewLayout>

@property (nonatomic, readonly) TWTRTweetViewMetrics *metrics;
@property (nonatomic, readonly) NSLayoutConstraint *imageTopConstraint;

@end

@interface TWTRTweetContentViewLayoutRegular : NSObject <TWTRTweetContentViewLayout>

@property (nonatomic, readonly) TWTRTweetViewMetrics *metrics;
@property (nonatomic, readonly) NSLayoutConstraint *imageBottomConstraint;

@end

@interface TWTRTweetContentViewLayoutQuote : NSObject <TWTRTweetContentViewLayout>

@property (nonatomic, readonly) TWTRTweetViewMetrics *metrics;

@end

@implementation TWTRTweetContentViewLayoutCompact

- (instancetype)initWithMetrics:(TWTRTweetViewMetrics *)metrics
{
    self = [super init];
    if (self) {
        _metrics = metrics;
    }
    return self;
}

- (TWTRTweetViewStyle)tweetViewStyle
{
    return TWTRTweetViewStyleCompact;
}

- (UIFont *)fontForTweetLabel
{
    return [TWTRFontUtil tweetFontForStyle:TWTRTweetViewStyleCompact];
}

- (BOOL)allowsMediaCornerRounding
{
    return YES;
}

- (void)applyConstraintsForContentView:(TWTRTweetContentView *)contentView
{
    NSDictionary *views = @{
        @"media": contentView.mediaView,
        @"profileHeader": contentView.profileHeaderView,
        @"text": contentView.tweetLabel,
    };

    NSDictionary *metrics = self.metrics.metricsDictionary;

    // TODO: When we drop iOS 8 use UILayoutGuides

    // Horizontal
    [TWTRViewUtil addVisualConstraints:@"H:|-profileMarginLeft-[profileHeader]-defaultMargin-|" metrics:metrics views:views];
    [TWTRViewUtil addVisualConstraints:@"H:[text]-defaultMargin-|" metrics:metrics views:views];
    [TWTRViewUtil addVisualConstraints:@"H:[media]-defaultMargin-|" metrics:metrics views:views];
    [TWTRViewUtil equateAttribute:NSLayoutAttributeLeading onView:contentView.profileHeaderView.fullname toView:contentView.tweetLabel];

    // Vertical
    [TWTRViewUtil addVisualConstraints:@"V:|-[profileHeader]-(>=0)-|" metrics:metrics views:views];
    [TWTRViewUtil addVisualConstraints:@"V:[fullname]-4-[text]" views:@{@"fullname": contentView.profileHeaderView.fullname, @"text": contentView.tweetLabel}];
    [TWTRViewUtil addVisualConstraints:@"V:[text]->=0-[media]|" options:NSLayoutFormatAlignAllLeading metrics:metrics views:views];

    _imageTopConstraint = [TWTRViewUtil marginConstraintBetweenTopView:contentView.tweetLabel bottomView:contentView.mediaView];
    _imageTopConstraint.active = YES;
}

- (void)setShowingMedia:(BOOL)showingMedia
{
    self.imageTopConstraint.constant = showingMedia ? self.metrics.imageMarginTop : 0;
}

- (CGSize)sizeThatFits:(CGSize)size forContentView:(TWTRTweetContentView *)contentView
{
    CGFloat height = 0.0;
    CGFloat width = size.width - self.metrics.profileMarginLeft - self.metrics.defaultMargin - self.metrics.profileMarginRight - self.metrics.profileImageSize;

    height += self.metrics.defaultAutolayoutMargin;
    height += [contentView.profileHeaderView sizeThatFits:size].height;
    height += [contentView.tweetLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)].height;
    height += [contentView.mediaView sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)].height;
    height += (contentView.mediaView.aspectRatio == 0.0) ? 0.0 : self.metrics.imageMarginTop;
    return CGSizeMake(size.width, height);
}

@end

@implementation TWTRTweetContentViewLayoutRegular

- (instancetype)initWithMetrics:(TWTRTweetViewMetrics *)metrics
{
    self = [super init];
    if (self) {
        _metrics = metrics;
    }
    return self;
}

- (TWTRTweetViewStyle)tweetViewStyle
{
    return TWTRTweetViewStyleRegular;
}

- (UIFont *)fontForTweetLabel
{
    return [TWTRFontUtil tweetFontForStyle:TWTRTweetViewStyleRegular];
}

- (BOOL)allowsMediaCornerRounding
{
    return YES;
}

- (void)applyConstraintsForContentView:(TWTRTweetContentView *)contentView
{
    NSDictionary *views = @{
        @"media": contentView.mediaView,
        @"profileHeader": contentView.profileHeaderView,
        @"text": contentView.tweetLabel,
    };

    NSDictionary *metrics = self.metrics.metricsDictionary;

    // TODO: When we drop iOS 8 use UILayoutGuides

    // Horizontal
    [TWTRViewUtil addVisualConstraints:@"H:|-regularMargin-[profileHeader]|" metrics:metrics views:views];

    [TWTRViewUtil addVisualConstraints:@"H:|-regularMargin-[text]-|" metrics:metrics views:views];
    [TWTRViewUtil addVisualConstraints:@"H:|[media]|" views:views];  // Main image full width

    // Vertical
    [TWTRViewUtil constraintToTopOfSuperview:contentView.mediaView].active = YES;
    _imageBottomConstraint = [TWTRViewUtil marginConstraintBetweenTopView:contentView.mediaView bottomView:contentView.profileHeaderView];
    _imageBottomConstraint.constant = self.metrics.marginTop;
    [TWTRViewUtil addVisualConstraints:@"V:[profileHeader]-profileHeaderMarginBottom-[text]" metrics:metrics views:views];
    [TWTRViewUtil addVisualConstraints:@"V:[text]|" views:views];

    _imageBottomConstraint.active = YES;
}

- (void)setShowingMedia:(BOOL)showingMedia
{
    /* Intentionally Blank */
}

- (CGSize)sizeThatFits:(CGSize)size forContentView:(TWTRTweetContentView *)contentView
{
    CGFloat height = 0.0;
    height += self.metrics.marginTop;
    height += [contentView.profileHeaderView sizeThatFits:CGSizeMake(size.width - self.metrics.regularMargin, CGFLOAT_MAX)].height;
    height += [contentView.tweetLabel sizeThatFits:CGSizeMake(size.width - self.metrics.regularMargin - self.metrics.defaultAutolayoutMargin, CGFLOAT_MAX)].height;
    height += [contentView.mediaView sizeThatFits:size].height;
    return CGSizeMake(size.width, height);
}

@end

@implementation TWTRTweetContentViewLayoutQuote

- (instancetype)initWithMetrics:(TWTRTweetViewMetrics *)metrics
{
    self = [super init];
    if (self) {
        _metrics = metrics;
    }
    return self;
}

- (TWTRTweetViewStyle)tweetViewStyle
{
    return TWTRTweetViewStyleCompact;
}

- (UIFont *)fontForTweetLabel
{
    return [TWTRFontUtil tweetFontForStyle:TWTRTweetViewStyleCompact];
}

- (BOOL)allowsMediaCornerRounding
{
    return NO;
}

- (void)applyConstraintsForContentView:(TWTRTweetContentView *)contentView
{
    contentView.profileHeaderView.showsTimestamp = NO;
    contentView.profileHeaderView.showsTwitterLogo = NO;
    contentView.profileHeaderView.showProfileThumbnail = NO;

    NSDictionary *views = @{
        @"media": contentView.mediaView,
        @"user": contentView.profileHeaderView.userName,
        @"name": contentView.profileHeaderView.fullname,
        @"profileHeader": contentView.profileHeaderView,
        @"text": contentView.tweetLabel,
    };

    NSDictionary *metrics = self.metrics.metricsDictionary;

    // TODO: When we drop iOS 8 use UILayoutGuides

    // Horizontal
    [TWTRViewUtil addVisualConstraints:@"H:|-profileMarginRight-[profileHeader]" metrics:metrics views:views];
    [TWTRViewUtil addVisualConstraints:@"H:[profileHeader]-defaultMargin-|" metrics:metrics views:views];

    [TWTRViewUtil addVisualConstraints:@"H:[text]-defaultMargin-|" metrics:metrics views:views];
    [TWTRViewUtil addVisualConstraints:@"H:|[media]|" metrics:metrics views:views];
    [TWTRViewUtil equateAttribute:NSLayoutAttributeLeading onView:contentView.profileHeaderView.fullname toView:contentView.tweetLabel];

    // Vertical
    [TWTRViewUtil addVisualConstraints:@"V:|-[profileHeader]-(>=0)-|" metrics:metrics views:views];
    [TWTRViewUtil addVisualConstraints:@"V:[name]-fullnameMarginBottom-[text]" metrics:metrics views:views];
    [TWTRViewUtil addVisualConstraints:@"V:[text]-imageMarginTop-[media]|" metrics:metrics views:views];
}

- (void)setShowingMedia:(BOOL)showingMedia
{
    /* Intentionally Blank */
}

- (CGSize)sizeThatFits:(CGSize)size forContentView:(TWTRTweetContentView *)contentView
{
    CGFloat height = 0.0;
    /*
     * First profileMarginRight comes from constraints set above (between the superview and the profileHeader).
     * Second profileMarginRight comes from constraints set in TWTRProfileHeaderView.
     */
    CGFloat width = size.width - self.metrics.defaultMargin - 2.0 * self.metrics.profileMarginRight;
    CGSize constrainedSize = CGSizeMake(width, CGFLOAT_MAX);

    height += self.metrics.defaultAutolayoutMargin;
    height += [contentView.profileHeaderView sizeThatFits:size].height;
    height += [contentView.tweetLabel sizeThatFits:constrainedSize].height;
    height += [contentView.mediaView sizeThatFits:size].height;
    height += self.metrics.imageMarginTop;

    return CGSizeMake(size.width, height);
}

@end

@implementation TWTRTweetContentViewLayoutFactory

+ (id<TWTRTweetContentViewLayout>)compactTweetViewLayoutWithMetrics:(TWTRTweetViewMetrics *)metrics
{
    return [[TWTRTweetContentViewLayoutCompact alloc] initWithMetrics:metrics];
}

+ (id<TWTRTweetContentViewLayout>)regularTweetViewLayoutWithMetrics:(TWTRTweetViewMetrics *)metrics
{
    return [[TWTRTweetContentViewLayoutRegular alloc] initWithMetrics:metrics];
    ;
}

+ (id<TWTRTweetContentViewLayout>)quoteTweetViewLayoutWithMetrics:(TWTRTweetViewMetrics *)metrics
{
    return [[TWTRTweetContentViewLayoutQuote alloc] initWithMetrics:metrics];
}

@end
