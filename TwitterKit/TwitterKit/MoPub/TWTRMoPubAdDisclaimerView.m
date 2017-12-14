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

#import "TWTRMoPubAdDisclaimerView.h"
#import <TwitterCore/TWTRColorUtil.h>
#import "TWTRFontUtil.h"
#import "TWTRTranslationsUtil.h"
#import "TWTRViewUtil.h"

static CGFloat const TWTRMoPubAdDisclaimerLabelFontSize = 12.0;

@implementation TWTRMoPubAdDisclaimerView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _privacyInfoIcon = [[UIImageView alloc] init];
    _disclaimerLabel = [[UILabel alloc] init];
    _disclaimerLabel.textColor = [TWTRColorUtil whiteColor];
    _disclaimerLabel.text = TWTRLocalizedString(@"tw__view_is_sponsored_ad");
    _disclaimerLabel.font = [UIFont systemFontOfSize:TWTRMoPubAdDisclaimerLabelFontSize];
    _disclaimerLabel.userInteractionEnabled = YES;  // to block propagating touch events
    [@[_privacyInfoIcon, _disclaimerLabel] enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        subview.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:subview];
    }];

    [self blockTapsOnDisclaimerLabel];
    [self prepareLayout];
    [self setUpAccessibility];
}

#pragma mark - Accessibility

- (void)setUpAccessibility
{
    // redundant information and this label actually pertains more to the container view
    self.disclaimerLabel.isAccessibilityElement = NO;

    self.privacyInfoIcon.isAccessibilityElement = YES;
    self.privacyInfoIcon.accessibilityLabel = TWTRLocalizedString(@"tw__privacy_information_button");
    // fake this to be a button but not image because MoPub requires the privacy icon to be an ImageView
    UIAccessibilityTraits withButtonTrait = (self.privacyInfoIcon.accessibilityTraits | UIAccessibilityTraitButton);
    UIAccessibilityTraits withoutImageTrait = (withButtonTrait & ~UIAccessibilityTraitImage);
    self.privacyInfoIcon.accessibilityTraits = withoutImageTrait;
}

#pragma mark - Gesture Recognizers

// Do not want to bring up ad modal when user taps on disclaimer text
- (void)blockTapsOnDisclaimerLabel
{
    UITapGestureRecognizer *ontap = [[UITapGestureRecognizer alloc] init];
    [self.disclaimerLabel addGestureRecognizer:ontap];
}

#pragma mark - Theming

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];

    self.privacyInfoIcon.backgroundColor = backgroundColor;
    self.disclaimerLabel.backgroundColor = backgroundColor;
}

#pragma mark - Layout

- (void)prepareLayout
{
    NSDictionary<NSString *, UIView *> *subviews = @{ @"privacyIcon": self.privacyInfoIcon, @"disclaimer": self.disclaimerLabel };
    CGFloat daaIconSize = 20.0;
    NSDictionary<NSString *, NSNumber *> *metrics = @{ @"margin": @5, @"iconSize": @(daaIconSize) };
    [TWTRViewUtil addVisualConstraints:@"H:|[privacyIcon(iconSize)]-margin-[disclaimer]|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:subviews];
    [TWTRViewUtil addVisualConstraints:@"V:|[privacyIcon(iconSize)]|" metrics:metrics views:subviews];
}

@end
