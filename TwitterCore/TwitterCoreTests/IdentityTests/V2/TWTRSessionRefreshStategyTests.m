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
#import <TwitterCore/TWTRAPIErrorCode.h>
#import <TwitterCore/TWTRAPIServiceConfig.h>
#import <TwitterCore/TWTRAuthConfig.h>
#import <TwitterCore/TWTRAuthenticationConstants.h>
#import <TwitterCore/TWTRGuestSession.h>
#import "TWTRNetworkSessionProvider.h"
#import "TWTRSessionRefreshStrategy.h"
#import "TWTRTestCase.h"

@interface TWTRSessionRefreshStategyTests : TWTRTestCase

@property (nonatomic, readonly) TWTRGuestSessionRefreshStrategy *guestRefreshStrategy;
@property (nonatomic, readonly) TWTRAuthConfig *authConfig;
@property (nonatomic, readonly) id<TWTRAPIServiceConfig> serviceConfig;
@property (nonatomic, readonly) NSString *accessToken;
@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) TWTRGuestSession *guestSession;

@end

@implementation TWTRSessionRefreshStategyTests

- (void)setUp
{
    [super setUp];

    _authConfig = [[TWTRAuthConfig alloc] initWithConsumerKey:@"consumerKey" consumerSecret:@"consumerSecret"];
    _serviceConfig = OCMProtocolMock(@protocol(TWTRAPIServiceConfig));
    _accessToken = @"accessToken";
    _guestRefreshStrategy = [[TWTRGuestSessionRefreshStrategy alloc] initWithAuthConfig:_authConfig APIServiceConfig:_serviceConfig];
    _url = [NSURL URLWithString:@"http://api.twitter.com"];
    _guestSession = [[TWTRGuestSession alloc] initWithAccessToken:@"accessToken" guestToken:@"guestToken"];
}

- (void)testSupportsGuestSessionClass
{
    XCTAssertTrue([TWTRGuestSessionRefreshStrategy canSupportSessionClass:[TWTRGuestSession class]]);
}

- (void)testIsSessionExpiredbasedOnRequestResponse_appTokenExpired
{
    NSHTTPURLResponse *expiredResponse = [[NSHTTPURLResponse alloc] initWithURL:self.url statusCode:TWTRAPIErrorCodeInvalidOrExpiredToken HTTPVersion:@"1.1" headerFields:@{}];
    XCTAssertTrue([TWTRGuestSessionRefreshStrategy isSessionExpiredBasedOnRequestResponse:expiredResponse]);
}

- (void)testIsSessionExpiredbasedOnRequestResponse_guestTokenExpired
{
    NSHTTPURLResponse *expiredResponse = [[NSHTTPURLResponse alloc] initWithURL:self.url statusCode:TWTRAPIErrorCodeBadGuestToken HTTPVersion:@"1.1" headerFields:@{}];
    XCTAssertTrue([TWTRGuestSessionRefreshStrategy isSessionExpiredBasedOnRequestResponse:expiredResponse]);
}

- (void)testIsSessionExpiredbasedOnRequestResponse_notExpired403
{
    NSHTTPURLResponse *expiredResponse = [[NSHTTPURLResponse alloc] initWithURL:self.url statusCode:403 HTTPVersion:@"1.1" headerFields:@{}];
    XCTAssertFalse([TWTRGuestSessionRefreshStrategy isSessionExpiredBasedOnRequestResponse:expiredResponse]);
}

- (void)testIsSessionExpiredbasedOnRequestResponse_notExpired200
{
    NSHTTPURLResponse *expiredResponse = [[NSHTTPURLResponse alloc] initWithURL:self.url statusCode:200 HTTPVersion:@"1.1" headerFields:@{}];
    XCTAssertFalse([TWTRGuestSessionRefreshStrategy isSessionExpiredBasedOnRequestResponse:expiredResponse]);
}

- (void)testIsSessionExpiredbasedOnError_appTokenExpired
{
    NSError *error = [NSError errorWithDomain:@"com.twitter" code:TWTRAPIErrorCodeInvalidOrExpiredToken userInfo:nil];
    XCTAssertTrue([TWTRGuestSessionRefreshStrategy isSessionExpiredBasedOnRequestError:error]);
}

- (void)testIsSessionExpiredbasedOnError_guestTokenExpired
{
    NSError *error = [NSError errorWithDomain:@"com.twitter" code:TWTRAPIErrorCodeBadGuestToken userInfo:nil];
    XCTAssertTrue([TWTRGuestSessionRefreshStrategy isSessionExpiredBasedOnRequestError:error]);
}

- (void)testIsSessionExpiredbasedOnError_notExpired403
{
    NSError *error = [NSError errorWithDomain:@"com.twitter" code:403 userInfo:nil];
    XCTAssertFalse([TWTRGuestSessionRefreshStrategy isSessionExpiredBasedOnRequestError:error]);
}

- (void)testRefreshSession_success
{
    id TWTRNetworkSessionProviderMock = OCMClassMock([TWTRNetworkSessionProvider class]);
    [OCMExpect([TWTRNetworkSessionProviderMock guestSessionWithAuthConfig:OCMOCK_ANY APIServiceConfig:OCMOCK_ANY URLSession:OCMOCK_ANY accessToken:OCMOCK_ANY completion:OCMOCK_ANY]) andDo:^(NSInvocation *invocation) {
        TWTRGuestSession *guestSession = [[TWTRGuestSession alloc] initWithAccessToken:@"accessToken" guestToken:@"guestToken2"];
        TWTRSessionRefreshCompletion refreshCompletion;
        [invocation getArgument:&refreshCompletion atIndex:6];
        refreshCompletion(guestSession, nil);
    }];
    [self.guestRefreshStrategy refreshSession:self.guestSession URLSession:[NSURLSession sharedSession] completion:^(TWTRGuestSession *refreshedSession, NSError *error) {
        XCTAssertEqualObjects(refreshedSession.guestToken, @"guestToken2");
        self.asyncComplete = YES;
    }];

    [self waitForCompletion];

    OCMVerifyAll(TWTRNetworkSessionProviderMock);

    [TWTRNetworkSessionProviderMock stopMocking];
}

- (void)testRefreshSession_failure
{
    id TWTRNetworkSessionProviderMock = OCMClassMock([TWTRNetworkSessionProvider class]);
    [OCMExpect([TWTRNetworkSessionProviderMock guestSessionWithAuthConfig:OCMOCK_ANY APIServiceConfig:OCMOCK_ANY URLSession:OCMOCK_ANY accessToken:OCMOCK_ANY completion:OCMOCK_ANY]) andDo:^(NSInvocation *invocation) {
        NSError *error = [NSError errorWithDomain:@"domain" code:1 userInfo:@{}];
        TWTRSessionRefreshCompletion refreshCompletion;
        [invocation getArgument:&refreshCompletion atIndex:6];
        refreshCompletion(nil, error);
    }];
    [self.guestRefreshStrategy refreshSession:self.guestSession URLSession:[NSURLSession sharedSession] completion:^(TWTRGuestSession *refreshedSession, NSError *error) {
        XCTAssertNotNil(error);
        self.asyncComplete = YES;
    }];

    [self waitForCompletion];

    OCMVerifyAll(TWTRNetworkSessionProviderMock);

    [TWTRNetworkSessionProviderMock stopMocking];
}

@end
