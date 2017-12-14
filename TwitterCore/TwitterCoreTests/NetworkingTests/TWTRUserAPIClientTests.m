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
#import "TWTRAuthenticationConstants.h"
#import "TWTRTestCase.h"
#import "TWTRUserAPIClient.h"

@interface TWTRUserAPIClientTests : XCTestCase

@property (nonatomic, readonly) TWTRUserAPIClient *userAPIClient;

@end

@implementation TWTRUserAPIClientTests

- (void)setUp
{
    [super setUp];

    _userAPIClient = [[TWTRUserAPIClient alloc] initWithAuthConfig:[[TWTRAuthConfig alloc] initWithConsumerKey:@"consumerKey" consumerSecret:@"consumerSecret"] authToken:@"authToken" authTokenSecret:@"authTokenSecret"];
}

- (void)testGet
{
    NSURLRequest *getReq = [self.userAPIClient URLRequestWithMethod:@"GET" URLString:@"https://google.com" parameters:@{@"2": @"4 5"}];
    NSString *expectedURL = @"https://google.com?2=4%205";
    XCTAssertNotNil(getReq);
    XCTAssertEqualObjects([[getReq URL] absoluteString], expectedURL);
    XCTAssertEqualObjects([getReq HTTPMethod], @"GET");
    XCTAssertNotNil([[getReq allHTTPHeaderFields] objectForKey:TWTRAuthorizationHeaderField]);
}

- (void)testPost
{
    NSURLRequest *postReq = [self.userAPIClient URLRequestWithMethod:@"POST" URLString:@"https://google.com" parameters:@{@"2": @"4 5"}];
    NSString *expectedURL = @"https://google.com";
    NSString *expectedParams = @"2=4%205";
    NSString *actualParams = [[NSString alloc] initWithData:[postReq HTTPBody] encoding:NSUTF8StringEncoding];
    XCTAssertNotNil(postReq);
    XCTAssertEqualObjects(actualParams, expectedParams);
    XCTAssertEqualObjects([[postReq URL] absoluteString], expectedURL);
    XCTAssertEqualObjects([postReq HTTPMethod], @"POST");
    XCTAssertNotNil([[postReq allHTTPHeaderFields] objectForKey:TWTRAuthorizationHeaderField]);
}

- (void)testDelete
{
    NSURLRequest *deleteReq = [self.userAPIClient URLRequestWithMethod:@"DELETE" URLString:@"https://google.com" parameters:@{@"2": @"4 5"}];
    NSString *expectedURL = @"https://google.com";
    NSString *expectedParams = @"2=4%205";
    NSString *actualParams = [[NSString alloc] initWithData:[deleteReq HTTPBody] encoding:NSUTF8StringEncoding];
    XCTAssertNotNil(deleteReq);
    XCTAssertEqualObjects(actualParams, expectedParams);
    XCTAssertEqualObjects([[deleteReq URL] absoluteString], expectedURL);
    XCTAssertEqualObjects([deleteReq HTTPMethod], @"DELETE");
    XCTAssertNotNil([[deleteReq allHTTPHeaderFields] objectForKey:TWTRAuthorizationHeaderField]);
}

@end
