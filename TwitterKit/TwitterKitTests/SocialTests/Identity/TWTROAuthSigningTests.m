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
#import <TwitterCore/TWTRAPIServiceConfigRegistry.h>
#import <TwitterCore/TWTRAuthConfig.h>
#import <TwitterCore/TWTRAuthenticationConstants.h>
#import <TwitterCore/TWTRConstants.h>
#import <TwitterCore/TWTRSession.h>
#import <XCTest/XCTest.h>
#import "TWTROAuthSigning.h"
#import "TWTRTwitterAPIServiceConfig.h"

static NSString *const TWTRFakeConsumerKey = @"com.TWTROAuthSigningTests.consumer.key";
static NSString *const TWTRFakeConsumerSecret = @"com.TWTROAuthSigningTests.consumer.secret";
static NSString *const TWTRFakeOAuthToken = @"com.TWTROAuthSigningTests.oauth.token";
static NSString *const TWTRFakeOAuthTokenSecret = @"com.TWTROAuthSigningTests.oauth.token.secret";
static NSString *const TWTRFakeUserID = @"1234567890";
static NSString *const TWTRFakePhoneNumber = @"+15551234567";

@interface TWTROAuthSigningTests : XCTestCase

@property (nonatomic, readonly) id registryMock;
@property (nonatomic, readonly) TWTRAPIServiceConfigRegistry *registry;
@property (nonatomic, readonly) TWTRAuthConfig *authConfig;
@property (nonatomic, readonly) TWTRTwitterAPIServiceConfig *apiServiceConfig;

@end

@implementation TWTROAuthSigningTests

- (void)setUp
{
    [super setUp];

    _authConfig = [[TWTRAuthConfig alloc] initWithConsumerKey:TWTRFakeConsumerKey consumerSecret:TWTRFakeConsumerSecret];
    _apiServiceConfig = [[TWTRTwitterAPIServiceConfig alloc] init];

    _registry = [[TWTRAPIServiceConfigRegistry alloc] init];
    [_registry registerServiceConfig:_apiServiceConfig forType:TWTRAPIServiceConfigTypeDefault];

    _registryMock = OCMClassMock([TWTRAPIServiceConfigRegistry class]);
    OCMStub([_registryMock defaultRegistry]).andReturn(_registry);
}

- (void)tearDown
{
    _authConfig = nil;
    _apiServiceConfig = nil;
    [_registryMock stopMocking];
    [super tearDown];
}

#pragma mark - Helpers

- (TWTRSession *)twitterSession
{
    return [[TWTRSession alloc] initWithSessionDictionary:@{ TWTRAuthOAuthTokenKey: TWTRFakeOAuthToken, TWTRAuthOAuthSecretKey: TWTRFakeOAuthTokenSecret, TWTRAuthAppOAuthScreenNameKey: @"screen_name", TWTRAuthAppOAuthUserIDKey: @"user_id" }];
}

- (void)verifyReturnedHeaders:(NSDictionary *)returnedHeaders withError:(NSError *)error expectedURLString:(NSString *)expectedURLString
{
    XCTAssertNil(error);
    XCTAssertNotNil(returnedHeaders);
    XCTAssertEqualObjects(returnedHeaders[TWTROAuthEchoRequestURLStringKey], expectedURLString);
    XCTAssertTrue([returnedHeaders[TWTROAuthEchoAuthorizationHeaderKey] length] > 0);
}

#pragma mark - OAuth Echo Tests

- (void)testOAuthEchoCustomRequesWithTwitterSession
{
    TWTRSession *twitterSession = [self twitterSession];

    TWTROAuthSigning *OAuthEcho = [[TWTROAuthSigning alloc] initWithAuthConfig:_authConfig authSession:twitterSession];

    NSString *URLString = @"https://api.twitter.com/1.1/some_api_method.json";

    NSError *error = nil;
    NSDictionary *returnedAuthHeaders = [OAuthEcho OAuthEchoHeadersForRequestMethod:@"GET" URLString:URLString parameters:nil error:&error];

    [self verifyReturnedHeaders:returnedAuthHeaders withError:error expectedURLString:URLString];
}

- (void)testOAuthEchoVerifyCredentialsHeadersWithTwitterSession
{
    TWTRSession *twitterSession = [self twitterSession];

    TWTROAuthSigning *OAuthEcho = [[TWTROAuthSigning alloc] initWithAuthConfig:_authConfig authSession:twitterSession];

    NSDictionary *returnedAuthHeaders = [OAuthEcho OAuthEchoHeadersToVerifyCredentials];

    [self verifyReturnedHeaders:returnedAuthHeaders withError:nil expectedURLString:@"https://api.twitter.com/1.1/account/verify_credentials.json"];
}

@end
