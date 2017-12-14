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

#import <OCMock/OCMock.h>
#import "TWTRCoreConstants.h"
#import "TWTRCoreLanguage.h"
#import "TWTRResourcesUtil_Private.h"
#import "TWTRTestCase.h"

@interface TWTRResourcesUtilTests : TWTRTestCase

@property (nonatomic, readonly) NSString *bundlePath;
@property (nonatomic, strong) NSBundle *kitBundle;
@property (nonatomic, strong) id mockResourcesUtil;

@end

@implementation TWTRResourcesUtilTests

- (void)setUp
{
    [super setUp];

    _bundlePath = @"TestKit.Resources.bundle";
    self.kitBundle = [TWTRResourcesUtil bundleWithBundlePath:self.bundlePath];
    self.mockResourcesUtil = [OCMockObject mockForClass:[TWTRResourcesUtil class]];
}

- (void)tearDown
{
    [self.mockResourcesUtil stopMocking];

    [super tearDown];
}

- (void)testBundleWithBundlePath_supportsMultipleDotsInPath
{
    XCTAssertNotNil([TWTRResourcesUtil bundleWithBundlePath:@"TestKit.Resources.bundle"]);
}

- (void)testBundleWithBundlePath_nilIfNotFound
{
    XCTAssertNil([TWTRResourcesUtil bundleWithBundlePath:@"notfound.bundle"]);
}

- (void)testBundleWithBundlePath_found
{
    XCTAssertNotNil(self.kitBundle);
}

- (void)testLocalizedBundleWithBundle_getsPreferredLanguageBundle
{
    NSString *language = [TWTRCoreLanguage preferredLanguage];

    id mockNSBundle = [OCMockObject mockForClass:[NSBundle class]];
    [[[mockNSBundle expect] andReturn:self.bundlePath] pathForResource:language ofType:TWTRResourcesUtilLanguageType];
    [[[mockNSBundle expect] andReturn:self.kitBundle] bundleWithPath:self.bundlePath];

    [TWTRResourcesUtil localizedBundleWithBundle:mockNSBundle];

    [mockNSBundle verify];
    [mockNSBundle stopMocking];
}

- (void)testLocalizedBundleWithBundlePath_found
{
    NSBundle *languageBundle = [[NSBundle alloc] init];
    [[[[self.mockResourcesUtil expect] classMethod] andReturn:languageBundle] localizedBundleWithBundle:OCMOCK_ANY];

    XCTAssertEqual(languageBundle, [TWTRResourcesUtil localizedBundleWithBundlePath:self.bundlePath]);
    [self.mockResourcesUtil verify];
}

- (void)testLocalizedBundle_returnKitBundleIfNotFound
{
    [[[self.mockResourcesUtil expect] andReturn:nil] localizedBundleWithBundle:OCMOCK_ANY];
    XCTAssertEqualObjects(self.kitBundle, [TWTRResourcesUtil localizedBundleWithBundlePath:self.bundlePath]);
    [self.mockResourcesUtil verify];
}

- (void)testLocalizedStringForKey_success
{
    NSString *key = @"tw__share_tweet";
    NSString *value = @"Share Tweet";

    id localizedBundleMock = [OCMockObject mockForClass:[NSBundle class]];
    [[[localizedBundleMock expect] andReturn:value] localizedStringForKey:key value:OCMOCK_ANY table:OCMOCK_ANY];

    [[[[self.mockResourcesUtil expect] classMethod] andReturn:localizedBundleMock] localizedBundleWithBundlePath:self.bundlePath];

    XCTAssertEqualObjects(value, [TWTRResourcesUtil localizedStringForKey:key bundlePath:self.bundlePath]);

    [localizedBundleMock verify];
    [self.mockResourcesUtil verify];
}

- (void)xtestLocalizedStringForKey_returnsStringFromFallbackBundleIfNotFound
{
    NSString *key = @"tw__share_tweet";
    NSString *fallbackValue = @"Share Tweet";

    id localizedBundleMock = [OCMockObject mockForClass:[NSBundle class]];
    [[[localizedBundleMock expect] andReturn:nil] localizedStringForKey:key value:OCMOCK_ANY table:OCMOCK_ANY];

    [[[[self.mockResourcesUtil expect] classMethod] andReturn:localizedBundleMock] localizedBundleWithBundlePath:self.bundlePath];

    XCTAssertEqualObjects(fallbackValue, [TWTRResourcesUtil localizedStringForKey:key bundlePath:self.bundlePath]);

    [localizedBundleMock verify];
    [self.mockResourcesUtil verify];
}

- (void)testUserAgentFromKitBundle
{
    NSDictionary *infoDictionary = @{(__bridge NSString *)kCFBundleExecutableKey: @"myapp", (__bridge NSString *)kCFBundleVersionKey: @"1.2.3" };

    id bundleMock = OCMPartialMock([NSBundle mainBundle]);
    OCMStub([bundleMock infoDictionary]).andReturn(infoDictionary);

    id TWTRResourcesUtilMock = OCMClassMock([TWTRResourcesUtil class]);
    OCMStub([TWTRResourcesUtilMock deviceModel]).andReturn(@"SuperPhone");
    OCMStub([TWTRResourcesUtilMock screenScale]).andReturn(2.0);
    OCMStub([TWTRResourcesUtilMock OSVersionString]).andReturn(@"OS 10.0");

    NSString *userAgentString = [TWTRResourcesUtil userAgentFromKitBundle];
#if TARGET_OS_TV
    NSString *expectedPlatform = @"tvOS";
#else
    NSString *expectedPlatform = @"iOS";
#endif
    NSString *expected = [NSString stringWithFormat:@"Fabric/X.Y.Z (myapp/1.2.3; SuperPhone; OS 10.0 %@; Scale/2.00) TwitterKit/%@", expectedPlatform, TWTRCoreVersion];
    XCTAssertEqualObjects(expected, userAgentString);
}

- (void)testUserAgent_afterVersionSet
{
    NSDictionary *infoDictionary = @{(__bridge NSString *)kCFBundleExecutableKey: @"myapp", (__bridge NSString *)kCFBundleVersionKey: @"1.2.3" };

    id bundleMock = OCMPartialMock([NSBundle mainBundle]);
    OCMStub([bundleMock infoDictionary]).andReturn(infoDictionary);

    id TWTRResourcesUtilMock = OCMClassMock([TWTRResourcesUtil class]);
    OCMStub([TWTRResourcesUtilMock deviceModel]).andReturn(@"SuperPhone");
    OCMStub([TWTRResourcesUtilMock screenScale]).andReturn(2.0);
    OCMStub([TWTRResourcesUtilMock OSVersionString]).andReturn(@"OS 10.0");

    // Override the kit version
    [TWTRResourcesUtil setKitVersion:@"3.0.0"];

    NSString *userAgentString = [TWTRResourcesUtil userAgentFromKitBundle];
    NSString *expected = @"Fabric/X.Y.Z (myapp/1.2.3; SuperPhone; OS 10.0 iOS; Scale/2.00) TwitterKit/3.0.0";
    XCTAssertEqualObjects(expected, userAgentString);
    [TWTRResourcesUtil setKitVersion:nil];  // Reset our version override
}

@end
