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
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TWTRLoginURLParser.h"
#import "TWTRTestSessionStore.h"
#import "TWTRTwitter.h"
#import "TWTRTwitter_Private.h"
#import "TWTRWebAuthenticationFlow.h"
#import "TWTRWebAuthenticationViewController.h"

@interface TWTRWebAuthenticationFlowTests : XCTestCase

@property (nonatomic) TWTRWebAuthenticationFlow *webAuthFlow;

@end

@interface TWTRWebAuthenticationFlow ()

- (void)presentWebAuthenticationViewController:(NSString *)token;

@end

// Set up the internal class to allow expectations
id mockWebAuthViewController()
{
    id mockController = OCMClassMock([TWTRWebAuthenticationViewController class]);
    OCMStub([mockController alloc]).andReturn(mockController);
    OCMStub([mockController initWithAuthenticationToken:OCMOCK_ANY authConfig:OCMOCK_ANY APIServiceConfig:OCMOCK_ANY hasExistingSession:NO]).andReturn(mockController);

    return mockController;
}

@implementation TWTRWebAuthenticationFlowTests

+ (void)setUp
{
    [TWTRTwitter resetSharedInstance];
    [[TWTRTwitter sharedInstance] startWithConsumerKey:@"xK8du" consumerSecret:@"secret"];
}

- (void)setUp
{
    [super setUp];

    self.webAuthFlow = [[TWTRWebAuthenticationFlow alloc] initWithSessionStore:[TWTRTwitter sharedInstance].sessionStore];
}

#pragma mark - Resume Auth Flow

- (void)testWebFlow_completionBlockHandlesAuthResponse
{
    id mockController = mockWebAuthViewController();

    // Expect the method that needs to be called correctly
    NSURL *url = [NSURL URLWithString:@"twitterkit-xK8du://testURL.com"];
    OCMExpect([mockController handleAuthResponseWithURL:url]);

    // Set up login completion block, and then call it
    [self.webAuthFlow presentWebAuthenticationViewController:@"token"];
    [self.webAuthFlow resumeAuthenticationWithRedirectURL:url];

    OCMVerifyAll(mockController);
    [mockController stopMocking];
}

- (void)testWebFlow_returnsYesForHandledURLs
{
    NSURL *url = [NSURL URLWithString:@"twitterkit-xK8du://testURL.com"];

    XCTAssert([self.webAuthFlow resumeAuthenticationWithRedirectURL:url]);
}

- (void)testWebFlow_doesNothingWithOtherURLs
{
    id mockController = mockWebAuthViewController();

    // Ensure that invalid URLs are not passed along
    [[mockController reject] handleAuthResponseWithURL:OCMOCK_ANY];

    // Set up login completion block, and then call it
    [self.webAuthFlow presentWebAuthenticationViewController:@"token"];
    NSURL *url = [NSURL URLWithString:@"otherSDK-xK8du://testURL.com"];
    [self.webAuthFlow resumeAuthenticationWithRedirectURL:url];

    OCMVerifyAll(mockController);
    [mockController stopMocking];
}

- (void)testWebFlow_returnsNoForHandledURLs
{
    NSURL *url = [NSURL URLWithString:@"otherSDK-xK8du://testURL.com"];

    XCTAssertEqual([self.webAuthFlow resumeAuthenticationWithRedirectURL:url], NO);
}

@end
