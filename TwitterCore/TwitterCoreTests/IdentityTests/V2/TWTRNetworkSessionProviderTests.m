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
#import <TwitterCore/TWTRAPIServiceConfig.h>
#import <TwitterCore/TWTRAppAuthProvider.h>
#import <TwitterCore/TWTRAuthConfig.h>
#import <TwitterCore/TWTRAuthenticationConstants.h>
#import <TwitterCore/TWTRGuestAuthProvider.h>
#import <TwitterCore/TWTRGuestSession.h>
#import "TWTRAppleSocialAuthenticaticationProvider.h"
#import "TWTRNetworkSessionProvider.h"
#import "TWTRSession.h"
#import "TWTRTestCase.h"

@interface TWTRNetworkSessionProviderTests : TWTRTestCase

@property (nonatomic, readonly) id appleAuthProviderMock;
@property (nonatomic, readonly) id appAuthProviderMock;
@property (nonatomic, readonly) id guestAuthProviderMock;
@property (nonatomic, readonly) TWTRAuthConfig *authConfig;
@property (nonatomic, readonly) id<TWTRAPIServiceConfig> serviceConfig;
@property (nonatomic, readonly) TWTRGuestSession *guestSession;
@property (nonatomic, readonly) TWTRSession *userSession;

@property (nonatomic, readonly) NSDictionary *appAuthResponse;
@property (nonatomic, readonly) NSDictionary *userAuthResponse;
@property (nonatomic, readonly) NSDictionary *guestAuthResponse;

@end

@implementation TWTRNetworkSessionProviderTests

- (void)setUp
{
    [super setUp];

#if !TARGET_OS_TV
    // FIXME: clean this up when refactoring auth providers
    _appleAuthProviderMock = OCMClassMock([TWTRAppleSocialAuthenticaticationProvider class]);
#endif
    _appAuthProviderMock = OCMClassMock([TWTRAppAuthProvider class]);
    _guestAuthProviderMock = OCMClassMock([TWTRGuestAuthProvider class]);

#if !TARGET_OS_TV
    NSArray *mocks = @[_appleAuthProviderMock, _appAuthProviderMock, _guestAuthProviderMock];
#else
    NSArray *mocks = @[_appAuthProviderMock, _guestAuthProviderMock];
#endif

    [mocks enumerateObjectsUsingBlock:^(id mockObj, NSUInteger idx, BOOL *stop) {
        // mock class should return the mock instance
        OCMStub([mockObj alloc]).andReturn(mockObj);
    }];
#if !TARGET_OS_TV
    [OCMStub([_appleAuthProviderMock initWithAuthConfig:OCMOCK_ANY apiServiceConfig:OCMOCK_ANY]) andReturn:_appleAuthProviderMock];
#endif
    [OCMStub([_appAuthProviderMock initWithAuthConfig:OCMOCK_ANY apiServiceConfig:OCMOCK_ANY]) andReturn:_appAuthProviderMock];
    [OCMStub([_guestAuthProviderMock initWithAuthConfig:OCMOCK_ANY apiServiceConfig:OCMOCK_ANY accessToken:OCMOCK_ANY]) andReturn:_guestAuthProviderMock];

    _authConfig = [[TWTRAuthConfig alloc] initWithConsumerKey:@"consumerKey" consumerSecret:@"consumerSecret"];
    _serviceConfig = OCMProtocolMock(@protocol(TWTRAPIServiceConfig));

    _userAuthResponse = @{ TWTRAuthOAuthTokenKey: @"token", TWTRAuthOAuthSecretKey: @"secret", TWTRAuthAppOAuthScreenNameKey: @"screenname", TWTRAuthAppOAuthUserIDKey: @"1" };
    _userSession = [[TWTRSession alloc] initWithSessionDictionary:_userAuthResponse];
    _appAuthResponse = @{ TWTRAuthAppOAuthTokenKey: @"accessToken" };
    _guestAuthResponse = @{ TWTRAuthAppOAuthTokenKey: @"accessToken", TWTRGuestAuthOAuthTokenKey: @"guestToken" };
    _guestSession = [[TWTRGuestSession alloc] initWithSessionDictionary:_guestAuthResponse];
}

- (void)tearDown
{
#if !TARGET_OS_TV
    [self.appleAuthProviderMock stopMocking];
#endif
    [self.appAuthProviderMock stopMocking];
    [self.guestAuthProviderMock stopMocking];

    [super tearDown];
}

#if !TARGET_OS_TV

- (void)testFetchUserSession_success
{
    [OCMExpect([self.appleAuthProviderMock authenticateWithCompletion:OCMOCK_ANY]) andDo:^(NSInvocation *invocation) {
        TWTRAuthenticationProviderCompletion authCompletion;
        [invocation getArgument:&authCompletion atIndex:invocation.methodSignature.numberOfArguments - 1];
        authCompletion(self.userAuthResponse, nil);
    }];
    [TWTRNetworkSessionProvider userSessionWithAuthConfig:self.authConfig APIServiceConfig:self.serviceConfig completion:^(TWTRSession *userSession, NSError *error) {
        XCTAssertEqualObjects(userSession.userID, @"1");
        self.asyncComplete = YES;
    }];

    [self waitForCompletion];
}

- (void)testFetchUserSession_failure
{
    [OCMExpect([self.appleAuthProviderMock authenticateWithCompletion:OCMOCK_ANY]) andDo:^(NSInvocation *invocation) {
        NSError *error = [NSError errorWithDomain:@"domain" code:0 userInfo:@{}];
        TWTRAuthenticationProviderCompletion authCompletion;
        [invocation getArgument:&authCompletion atIndex:invocation.methodSignature.numberOfArguments - 1];
        authCompletion(nil, error);
    }];
    [TWTRNetworkSessionProvider userSessionWithAuthConfig:self.authConfig APIServiceConfig:self.serviceConfig completion:^(TWTRSession *userSession, NSError *error) {
        XCTAssertNil(userSession);
        XCTAssertNotNil(error);
        self.asyncComplete = YES;
    }];

    [self waitForCompletion];
    OCMVerifyAll(self.appleAuthProviderMock);
}

#endif

- (void)testFetchGuestSession_success
{
    [OCMStub([self.guestAuthProviderMock authenticateWithCompletion:OCMOCK_ANY]) andDo:^(NSInvocation *invocation) {
        TWTRAuthenticationProviderCompletion authCompletion;
        [invocation getArgument:&authCompletion atIndex:invocation.methodSignature.numberOfArguments - 1];
        authCompletion(self.guestAuthResponse, nil);
    }];
    [TWTRNetworkSessionProvider guestSessionWithAuthConfig:self.authConfig APIServiceConfig:self.serviceConfig URLSession:[NSURLSession sharedSession] accessToken:@"accessToken" completion:^(TWTRGuestSession *guestSession, NSError *error) {
        XCTAssertEqualObjects(guestSession.accessToken, @"accessToken");
        XCTAssertEqualObjects(guestSession.guestToken, @"guestToken");
        XCTAssertNil(error);
        self.asyncComplete = YES;
    }];

    [self waitForCompletion];
    OCMVerifyAll(self.guestAuthProviderMock);
}

- (void)testFetchGuestSession_shouldNotPerformAppAuthIfAccessTokenProvided
{
    [[self.appAuthProviderMock reject] authenticateWithCompletion:OCMOCK_ANY];
    [OCMStub([self.guestAuthProviderMock authenticateWithCompletion:OCMOCK_ANY]) andDo:^(NSInvocation *invocation) {
        TWTRAuthenticationProviderCompletion authCompletion;
        [invocation getArgument:&authCompletion atIndex:invocation.methodSignature.numberOfArguments - 1];
        authCompletion(self.guestAuthResponse, nil);
    }];
    [TWTRNetworkSessionProvider guestSessionWithAuthConfig:self.authConfig APIServiceConfig:self.serviceConfig URLSession:[NSURLSession sharedSession] accessToken:@"accessToken" completion:^(TWTRGuestSession *guestSession, NSError *error) {
        self.asyncComplete = YES;
    }];

    [self waitForCompletion];
    OCMVerifyAll(self.appAuthProviderMock);
    OCMVerifyAll(self.guestAuthProviderMock);
}

- (void)testFetchGuestSession_failure
{
    [OCMStub([self.guestAuthProviderMock authenticateWithCompletion:OCMOCK_ANY]) andDo:^(NSInvocation *invocation) {
        NSError *error = [NSError errorWithDomain:@"domain" code:0 userInfo:@{}];
        TWTRAuthenticationProviderCompletion authCompletion;
        [invocation getArgument:&authCompletion atIndex:invocation.methodSignature.numberOfArguments - 1];
        authCompletion(nil, error);
    }];
    [TWTRNetworkSessionProvider guestSessionWithAuthConfig:self.authConfig APIServiceConfig:self.serviceConfig URLSession:[NSURLSession sharedSession] accessToken:@"accessToken" completion:^(TWTRGuestSession *guestSession, NSError *error) {
        XCTAssertNil(guestSession);
        XCTAssertNotNil(error);
        self.asyncComplete = YES;
    }];

    [self waitForCompletion];
    OCMVerifyAll(self.guestAuthProviderMock);
}

- (void)testFetchGuestSession_performAppAuthAndGuestAuthIfNoAccessToken
{
    [OCMStub([self.appAuthProviderMock authenticateWithCompletion:OCMOCK_ANY]) andDo:^(NSInvocation *invocation) {
        TWTRAuthenticationProviderCompletion appAuthCompletion;
        [invocation getArgument:&appAuthCompletion atIndex:invocation.methodSignature.numberOfArguments - 1];
        appAuthCompletion(self.appAuthResponse, nil);
    }];
    [OCMStub([self.guestAuthProviderMock authenticateWithCompletion:OCMOCK_ANY]) andDo:^(NSInvocation *invocation) {
        TWTRAuthenticationProviderCompletion guestAuthCompletion;
        [invocation getArgument:&guestAuthCompletion atIndex:invocation.methodSignature.numberOfArguments - 1];
        guestAuthCompletion(self.guestAuthResponse, nil);
    }];

    [TWTRNetworkSessionProvider guestSessionWithAuthConfig:self.authConfig APIServiceConfig:self.serviceConfig URLSession:[NSURLSession sharedSession] accessToken:@"accessToken" completion:^(TWTRGuestSession *guestSession, NSError *error) {
        XCTAssertEqualObjects(guestSession.accessToken, @"accessToken");
        XCTAssertEqualObjects(guestSession.guestToken, @"guestToken");
        XCTAssertNil(error);
        self.asyncComplete = YES;
    }];

    [self waitForCompletion];
    OCMVerifyAll(self.guestAuthProviderMock);
    OCMVerifyAll(self.appAuthProviderMock);
}

@end
