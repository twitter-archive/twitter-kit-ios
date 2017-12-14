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

#import <TwitterCore/TWTRAuthenticationConstants.h>
#import <TwitterCore/TWTRGuestSession.h>
#import "TWTRAuthenticationTestUtil.h"
#import "TWTRGuestAuthRequestSigner.h"
#import "TWTRTestCase.h"

@interface TWTRGuestAuthRequestSignerTests : TWTRTestCase

@property (nonatomic, strong, readonly) NSURLRequest *request;
@property (nonatomic, strong, readonly) TWTRGuestSession *guestSession;
@property (nonatomic, strong, readonly) NSURLRequest *signedRequest;

@end

@implementation TWTRGuestAuthRequestSignerTests

- (void)setUp
{
    [super setUp];

    _guestSession = [[TWTRGuestSession alloc] initWithSessionDictionary:@{ TWTRAuthAppOAuthTokenKey: @"accessToken", TWTRGuestAuthOAuthTokenKey: @"guestToken" }];

    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/endpoint"];
    _request = [NSURLRequest requestWithURL:url];
    _signedRequest = [TWTRGuestAuthRequestSigner signedURLRequest:_request session:_guestSession];
}

- (void)testSignedRequestWithGuestSession_containsAccessToken
{
    NSString *accessToken = [NSString stringWithFormat:@"Bearer %@", self.guestSession.accessToken];
    XCTAssertTrue([TWTRAuthenticationTestUtil URLRequest:self.signedRequest header:@"Authorization" equalsExpectedValue:accessToken]);
}

- (void)testSignedRequestWithGuestSession_containsGuestToken
{
    XCTAssertTrue([TWTRAuthenticationTestUtil URLRequest:self.signedRequest header:@"x-guest-token" equalsExpectedValue:self.guestSession.guestToken]);
}

@end
