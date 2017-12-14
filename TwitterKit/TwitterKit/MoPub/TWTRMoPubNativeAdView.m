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

#import "TWTRMoPubNativeAdView.h"
#import <MoPub/MPNativeAd.h>
#import <TwitterCore/TWTRColorUtil.h>
#import <UIKit/UIKit.h>
#import "TWTRFontUtil.h"
#import "TWTRTranslationsUtil.h"
#import "TWTRViewUtil.h"

static const CGFloat TWTRMoPubAdViewIconWidth = 34.0;
static const CGFloat TWTRMoPubAdViewMargin = 10.0;
// This is a requirement and should not be changed.
static const CGFloat TWTRMoPubNativeAdFixedImageRatio = 1.91;  // W:H
static const CGFloat TWTRMoPubNativeAdIconCornerRadius = 3.0;
static const CGFloat TWTRMoPubNativeAdViewCornerRadius = 5.0;
static const CGFloat TWTRMoPubNativeAdViewCTAButtonHeight = 44.0;

@interface TWTRMoPubNativeAdView () <UIGestureRecognizerDelegate>

@property (nonatomic) UIColor *savedCallToActionBackgroundColor;

@end

@implementation TWTRMoPubNativeAdView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
        [self prepareLayout];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
        [self prepareLayout];
    }
    return self;
}

- (void)commonInit
{
    _titleTextLabel = [[UILabel alloc] init];
    _titleTextLabel.font = [TWTRFontUtil adTitleFont];

    _mainTextLabel = [[UILabel alloc] init];
    _mainTextLabel.font = [TWTRFontUtil adBodyFont];
    _mainTextLabel.numberOfLines = 0;
    _mainTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [_mainTextLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [_mainTextLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

    _callToActionTextLabel = [[UILabel alloc] init];
    _callToActionTextLabel.backgroundColor = [TWTRColorUtil lightBlueColor];
    _callToActionTextLabel.textColor = [TWTRColorUtil whiteColor];
    _callToActionTextLabel.font = [TWTRFontUtil largeBoldSystemFont];
    _callToActionTextLabel.textAlignment = NSTextAlignmentCenter;
    _callToActionTextLabel.userInteractionEnabled = YES;  // for onTap gesture recognizer
    [_callToActionTextLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [_callToActionTextLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

    _iconImageView = [[UIImageView alloc] init];
    _iconImageView.clipsToBounds = YES;
    _iconImageView.layer.cornerRadius = TWTRMoPubNativeAdIconCornerRadius;

    _mainImageView = [[UIImageView alloc] init];

    NSArray *subviews = @[_titleTextLabel, _mainTextLabel, _callToActionTextLabel, _iconImageView, _mainImageView];
    [subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        subview.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:subview];
    }];

    self.clipsToBounds = YES;
    self.layer.cornerRadius = TWTRMoPubNativeAdViewCornerRadius;

    [self prepareCTAGestureRecognizer];
    [self setUpAccessibility];
}

#pragma mark - Accessibility

- (NSString *)accessibilityLabel
{
    NSArray<NSString *> *textItems = @[TWTRLocalizedString(@"tw__view_is_sponsored_ad"), self.titleTextLabel.accessibilityLabel ?: @"", self.mainTextLabel.accessibilityLabel ?: @"", self.callToActionTextLabel.accessibilityLabel ?: @""];
    return [TWTRTranslationsUtil accessibilityStringByConcatenatingItems:textItems];
}

- (void)setUpAccessibility
{
    self.accessibilityTraits = [super accessibilityTraits] | UIAccessibilityTraitButton;
}

- (BOOL)isAccessibilityElement
{
    return YES;
}

#pragma mark - Layout

- (void)prepareLayout
{
    [self prepareImageHeader];
    [self prepareIcon];
    [self prepareTextContent];
    [self prepareCallToAction];
}

- (void)prepareImageHeader
{
    [TWTRViewUtil constraintToTopOfSuperview:self.mainImageView].active = YES;
    [TWTRViewUtil addVisualConstraints:@"H:|[image]|" views:[self subviewsMapping]];
    [TWTRViewUtil constraintForAspectRatio:TWTRMoPubNativeAdFixedImageRatio onView:self.mainImageView].active = YES;
}

- (void)prepareIcon
{
    NSDictionary<NSString *, UIView *> *subviews = [self subviewsMapping];
    [TWTRViewUtil addVisualConstraints:@"V:[image]-margin-[icon]" metrics:@{ @"margin": @(TWTRMoPubAdViewMargin) } views:subviews];
    [TWTRViewUtil addVisualConstraints:@"H:|-margin-[icon(iconWidth)]" metrics:@{ @"margin": @(TWTRMoPubAdViewMargin), @"iconWidth": @(TWTRMoPubAdViewIconWidth) } views:subviews];
    [TWTRViewUtil constraintForAspectRatio:1.0 onView:self.iconImageView].active = YES;
}

- (void)prepareTextContent
{
    NSDictionary<NSString *, UIView *> *subviews = [self subviewsMapping];
    NSDictionary<NSString *, NSNumber *> *metrics = @{ @"margin": @(TWTRMoPubAdViewMargin), @"titleMarginTop": @12, @"titleMarginBottom": @2 };

    [NSLayoutConstraint constraintWithItem:self.titleTextLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.iconImageView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;

    [TWTRViewUtil addVisualConstraints:@"H:[icon]-margin-[title]-margin-|" metrics:metrics views:subviews];
    [TWTRViewUtil addVisualConstraints:@"H:[text]-margin-|" metrics:metrics views:subviews];
    [TWTRViewUtil addVisualConstraints:@"V:[image]-titleMarginTop-[title]" metrics:metrics views:subviews];
    [TWTRViewUtil addVisualConstraints:@"V:[title]-titleMarginBottom-[text]" options:NSLayoutFormatAlignAllLeading metrics:metrics views:subviews];
}

- (void)prepareCallToAction
{
    NSDictionary<NSString *, UIView *> *subviews = [self subviewsMapping];
    NSDictionary<NSString *, NSNumber *> *metrics = @{ @"margin": @(TWTRMoPubAdViewMargin), @"buttonHeight": @(TWTRMoPubNativeAdViewCTAButtonHeight) };

    [TWTRViewUtil addVisualConstraints:@"H:|[cta]|" views:subviews];
    // make sure cta is at least margin below the icon or the main text
    [TWTRViewUtil addVisualConstraints:@"V:[text]-(>=margin)-[cta(buttonHeight)]|" metrics:metrics views:subviews];
    [TWTRViewUtil addVisualConstraints:@"V:[icon]-(>=margin)-[cta]|" metrics:metrics views:subviews];
}

// Handle multi-line sizing issues (http://www.objc.io/issue-3/advanced-auto-layout-toolbox.html )
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.mainTextLabel.preferredMaxLayoutWidth = self.mainTextLabel.frame.size.width;
}

#pragma mark - Gesture Recognizers

// MoPub needs to inject CTA text when ready and requires a UILabel to do so. Set up
// a long press gesture recognizer to make the label still behave like a button and
// change backgroundColor on tap
- (void)prepareCTAGestureRecognizer
{
    UILongPressGestureRecognizer *longPressOnCTA = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressCTA:)];
    longPressOnCTA.minimumPressDuration = 0.001;  // mimic simple tap event
    longPressOnCTA.cancelsTouchesInView = NO;
    longPressOnCTA.delegate = self;
    [self.callToActionTextLabel addGestureRecognizer:longPressOnCTA];
}

- (void)handleLongPressCTA:(UILongPressGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateCancelled: {
            self.savedCallToActionBackgroundColor = self.callToActionTextLabel.backgroundColor;
            if ([TWTRColorUtil isLightColor:self.callToActionTextLabel.backgroundColor]) {
                self.callToActionTextLabel.backgroundColor = [TWTRColorUtil darkerColorForColor:self.savedCallToActionBackgroundColor lightnessLevel:0.1];
            } else {
                self.callToActionTextLabel.backgroundColor = [TWTRColorUtil lighterColorForColor:self.savedCallToActionBackgroundColor lightnessLevel:0.2];
            }
        } break;
        case UIGestureRecognizerStateEnded: {
            self.callToActionTextLabel.backgroundColor = self.savedCallToActionBackgroundColor;
            self.savedCallToActionBackgroundColor = nil;
        } break;
        default:
            break;
    }
}

// This is necessary for MoPub's ad view tap gesture recognizer to still bring
// up the ad modal
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return gestureRecognizer.view == self.callToActionTextLabel;
    }
    return NO;
}

#pragma mark - Theming

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];

    self.titleTextLabel.backgroundColor = backgroundColor;
    self.mainTextLabel.backgroundColor = backgroundColor;
    self.iconImageView.backgroundColor = backgroundColor;
    self.mainImageView.backgroundColor = backgroundColor;
}

#pragma mark - Helpers

- (NSDictionary<NSString *, UIView *> *)subviewsMapping
{
    return @{ @"icon": self.iconImageView, @"title": self.titleTextLabel, @"text": self.mainTextLabel, @"image": self.mainImageView, @"cta": self.callToActionTextLabel };
}

@end
