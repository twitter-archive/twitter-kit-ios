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
#import <TwitterCore/TWTRGuestSession.h>
#import <TwitterCore/TWTRNetworking.h>
#import <TwitterCore/TWTRSession.h>
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TWTRMockURLSessionProtocol.h"
#import "TWTRStubTwitterClient.h"
#import "TWTRTestSessionStore.h"
#import "TWTRTwitterAPIServiceConfig.h"
#import "TWTRWebAuthenticationTokenRequestor.h"

@interface TWTRNetworking ()

+ (NSURLSession *)URLSession;

@end

@interface TWTRWebAuthenticationTokenRequestorTests : XCTestCase

@property (nonatomic) TWTRWebAuthenticationTokenRequestor *requestor;
@property (nonatomic, readonly) id mockAPIClient;

@end

@implementation TWTRWebAuthenticationTokenRequestorTests

- (void)setUp
{
    [super setUp];
    /// Needs to be called before any Twitter related methods so we use the correct API Client stub.
    id mockURLSession = [TWTRNetworking URLSessionForMockingWithProtocolClasses:@[[TWTRMockURLSessionProtocol class]]];
    _mockAPIClient = OCMClassMock([TWTRNetworking class]);
    OCMStub([_mockAPIClient URLSession]).andReturn(mockURLSession);

    TWTRTwitterAPIServiceConfig *serviceConfig = [[TWTRTwitterAPIServiceConfig alloc] init];
    TWTRAuthConfig *authConfig = [[TWTRAuthConfig alloc] initWithConsumerKey:@"key" consumerSecret:@"secret"];

    self.requestor = [[TWTRWebAuthenticationTokenRequestor alloc] initWithAuthConfig:authConfig serviceConfig:serviceConfig];
}

- (void)tearDown
{
    XCTAssertTrue([TWTRMockURLSessionProtocol isEmpty]);
    [self.mockAPIClient stopMocking];
    [super tearDown];
}

- (void)testRequestAuthToken_errorCallsBackWithError
{
    NSError *error = [NSError errorWithDomain:@"domain" code:1 userInfo:nil];
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithError:error]];

    XCTestExpectation *expectation = [self expectationWithDescription:@"wait for token"];
    [self.requestor requestAuthenticationToken:^(NSString *token, NSError *connectionError) {
        XCTAssertNil(token);
        XCTAssertNotNil(connectionError);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testRequestAuthToken_invalidResponseCallsBackWithError
{
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:@"bad data"]];

    XCTestExpectation *expectation = [self expectationWithDescription:@"wait for token"];
    [self.requestor requestAuthenticationToken:^(NSString *token, NSError *connectionError) {
        XCTAssertNil(token);
        XCTAssertNotNil(connectionError);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testRequestAuthToken_success
{
    NSString *expectedToken = @"token";
    NSString *response = [NSString stringWithFormat:@"oauth_token=%@", expectedToken];

    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:response]];

    XCTestExpectation *expectation = [self expectationWithDescription:@"wait for token"];
    [self.requestor requestAuthenticationToken:^(NSString *token, NSError *connectionError) {
        XCTAssertEqualObjects(token, expectedToken);
        XCTAssertNil(connectionError);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
