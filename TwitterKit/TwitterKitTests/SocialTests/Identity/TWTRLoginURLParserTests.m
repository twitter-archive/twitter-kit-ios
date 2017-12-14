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
#import <TwitterCore/TWTRAuthConfig.h>
#import <XCTest/XCTest.h>
#import "TWTRLoginURLParser.h"

@interface TWTRLoginURLParserTests : XCTestCase

@property (nonatomic) TWTRLoginURLParser *loginURLParser;

@end

@implementation TWTRLoginURLParserTests

- (void)setUp
{
    TWTRAuthConfig *authConfig = [[TWTRAuthConfig alloc] initWithConsumerKey:@"xK8du" consumerSecret:@"s7r5p2"];
    self.loginURLParser = [[TWTRLoginURLParser alloc] initWithAuthConfig:authConfig];
}

#pragma mark - URL Scheme

- (void)testURLScheme_valid
{
    NSURL *url = [NSURL URLWithString:@"twitterkit-xK8du://fakeredirect.com/args"];
    XCTAssert([self.loginURLParser isTwitterKitRedirectURL:url]);
}

- (void)testURLScheme_noID
{
    NSURL *url = [NSURL URLWithString:@"twitterkit-://fakeredirect.com/args"];
    XCTAssertEqual([self.loginURLParser isTwitterKitRedirectURL:url], NO);
}

- (void)testURLScheme_wrongPrefix
{
    NSURL *url = [NSURL URLWithString:@"othersdk987124://fakeredirect.com/args"];
    XCTAssertEqual([self.loginURLParser isTwitterKitRedirectURL:url], NO);
}

#pragma mark - Info.plist Parsing

- (void)testURLScheme_defaultWhenEmptyInfoPlist
{
    NSString *appScheme = [self.loginURLParser authRedirectScheme];

    XCTAssertEqual(appScheme, @"twittersdk");
}

- (void)testURLScheme_usesDefaultWhenInvalidURLScheme
{
    id mainBundleMock = OCMPartialMock([NSBundle mainBundle]);

    OCMStub([mainBundleMock infoDictionary]).andReturn(@{ @"CFBundleURLTypes": @[@{@"CFBundleURLSchemes": @[@"twitt23984"]}] });
    NSString *appScheme = [self.loginURLParser authRedirectScheme];

    XCTAssertEqualObjects(appScheme, @"twittersdk");
    XCTAssertFalse([self.loginURLParser hasValidURLScheme]);
}

- (void)testURLScheme_usesAppSchemeWhenSetup
{
    id mainBundleMock = OCMPartialMock([NSBundle mainBundle]);
    OCMStub([mainBundleMock infoDictionary]).andReturn(@{ @"CFBundleURLTypes": @[@{@"CFBundleURLSchemes": @[@"twitterkit-xK8du"]}] });
    NSString *appScheme = [self.loginURLParser authRedirectScheme];

    XCTAssertEqualObjects(appScheme, @"twitterkit-xK8du");
    XCTAssertTrue([self.loginURLParser hasValidURLScheme]);
}

- (void)testURLScheme_parsesCorrectSchemeWhenMultiplesExist
{
    NSDictionary *fakeInfoDict = @{
        @"CFBundleURLTypes": @[
            @{
               @"CFBundleTypeRole": @"Editor",
               @"CFBundleURLSchemes": @[@"tester90"],
            },
            @{
               @"CFBundleTypeRole": @"Editor",
               @"CFBundleURLSchemes": @[@"twitterkit-xK8du"],
            },
        ]
    };
    id mainBundleMock = OCMPartialMock([NSBundle mainBundle]);
    OCMStub([mainBundleMock infoDictionary]).andReturn(fakeInfoDict);

    NSString *appScheme = [self.loginURLParser authRedirectScheme];

    XCTAssertEqualObjects(appScheme, @"twitterkit-xK8du");
    XCTAssertTrue([self.loginURLParser hasValidURLScheme]);
}

- (void)testURLScheme_parsesCorrectSchemeWithUnorderedArray
{
    NSDictionary *fakeInfoDict = @{
        @"CFBundleURLTypes": @[@{
            @"CFBundleTypeRole": @"Editor",
            @"CFBundleURLSchemes": @[@"tester90", @"twitterkit-xK8du"],
        }]
    };
    id mainBundleMock = OCMPartialMock([NSBundle mainBundle]);
    OCMStub([mainBundleMock infoDictionary]).andReturn(fakeInfoDict);

    NSString *appScheme = [self.loginURLParser authRedirectScheme];

    XCTAssertEqualObjects(appScheme, @"twitterkit-xK8du");
    XCTAssertTrue([self.loginURLParser hasValidURLScheme]);
}

#pragma mark - Mobile SSO

- (void)testTwitterAuthorizeURL_properFormat
{
    NSURL *url = [self.loginURLParser twitterAuthorizeURL];

    XCTAssertEqualObjects(url.scheme, @"twitterauth");
    XCTAssertEqualObjects(url.host, @"authorize");
    XCTAssert([url.query containsString:@"consumer_key=xK8du"]);
    XCTAssert([url.query containsString:@"consumer_secret=s7r5p2"]);
    XCTAssert([url.query containsString:@"oauth_callback=twitterkit-xK8du"]);
}

- (void)testIsMobileSSO_success
{
    NSURL *cancelURL = [NSURL URLWithString:@"twitterkit-xK8du://"];
    NSURL *successURL = [NSURL URLWithString:@"twitterkit-xK8du://secret=RVfziSc&token=23698-mzYEJHqJ&username=fabric_tester"];

    XCTAssertTrue([self.loginURLParser isMobileSSOSuccessURL:successURL]);
    XCTAssertFalse([self.loginURLParser isMobileSSOSuccessURL:cancelURL]);
}

- (void)testIsMobileSSO_cancel
{
    NSURL *cancelURL = [NSURL URLWithString:@"twitterkit-xK8du://"];
    NSURL *successURL = [NSURL URLWithString:@"twitterkit-xK8du://secret=RVfziSc&token=23698-mzYEJHqJ&username=fabric_tester"];

    XCTAssertTrue([self.loginURLParser isMobileSSOCancelURL:cancelURL]);
    XCTAssertFalse([self.loginURLParser isMobileSSOCancelURL:successURL]);
}

- (void)testMobileSSOParameters
{
    NSDictionary *parsedParameters = [self.loginURLParser parametersForSSOURL:[NSURL URLWithString:@"twitterkit-xK8du://secret=RVfziSc&token=23698-mzYEJHqJ&username=fabric_tester"]];
    NSDictionary *expectedParameters = @{ @"token": @"23698-mzYEJHqJ", @"secret": @"RVfziSc", @"username": @"fabric_tester" };
    XCTAssertEqualObjects(parsedParameters, expectedParameters);
}

@end
