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

#import <Foundation/Foundation.h>
#import <OCMock/OCMock.h>
#import "TWTRTestCase.h"
#import "TWTRUtils.h"

@interface TWTRUtilsTests : TWTRTestCase

@end

@implementation TWTRUtilsTests

- (void)testDictionaryWithQueryString
{
    NSDictionary *dictFromQueryString = [TWTRUtils dictionaryWithQueryString:@"field1=value1&field2=value2&field3=value3"];
    NSDictionary *expectedDictionary = @{ @"field1": @"value1", @"field2": @"value2", @"field3": @"value3" };
    XCTAssertEqualObjects(dictFromQueryString, expectedDictionary, @"Incorrect values for dictionary");
}

- (void)testQueryStringFromDictionary
{
    NSDictionary *inputDictionary = @{ @"field1": @"value1", @"field2": @"value2", @"field3": @"value3" };
    NSString *resultantString = [TWTRUtils queryStringFromDictionary:inputDictionary];
    NSString *expectedValue = @"field3=value3&field2=value2&field1=value1";
    XCTAssertEqualObjects(resultantString, expectedValue, @"Incorrect values for query string");
}

- (void)testURLEncoding
{
    NSString *inputString = @"This is a simple & short test";
    NSString *outputString = [TWTRUtils urlEncodedStringForString:inputString];
    NSString *expectedString = @"This%20is%20a%20simple%20%26%20short%20test";
    XCTAssertEqualObjects(outputString, expectedString, @"URL encoding failed");
    NSString *decodedString = [TWTRUtils urlDecodedStringForString:outputString];
    XCTAssertEqualObjects(decodedString, inputString, @"URL decoding failed");
}

- (void)testURLDecoding
{
    NSString *inputString = @"%3B%3F%2F%3A%23%26%3D%2B%24%2C%20%25%3C%3E~%25";
    NSString *outputString = [TWTRUtils urlDecodedStringForString:inputString];
    NSString *expectedString = @";?/:#&=+$, %<>~%";
    XCTAssertEqualObjects(outputString, expectedString, @"URL encoding failed");
}

#pragma mark Localized app names (long)

- (void)testLocalizedLongAppName_successWhenLocalizedAvailable
{
    NSDictionary *infoDict = @{ @"CFBundleDisplayName": @"my amazing app name" };

    id mockNSBundle = [OCMockObject mockForClass:[NSBundle class]];
    [[[mockNSBundle stub] andReturn:infoDict] localizedInfoDictionary];
    [[[mockNSBundle stub] andReturn:mockNSBundle] mainBundle];

    NSString *appName = [TWTRUtils localizedLongAppName];
    XCTAssertEqualObjects(appName, @"my amazing app name");

    [mockNSBundle stopMocking];
}

- (void)testLocalizedLongAppName_fallsBackToUnlocalized
{
    NSDictionary *infoDict = @{ @"CFBundleDisplayName": @"my amazing app name" };

    id mockNSBundle = [OCMockObject mockForClass:[NSBundle class]];
    [[[mockNSBundle stub] andReturn:nil] localizedInfoDictionary];
    [[[mockNSBundle stub] andReturn:infoDict] infoDictionary];
    [[[mockNSBundle stub] andReturn:mockNSBundle] mainBundle];

    NSString *appName = [TWTRUtils localizedLongAppName];
    XCTAssertEqualObjects(appName, @"my amazing app name");

    [mockNSBundle stopMocking];
}

#pragma mark Localized app names (short)

- (void)testLocalizedShortAppName_successWhenLocalizedAvailable
{
    NSDictionary *infoDict = @{ @"CFBundleName": @"my amazing app name" };

    id mockNSBundle = [OCMockObject mockForClass:[NSBundle class]];
    [[[mockNSBundle stub] andReturn:infoDict] localizedInfoDictionary];
    [[[mockNSBundle stub] andReturn:mockNSBundle] mainBundle];

    NSString *appName = [TWTRUtils localizedShortAppName];
    XCTAssertEqualObjects(appName, @"my amazing app name");

    [mockNSBundle stopMocking];
}

#if IS_UIKIT_AVAILABLE
#pragma mark UIWindow Tests
// A typical app with an active UIWindow in its AppDelegate
- (void)testApplicationWithSingleWindowInAppDelegate_topVCIsRootVCOfWindow
{
    UIViewController *testVC = [[UIViewController alloc] init];
    UIWindow *testWindow = [[UIWindow alloc] init];
    testWindow.rootViewController = testVC;

    id mockDelegate = [OCMockObject mockForProtocol:@protocol(UIApplicationDelegate)];
    [[[mockDelegate stub] andReturn:testWindow] window];

    id mockApp = [OCMockObject mockForClass:[UIApplication class]];
    [[[mockApp stub] andReturn:mockApp] sharedApplication];
    [[[mockApp stub] andReturn:mockDelegate] delegate];

    XCTAssertEqual([TWTRUtils topViewController], testVC);
    [mockDelegate stopMocking];
    [mockApp stopMocking];
}

// An app with no UIWindow in [AppDelegate window]
// We'll resort to getting the window from
// [UIApplication sharedApplication].keyWindow
- (void)testApplicationWithNoWindowInAppDelegate_topVCIsRootVCOfKeyWindow
{
    UIViewController *testVC = [[UIViewController alloc] init];
    UIWindow *testWindow = [[UIWindow alloc] init];
    testWindow.rootViewController = testVC;

    id mockDelegate = [OCMockObject mockForProtocol:@protocol(UIApplicationDelegate)];
    [[[mockDelegate stub] andReturn:nil] window];

    id mockApp = [OCMockObject niceMockForClass:[UIApplication class]];
    [[[mockApp stub] andReturn:mockApp] sharedApplication];
    [[[mockApp stub] andReturn:mockDelegate] delegate];
    [[[mockApp stub] andReturn:testWindow] keyWindow];

    XCTAssertEqual([TWTRUtils topViewController], testVC);
    [mockApp stopMocking];
}

// This is a known fail case that [TWTRUtils topViewController]
// does not support. If the [AppDelegate window] is not the
// presented UIWindow(If the developer is using multiple UIWindows
// for various reasons), it returns the top VC in the wrong UIWindow
// This fail case exists to show that our current implemention of
// topViewController does not work for this scenario. Fixing this
// would require an API change, i.e. Getting viewControllerToPresentOn
// from the user.
- (void)testApplicationKeyWindowNotInAppDelegate_topVCIsRootVCOfKeyWindow
{
    UIViewController *hiddenVC = [[UIViewController alloc] init];
    UIWindow *hiddenWindow = [[UIWindow alloc] init];
    hiddenWindow.rootViewController = hiddenVC;

    UIViewController *visibleVC = [[UIViewController alloc] init];
    UIWindow *visibleWindow = [[UIWindow alloc] init];
    visibleWindow.rootViewController = visibleVC;

    id mockDelegate = [OCMockObject mockForProtocol:@protocol(UIApplicationDelegate)];
    [[[mockDelegate stub] andReturn:hiddenWindow] window];

    id mockApp = [OCMockObject niceMockForClass:[UIApplication class]];
    [[[mockApp stub] andReturn:mockApp] sharedApplication];
    [[[mockApp stub] andReturn:mockDelegate] delegate];
    [[[mockApp stub] andReturn:visibleWindow] keyWindow];

    // In this test there's a window property in AppDelegate but
    // the actual active window is another window.
    XCTAssertNotEqualObjects([TWTRUtils topViewController], visibleVC);
    [mockApp stopMocking];
}
#endif

#pragma mark - Equality Tests
- (void)testReturnsEqualForBothNil
{
    XCTAssertTrue([TWTRUtils isEqualOrBothNil:nil other:nil]);
}

- (void)testReturnsFalseIfNotEqual
{
    NSString *first = @"first";
    NSString *second = @"second";
    XCTAssertNotEqualObjects(first, second);
    XCTAssertFalse([TWTRUtils isEqualOrBothNil:first other:second]);
}

- (void)testReturnsTrueForEqual
{
    NSString *first = @"first";
    NSString *second = @"first";
    XCTAssertEqualObjects(first, second);
    XCTAssertTrue([TWTRUtils isEqualOrBothNil:first other:second]);
}

- (void)testSingleNilInstance
{
    NSString *obj = @"obj";
    NSString *other = nil;
    XCTAssertFalse([TWTRUtils isEqualOrBothNil:obj other:other]);
    XCTAssertFalse([TWTRUtils isEqualOrBothNil:other other:obj]);
}

@end
