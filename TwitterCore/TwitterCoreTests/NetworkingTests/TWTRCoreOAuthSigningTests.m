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

#import <TwitterCore/TWTRAuthConfig.h>
#import <TwitterCore/TWTRAuthSession.h>
#import <TwitterCore/TWTRConstants.h>
#import <TwitterCore/TWTRCoreOAuthSigning+Private.h>
#import <TwitterCore/TWTRCoreOAuthSigning.h>
#import "TWTRTestCase.h"

static NSString *const TWTRFakeConsumerKey = @"com.TWTROAuthSigningTests.consumer.key";
static NSString *const TWTRFakeConsumerSecret = @"com.TWTROAuthSigningTests.consumer.secret";
static NSString *const TWTRFakeOAuthToken = @"com.TWTROAuthSigningTests.oauth.token";
static NSString *const TWTRFakeOAuthTokenSecret = @"com.TWTROAuthSigningTests.oauth.token.secret";

@interface TWTRFakeAuthSession : NSObject <TWTRAuthSession>

@end

@implementation TWTRFakeAuthSession

- (NSString *)authToken
{
    return TWTRFakeOAuthToken;
}

- (NSString *)authTokenSecret
{
    return TWTRFakeOAuthTokenSecret;
}

- (NSString *)userID
{
    return @"fakeUserID";
}

- (id)initWithCoder:(NSCoder *)coder;
{
    return [self init];
}

- (void)encodeWithCoder:(NSCoder *)coder;
{
}

@end

@interface TWTRCoreOAuthSigningTests : XCTestCase

@end

@implementation TWTRCoreOAuthSigningTests

+ (TWTRAuthConfig *)authConfig
{
    return [[TWTRAuthConfig alloc] initWithConsumerKey:TWTRFakeConsumerKey consumerSecret:TWTRFakeConsumerSecret];
}

+ (id<TWTRAuthSession>)authSession
{
    return [[TWTRFakeAuthSession alloc] init];
}

- (void)testCoreOAauthSigningRequiresValidAPIURLHost
{
    TWTRAuthConfig *authConfig = [[self class] authConfig];
    id<TWTRAuthSession> authSession = [[self class] authSession];

    NSString *requestURLString = @"http://dangerous-api.com/steal-my-credentials/";

    NSError *error = nil;
    NSDictionary *oauthHeaders = TWTRCoreOAuthSigningOAuthEchoHeaders(authConfig, authSession, @"GET", requestURLString, nil, @"api.digits.com", &error);

    XCTAssertNil(oauthHeaders);
    XCTAssertEqualObjects(error.domain, TWTRErrorDomain);
    XCTAssertEqual(error.code, TWTRErrorCodeInvalidURL);
}

- (void)testCoreOAauthSigningProvidesOAuthHeadersForValidURL
{
    TWTRAuthConfig *authConfig = [[self class] authConfig];
    id<TWTRAuthSession> authSession = [[self class] authSession];

    NSString *requestURLString = @"http://api.twitter.com/verify_credentials/";

    NSError *error = nil;
    NSDictionary *oauthHeaders = TWTRCoreOAuthSigningOAuthEchoHeaders(authConfig, authSession, @"GET", requestURLString, nil, @"api.twitter.com", &error);

    XCTAssertNotNil(oauthHeaders);
    XCTAssertTrue([oauthHeaders[TWTROAuthEchoRequestURLStringKey] length] > 0);
    XCTAssertTrue([oauthHeaders[TWTROAuthEchoAuthorizationHeaderKey] length] > 0);
}

@end
