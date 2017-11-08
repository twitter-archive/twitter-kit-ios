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

#import <MoPub/MPNativeAdRendererConfiguration.h>
#import <MoPub/MPNativeAdRequestTargeting.h>
#import <MoPub/MPStaticNativeAdRendererSettings.h>
#import "TWTRMoPubAdConfiguration.h"
#import "TWTRMoPubAdConfiguration_Private.h"
#import "TWTRMoPubNativeAdContainerView.h"
#import "TWTRTestCase.h"

@interface TWTRMoPubAdConfigurationTests : TWTRTestCase

@property (nonatomic, readonly) TWTRMoPubAdConfiguration *config;
@property (nonatomic, readonly) TWTRMoPubAdConfiguration *configWithKeywords;

@end

@implementation TWTRMoPubAdConfigurationTests

- (void)setUp
{
    [super setUp];

    _config = [[TWTRMoPubAdConfiguration alloc] initWithAdUnitID:@"123" keywords:nil];
    _configWithKeywords = [[TWTRMoPubAdConfiguration alloc] initWithAdUnitID:@"123" keywords:@"foo:bar"];
}

- (void)testAdRequestTargeting_noKeywords
{
    MPNativeAdRequestTargeting *targeting = self.config.adRequestTargeting;
    XCTAssertEqualObjects(targeting.keywords, @"src:twitterkit");
}

- (void)testAdRequestTargeting_hasKeywords
{
    MPNativeAdRequestTargeting *targeting = self.configWithKeywords.adRequestTargeting;
    XCTAssertEqualObjects(targeting.keywords, @"foo:bar,src:twitterkit");
}

// Should always be true since we have MoPub linked in tests
- (void)testAdRendererSettings_notNil
{
    MPStaticNativeAdRendererSettings *settings = self.config.adRendererSettings;
    XCTAssertNotNil(settings);
}

- (void)testIsEqual_yes
{
    TWTRMoPubAdConfiguration *equalConfig = [[TWTRMoPubAdConfiguration alloc] initWithAdUnitID:@"123" keywords:@"foo:bar"];
    XCTAssertEqualObjects(self.configWithKeywords, equalConfig);
}

- (void)testIsEqual_noIfDiffAdUnitID
{
    TWTRMoPubAdConfiguration *diffConfig = [[TWTRMoPubAdConfiguration alloc] initWithAdUnitID:@"1234" keywords:@"foo:bar"];
    XCTAssertNotEqualObjects(self.configWithKeywords, diffConfig);
}

- (void)testIsEqual_worksForNullableKeywords
{
    TWTRMoPubAdConfiguration *equalConfig = [[TWTRMoPubAdConfiguration alloc] initWithAdUnitID:@"123" keywords:nil];
    XCTAssertEqualObjects(self.config, equalConfig);
}

- (void)testIsEqual_worksForNullableKeywordsAndDiffAdUnitID
{
    TWTRMoPubAdConfiguration *diffConfig = [[TWTRMoPubAdConfiguration alloc] initWithAdUnitID:@"1234" keywords:nil];
    XCTAssertNotEqualObjects(self.config, diffConfig);
}

- (void)testIsEqual_noIfDiff
{
    TWTRMoPubAdConfiguration *diffConfig = [[TWTRMoPubAdConfiguration alloc] initWithAdUnitID:@"1234" keywords:@"foo:bar"];
    XCTAssertNotEqualObjects(self.configWithKeywords, diffConfig);
}

- (void)testAdRendererSettings_rendersWithCustomAdView
{
    MPStaticNativeAdRendererSettings *settings = self.config.adRendererSettings;
    XCTAssertEqualObjects(settings.renderingViewClass, [TWTRMoPubNativeAdContainerView class]);
}

- (void)testAdRendererSettings_hasViewSizeHandler
{
    MPStaticNativeAdRendererSettings *settings = self.config.adRendererSettings;
    XCTAssertNotNil(settings.viewSizeHandler);
}

// Should always be true since we have MoPub linked in tests
- (void)testAdRendererConfiguration_notNil
{
    MPNativeAdRendererConfiguration *rendererConfig = [self.config adRendererConfiguration];
    XCTAssertNotNil(rendererConfig);
}

@end
