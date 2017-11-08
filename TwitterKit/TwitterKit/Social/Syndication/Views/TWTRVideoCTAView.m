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

#import "TWTRVideoCTAView.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRColorUtil.h>
#import "TWTRFontUtil.h"
#import "TWTRImages.h"
#import "TWTRVideoDeeplinkConfiguration.h"
#import "TWTRViewUtil.h"

static const CGFloat TWTRVideoCTABorderViewCornerRadius = 16.0;

@interface TWTRVideoCTAView ()

@property (nonatomic, readonly) UIButton *CTAButton;
@property (nonatomic, readonly) TWTRVideoDeeplinkConfiguration *deeplinkConfiguration;

@end

@implementation TWTRVideoCTAView

- (instancetype)initWithFrame:(CGRect)frame deeplinkConfiguration:(TWTRVideoDeeplinkConfiguration *)deeplinkConfiguration
{
    TWTRParameterAssertOrReturnValue(deeplinkConfiguration, nil);

    self = [super initWithFrame:frame];
    if (self) {
        _CTAButton = [self makeButtonWithTitle:deeplinkConfiguration.displayText];
        _CTAButton.frame = self.bounds;
        _CTAButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_CTAButton];

        self.backgroundColor = [UIColor clearColor];
        _deeplinkConfiguration = deeplinkConfiguration;
    }
    return self;
}

- (UIButton *)makeButtonWithTitle:(NSString *)title
{
    UIButton *cta = [UIButton buttonWithType:UIButtonTypeSystem];
    [cta setTitle:title forState:UIControlStateNormal];

    cta.titleLabel.font = [UIFont boldSystemFontOfSize:[TWTRFontUtil defaultFontSize]];
    cta.tintColor = [UIColor whiteColor];

    cta.contentEdgeInsets = UIEdgeInsetsMake(0, TWTRVideoCTABorderViewCornerRadius, 0, TWTRVideoCTABorderViewCornerRadius);

    [cta setBackgroundImage:[[self class] borderImage] forState:UIControlStateNormal];

    [cta addTarget:self action:@selector(handleDeeplinkButton) forControlEvents:UIControlEventTouchUpInside];

    return cta;
}

+ (UIImage *)borderImage
{
    static UIImage *borderImage;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        UIColor *backgroundColor = [[TWTRColorUtil blackColor] colorWithAlphaComponent:0.7];
        UIColor *borderColor = [TWTRColorUtil whiteColor];
        borderImage = [TWTRImages buttonImageWithCornerRadius:TWTRVideoCTABorderViewCornerRadius backgroundColor:backgroundColor borderColor:borderColor];
    });

    return borderImage;
}

- (CGSize)intrinsicContentSize
{
    return [self.CTAButton intrinsicContentSize];
}

- (void)handleDeeplinkButton
{
    if ([self.delegate respondsToSelector:@selector(videoCTAView:willDeeplinkToTargetURL:)]) {
        [self.delegate videoCTAView:self willDeeplinkToTargetURL:self.deeplinkConfiguration.targetURL];
    }

    [[UIApplication sharedApplication] openURL:self.deeplinkConfiguration.targetURL];

    [self fireMetricsCallForMetricsURL:self.deeplinkConfiguration.metricsURL];
}

- (void)fireMetricsCallForMetricsURL:(NSURL *)metricsURL
{
    /// We want a smooth user experience when we deep link so we go directly to the expanded url
    /// which avoids opening Safari and then the target app. However, this makes it so we don't get
    /// to count the t.co metrics so we just make that request anyway.
    [[[NSURLSession sharedSession] dataTaskWithURL:metricsURL] resume];
}

@end
