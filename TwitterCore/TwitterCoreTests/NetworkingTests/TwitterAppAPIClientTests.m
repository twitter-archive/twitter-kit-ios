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
#import "TWTRAppAPIClient.h"
#import "TWTRAuthenticationConstants.h"
#import "TWTRTestCase.h"

static NSString *const TWTRTestAccessToken = @"tokentokentoken";

@interface TWTRAppAPIClientTests : TWTRTestCase

@property (nonatomic) TWTRAppAPIClient *appAPIClient;

@end

@implementation TWTRAppAPIClientTests

- (void)setUp
{
    [super setUp];
    self.appAPIClient = [[TWTRAppAPIClient alloc] initWithAuthConfig:[[TWTRAuthConfig alloc] initWithConsumerKey:@"consumerKey" consumerSecret:@"consumerSecret"] accessToken:TWTRTestAccessToken];
}

- (void)tearDown
{
    self.appAPIClient = nil;

    [super tearDown];
}

- (void)testAuthHeader
{
    NSURLRequest *request = [[self appAPIClient] URLRequestWithMethod:@"GET" URLString:@"" parameters:nil];
    NSString *authHeaderValue = [request valueForHTTPHeaderField:TWTRAuthorizationHeaderField];
    NSString *expectedAuthHeaderValue = [NSString stringWithFormat:@"Bearer %@", TWTRTestAccessToken];
    XCTAssertEqualObjects(authHeaderValue, expectedAuthHeaderValue);
}

- (void)testGET
{
    NSURLRequest *request = [[self appAPIClient] URLRequestWithMethod:@"GET" URLString:@"" parameters:nil];
    XCTAssertEqualObjects([request HTTPMethod], @"GET");
}

- (void)testPOST
{
    NSURLRequest *request = [[self appAPIClient] URLRequestWithMethod:@"POST" URLString:@"" parameters:nil];
    XCTAssertEqualObjects([request HTTPMethod], @"POST");
}

- (void)testDELETE
{
    NSURLRequest *request = [[self appAPIClient] URLRequestWithMethod:@"DELETE" URLString:@"" parameters:nil];
    XCTAssertEqualObjects([request HTTPMethod], @"DELETE");
}

@end
