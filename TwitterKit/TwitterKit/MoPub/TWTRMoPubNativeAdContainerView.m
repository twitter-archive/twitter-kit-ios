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

#import "TWTRMoPubNativeAdContainerView.h"
#import <MoPub/MPNativeAdRendering.h>
#import <TwitterCore/TWTRColorUtil.h>
#import "TWTRMoPubAdDisclaimerView.h"
#import "TWTRMoPubNativeAdView.h"
#import "TWTRViewUtil.h"

static const CGFloat TWTRMoPubAdContainerViewPadding = 15.0;
static const CGFloat TWTRMoPubAdContainerViewAdViewCornerRadius = 4.0;
static const CGFloat TWTRMoPubAdViewBorderWidth = 0.5;

/**
 *  The container view around TwitterKit's custom native MoPub ad view. This
 *  serves as the container around the card style ad.
 *  This is required because our design calls for different background
 *  color than what the table view cell is configured as but the custom ad view
 *  doesn't have visibility into that the way custom ad view classes are
 *  registered with your MoPub renderer settings.
 *
 *  `TWTRMoPubNativeAdContainerView` conforms to `UIAppearanceContainer` acting as a proxy to manage
 *  themeable view properties of the ad cell and its underlying ad view(s). Conforming to `UIAppearanceContainer`
 *  also works around the lack of access to `TWTRMoPubNativeAdContainerView` during ad initialization.
 */
@interface TWTRMoPubNativeAdContainerView () <MPNativeAdRendering>

@property (nonatomic, readonly, nonnull) TWTRMoPubNativeAdView *adView;
@property (nonatomic, readonly, nonnull) TWTRMoPubAdDisclaimerView *disclaimerView;

// Theming support properties
@property (nonatomic) BOOL doneInitializing;

@end

@implementation TWTRMoPubNativeAdContainerView

#pragma mark - Initialization

+ (void)initialize
{
    if (self == [TWTRMoPubNativeAdContainerView class]) {
        [[self appearance] setTheme:TWTRNativeAdThemeLight];
    }
}

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
        _doneInitializing = YES;
    }
    return self;
}

- (void)commonInit
{
    _adView = [[TWTRMoPubNativeAdView alloc] init];
    _adView.layer.cornerRadius = TWTRMoPubAdContainerViewAdViewCornerRadius;
    _adView.layer.borderWidth = TWTRMoPubAdViewBorderWidth;
    _adView.clipsToBounds = YES;
    _disclaimerView = [[TWTRMoPubAdDisclaimerView alloc] init];
    [@[_adView, _disclaimerView] enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        subview.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:subview];
    }];

    [self prepareLayout];
    [self setUpAccessibility];
}

#pragma mark - Layout

- (void)prepareLayout
{
    NSDictionary<NSString *, UIView *> *subviews = @{ @"adView": self.adView, @"disclaimer": self.disclaimerView };
    NSDictionary<NSString *, NSNumber *> *metrics = @{ @"padding": @(TWTRMoPubAdContainerViewPadding) };

    [TWTRViewUtil addVisualConstraints:@"H:|-padding-[adView]-padding-|" metrics:metrics views:subviews];
    [TWTRViewUtil addVisualConstraints:@"V:|-padding-[adView]-13-[disclaimer]-padding-|" metrics:metrics views:subviews];
    [TWTRViewUtil equateAttribute:NSLayoutAttributeLeading onView:self.disclaimerView toView:self.adView constant:0.0];
}

#pragma mark - UIAccessibilityContainer

- (void)setUpAccessibility
{
    self.accessibilityElements = @[self.adView, self.disclaimerView];
}

#pragma mark - MPNativeAdRendering Protocol

- (UILabel *)nativeMainTextLabel
{
    return self.adView.mainTextLabel;
}

- (UILabel *)nativeTitleTextLabel
{
    return self.adView.titleTextLabel;
}

- (UILabel *)nativeCallToActionTextLabel
{
    return self.adView.callToActionTextLabel;
}

- (UIImageView *)nativeIconImageView
{
    return self.adView.iconImageView;
}

- (UIImageView *)nativeMainImageView
{
    return self.adView.mainImageView;
}

- (UIImageView *)nativePrivacyInformationIconImageView
{
    return self.disclaimerView.privacyInfoIcon;
}

#pragma mark - Theming / UIAppearance

- (void)setTheme:(TWTRNativeAdTheme)theme
{
    theme = (theme == TWTRNativeAdThemeDark) ? theme : TWTRNativeAdThemeLight;

    if (self.doneInitializing) {
        _theme = theme;
    }

    self.backgroundColor = [[self class] backgroundColorForTheme:theme];
    self.primaryTextColor = [[self class] primaryTextColorForTheme:theme];
    self.adBackgroundColor = [[self class] adBackgroundColorForTheme:theme];
    self.buttonBackgroundColor = [[self class] defaultButtonBackgroundColor];

    self.adView.layer.borderColor = [[self class] borderColorForTheme:theme].CGColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    if (self.doneInitializing) {
        _backgroundColor = backgroundColor;
    }
    [super setBackgroundColor:backgroundColor];

    // Avoid seeing the background of the subviews if the user sets a semi-transparent background color.
    const BOOL colorIsOpaque = [TWTRColorUtil isOpaqueColor:backgroundColor];
    UIColor *backgroundColorForSubviews = colorIsOpaque ? backgroundColor : [UIColor clearColor];
    _disclaimerView.backgroundColor = backgroundColorForSubviews;

    [self setNeedsUpdateComputedColors];
}

- (void)setAdBackgroundColor:(UIColor *)adBackgroundColor
{
    if (self.doneInitializing) {
        _adBackgroundColor = adBackgroundColor;
    }
    _adView.backgroundColor = adBackgroundColor;

    // Avoid seeing the background of the subviews if the user sets a semi-transparent background color.
    const BOOL colorIsOpaque = [TWTRColorUtil isOpaqueColor:adBackgroundColor];
    UIColor *backgroundColorForSubviews = colorIsOpaque ? adBackgroundColor : [UIColor clearColor];
    _adView.titleTextLabel.backgroundColor = backgroundColorForSubviews;
    _adView.mainTextLabel.backgroundColor = backgroundColorForSubviews;
    _adView.iconImageView.backgroundColor = backgroundColorForSubviews;
    _adView.mainImageView.backgroundColor = backgroundColorForSubviews;

    [self setNeedsUpdateComputedColors];
}

- (void)setPrimaryTextColor:(UIColor *)primaryTextColor
{
    if (self.doneInitializing) {
        _primaryTextColor = primaryTextColor;
    }
    _adView.titleTextLabel.textColor = primaryTextColor;
    _adView.mainTextLabel.textColor = primaryTextColor;
    [self setNeedsUpdateComputedColors];
}

- (void)setButtonBackgroundColor:(UIColor *)buttonBackgroundColor
{
    if (self.doneInitializing) {
        _buttonBackgroundColor = buttonBackgroundColor;
    }
    _adView.callToActionTextLabel.backgroundColor = buttonBackgroundColor;
    [self setNeedsUpdateComputedColors];
}

+ (UIColor *)backgroundColorForTheme:(TWTRNativeAdTheme)theme
{
    return theme == TWTRNativeAdThemeDark ? [TWTRColorUtil blackColor] : [TWTRColorUtil faintGrayColor];
}

+ (UIColor *)adBackgroundColorForTheme:(TWTRNativeAdTheme)theme
{
    return theme == TWTRNativeAdThemeDark ? [TWTRColorUtil textColor] : [TWTRColorUtil whiteColor];
}

+ (UIColor *)primaryTextColorForTheme:(TWTRNativeAdTheme)theme
{
    return theme == TWTRNativeAdThemeDark ? [TWTRColorUtil faintGrayColor] : [TWTRColorUtil textColor];
}

+ (UIColor *)defaultButtonBackgroundColor
{
    return [TWTRColorUtil blueTextColor];
}

+ (UIColor *)borderColorForTheme:(TWTRNativeAdTheme)theme
{
    return theme == TWTRNativeAdThemeDark ? [TWTRColorUtil darkBorderGrayColor] : [TWTRColorUtil borderGrayColor];
}

+ (UIColor *)callToActionTextColorFromBackgroundColor:(UIColor *)backgroundColor
{
    // higher threshold because we want to display lighter text for the most part
    if ([TWTRColorUtil isLightColor:backgroundColor lightnessThreshold:0.6]) {
        return [TWTRColorUtil darkerColorForColor:backgroundColor lightnessLevel:0.5];
    } else {
        return [TWTRColorUtil whiteColor];
    }
}

/**
 *  Computed colors:
 *  - CTA button background color -> CTA button text color
 *  - CTA button background color -> CTA button on tap background color
 *  - (container) background color -> sponsored ad text color
 */
- (void)setNeedsUpdateComputedColors
{
    UIColor *buttonBackgroundColor = self.adView.callToActionTextLabel.backgroundColor;
    if (buttonBackgroundColor) {
        self.adView.callToActionTextLabel.textColor = [[self class] callToActionTextColorFromBackgroundColor:buttonBackgroundColor];
    }

    UIColor *backgroundColor = self.backgroundColor;
    if (backgroundColor) {
        self.disclaimerView.disclaimerLabel.textColor = [TWTRColorUtil contrastingTextColorFromBackgroundColor:backgroundColor];
    }
}

#pragma mark - Helpers

- (CGSize)sizeThatFits:(CGSize)size
{
    NSLayoutConstraint *widthConstraint = [TWTRViewUtil constraintForAttribute:NSLayoutAttributeWidth onView:self value:size.width];
    widthConstraint.identifier = @"(Temp) AdContainerView constraints for size calculation";
    widthConstraint.active = YES;
    CGSize systemSize = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    widthConstraint.active = NO;
    return systemSize;
}

@end
