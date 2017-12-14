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
#import <SafariServices/SafariServices.h>
#import <TwitterCore/TWTRAuthConfig.h>
#import <TwitterCore/TWTRSessionStore_Private.h>
#import <TwitterCore/TWTRUtils.h>
#import <XCTest/XCTest.h>
#import "TWTRAPIClient.h"
#import "TWTRLoginURLParser.h"
#import "TWTRTwitter.h"
#import "TWTRTwitter_Private.h"
#import "TWTRWebAuthenticationViewController.h"
#import "TWTRWebViewController.h"

@interface TWTRWebAuthenticationViewControllerTests : XCTestCase

@property (nonatomic) TWTRWebAuthenticationViewController *controller;
@property (nonatomic) TWTRSessionStore *sessionStore;

@end

@interface TWTRWebAuthenticationViewController ()

@property (nonatomic, readonly) NSURL *authURL;

@end

@implementation TWTRWebAuthenticationViewControllerTests

+ (void)setUp
{
    [TWTRTwitter resetSharedInstance];
    [[TWTRTwitter sharedInstance] startWithConsumerKey:@"xK8du" consumerSecret:@"secret"];
}

- (void)setUp
{
    [super setUp];
    self.sessionStore = [TWTRTwitter sharedInstance].sessionStore;
}

#pragma mark - Init

- (void)testQueryDict_hasExistingSession
{
    TWTRWebAuthenticationViewController *controller = [[TWTRWebAuthenticationViewController alloc] initWithAuthenticationToken:@"token23" authConfig:self.sessionStore.authConfig APIServiceConfig:self.sessionStore.APIServiceConfig hasExistingSession:YES];
    NSDictionary *parameters = [TWTRUtils dictionaryWithQueryString:controller.authURL.query];

    XCTAssert([[parameters allKeys] containsObject:@"force_login"]);
    XCTAssertEqualObjects(parameters[@"force_login"], @"true");
}

- (void)testQueryDict_noExistingSession
{
    TWTRWebAuthenticationViewController *controller = [[TWTRWebAuthenticationViewController alloc] initWithAuthenticationToken:@"token23" authConfig:self.sessionStore.authConfig APIServiceConfig:self.sessionStore.APIServiceConfig hasExistingSession:NO];
    NSDictionary *parameters = [TWTRUtils dictionaryWithQueryString:controller.authURL.query];

    XCTAssert([[parameters allKeys] containsObject:@"force_login"]);
    XCTAssertEqualObjects(parameters[@"force_login"], @"false");
}

- (void)testScheme_callAuthenticate
{
    TWTRWebAuthenticationViewController *controller = [[TWTRWebAuthenticationViewController alloc] initWithAuthenticationToken:@"token23" authConfig:self.sessionStore.authConfig APIServiceConfig:self.sessionStore.APIServiceConfig hasExistingSession:YES];
    XCTAssertEqualObjects([controller.authURL path], @"/oauth/authorize");
}

#pragma mark - Embedded View Controllers

- (void)testEmbededViewController_isWebViewController
{
    self.controller = [[TWTRWebAuthenticationViewController alloc] initWithAuthenticationToken:@"token23" authConfig:self.sessionStore.authConfig APIServiceConfig:self.sessionStore.APIServiceConfig hasExistingSession:YES];
    [self.controller view];

    UIViewController *embeddedViewController = [[self.controller childViewControllers] firstObject];
    XCTAssertEqual([embeddedViewController class], [TWTRWebViewController class]);
}

- (void)testEmbededViewController_isSafariViewController
{
    self.controller = [[TWTRWebAuthenticationViewController alloc] initWithAuthenticationToken:@"token23" authConfig:self.sessionStore.authConfig APIServiceConfig:self.sessionStore.APIServiceConfig hasExistingSession:NO];
    [self.controller view];

    UIViewController *embeddedViewController = [[self.controller childViewControllers] firstObject];
    XCTAssertEqual([embeddedViewController class], [SFSafariViewController class]);
}

@end
