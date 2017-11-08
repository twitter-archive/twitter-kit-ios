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
#import <XCTest/XCTest.h>
#import "TWTRGuestAuthRequestSigner.h"
#import "TWTRNetworkingPipeline.h"
#import "TWTRNetworkingPipelinePackage.h"
#import "TWTRPipelineSessionMock.h"
#import "TWTRRequestSigningOperation.h"
#import "TWTRSession.h"
#import "TWTRSessionFixtureLoader.h"
#import "TWTRUserAuthRequestSigner.h"

@interface TWTRRequestSigningOperationTests : XCTestCase
@property (nonatomic) NSOperationQueue *operationQueue;
@property (nonatomic) TWTRNetworkingPipelinePackage *package;
@property (nonatomic) TWTRPipelineSessionMock *sessionStoreMock;

@end

@implementation TWTRRequestSigningOperationTests

- (void)setUp
{
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.sessionStoreMock = [[TWTRPipelineSessionMock alloc] init];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.twitter.com"]];
    self.package = [TWTRNetworkingPipelinePackage packageWithRequest:request sessionStore:self.sessionStoreMock userID:nil completion:nil];
    [super setUp];
}

- (void)tearDown
{
    self.operationQueue = nil;
    [super tearDown];
}

- (void)testCancelInvokesCancelBlock
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"invoke callback with error"];

    self.operationQueue.suspended = YES;

    TWTRRequestSigningOperation *op = [[TWTRRequestSigningOperation alloc] initWithPackage:self.package success:nil cancel:^{
        [expectation fulfill];
    }];

    [self.operationQueue addOperation:op];

    [self.operationQueue cancelAllOperations];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testCancelOnlyInvokesOnce
{
    NSInteger __block callbackCount = 0;

    self.operationQueue.suspended = YES;

    TWTRRequestSigningOperation *op = [[TWTRRequestSigningOperation alloc] initWithPackage:self.package success:nil cancel:^{
        callbackCount += 1;
    }];

    [self.operationQueue addOperation:op];

    [self.operationQueue cancelAllOperations];
    [op cancel];

    XCTAssertTrue(callbackCount == 1, @"should only callback once: got %td", callbackCount);
}

- (void)testSuccessBlockCalledForGuestQueue
{
    BOOL __block didCallback = NO;

    TWTRGuestSessionProvider sessionProvider = ^{
        return [TWTRSessionFixtureLoader twitterGuestSession];
    };

    TWTRGuestRequestSigningOperation *op = [[TWTRGuestRequestSigningOperation alloc] initWithPackage:self.package sessionProvider:sessionProvider success:^(NSURLRequest *r) {
        didCallback = YES;
    }
                                                                                              cancel:nil];

    /// call it directly
    [op start];

    XCTAssertTrue(didCallback, @"Should callback success: got %@", didCallback ? @"YES" : @"NO");
}

- (void)testSuccessBlockCalledForUserQueue
{
    BOOL __block didCallback = NO;

    TWTRUserSessionProvider sessionProvider = ^{
        return [TWTRSessionFixtureLoader twitterSession];
    };

    TWTRUserRequestSigningOperation *op = [[TWTRUserRequestSigningOperation alloc] initWithPackage:self.package sessionProvider:sessionProvider success:^(NSURLRequest *r) {
        didCallback = YES;
    }
                                                                                            cancel:nil];

    /// call it directly
    [op start];

    XCTAssertTrue(didCallback, @"Should callback success: got %@", didCallback ? @"YES" : @"NO");
}

- (void)testCancelDoesNotInvokeAfterCompletionForGuestQueue
{
    BOOL __block didCallback = NO;

    TWTRGuestSessionProvider sessionProvider = ^{
        return [TWTRSessionFixtureLoader twitterGuestSession];
    };

    TWTRGuestRequestSigningOperation *op = [[TWTRGuestRequestSigningOperation alloc] initWithPackage:self.package sessionProvider:sessionProvider success:nil cancel:^{
        didCallback = YES;
    }];

    /// call it directly
    [op start];
    [op cancel];

    XCTAssert(op.isFinished);
    XCTAssertFalse(didCallback, @"Should not callback cancel: got %@", didCallback ? @"YES" : @"NO");
}

- (void)testCancelDoesNotInvokeAfterCompletionForUserQueue
{
    BOOL __block didCallback = NO;

    TWTRUserSessionProvider sessionProvider = ^{
        return [TWTRSessionFixtureLoader twitterSession];
    };

    TWTRUserRequestSigningOperation *op = [[TWTRUserRequestSigningOperation alloc] initWithPackage:self.package sessionProvider:sessionProvider success:nil cancel:^{
        didCallback = YES;
    }];

    /// call it directly
    [op start];
    [op cancel];

    XCTAssert(op.isFinished);
    XCTAssertFalse(didCallback, @"Should not callback cancel: got %@", didCallback ? @"YES" : @"NO");
}

- (void)testGuestRequestOperationActuallySignsRequest
{
    TWTRGuestSession *session = [TWTRSessionFixtureLoader twitterGuestSession];
    id mock = OCMClassMock([TWTRGuestAuthRequestSigner class]);

    TWTRGuestSessionProvider sessionProvider = ^{
        return session;
    };

    TWTRGuestRequestSigningOperation *op = [[TWTRGuestRequestSigningOperation alloc] initWithPackage:self.package sessionProvider:sessionProvider success:nil cancel:nil];

    [op start];

    /// the auth config does not implement isEqual: so we need to use OCMOCK_ANY for that parameter or this test will fail
    OCMVerify([mock signedURLRequest:self.package.request session:session]);
    [mock stopMocking];
}

- (void)testUserRequestOperationActuallySignsRequest
{
    TWTRAuthConfig *authConfig = [[TWTRAuthConfig alloc] initWithConsumerKey:@"consumer" consumerSecret:@"secret"];
    TWTRSession *session = [TWTRSessionFixtureLoader twitterSession];
    self.sessionStoreMock.authConfig = authConfig;
    id mock = OCMClassMock([TWTRUserAuthRequestSigner class]);

    TWTRUserSessionProvider sessionProvider = ^{
        return session;
    };

    OCMExpect([mock signedURLRequest:self.package.request authConfig:authConfig session:session]);

    TWTRUserRequestSigningOperation *op = [[TWTRUserRequestSigningOperation alloc] initWithPackage:self.package sessionProvider:sessionProvider success:nil cancel:nil];

    [op start];

    /// For some reason OCMVerify() was crashing. I moved to OCMExpect/OCMVerifyAll per https://github.com/erikdoe/ocmock/issues/147 to fix this issue.
    OCMVerifyAll(mock);

    [mock stopMocking];
}

@end
