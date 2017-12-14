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
#import "TWTRAppAPIClient.h"
#import "TWTRAppAuthProvider.h"
#import "TWTRAppAuthProvider_Private.h"
#import "TWTRAuthenticationConstants.h"
#import "TWTRFakeAPIServiceConfig.h"
#import "TWTRGuestAuthProvider.h"
#import "TWTRTestCase.h"

@interface TWTRGuestAuthProvider ()

- (NSURLRequest *)activateNewGuestTokenRequest;

@property (nonatomic, strong) TWTRAppAPIClient *appAPIClient;

@end

@interface TWTRGuestAuthProviderTests : TWTRTestCase

@property (nonatomic, strong) TWTRAuthConfig *authConfig;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, strong) TWTRAppAPIClient *appAPIClient;
@property (nonatomic, strong) TWTRGuestAuthProvider *guestAuthProvider;
@property (nonatomic, readonly) TWTRFakeAPIServiceConfig *apiServiceConfig;

@end

@implementation TWTRGuestAuthProviderTests

- (void)setUp
{
    [super setUp];
    _apiServiceConfig = [[TWTRFakeAPIServiceConfig alloc] init];
    self.authConfig = [[TWTRAuthConfig alloc] initWithConsumerKey:@"test" consumerSecret:@"test"];
    self.accessToken = @"app_access_token";
    self.appAPIClient = [[TWTRAppAPIClient alloc] initWithAuthConfig:self.authConfig accessToken:self.accessToken];
    self.guestAuthProvider = [[TWTRGuestAuthProvider alloc] initWithAuthConfig:self.authConfig apiServiceConfig:self.apiServiceConfig accessToken:self.accessToken];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)assertAuthenticateWithAssertionBlock:(BOOL (^)(NSDictionary *guestResponseDict, NSError *guestAuthError))assertionBlock
{
    TWTRGuestAuthProvider *guestProvider = [[TWTRGuestAuthProvider alloc] initWithAuthConfig:self.authConfig apiServiceConfig:self.apiServiceConfig accessToken:self.accessToken];
    NSURLRequest *activationRequest = [guestProvider activateNewGuestTokenRequest];
    NSDictionary *mockResponseDict = @{TWTRGuestAuthOAuthTokenKey: @"guesttoken", TWTRAuthAppOAuthTokenKey: @"apptoken"};
    NSData *mockResponseBodyData = [NSJSONSerialization dataWithJSONObject:mockResponseDict options:0 error:nil];

    id apiClientMock = [OCMockObject partialMockForObject:self.guestAuthProvider.appAPIClient];
    [[[apiClientMock stub] andDo:^(NSInvocation *invocation) {
        TWTRTwitterNetworkCompletion completionBlock;
        [invocation getArgument:&completionBlock atIndex:invocation.methodSignature.numberOfArguments - 1];
        completionBlock(nil, mockResponseBodyData, nil);
    }] sendAsynchronousRequest:activationRequest
                     completion:OCMOCK_ANY];

    self.guestAuthProvider.appAPIClient = apiClientMock;

    [self.guestAuthProvider authenticateWithCompletion:^(NSDictionary *guestResponseDict, NSError *guestAuthError) {
        XCTAssert(assertionBlock(guestResponseDict, guestAuthError));
        self.asyncComplete = YES;
    }];

    [self waitForCompletion];

    [apiClientMock stopMocking];
}

- (void)testGuestAuthTokenRequest_methodIsPOST
{
    TWTRGuestAuthProvider *guestProvider = [[TWTRGuestAuthProvider alloc] initWithAuthConfig:self.authConfig apiServiceConfig:self.apiServiceConfig accessToken:self.accessToken];
    NSURLRequest *activationRequest = [guestProvider activateNewGuestTokenRequest];

    XCTAssertEqualObjects(activationRequest.HTTPMethod, @"POST");
}

- (void)testGuestAuthTokenRequest_validActivationURL
{
    TWTRGuestAuthProvider *guestProvider = [[TWTRGuestAuthProvider alloc] initWithAuthConfig:self.authConfig apiServiceConfig:self.apiServiceConfig accessToken:self.accessToken];
    NSURLRequest *activationRequest = [guestProvider activateNewGuestTokenRequest];
    NSURL *activationRequestURL = [activationRequest URL];
    XCTAssertEqualObjects([activationRequestURL absoluteString], @"https://api.sample.com/1.1/guest/activate.json");
}

- (void)testAuthenticateWithCompletion_returnsGuestTokenOnSuccess
{
    [self assertAuthenticateWithAssertionBlock:^BOOL(NSDictionary *guestResponseDict, NSError *guestAuthError) {
        return guestResponseDict != nil && [guestResponseDict[TWTRGuestAuthOAuthTokenKey] length] > 0;
    }];
}

- (void)testAuthenticateWithCompletion_returnsAppTokenOnSuccess
{
    [self assertAuthenticateWithAssertionBlock:^BOOL(NSDictionary *guestResponseDict, NSError *guestAuthError) {
        return [guestResponseDict[TWTRAuthAppOAuthTokenKey] length] > 0;
    }];
}

- (void)testAuthenticateWithCompletion_noErrorOnSucess
{
    [self assertAuthenticateWithAssertionBlock:^BOOL(NSDictionary *guestResponseDict, NSError *guestAuthError) {
        return guestAuthError == nil;
    }];
}

@end
