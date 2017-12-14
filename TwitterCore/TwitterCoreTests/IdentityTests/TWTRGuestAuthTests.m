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
#import "TWTRAPIErrorCode.h"
#import "TWTRAuthClient.h"
#import "TWTRAuthConfig.h"
#import "TWTRAuthenticationConstants.h"
#import "TWTRAuthenticator.h"
#import "TWTRFakeAPIServiceConfig.h"
#import "TWTRIdentityTestConstants.h"
#import "TWTRMockURLProtocol.h"
#import "TWTRTestCase.h"

@interface TWTRGuestAuthTests : TWTRTestCase

@property (nonatomic, readonly) TWTRFakeAPIServiceConfig *apiServiceConfig;

@end

@implementation TWTRGuestAuthTests

- (void)setUp
{
    [super setUp];
    _apiServiceConfig = [[TWTRFakeAPIServiceConfig alloc] init];

    // mock the app auth request
    NSURL *appTokenURL = TWTRAPIURLWithPath(self.apiServiceConfig, TWTRAppAuthTokenPath);
    NSMutableURLRequest *requestToken = [NSMutableURLRequest requestWithURL:appTokenURL];
    [requestToken setHTTPMethod:@"POST"];
    NSString *strDataApp = [NSString stringWithFormat:@"{\"%@\":\"%@\",\"%@\":\"%@\"}", TWTRAuthTokenTypeKey, TWTRGuestTokenType, TWTRAuthAppOAuthTokenKey, TWTRAppAuthToken];
    [TWTRMockURLProtocol setMockResponseString:[NSString stringWithFormat:@"%@", strDataApp] mockResponse:nil forRequest:requestToken];
    [TWTRAuthClient logoutApp];
}

- (void)tearDown
{
    [TWTRMockURLProtocol clearAllMocks];
}

- (void)testGuestAuth
{
    // mock the guest auth request
    NSURL *guestAuthURL = TWTRAPIURLWithPath(self.apiServiceConfig, TWTRGuestAuthTokenPath);
    NSMutableURLRequest *guestTokenReq = [NSMutableURLRequest requestWithURL:guestAuthURL];
    [guestTokenReq setHTTPMethod:@"POST"];
    NSString *strDataGuestAuth = [NSString stringWithFormat:@"{ \"%@\": \"%@\", \"%@\": \"%@\" }", TWTRGuestAuthOAuthTokenKey, TWTRGuestAuthToken, TWTRAuthAppOAuthTokenKey, TWTRAppAuthToken];
    [TWTRMockURLProtocol setMockResponseString:strDataGuestAuth mockResponse:nil forRequest:guestTokenReq];
    TWTRAuthClient *authClient = [[TWTRAuthClient alloc] initWithAPIServiceConfig:self.apiServiceConfig];
    TWTRAuthConfig *authConfig = [[TWTRAuthConfig alloc] initWithConsumerKey:@"test" consumerSecret:@"test"];
    [authClient authenticateGuestWithAuthConfig:authConfig completion:^(TWTRGuestSession *guestSession, NSError *error) {
        XCTAssertTrue([[guestSession accessToken] isEqualToString:TWTRAppAuthToken], @"Response : %@", [guestSession accessToken]);
        XCTAssertTrue([[guestSession guestToken] isEqualToString:TWTRGuestAuthToken], @"Response : %@", [guestSession guestToken]);
        [self setAsyncComplete:YES];
    }];
    [self waitForCompletion];
}

- (void)testGuestAuthFailure
{
    // mock the guest auth request
    NSURL *guestAuthURL = TWTRAPIURLWithPath(self.apiServiceConfig, TWTRGuestAuthTokenPath);
    NSMutableURLRequest *guestTokenReq = [NSMutableURLRequest requestWithURL:guestAuthURL];
    [guestTokenReq setHTTPMethod:@"POST"];
    NSString *strDataGuestAuth = [NSString stringWithFormat:@"{\"errors\":[{\"code\":200,\"message\":\"Forbidden\"}]}"];
    NSHTTPURLResponse *httpResponse = [[NSHTTPURLResponse alloc] initWithURL:OCMClassMock([NSURL class]) statusCode:403 HTTPVersion:nil headerFields:nil];
    [TWTRMockURLProtocol setMockResponseString:strDataGuestAuth mockResponse:httpResponse forRequest:guestTokenReq];
    TWTRAuthClient *authClient = [[TWTRAuthClient alloc] initWithAPIServiceConfig:self.apiServiceConfig];
    TWTRAuthConfig *authConfig = [[TWTRAuthConfig alloc] initWithConsumerKey:@"test" consumerSecret:@"test"];
    // stubbing keychain to return no saved tokens
    id authenticatorMock = [OCMockObject mockForClass:[TWTRAuthenticator class]];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[[authenticatorMock stub] andReturn:nil] authenticationResponseForAuthType:TWTRAuthTypeGuest];
    [TWTRAuthenticator authenticationResponseForAuthType:TWTRAuthTypeGuest];
#pragma clang diagnostic pop
    [authClient authenticateGuestWithAuthConfig:authConfig completion:^(TWTRGuestSession *guestSession, NSError *error) {
        XCTAssertNil(guestSession, @"Response : %@", guestSession);
        XCTAssertNotNil(error, @"Response : %@", error);
        [self setAsyncComplete:YES];
        [authenticatorMock stopMocking];
    }];
    [self waitForCompletion];
}

- (void)testGuestAuthExpired_AppTokenExpiredReturnsNilSession
{
    NSString *responseFixture = [NSString stringWithFormat:@"{\"errors\":[{\"code\":%lu,\"message\":\"Forbidden\"}]}", (unsigned long)TWTRAPIErrorCodeInvalidOrExpiredToken];
    [self assertErrorOnTokenExpiredWithAuthType:TWTRAuthTypeGuest responseFixture:responseFixture assertionBlock:^BOOL(TWTRGuestSession *guestSession, NSError *error) {
        return guestSession == nil;
    }];
}

- (void)testGuestAuthExpired_AppTokenExpiredReturnsErrorCode
{
    NSString *responseFixture = [NSString stringWithFormat:@"{\"errors\":[{\"code\":%lu,\"message\":\"Forbidden\"}]}", (unsigned long)TWTRAPIErrorCodeInvalidOrExpiredToken];
    [self assertErrorOnTokenExpiredWithAuthType:TWTRAuthTypeGuest responseFixture:responseFixture assertionBlock:^BOOL(TWTRGuestSession *guestSession, NSError *error) {
        return error != nil && error.code == TWTRAPIErrorCodeInvalidOrExpiredToken;
    }];
}

- (void)testGuestAuthExpired_AppTokenExpiredReturnsErrorCodeDomain
{
    NSString *responseFixture = [NSString stringWithFormat:@"{\"errors\":[{\"code\":%lu,\"message\":\"Forbidden\"}]}", (unsigned long)TWTRAPIErrorCodeInvalidOrExpiredToken];
    [self assertErrorOnTokenExpiredWithAuthType:TWTRAuthTypeGuest responseFixture:responseFixture assertionBlock:^BOOL(TWTRGuestSession *guestSession, NSError *error) {
        return error != nil && error.domain == TWTRAPIErrorDomain;
    }];
}

- (void)testGuestAuthExpired_GuestTokenExpiredReturnsNilSession
{
    NSString *responseFixture = [NSString stringWithFormat:@"{\"errors\":[{\"code\":%lu,\"message\":\"Forbidden\"}]}", (long)TWTRAPIErrorCodeBadGuestToken];
    [self assertErrorOnTokenExpiredWithAuthType:TWTRAuthTypeGuest responseFixture:responseFixture assertionBlock:^BOOL(TWTRGuestSession *guestSession, NSError *error) {
        return guestSession == nil;
    }];
}

- (void)testGuestAuthExpired_GuestTokenExpiredReturnsErrorCode
{
    NSString *responseFixture = [NSString stringWithFormat:@"{\"errors\":[{\"code\":%lu,\"message\":\"Forbidden\"}]}", (long)TWTRAPIErrorCodeBadGuestToken];
    [self assertErrorOnTokenExpiredWithAuthType:TWTRAuthTypeGuest responseFixture:responseFixture assertionBlock:^BOOL(TWTRGuestSession *guestSession, NSError *error) {
        return error.code == TWTRAPIErrorCodeBadGuestToken;
    }];
}

- (void)testGuestAuthExpired_GuestTokenExpiredReturnsErrorCodeDomain
{
    NSString *responseFixture = [NSString stringWithFormat:@"{\"errors\":[{\"code\":%lu,\"message\":\"Forbidden\"}]}", (long)TWTRAPIErrorCodeBadGuestToken];
    [self assertErrorOnTokenExpiredWithAuthType:TWTRAuthTypeGuest responseFixture:responseFixture assertionBlock:^BOOL(TWTRGuestSession *guestSession, NSError *error) {
        return error.domain == TWTRAPIErrorDomain;
    }];
}

- (void)assertErrorOnTokenExpiredWithAuthType:(TWTRAuthType)authType responseFixture:(NSString *)responseFixture assertionBlock:(BOOL (^)(TWTRGuestSession *guestSession, NSError *error))assertionBlock
{
    // stubbing keychain to return no saved tokens so we can test out the auth and networking flow
    id authenticatorMock = [OCMockObject mockForClass:[TWTRAuthenticator class]];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[[authenticatorMock stub] andReturn:nil] authenticationResponseForAuthType:authType];

    // mock the guest auth request
    NSHTTPURLResponse *httpResponse = [[NSHTTPURLResponse alloc] initWithURL:OCMClassMock([NSURL class]) statusCode:403 HTTPVersion:nil headerFields:nil];
#pragma clang diagnostic pop
    NSURL *guestAuthURL = TWTRAPIURLWithPath(self.apiServiceConfig, TWTRGuestAuthTokenPath);
    NSMutableURLRequest *guestTokenReq = [NSMutableURLRequest requestWithURL:guestAuthURL];
    [guestTokenReq setHTTPMethod:@"POST"];
    [TWTRMockURLProtocol setMockResponseString:responseFixture mockResponse:httpResponse forRequest:guestTokenReq];

    // mock app auth request
    NSURL *appAuthURL = TWTRAPIURLWithPath(self.apiServiceConfig, TWTRAppAuthTokenPath);
    NSMutableURLRequest *appTokenReq = [NSMutableURLRequest requestWithURL:appAuthURL];
    [appTokenReq setHTTPMethod:@"POST"];
    [TWTRMockURLProtocol setMockResponseString:responseFixture mockResponse:httpResponse forRequest:appTokenReq];

    TWTRAuthClient *authClient = [[TWTRAuthClient alloc] initWithAPIServiceConfig:self.apiServiceConfig];
    TWTRAuthConfig *authConfig = [[TWTRAuthConfig alloc] initWithConsumerKey:@"test" consumerSecret:@"test"];

    [authClient authenticateGuestWithAuthConfig:authConfig completion:^(TWTRGuestSession *guestSession, NSError *guestAuthError) {
        XCTAssert(assertionBlock(guestSession, guestAuthError));
        self.asyncComplete = YES;
        [authenticatorMock stopMocking];
    }];
    [self waitForCompletion];
}

@end
