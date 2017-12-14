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

#import "TWTRMoPubAdConfiguration.h"
#import <MoPub/MPNativeAdRendererConfiguration.h>
#import <MoPub/MPNativeAdRequestTargeting.h>
#import <MoPub/MPStaticNativeAdRenderer.h>
#import <MoPub/MPStaticNativeAdRendererSettings.h>
#import <TwitterCore/TWTRUtils.h>
#import "TWTRMoPubAdConfiguration_Private.h"
#import "TWTRMoPubNativeAdContainerView.h"

// MoPub classes and variables
static Class TWTRNativeAdRequestTargetingClass = nil;
static Class TWTRStaticNativeAdRendererSettings = nil;
static Class TWTRStaticNativeAdRenderer = nil;

// Copy of the constants because we cannot reliably check if the constants are defined at runtime
// https://github.com/mopub/mopub-ios-sdk/blob/master/MoPubSDK/Native%20Ads/MPNativeAdConstants.m
static NSString *const TWTRMoPubAdIconImageKey = @"iconimage";
static NSString *const TWTRMoPubAdMainImageKey = @"mainimage";
static NSString *const TWTRMoPubAdCTATextKey = @"ctatext";
static NSString *const TWTRMoPubAdTextKey = @"text";
static NSString *const TWTRMoPubAdTitleKey = @"title";

/**
 *  Keyword to be appended to MoPub ad targeting keywords for ad attribution.
 */
static NSString *const TWTRMoPubAttributionKeyword = @"src:twitterkit";

/**
 *  Correspondes to `MPNativeViewDynamicDimension`.
 */
static const CGFloat TWTRMoPubNNativeViewDynamicDimension = -1.0;

// From MoPub KFT
@implementation TWTRMoPubAdConfiguration

+ (void)initialize
{
    if (self == [TWTRMoPubAdConfiguration class]) {
        TWTRNativeAdRequestTargetingClass = NSClassFromString(@"MPNativeAdRequestTargeting");
        TWTRStaticNativeAdRendererSettings = NSClassFromString(@"MPStaticNativeAdRendererSettings");
        TWTRStaticNativeAdRenderer = NSClassFromString(@"MPStaticNativeAdRenderer");
    }
}

- (instancetype)initWithAdUnitID:(NSString *)adUnitID keywords:(NSString *)keywords
{
    if (self = [super init]) {
        _adUnitID = [adUnitID copy];
        _keywords = [keywords copy];

        [self setupMoPubClassesIfPossible];
    }

    return self;
}

/**
 *  1. Instances required to set up MoPub are only set if their respective classes are resolvable
 *  during run-time
 *  2. MoPub constants have to be duplicated because we cannot reliably determine if they are defined being a static framework
 *  3. Blocks types are ok as long as their signatures match
 *  4. Protocols can be conformed to as long as they are in private headers or .m
 */
- (void)setupMoPubClassesIfPossible
{
    self->_adRequestTargeting = [[TWTRNativeAdRequestTargetingClass alloc] init];
    self.adRequestTargeting.keywords = [self keywordsWithAttribution];
    self.adRequestTargeting.desiredAssets = [[NSSet alloc] initWithArray:@[TWTRMoPubAdIconImageKey, TWTRMoPubAdMainImageKey, TWTRMoPubAdCTATextKey, TWTRMoPubAdTextKey, TWTRMoPubAdTitleKey]];

    self->_adRendererSettings = [[TWTRStaticNativeAdRendererSettings alloc] init];
    self.adRendererSettings.renderingViewClass = [TWTRMoPubNativeAdContainerView class];
    self.adRendererSettings.viewSizeHandler = ^CGSize(CGFloat maxWidth) {
        return CGSizeMake(maxWidth, TWTRMoPubNNativeViewDynamicDimension);
    };
}

#pragma mark - Private Methods

- (MPNativeAdRendererConfiguration *)adRendererConfiguration
{
    if (self.adRendererSettings) {
        return [TWTRStaticNativeAdRenderer rendererConfigurationWithRendererSettings:self.adRendererSettings];
    } else {
        return nil;
    }
}

- (NSString *)keywordsWithAttribution
{
    if ([self.keywords length] > 0) {
        return [NSString stringWithFormat:@"%@,%@", self.keywords, TWTRMoPubAttributionKeyword];
    }

    return TWTRMoPubAttributionKeyword;
}

#pragma mark - NSObject

- (NSUInteger)hash
{
    return self.adUnitID.hash ^ self.keywords.hash;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[TWTRMoPubAdConfiguration class]]) {
        return [self isEqualToConfig:object];
    } else {
        return NO;
    }
}

- (BOOL)isEqualToConfig:(TWTRMoPubAdConfiguration *)config
{
    return [self.adUnitID isEqualToString:config.adUnitID] && [TWTRUtils isEqualOrBothNil:self.keywords other:config.keywords];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Ad: %@", self.adUnitID];
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<%@: %p> adUnitID = %@, keywords = %@", [self class], self, self.adUnitID, self.keywords];
}

@end
